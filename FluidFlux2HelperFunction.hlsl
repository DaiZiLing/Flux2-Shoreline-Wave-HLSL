// ----------------------------------------------------------------------------------------

// FluidFlux2HelperFunction.hlsl

// Functions which are NOT straightly depend on Fluid Flux

// ----------------------------------------------------------------------------------------

float3 MF_TriangleNormal(float3 P0, float3 P1, float3 P2)
{
    float3 Normal;
    Normal = cross(P1 - P0, P2 - P0);
    // Normal.z = -Normal.z;

    return normalize(Normal);
}

float MF_PolynomialHalf(float P_0_5, float P_1_0, float X)
{
    return X * ( (1 - X) * P_0_5 * 4 + (X - 0.5) * P_1_0 * 2 );
}


// float MF_RectMask(float2 Position, float2 Size, float2 UV)
// {
    //     float2 X = abs(UV - Position);
    //     float2 Y = Size * 0.5;
    //     return min( step(X.x, Y.x) , step(Y.y, Y.y) );
// }

float3 MF_Lerp3Vecto3 (float3 Color0, float3 Color1, float3 ColorShore, float3 Shore, float Blend_S)
{
    float3 Lerp_1 = lerp(Color0, ColorShore, Shore);
    float3 Lerp_2 = lerp(Lerp_1, Color1, Blend_S);
    return Lerp_2;
}

float3 MF_Lerp (float3 A, float3 B, float Alpha)
{
    float3 Result = A * (1 - Alpha) + B * Alpha;
    return Result;
}

float MF_Fresnel (float Bias, float Scale, float Power, float3 NormalWS, float3 CameraDir)
{
    float Fresnel;
    Fresnel = dot(NormalWS, CameraDir) * (-1.0) + 1.0;
    Fresnel = pow(Fresnel, Power);
    Fresnel *= Scale;
    Fresnel += Bias;
    return saturate(Fresnel);
}

float MF_DirectionalSpecular (float3 NormalWS, float3 CameraDir)
{
    float3 Vector_F3  = normalize(CameraDir + normalize(_DirectionalLightDirection * float3(-1, 1, -1)));
    float  HalfVector = dot(Vector_F3.xzy, NormalWS);
    return HalfVector;
}

float2 MF_FluidFoamDistortion (float2 UV)
{
    // Absolute World Position (Excluding Material Offset)
    float2 Add_Up     = UV;
    float2 Add_Down   = UV * _FoamDistortionScale + _Time.x * _FoamDistortionSpeed;
    float2 Turbulence = SAMPLE_TEXTURE2D_LOD(_FoamDistortionMap, SamplerTriLinearRepeat, Add_Down, 0).rg;
    Turbulence = (Turbulence - 0.5) * _FoamDistortionIntensity;

    float2 Result = ((_UseFoamDistortion) ? (Add_Up + Turbulence) : 0.0);
    return Result;
}

float3 MF_ImposibleNormalFix (float3 Normal, float3 CameraDir)
{
    float3 CorrectedNormal;

    CorrectedNormal = saturate(reflect(CameraDir, Normal).g * (-1.0)) * CameraDir + Normal;
    CorrectedNormal = normalize(CorrectedNormal);

    return CorrectedNormal;
}

float MF_ScatteringPhysical (float3 L, float3 N, float3 V, float LTPower, float LTIntensity, float LTDistortion, float3 PosWS)
{
    float Scattering;
    float3 Subtract_A = LTDistortion * N * (-1.0);
    float3 Subtract_B = L;

    Scattering = normalize(Subtract_A - Subtract_B);
    Scattering = pow(saturate(dot(Scattering, V)), LTPower) * LTIntensity;

    return Scattering;
}

float MF_ScatteringNormal (float3 V, float3 L, float Intensity, float Distortion, float FrasnelPower, float FrasnelBase, float SunAngle, float3 VertexNormal)
{
    float Scattering;

    float Part_1, Part_2, Part_3, Part_4;

    Part_1 = pow(max(0.0, dot(V, VertexNormal)), FrasnelPower) + FrasnelBase;
    Part_2 = pow(dot(VertexNormal - float3(L.x, 0.7, L.z), V), Distortion);
    Part_3 = dot(float3(VertexNormal.x, 1 - VertexNormal.y, VertexNormal.z) * (-1.0), L);
    Part_4 = max(0.0, saturate(Part_1 * Part_2 * Intensity) * Part_3);

    Scattering = Part_4;

    return Scattering;
}

