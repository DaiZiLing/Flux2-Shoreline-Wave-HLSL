// Toggle Layer
	_HideSLW("Hide SLW", Int) = 1
	_HideFluxDefaultValue("Hide Flux Default Value", Int) = 1
	_DirectionalLightDirection ("Directional Light Direction", Vector) = (0.5, -0.5, -0.2, 0.2) // Helper Dir

	// Base Input
	_BaseMap ("Base Map", 2D) = "white" {}
	[HDR] _BaseColor ("Base Color", Color) = (1, 1, 1, 0)

	// Water Input
	_WaterScattering ("Water Scattering", Color) = (0, 0, 0)
	_WaterAbsorption ("Water Absorption", Color) = (0.25, 0.05, 0.01)
	[HDR]_ColorScaleBehindWater ("Color Scale Behind Water", Color) = (1, 1, 1)
	_PhaseG ("Phase G", Range(-1, 1)) = 0
	_RefractionIOR ("Refraction IOR", Float) = 1.03

	// === Flux 2 Parameters Start ===
	_CoastlineFoamDistance ("Coastline Foam Distance", Float)           = 250.0
	_CoastlineFoamScale ("Coastline Foam Scale", Float)                 = 1.0
	_CoastlineNormalRange ("Coastline Normal Range", Float)             = 14.0
	_CoastlineScattringDistance ("Coastline Scattring Distance", Float) = 0.00005
	_CoastlineScattringHeight ("Coastline Scattring Height", Float)     = 0.000588
	_CoastlineVelocityAdd ("Coastline Velocity Add", Float)             = -0.2
	_CoastlineVelocityScale ("Coastline Velocity Scale", Float)         = 0.0006
	_NoiseScale ("Noise Scale", Float)                                  = 0.242
	_NoiseTime ("Noise Time", Float)                                    = 0.7
	_ShoreWaveScale ("Shore Wave Scale", Float)                         = 0.00015
	_ShoreWaveWidth ("Shore Wave Width", Float)                         = -9.0
	[NoScaleOffset]_SmoothNoiseMap ("Smooth Noise Map", 2D)             = "white" {}
	_UsePreciseCoastline ("Use Precise Coastline", Int)                 = 0.0

	_UseDetailWave ("Use Detail Wave", Int)                              = 1
	_DetailWaveChoppiness ("Detail Wave Choppiness", Float)                     = 0.22
	_DetailWaveHeight ("Detail Wave Height", Float)                     = 0.22
	_DetailWaveLength ("Detail Wave Length", Float)                     = 9.0
	[NoScaleOffset]_DetailWaveTexture ("Detail Wave Texture", 2D)       = "white" {}
	_DetailWaveUVOffset ("Detail Wave UV Offset", Float)                = -0.3
	_DetailWaveUVSwitching ("Detail Wave UV Switching", Float)          = 1.0
	_DetailWaveUVVelocityScale ("Detail Wave UV Velocity Scale", Float) = 11.0
	_UseDetailWaveWPO("Use Detail Wave WPO", Int)                       = 1
	_WaveDetailFastFoam ("Wave Detail Fast Foam", Float)                = 1.5
	_WaveDetailWPOScale ("Wave Detail WPO Scale", Float)                = 0.9

	_SurfaceAbsorption0 ("Surface Absorption 0", Vector)                 = (70.0, 180.0, 330.0, 3.0)
	_SurfaceAbsorption1 ("Surface Absorption 1", Vector)                 = (70.0, 180.0, 330.0, 3.0)
	_SurfaceOverlay0 ("Surface Overlay 0", Color)                        = (0, 0, 0)
	_SurfaceOverlay1 ("Surface Overlay 1", Color)                        = (0, 0, 0)
	_SurfaceScattering0 ("Surface Scattering 0", Color)                  = (0.2, 0.3, 0.4, 0.0003)
	_SurfaceScattering1 ("Surface Scattering 1", Color)                  = (0.2, 0.4, 0.3, 0.0003)
	_ColorBehind0 ("Color Behind 0", Color)                              = (0.7, 0.6, 0.5, 0.9)
	_ColorBehind1 ("Color Behind 1", Color)                              = (0.7, 0.6, 0.5, 0.9)
	_ColorBehindShoreline ("Color Behind Shoreline", Color)              = (0.7, 0.6, 0.5, 0.9)
	_FoamScatteringScale ("Foam Scattering Scale", Float)                = 4.0
	_PhaseGDeepSunHigh ("PhaseG Deep Sun High", Range(-1, 1))            = 0.5
	_PhaseGDeepSunLow ("PhaseG Deep Sun Low", Range(-1, 1))              = -0.7
	_PhaseGShallowSunHigh ("PhaseG Shallow Sun High", Range(-1, 1))      = -0.2
	_PhaseGShallowSunLow ("PhaseG Shallow Sun Low", Range(-1, 1))        = 0.7
	_SurfaceAbsorptionShoreline ("Surface Absorption Shoreline", Vector) = (50.0, 180.0, 220.0, 5.0)
	_SurfaceOverlayShoreline ("Surface Overlay Shoreline", Color)        = (0, 0, 0)
	_SurfacePhaseG0 ("Surface PhaseG 0", Range(-1, 1))                   = 0.0
	_SurfacePhaseG1 ("Surface PhaseG 1", Range(-1, 1))                   = 0.0
	_SurfacePhaseGShoreline ("Surface PhaseG Shoreline", Range(-1, 1))   = 0.0
	_SurfaceScatteringShoreline ("Surface Scattering Shoreline", Color)  = (0.1, 0.1, 0.1, 0.002)

	_CaptureHeight ("Capture Height", Float)                                   = 0.0
	[NoScaleOffset]_FluidHeightMap ("Fluid Height Map", 2D)                    = "white" {}
	[NoScaleOffset]_FluidVelocityHeightFoam ("Fluid Velocity Height Foam", 2D) = "white" {}
	[NoScaleOffset]_GroundMap ("Ground", 2D) = "white" {}
	_MotionVector ("Motion Vector", Float)                                     = 10.0
	_SimulationPixelSize ("Simulation Pixel Size", Vector)                     = (1.0, 0.0, 0.0, 0.0)
	_StateDecodeData ("State Decode Data", Vector)                             = (0.0, 1.0, 0.0, 0.0)
	_WorldToSimulationUV ("World To Simulation UV", Vector)                    = (1.0, 0.0, 0.0, 0.0)

	_FluxLevelToWorldGroundUV ("Flux Level To World Ground UV", Vector)    = (0.0, 0.0, 1.0, 0.0)
	_FluxStateBorders ("Flux State Borders", Vector)      = (0.0, 0.0, 0.0, 0.0)
	_FluxWorldCoastlineDecode ("Flux World Coastline Decode", Float)       = 10640.0
	[NoScaleOffset]_FluxWorldCoastlineMap ("Flux World Coastline Map", 2D) = "black" {}
	_FluxWorldGroundHeight ("Flux World Ground Height", Float)             = -10000.0
	[NoScaleOffset]_FluxWorldGroundMap ("Flux World Ground Map", 2D)       = "white" {}
	_FluxWorldGroundPixelSize ("Flux World Ground Pixel Size", Vector)     = (1.0, 1.0, 1.0, 1.0)

	_UseFluxInteraction ("Use Interaction", Int)                        = 1

	_UsePainter ("Use Painter", Int)                        = 0
	[NoScaleOffset]_PainterTexture ("Painter Texture", 2D) = "black" {}
	_WorldToPainterUV ("World To Painter UV", Vector)      = (0.0, 0.0, 1.0, 0.0)

	_StateCheapNormal ("State Cheap Normal", Int)                    = 1.0
	_StateDistanceDepthMax ("State Distance Depth Max", Float)       = 0.0
	_StateDistanceDepthOffset ("State Distance Depth Offset", Float) = 100.0
	_StateDistanceDepthScale ("State Distance Depth Scale", Float)   = 0.0015
	_StateDivergenceBase ("State Divergence Base", Float)            = 0.1
	_StateDivergenceIntensity ("State Divergence Intensity", Float)  = 5.0
	_StateDivergenceMax ("State Divergence Max", Float)              = 1.5
	_StateDivergenceVelocity ("State Divergence Velocity", Float)    = 3.0
	_StateDivergenceVolumeMin ("State Divergence Volume Min", Float) = 30.0
	_StateFoamDivergence ("State Foam Divergence", Float)            = 0.1
	_StateFoamSlope ("State Foam Slope", Float)                      = 2.0
	_StateSteepnessFromHeight ("State Steepness From Height", Float) = 0.05
	_StateSteepnessScale ("State Steepness Scale", Float)            = 0.25
	_StateVelocityMax ("State Velocity Max", Float)                  = 4.0
	_StateVelocityNormalize ("State Velocity Normalize", Float)      = 0.05
	_StateVelocityOffsetScale ("State Velocity Offset Scale", Float) = 0.25
	_StateVelocityScale ("State Velocity Scale", Float)              = 0.9
	_StateWetHeightOffset ("State Wet Height Offset", Float)         = 0.0
	_StateWorldPixelSize ("State World Pixel Size", Float)           = 20.0
	_UseExtraMasking ("Use Extra Masking", Int)                      = 1.0
	_UseSection ("Use Section", Int)                                 = 0.0

	_SurfaceCutMask ("Surface Cut Mask", Vector)      = (0.0, 0.0, 0.0, 0.0)
	_UseCoastline ("Use Coastline", Int)              = 0.0
	_UseCutMask ("Use Cut Mask", Int)                 = 1.0
	_UseOcean ("Use Ocean", Int)                      = 1.0
	_UseSimulation ("Use Simulation", Int)            = 1.0
	_UseSimulationBlend ("Use Simulation Blend", Int) = 1.0

	_UseFluxWaveDistant ("Use Flux Wave Distant", Int)                            = 0.0
	_UseSingleLayerWater ("Use SingleLayerWater", Int)                            = 1.0
	_UseWaveTextureRenderTarget("Use Wave Texture RT", Int)                       = 1.0
	[NoScaleOffset]_WaveTextureAnimation ("Wave Texture Animation", 2D)           = "black" {}
	_WaveTextureChoppiness ("Wave Texture Choppiness", Float)                     = 0.5
	_WaveTextureDecodeHeight ("Wave Texture Decode Height", Float)                = 26.6666
	_WaveTextureDecodeNormal ("Wave Texture Decode Normal", Float)                = 1.0
	_WaveTextureDistanceBlend ("Wave Texture Distance Blend", Float)              = 800.0
	_WaveTextureDivergenceFoam ("Wave Texture Divergence Foam", Float)            = 0.5
	_WaveTextureDivergenceOffset ("Wave Texture Divergence Offset", Float)        = 0.15
	_WaveTextureDivergenceScale ("Wave Texture Divergence Scale", Float)          = 1.45
	_WaveTextureFoamOffset  ("Wave Texture Foam Offset", Float)                   = -0.47
	_WaveTextureFoamScale  ("Wave Texture Foam Scale", Float)                     = 1.5
	_WaveTextureHeight  ("Wave Texture Height", Float)                            = 3.0
	_WaveTextureOffsetScale ("Wave Texture Offset Scale", Vector)                 = (0.0, 0.0, 0.000125, 0.000125)
	_WaveTextureOffsetZ ("Wave Texture OffsetZ", Float)                           = -100.0
	[NoScaleOffset]_WaveTextureRenderTarget ("Wave Texture RT", 2D)               = "black" {}
	_WaveTextureVelocityScaleBottom ("Wave Texture Velocity Scale Bottom", Float) = -1.2
	_WaveTextureVelocityScaleTop ("Wave Texture Velocity Scale Top", Float)       = 0.2
	_WaveTextureVelocityWind ("Wave Texture Velocity Wind", Float)                = 0.001
	_WaveTextureWind ("Wave Texture Wind", Vector)                                = (0.0, 0.0, 0.0, 0.25)

	_FluxWaveProfileDecode ("Flux Wave Profile Decode", Vector)      = (-0.5, 0.0, 0.5, 0.5)
	[NoScaleOffset]_FluxWaveProfileMap ("Flux Wave Profile Map", 2D) = "black" {}

	_UseFoam ("Use Foam", Int)                                                 = 1
	_FoamColorDetail ("Foam Color Detail", Float)                              = 0.5
	_FoamColorAlpha ("Foam Color Alpha", Float)                                = 0.0
	_FoamColorBase ("Foam Color Base", Color)                                  = (0.4, 0.42, 0.43, 0.6)
	_FoamNormalBlend ("Foam Normal Blend", Float)                              = 3.0
	_FoamNormalScale ("Foam Normal Scale", Float)                              = 1.0
	_FoamRoughness ("Foam Roughness", Float)                                   = 0.2
	_FoamSpecular ("Foam Specular", Float)                                     = 0.2
	_FoamDitheringAlpha ("Foam Dithering Alpha", Float)                        = 0.0
	_FoamDitheringOffset ("Foam Dithering Offset", Float)                      = 2.0
	_FoamDitheringScale ("Foam Dithering Scale", Float)                        = 40.0
	_FoamEmissive ("Foam Emissive", Color)                                     = (0.0, 0.0, 0.0, 0.01)
	_FoamHardnessIntensity ("Foam Hardness Intensity", Float)                  = -0.05
	_FoamHardnessWidth ("Foam Hardness Width", Float)                          = 0.2
	_FoamShallowOffset ("Foam Shallow Offset", Float)                          = 0.3
	_FoamShallowScale ("Foam Shallow Scale", Float)                            = 0.1
	_FoamSoftBase ("Foam Soft Base", Float)                                    = 0.5
	_FoamSoftIntensity ("Foam Soft Intensity", Float)                          = 1.5
	_FoamSoftMax ("Foam Soft Max", Float)                                      = 1.0
	_FoamSoftVelocity ("Foam Soft Velocity", Float)                            = 0.5
	_FoamUVAdvectionOffset ("Foam UV Advection Offset", Float)                 = -0.5
	_FoamUVAdvectionVelocity ("Foam UV Advection Velocity", Float)             = 7.0
	_FoamUVRandomization ("Foam UV Randomization", Range(0, 1))                = 1.0
	_FoamUVScale ("Foam UV Scale", Float)                                      = 0.0009
	_FoamUVSpeed ("Foam UV Speed", Float)                                      = 1.1
	_UseFoamDithering ("Use Foam Dithering", Int)                              = 1
	[NoScaleOffset]_FoamDitherMap ("Foam Dither Map", 2D)                             = "white" {}
	[NoScaleOffset]_FoamNormalSoftHeightMap ("Foam Normal Soft HeightMap", 2D) = "black" {}
	_UseFoamDistortion ("Use Foam Distortion", Int)                            = 1
	[NoScaleOffset]_FoamDistortionMap ("Foam Distortion Map", 2D)                             = "black" {}
	_FoamDistortionIntensity ("Foam Distortion Intensity", Float)              = 20.0
	_FoamDistortionScale ("Foam Distortion Scale", Float)                      = 0.005
	_FoamDistortionSpeed ("Foam Distortion Speed", Float)                      = 0.2

	_CheapScatteringDetails ("Cheap Scattering Details", Float) = 0.5
	_CheapScatteringPower ("Cheap Scattering Power", Float)     = 2.0
	_CheapScatteringScale ("Cheap Scattering Scale", Float)     = 3.0
	_UseCheapScattering ("Use Cheap Scattering", Int)           = 1.0

	_CameraRadius("Camera Radius", Vector)                                      = (0.02, 0.02, 0.004, 1.8)
	_SurfaceOverlayAlpha ("Surface Overlay Alpha", Float)                       = 0.1
	_WaterDepthUpwardBlend ("Water Depth Upward Blend", Float)                  = 1.0
	_WaterDitherMasking ("Water Dither Masking", Float)                         = 0.0
	_WaterDitherSlope ("Water Dither Slope", Float)                             = 0.0
	_WaterRefractionDistanceOffset ("Water Refraction Distance Offset", Float)  = 0.0
	_WaterRefractionDistanceScale ("Water Refraction Distance Scale", Float)    = 80.0
	_WaterRefractionFar ("Water Refraction Far", Float)                         = 1.01
	_WaterRefractionNear ("Water Refraction Far", Float)                        = 1.025
	_WaterShallowBlend ("Water Shallow Blend", Float)                           = 1.0
	_WaterSpecular ("Water Specular", Vector)                                   = (0.045, 0.37, 9.0, 0.2)   // Bias, Scale, Power, Horizon
	_WaterSpecularHorizonDistance ("Water Specular Horizon Distance", Float)    = 900.0
	_WaterSpecularHorizonOffset ("Water Specular Horizon Offset", Float)        = 6.0
	_UseWaterRoughnessAdvanced("Use Water Roughness Advanced", Int)             = 1.0
	_WaterRoughnessFromFresnel ("Water Roughness From Fresnel", Float)          = 0.3
	_WaterRoughnessFromSpecular ("Water Roughness From Specular", Float)        = 0.007
	_WaterRoughnessFromSpecularDiv ("Water Roughness From Specular Div", Float) = 0.997
	_WaterRoughnessMin ("Water Roughness Min", Float)                           = 0.04

	_WaveGroundPrediction ("Wave Ground Prediction", Float)            = 200.0
	_WaveProfileAnimationSpeed ("Wave Profile Animation Speed", Float) = 0.75
	_WaveProfileDistance ("Water Profile Distance", Float)             = 2.25
	_WaveProfileSpeed ("Water Profile Speed", Float)                   = 0.9
	_WaveProfileWidth ("Water Profile Width", Float)                   = 500.0
	

	#include "FluidFlux2Circuit.hlsl"

