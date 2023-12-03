// MF_FluidFoam

AdvectTexture2D MF_AdvectTexture2D (float3 Weights, float2 UV1, float2 UV2, float2 UV3, Texture2D Texture, float Mipmaps)
{
    float4 Texture2DSample_1 = SAMPLE_TEXTURE2D_LOD(Texture, SamplerLinearRepeat, UV1, 0).rgba;
    float4 Texture2DSample_2 = SAMPLE_TEXTURE2D_LOD(Texture, SamplerLinearRepeat, UV2, 0).rgba;
    float4 Texture2DSample_3 = SAMPLE_TEXTURE2D_LOD(Texture, SamplerLinearRepeat, UV3, 0).rgba;

    ZERO_INITIALIZE(AdvectTexture2D, Data);
    Data.AOnly = dot(Weights, float3(Texture2DSample_1.a, Texture2DSample_2.a, Texture2DSample_3.a));
    Data.Color0 = Texture2DSample_1;
    Data.Color1 = Texture2DSample_2;
    Data.Color2 = Texture2DSample_3;

    Data.RGBA = Weights.x * Texture2DSample_1 + Weights.y * Texture2DSample_2 + Weights.z * Texture2DSample_3;

    return Data;
}

AdvectionData MF_AdvectionData(float Time)
{
    AdvectionData Data = (AdvectionData)0;
    Data.Offset = frac(frac(Time) + float3(0, 1, 2) / 3);
    Data.Weights = float3(0, 1, 2) / 3 + frac(Time);
    Data.Weights = 1 - cos(Data.Weights * 2 * PI); 
    Data.Weights *= 0.3333;

    return Data;
}

AdvectUV3 MF_AdvectUV3 (float Speed, float Offset, float2 UV, float2 Velocity, bool UseUVOffsets, bool PerVertex)
{
    ZERO_INITIALIZE(AdvectionData, Data);
    ZERO_INITIALIZE(AdvectUV3, AdvectUV3Out);

    Data = MF_AdvectionData(frac(_Time.y * Speed));

    float3 AdvectionData_Weights = Data.Weights;
    float3 AdvectionData_Offset = Data.Offset;

    AdvectionData_Offset += Offset;

    AdvectUV3Out.Weights = AdvectionData_Weights;
    AdvectUV3Out.UV1 = UV + AdvectionData_Offset.r * Velocity;
    AdvectUV3Out.UV2 = (UseUVOffsets > 0 ? (UV + float2(0.33, 0.66)) : UV ) + AdvectionData_Offset.g * Velocity;
    AdvectUV3Out.UV3 = (UseUVOffsets > 0 ? (UV + float2(0.66, 0.33)) : UV ) + AdvectionData_Offset.b * Velocity;

    return AdvectUV3Out;
}

FluidFoamAdvect MF_FluidFoamAdvect(float Speed, float Offset, float2 UV, float2 Velocity, float UseOffsets)
{
    ZERO_INITIALIZE(FluidFoamAdvect, Advect);
    ZERO_INITIALIZE(AdvectTexture2D, AdvectData);

    float3 Weights;
    float2 UV1;
    float2 UV2;
    float2 UV3;
    Texture2D FoamNormalSoftHeightMap; 

    float3 AdvectionData_Weights = MF_AdvectionData(frac(Speed * _Time.y)).Weights;
    float3 AdvectionData_Offset  = MF_AdvectionData(frac(Speed * _Time.y)).Offset;

    FoamNormalSoftHeightMap = _FoamNormalSoftHeightMap;
    Weights                 = AdvectionData_Weights;

    AdvectionData_Offset += Offset;

    UV1 = AdvectionData_Offset.r * Velocity + UV;
    UV2 = AdvectionData_Offset.g * Velocity + UV + UseOffsets * float2(0.124905, 0.836666);
    UV3 = AdvectionData_Offset.b * Velocity + UV + UseOffsets * float2(0.500952, 0.887143);

    AdvectData = MF_AdvectTexture2D(Weights, UV1, UV2, UV3, FoamNormalSoftHeightMap, 0);

    Advect.Soft     = AdvectData.RGBA.b;
    Advect.Height   = AdvectData.RGBA.a;
    Advect.NormalXY = (AdvectData.RGBA.rg * 2.0 - 1.0);
    Advect.Normal   = MF_ReconstructNormal(Advect.NormalXY);

    return Advect;
}

void MF_FluidFoamApply (inout MaterialAttributes WaterLayer, MaterialAttributes Foam)
{
    float4 CombineTranslucent = MF_CombineTranslucent(Foam.BaseColor, Foam.Opacity, WaterLayer.BaseColor, WaterLayer.Opacity);
    WaterLayer.BaseColor = CombineTranslucent.rgb;
    WaterLayer.Opacity = CombineTranslucent.a;

    WaterLayer.Normal.xy = _FoamNormalScale * Foam.OpacityMask * WaterLayer.Normal.z * Foam.Normal.xy + WaterLayer.Normal.xy;
    WaterLayer.Normal.z = WaterLayer.Normal.z;
    WaterLayer.Normal = normalize(WaterLayer.Normal);

    WaterLayer.Specular = lerp(WaterLayer.Specular, Foam.Specular, Foam.OpacityMask);
    WaterLayer.Roughness = lerp(WaterLayer.Roughness, Foam.Roughness, Foam.OpacityMask);
    WaterLayer.SubsurfaceColor = WaterLayer.SubsurfaceColor + Foam.SubsurfaceColor;
}

