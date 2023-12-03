// ----------------------------------------------------------------------------------------

// FluidFlux2HelperStruct.hlsl

// Functions which construct Material Function, and void function without math manipulation like "Set/Get" 

// ----------------------------------------------------------------------------------------

struct MaterialAttributes
{
    float3 BaseColor;
    float Metallic;
    float Specular;
    float Roughness;
    float Anisotropy;
    float3 EmissiveColor;
    float Opacity;
    float OpacityMask;
    float3 Normal;
    float3 Tangent;
    float3 WorldPositionOffset;
    float3 SubsurfaceColor; 
    float ClearCoat;
    float ClearCoatRoughness;
    float AmbientOcclusion;
    float Refraction;
    float2 CustomizedUVs_0;
    float2 CustomizedUVs_1;
    float2 CustomizedUVs_2;
    float2 CustomizedUVs_3;
    float2 CustomizedUVs_4;
    float2 CustomizedUVs_5;
    float2 CustomizedUVs_6;
    float2 CustomizedUVs_7;
    float PixelDepthOffset;
    float ShadingModel;
};
MaterialAttributes MF_MaterialAttributes (FMaterialInput MInput, FPixelInput PixelIn)
{
    ZERO_INITIALIZE(MaterialAttributes, Attributes);

    Attributes.BaseColor = MInput.BaseColor;
    Attributes.Metallic  = MInput.Metallic;

    #if defined(MATERIAL_USE_REFLECTANCE)
        Attributes.Specular   = MInput.DielectricReflectance;
        Attributes.Refraction = MInput.IOR;
    #endif

    Attributes.Roughness = MInput.PerceptualRoughness;

    // #if defined(MATERIAL_USE_ANISOTROPIC)
    //     Attributes.Anisotropy = MInput.Anisotropic;
    // #endif

    #if defined(MATERIAL_USE_EMISSIVE)
        Attributes.EmissiveColor = MInput.EmissiveColor;
    #endif

    Attributes.Opacity = MInput.Opacity;

    // ClearCoatMask replace OpacityMask
    #if defined(MATERIAL_USE_CLEARCOAT)
        Attributes.OpacityMask = MInput.ClearCoatMask;
    #endif

    #if defined(MATERIAL_USE_CUSTOM_NORMAL)
        Attributes.Normal = MInput.NormalWS;
    #endif

    Attributes.Tangent = PixelIn.GeometricTangentWS;

    #if defined(USE_VERTEX_ATTR_CUSTOM_OUTPUT_DATA)
        Attributes.WorldPositionOffset = PixelIn.CustomVertexData;
    #endif

    #if defined(MATERIAL_USE_CLEARCOAT)
        Attributes.ClearCoat = 0.0;
        Attributes.ClearCoatRoughness = MInput.ClearCoatPerceptualRoughness;
    #endif
    
    #if defined(MATERIAL_USE_AMBIENT_OCCLUSION)
        Attributes.AmbientOcclusion = MInput.AmbientOcclusion;
    #endif

    #if defined(MATERIAL_USE_PLUGIN_CHANNEL_DATA) || defined(PLUGIN_USE_PLUGIN_CHANNEL_DATA)
        Attributes.CustomizedUVs_0 = MInput.PluginChannelData0.xy;
        Attributes.CustomizedUVs_1 = MInput.PluginChannelData1.xy;

        // SubsurfaceColor
        Attributes.SubsurfaceColor = MInput.PluginChannelData2.xyz;

        // CustomizedUVs_3 ~ 7 never used in FF2;
        // Attributes.CustomizedUVs_2 = ...
    #endif

    #if defined(MATERIAL_USE_PIXEL_DEPTH_OFFSET)
        Attributes.PixelDepthOffset = MInput.DepthOffset;
    #endif

    // Attributes.ShadingModel = 0.0;

    return Attributes;
}

// ----------------------------------------------------------------------------------------

struct FluxWorldToCoastlineUV
{
    float2 Scale;
    float2 UV;
    float2 Location;
    float ReferencePlaneHeight;
    float2 Resolution;
    float2 TexelSize;
};

struct CoastlineData
{
    float Distance;
    float2 Direction;
    float Scale;
    float Mask;
};

struct CoastlineHeight
{
    float GroundWorldZ;
    float GroundRelativeZ;
    float ReferencePlaneZ;
};

struct CoastlineOffsets
{
    float Time;
    float DetailsFloat;
}; 

struct WaveProfile
{
    float3 	Offset;
    float 	ForwardNormalized;
    float4 	DataSource;
    float 	Foam;
    float2 	ForwardUpward;
    float 	Forward;
    float  Upward;
    float3 	ForwardInverted;
};