float MF_ScatteringAquatic (float3 V, float Distance, float3 Flatten, float Intensity, float3 VertexNormal)
{
    Flatten   = lerp(float3(1.2, 1.2, 0.7), float3(0.4, 0.4, 1.4), 0);

    float Scattering;
    Scattering  = Pow2(1.0 - V.y) * (1.0 + dot(_DirectionalLightDirection, V * float3(-1, 1, -1)));
    Scattering *= dot(VertexNormal, V * Flatten);
    Scattering *= Intensity;

    return Scattering;
}


float MF_FluidAdvancedScattering (float3 CameraDir, float3 PixelNormal, float3 PosWS)
{
    float FluidAdvancedScattering;

    // MF_ScatteringPhysical
    float3 ScatteringPhysical;
    float3 ScatteringPhysical_L;
    float3 ScatteringPhysical_N;

    ScatteringPhysical_L = normalize(_DirectionalLightDirection * float3(1.0, 0.3, 1.0));
    ScatteringPhysical_N = normalize(float3(-1.0, 0.2, -1.0) * PixelNormal);

    ScatteringPhysical = MF_ScatteringPhysical(ScatteringPhysical_L, ScatteringPhysical_N, CameraDir, 4.0, 2.0, 0.6, PosWS);

    // MF_ScatteringNormal
    float3 ScatteringNormal;
    ScatteringNormal = MF_ScatteringNormal(CameraDir, _DirectionalLightDirection, 0.05, 8.0, 10.0, 0.1, 0.7, PixelNormal);

    // MF_ScatteringAquatic
    float3 ScatteringAquatic;
    ScatteringAquatic = MF_ScatteringAquatic(CameraDir, 0.1, 0, 0.1, PixelNormal);

    FluidAdvancedScattering = ScatteringPhysical + ScatteringNormal + ScatteringAquatic;

    return FluidAdvancedScattering;
}

float3 MF_ReconstructNormal (float2 XY)
{
    float3 normal;

    normal.xy = XY;
    normal.z = sqrt(saturate(1 - dot(XY, XY)));

    return normal;
}

float MF_FluidFoamShallow (float Height, float Depth)
{
    float Result = (Height + _FoamShallowOffset) * (Depth * _FoamShallowScale);
    return saturate(Result);
}


float4 MF_CombineTranslucent(float3 TopRGB, float TopA, float3 BottomRGB, float BottomA)
{
    float4 OutRGBA;

    OutRGBA.a = (BottomA + TopA) - (BottomA * TopA);
    OutRGBA.rgb = lerp(BottomRGB * BottomA, TopRGB, TopA);
    OutRGBA.rgb = OutRGBA.rgb / (max(OutRGBA.a, 0.0001));

    return OutRGBA;
}

float2 FlipbookUV(float2 UV, float CurrentTile, float Time)
{
    // for T_OceanWave.png
    float Columns = 8;
    float Height = 8;

    CurrentTile      = floor(CurrentTile + Time);
    CurrentTile      = fmod(CurrentTile, Columns * Height);
    float2 CurrentTileCount = float2(1.0, 1.0) / float2(Columns, Height);
    float  CurrentTileY     = abs(Height - (floor(CurrentTile * CurrentTileCount.x) + 1));
    float  CurrentTileX     = abs(((CurrentTile - Columns * floor(CurrentTile * CurrentTileCount.x))));
    return (float2(1, 1) * ((UV + float2(CurrentTileX, CurrentTileY)) * CurrentTileCount)); // inverse Y
}

FSurfacePositionData MF_PosData_VS (FVertexOutput VertexOut)
{
    FSurfacePositionData Data = (FSurfacePositionData)0;

    Data.PositionWS = VertexOut.PositionWS;
    Data.CameraPositionWS = GetCurrentViewPositionWS();

    // Camera
    float3 UnnormalizedVector = Data.CameraVectorWS - Data.PositionWS;

    Data.CameraVectorWS = SafeNormalize(UnnormalizedVector);
    Data.CameraDistance = length(UnnormalizedVector);

    return Data;
}

FSurfacePositionData MF_PosData_VS2 (FVertexInput VertIn)
{
    FSurfacePositionData Data = (FSurfacePositionData)0;

    Data.PositionWS = TransformPositionOSToPositionWS(VertIn.PositionOS, GetObjectToWorldMatrix());
    Data.CameraPositionWS = GetCurrentViewPositionWS();

    // Camera
    float3 UnnormalizedVector = Data.CameraVectorWS - Data.PositionWS;

    Data.CameraVectorWS = SafeNormalize(UnnormalizedVector);
    Data.CameraDistance = length(UnnormalizedVector);

    return Data;
}