// DitherTemporalTAA
float2 ScreenAlignedPixelToPixelUVs (float2 ScreenPos, float2 TextureResolution)
{
    return (ScreenPos / TextureResolution);
}

float DitherTemporalTAA (float AlphaThreshold, float Random, FSurfacePositionData PosData)
{
    float DitherPattern = SAMPLE_TEXTURE2D(_FoamDitherMap, SamplerLinearRepeat, ScreenAlignedPixelToPixelUVs(PosData.ScreenPixelCoord, float2(64,64))).r;
    DitherPattern += fmod(((uint)(PosData.ScreenPixelCoord.x) + 2 * (uint)(PosData.ScreenPixelCoord.y)) , 5);
    DitherPattern = DitherPattern / 6;
    DitherPattern = DitherPattern + AlphaThreshold - 0.5;
    
    return DitherPattern;
}

void MF_FluidFoam (FSurfacePositionData PosData, float Depth, inout MaterialAttributes FluidLayer, float Intensity, float3 FoamWetColor, MaterialAttributes SurfaceLayer, float3 PosWS, out float OutFoam)
{
    float  MF_SurfaceFluxGet_Foam     = 0;
    float2 MF_SurfaceFluxGet_Velocity = 0;

    MF_SurfaceFluxGet_Foam     = MF_SurfaceFluxGet(SurfaceLayer).Foam;
    MF_SurfaceFluxGet_Velocity = MF_SurfaceFluxGet(SurfaceLayer).Velocity;

    if (!_UseFoam)
    {
        MF_SurfaceFluxGet_Foam = 0.0;
    }

    Intensity = 1.0;

    OutFoam = saturate(MF_SurfaceFluxGet_Foam); // avoid NAN

    float  Advect_Speed      = _FoamUVSpeed;
    float  Advect_Offset     = _FoamUVAdvectionOffset;
    float2 Advect_UV         = _FoamUVScale * MF_FluidFoamDistortion(PosWS.rg);
    float2 Advect_Velocity   = _FoamUVScale * _FoamUVAdvectionVelocity * (-1.0) * MF_SurfaceFluxGet_Velocity;
    float  Advect_UseOffsets = _FoamUVRandomization;

    FluidFoamAdvect Advect          = MF_FluidFoamAdvect(Advect_Speed, Advect_Offset, Advect_UV, Advect_Velocity, Advect_UseOffsets);
    float3          Advect_Normal   = Advect.Normal;
    float           Advect_Height   = Advect.Height;
    float2          Advect_NormalXY = Advect.NormalXY;
    float           Advect_Soft     = Advect.Soft;

    ZERO_INITIALIZE(MaterialAttributes, FoamAttributes);

    FoamAttributes.BaseColor = lerp(FoamWetColor, _FoamColorBase.rgb, saturate(MF_SurfaceFluxGet_Foam * _FoamSoftIntensity));

    float3 FoamBaseColorLerpB     = _FoamColorBase.rgb * lerp((Advect_Normal.b + Advect_Height) * _FoamColorDetail, 1, _FoamColorAlpha);
    float  FluidFoamShallowResult = (MF_SurfaceFluxGet_Foam * MF_FluidFoamShallow(Advect_Height, Depth));

    float Opacity_Botttom = distance(MF_SurfaceFluxGet_Velocity, 0) * _FoamSoftVelocity + _FoamSoftBase;
          Opacity_Botttom = min(_FoamSoftMax, Opacity_Botttom);
          Opacity_Botttom = Opacity_Botttom * (MF_SurfaceFluxGet_Foam + 1);
          Opacity_Botttom = Opacity_Botttom * FluidFoamShallowResult;

    float Opacity_Top = ((_FoamHardnessIntensity + 1.0) / (_FoamHardnessWidth - 1.0)) * ((_FoamHardnessWidth - 1.0) + FluidFoamShallowResult);
          Opacity_Top = saturate(Opacity_Top);
        //   Opacity_Top = Advect_Height - Opacity_Top;
        //   Opacity_Top = saturate(Opacity_Top);

    FoamAttributes.Opacity     = saturate(saturate(_FoamColorBase.a * Intensity) * max(saturate(Advect_Height - Opacity_Top), Opacity_Botttom * Advect_Soft));
    FoamAttributes.OpacityMask = saturate(saturate(Advect_Height - Opacity_Top) * _FoamNormalBlend);

    FoamAttributes.BaseColor = lerp(FoamAttributes.BaseColor, FoamBaseColorLerpB, FoamAttributes.OpacityMask);

    FoamAttributes.Normal = Advect_Normal;

    FoamAttributes.Roughness = 0.3;
    // FoamAttributes.Opacity = FoamAttributes.Opacity;

    FoamAttributes.Opacity = saturate(pow(FoamAttributes.Opacity, 0.45));

    MF_FluidFoamApply(FluidLayer, FoamAttributes);

    // FluidLayer.BaseColor = 1; //debug

    float PixelOffset = 0.0;

    // Replace by XRP Dither! (TODO)
    if (_UseFoamDithering)
    {
            PixelOffset = (_FoamDitheringOffset - Advect_Height) * OutFoam;
            PixelOffset *= DitherTemporalTAA(_FoamDitheringAlpha, 1, PosData) * _FoamDitheringScale;

            FluidLayer.PixelDepthOffset = PixelOffset;
    }
    else
    {
            FluidLayer = FluidLayer;
    }

    if (_UseFoam)
    {
        FluidLayer.EmissiveColor = _FoamEmissive.rgb * (FoamAttributes.Opacity - _FoamEmissive.a);
    }
    else
    {
        FluidLayer = FluidLayer;
    }


}