// MF_FluidWaterLayer

void MF_FluidWaterLayer (FSurfacePositionData PosData, float Translucent, float3 SurfaceOverlayColor, inout MaterialAttributes SurfaceLayer, inout float Depth, inout MaterialAttributes FluidLayer)
{
    SurfaceLayer = SurfaceLayer;

    float SceneDepthWithoutWater;

    if (!_UseSingleLayerWater)
    {
        SceneDepthWithoutWater = 10000.0;
    }

    SceneDepthWithoutWater = PosData.ViewSpaceZ;

    // Calculate Screen UV
    float2 ViewportUV                               = PosData.ScreenUV;
    const  float2 SceneWithoutSingleLayerWaterMinUV = 0 + (_ScreenParams.zw - 1);
    const  float2 SceneWithoutSingleLayerWaterMaxUV = 1 - (_ScreenParams.zw - 1);
    ViewportUV                               = clamp(ViewportUV, SceneWithoutSingleLayerWaterMinUV, SceneWithoutSingleLayerWaterMaxUV);

    // Calculate Depth, Opaque Depth
    float PixelSceneDeviceZ = SAMPLE_TEXTURE2D_LOD(_OpaqueDepthTexture, SamplerLinearClamp, ViewportUV, 0).r;
    float PixelSceneDepth   = LinearEyeDepth(PixelSceneDeviceZ, _ZBufferParams);

    Depth = 100 * (PixelSceneDepth - SceneDepthWithoutWater);
    Depth = Depth * (abs(PosData.CameraVectorWS.y) * _WaterDepthUpwardBlend + 1.0);

    // Translucent
    Translucent = Depth * _WaterShallowBlend;

    // Init FluidLayer
    FluidLayer = (MaterialAttributes)0;

    float3 FluidLayer_BaseColor = SurfaceOverlayColor;
    float  FluidLayer_Metallic  = 0.0;

    // FluidLayer Specular
    float Specular_A;
    float3 Specular_B;

    Specular_A    = saturate(Translucent);
    Specular_B    = (100 * (PosData.PositionWS - PosData.CameraPositionWS));
    float Specular_B_Y  = Specular_B.y * _WaterSpecularHorizonOffset;
    Specular_B_Y  = _WaterSpecularHorizonDistance - Specular_B_Y;
    Specular_B_Y  = (Specular_B_Y - length(Specular_B)) / (Specular_B_Y * 0.9);
    Specular_B_Y  = saturate(Specular_B_Y);
    Specular_B_Y  = Pow2(Specular_B_Y);
    Specular_B_Y  = saturate(Specular_B_Y + _WaterSpecular.a);
    Specular_B_Y *= MF_Fresnel(_WaterSpecular.r, _WaterSpecular.g, _WaterSpecular.b, SurfaceLayer.Normal, PosData.CameraVectorWS);

    float FluidLayer_Specular = min(saturate(Translucent) * Specular_B_Y, SurfaceLayer.Normal.y);

    // FluidLayer Roughness
    float FluidLayer_Roughness;

    FluidLayer_Roughness = MF_DirectionalSpecular(SurfaceLayer.Normal, PosData.CameraPositionWS) - _WaterRoughnessFromSpecularDiv;
    FluidLayer_Roughness = FluidLayer_Roughness / (1 - _WaterRoughnessFromSpecularDiv);
    FluidLayer_Roughness *= _WaterRoughnessFromSpecular;

    FluidLayer_Roughness += _WaterRoughnessFromFresnel * pow(1 - dot(SurfaceLayer.Normal, PosData.CameraVectorWS), 5.0);
    FluidLayer_Roughness = max(FluidLayer_Roughness, _WaterRoughnessMin);

    if (!_UseWaterRoughnessAdvanced)
    {
        FluidLayer_Roughness = _WaterRoughnessMin;
    }

    // FluidLayer Opacity
    float FluidLayer_Opacity;
    FluidLayer_Opacity = saturate(Translucent) * _SurfaceOverlayAlpha;

    // FluidLayer OpacityMask
    float FluidLayer_OpacityMask;
    FluidLayer_OpacityMask = 1.0;

    // FluidLayer Normal
    float3 FluidLayer_Normal;
    FluidLayer_Normal = SurfaceLayer.Normal;

    // FluidLayer WPO
    float3 FluidLayer_WPO;
    FluidLayer_WPO = SurfaceLayer.WorldPositionOffset;

    // FluidLayer IOR
    float FluidLayer_IOR;
    FluidLayer_IOR = distance(PosData.PositionWS, PosData.CameraPositionWS) * (1.0 / _WaterRefractionDistanceScale) + _WaterRefractionDistanceOffset;
    FluidLayer_IOR = saturate(FluidLayer_IOR);
    FluidLayer_IOR = lerp(_WaterRefractionNear, _WaterRefractionFar, FluidLayer_IOR);
    FluidLayer_IOR = lerp(1.0, saturate(SurfaceLayer.Normal.y + 0.1), FluidLayer_IOR);

    // MA FluidLayer
    FluidLayer.BaseColor           = FluidLayer_BaseColor;
    FluidLayer.Metallic            = FluidLayer_Metallic;
    FluidLayer.Specular            = FluidLayer_Specular;
    FluidLayer.Roughness           = FluidLayer_Roughness;
    FluidLayer.Opacity             = FluidLayer_Opacity;
    FluidLayer.OpacityMask         = FluidLayer_OpacityMask;
    FluidLayer.Normal              = FluidLayer_Normal;
    FluidLayer.WorldPositionOffset = FluidLayer_WPO;
    FluidLayer.Refraction          = FluidLayer_IOR;

    // FluidLayer.Opacity = (PixelSceneDepth - SceneDepthWithoutWater);

    // Debug
    // Depth = FluidLayer_Roughness;
    
}