//pixel shader

{
		float3 WPT_ExcludeAllShaderOffsets  = PixelIn.CustomVertexData.xyz;
	       WPT_ExcludeAllShaderOffsets  = float3(WPT_ExcludeAllShaderOffsets.xzy);  // -- UE to UNITY -- (Chirality)
	       WPT_ExcludeAllShaderOffsets *= 100;                                      // -- UE to UNITY -- (Unit)

	// PBR Attributes
	// =====================================================================

	FluxSurfaceOver    SurfaceLayer   = MF_FluxSurfaceOver(WPT_ExcludeAllShaderOffsets, PosData);
	MaterialAttributes SurfaceLayerVS = SurfaceLayer.SurfaceLayerVS;

	MInput.NormalWS            = SurfaceLayerVS.Normal.xzy;
	MInput.PerceptualRoughness = 0.05;                                       // (TODO) Flux Roughness & Specular
	MInput.Opacity             = SurfaceLayerVS.Opacity;
	MInput.BaseColor           = SurfaceLayerVS.BaseColor * MInput.Opacity;
	MInput.DepthOffset         = SurfaceLayerVS.PixelDepthOffset;

	// SLW Color
	// =====================================================================

		MInput.CustomData0.xyz = SurfaceLayer.Scattering;
		MInput.CustomData1.xyz = SurfaceLayer.Absorption;
		MInput.CustomData2.xyz = SurfaceLayer.ColorBehind;

		MInput.CustomData0.w = -SurfaceLayer.PhaseG; // inverse final phaseG
		MInput.CustomData1.w = 1.00;
		MInput.CustomData2.w = 0.0;

}


//vertex shader, Attribute
{
	// WPT_ExcludeAllShaderOffsets : Absolute World Position (Excluding Material Offsets)
	float3 WPT_ExcludeAllShaderOffsets = TransformPositionOSToPositionWS(VertexIn.PositionOS, GetObjectToWorldMatrix());
	return float4(WPT_ExcludeAllShaderOffsets, 1.0);
}

//vertex shader , World Position offset
{
	FSurfacePositionData PosData_VS2     = MF_PosData_VS2(VertIn);                                        // Reconstruct PosData to get camera properties
	float3               UEPositionWS    = float3(PosData_VS2.PositionWS.xzy);                            // -- UE to UNITY -- (Chirality)
	                     UEPositionWS   *= 100;                                                           // -- UE to UNITY -- (Unit)
	MaterialAttributes   SurfaceLayerVS  = MF_FluxSurfaceOver(UEPositionWS, PosData_VS2).SurfaceLayerVS;
	return float3(SurfaceLayerVS.WorldPositionOffset.xzy * 0.01);  // -- UE to UNITY -- (Chirality)
}
