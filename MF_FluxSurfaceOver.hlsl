// MF_FluxSurfaceOver

FluxSurfaceOver MF_FluxSurfaceOver (float3 WorldPosition, FSurfacePositionData PosData)
{
    FluxSurfaceOver FF_Result = (FluxSurfaceOver)0;

    //--------------------------------------------------------------------------------------------

    // MF_SurfaceLayer
    FFMain_SurfaceLayer ST_SurfaceLayer = MF_SurfaceLayer(WorldPosition, PosData);
    MaterialAttributes  SurfaceLayerVS  = ST_SurfaceLayer.SurfaceLayerVS;
    float               Shoreline       = ST_SurfaceLayer.Shoreline;

    //--------------------------------------------------------------------------------------------

    // MF_SurfaceFluxGet
    SurfaceFlux ST_SurfaceFluxGet = MF_SurfaceFluxGet(SurfaceLayerVS);
    float3      Normal            = ST_SurfaceFluxGet.Normal;
    float       Foam              = ST_SurfaceFluxGet.Foam;
    float       Color             = ST_SurfaceFluxGet.Color;

    //--------------------------------------------------------------------------------------------

    // MF_WaterTransition
    WaterTransition ST_WaterTransition  = MF_WaterTransition(Color, Shoreline);
    float3          ColorBehind         = ST_WaterTransition.ColorBehind;
    float3          SuraceLineColor     = ST_WaterTransition.SuraceLineColor;
    float3          UnderwaterFog       = ST_WaterTransition.UnderwaterFog;
    float3          SurfaceOverlayColor = ST_WaterTransition.SurfaceOverlayColor;
    float3          FoamWetColor        = ST_WaterTransition.FoamWetColor;
    float3          SurfaceAbsorption   = ST_WaterTransition.SurfaceAbsorption;
    float3          SurfaceScattering   = ST_WaterTransition.SurfaceScattering;
    float3          FoamScattering      = ST_WaterTransition.FoamScattering;
    float           PhaseG              = ST_WaterTransition.PhaseG;

    //--------------------------------------------------------------------------------------------

    // MF_FluidScattering
    float FluidScattering = MF_FluidScattering(PosData.CameraVectorWS, Normal, Normal, WorldPosition);

    //--------------------------------------------------------------------------------------------

    // MF_SingleLayerWater
    MF_SingleLayerWater_Attributes ST_SingleLayerWater = MF_SingleLayerWater(saturate(Foam), FluidScattering, 0.0, Shoreline);
    float3                         SLW_Scattering      = ST_SingleLayerWater.Scattering;
    float3                         SLW_Absorption      = ST_SingleLayerWater.Absorption;
    float3                         SLW_ColorBehind     = ST_SingleLayerWater.ColorBehind;
    float                          SLW_PhaseG          = ST_SingleLayerWater.PhaseG;

    //--------------------------------------------------------------------------------------------

    // MF_FluidWaterLayer
    float Depth = 0;
    MaterialAttributes FluidLayer = (MaterialAttributes)0;
    MF_FluidWaterLayer(PosData, 0.0, SurfaceOverlayColor, SurfaceLayerVS, Depth, FluidLayer);

    //--------------------------------------------------------------------------------------------

    // MF_FluidFoam
    float OutFoam = 0.0;
    MF_FluidFoam(PosData, Depth, FluidLayer, 1.0, FoamWetColor, SurfaceLayerVS, WorldPosition, OutFoam);

    //--------------------------------------------------------------------------------------------

    // MF_FluidNormalCorrection
    MF_FluidNormalCorrection(FluidLayer, PosData);

    //--------------------------------------------------------------------------------------------

    // MF_FluidTranslucent
    MF_FluidTranslucent(FluidLayer);

    //--------------------------------------------------------------------------------------------
    
    FF_Result.SurfaceLayerVS = FluidLayer;

    FF_Result.Scattering  = SLW_Scattering;
    FF_Result.Absorption  = SLW_Absorption;
    FF_Result.ColorBehind = SLW_ColorBehind;
    FF_Result.PhaseG      = SLW_PhaseG;

    //--------------------------------------------------------------------------------------------

    return FF_Result;
}