struct CoastSlope
{
    float3 Normal;
    float3 Offset;
};

struct SurfaceFlux_Coastline
{
    MaterialAttributes SurfaceLayer;
    float Distance;
    float Intensity;
    float Shoreline;
    float Blend;
};

struct CoastlineWater
{
    CoastlineData CData;
    float2 ForwardUpward;
    float Foam;
    float3 WPO;
    float3 WPO_World;
};

struct EdgeCorrection
{
    float PositionWorldHeight;
    float3 Offset;
};

struct SurfaceFlux
{
    float3 Normal;
    float3 Offset;
    float Foam;
    float Mask;
    float2 Velocity;
    float Divergence;
    float Color;
    float OffsetCorrection;
};

void MF_SurfaceFluxSet(inout MaterialAttributes SurfaceLayer, SurfaceFlux Flux)
{
    SurfaceLayer.Normal              = Flux.Normal;
    SurfaceLayer.WorldPositionOffset = Flux.Offset;
    SurfaceLayer.Specular            = Flux.Foam;
    SurfaceLayer.OpacityMask         = Flux.Mask;
    SurfaceLayer.CustomizedUVs_0     = Flux.Velocity;
    SurfaceLayer.Metallic            = Flux.Divergence;
    SurfaceLayer.AmbientOcclusion    = Flux.Color;
    SurfaceLayer.Roughness           = Flux.OffsetCorrection;
}

SurfaceFlux MF_SurfaceFluxGet(MaterialAttributes SurfaceLayer)
{
    SurfaceFlux Flux                  = (SurfaceFlux)0;
    Flux.Foam             = SurfaceLayer.Specular;
    Flux.Normal           = SurfaceLayer.Normal;
    Flux.Offset           = SurfaceLayer.WorldPositionOffset;
    Flux.Divergence       = SurfaceLayer.Metallic;
    Flux.Velocity         = SurfaceLayer.CustomizedUVs_0;
    Flux.Mask             = SurfaceLayer.OpacityMask;
    Flux.Color            = SurfaceLayer.AmbientOcclusion;
    Flux.OffsetCorrection = SurfaceLayer.Roughness;
    return Flux;
}

struct WaterTransition
{
    float3 ColorBehind;
    float3 SuraceLineColor;
    float3 UnderwaterFog;
    float3 SurfaceOverlayColor;
    float3 FoamWetColor;
    float3 SurfaceAbsorption;
    float3 SurfaceScattering;
    float3 FoamScattering;
    float PhaseG;
};

struct MF_SingleLayerWater_Attributes
{
    float3 Scattering;
    float3 Absorption;
    float3 ColorBehind;
    float PhaseG;
};


struct FluidFoamAdvect
{
    float3 	Normal;
    float 	Height;
    float2 	NormalXY;
    float 	Soft;
};

struct AdvectTexture2D
{
    float4 	RGBA;
    float 	AOnly;
    float4 	Color0;
    float4 	Color1;
    float4 	Color2;
};


struct AdvectionData
{
    float3 Weights;
    float3 Offset;
};

struct AdvectUV3
{
    float3 Weights;
    float2 UV1;
    float2 UV2;
    float2 UV3;
};

struct SurfaceFlux_WaveTexture
{
    MaterialAttributes SurfaceLayer;
    float4 SampleResult;
    float Height;
};

struct WaveTextureInfo
{
    float2 UV;
    float2 Wind;
    float Time;
    float WaveUVScale;
    float LOD;
    float Scale;
};

struct WaveSampleDecode
{
    float3 Normal;
    float3 Offset;
    float OffsetZ;
    float2 Derivate;
    float SampleHeight;
    float SampleFoam;
};

struct DecodeNormaDerivate
{
    float2 DerivateXY;
    float3 Normal;
};

struct FFMain_SurfaceLayer
{
    MaterialAttributes SurfaceLayerVS;
    float Shoreline;
};

struct RectMask
{
    float MaskIn;
    float MaskOut;
};

struct FluxSurfaceOver
{
    MaterialAttributes SurfaceLayerVS;
    float3 Scattering;
    float3 Absorption;
    float3 ColorBehind;
    float PhaseG;
};

struct CombinePremultiplied
{
    float3 OutRGB;
    float OutA;
};

// struct FSurfacePositionData_VS
// {
//     float3      PositionWS;                 // World space position

//     float3      CameraVectorWS;             // Surface -> Camera Vector
//     float3      CameraPositionWS;
//     float       CameraDistance;             // View Space Camera-Surface Distance
// };
