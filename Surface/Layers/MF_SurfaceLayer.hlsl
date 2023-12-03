// MF_SurfaceLayer

// Layer blending between multiple types of water bodies.

// ===================================================================================================================
// ===================================================================================================================
// =================================               MF_SurfaceFlux_Coastline        =================================== 
// ===================================================================================================================
// ===================================================================================================================

FluxWorldToCoastlineUV MF_FluxWorldToCoastlineUV(float2 WorldPosition)
{
    FluxWorldToCoastlineUV Attributes = (FluxWorldToCoastlineUV)0;

    Attributes.Scale                = _FluxLevelToWorldGroundUV.zw;
    Attributes.Location             = _FluxLevelToWorldGroundUV.xy;
    Attributes.UV                   = (WorldPosition - Attributes.Location) / Attributes.Scale;  // // XZ in unity, XY in ue.
    Attributes.ReferencePlaneHeight = _FluxWorldGroundHeight;                                       // -1e+4
    Attributes.TexelSize            = _FluxWorldGroundPixelSize.xy;
    Attributes.Resolution           = _FluxWorldGroundPixelSize.zw;

    return Attributes;
}

CoastlineData MF_CoastlineSample(float2 WorldPosition)
{
    CoastlineData Attributes = (CoastlineData)0;

    float2 CoastlineUV  = MF_FluxWorldToCoastlineUV(WorldPosition).UV;

    float4 CoastlineMap = SAMPLE_TEXTURE2D_LOD(_FluxWorldCoastlineMap, SamplerLinearRepeat, CoastlineUV, 0);

    Attributes.Distance = _FluxWorldCoastlineDecode * (0.5 - CoastlineMap.r);  // FluxWorldCoastlineDecode = 10640.0 default
    Attributes.Scale    = CoastlineMap.a;

    float Distance = distance(0.5 - CoastlineMap.gb, float2(0, 0));
    
    Attributes.Direction = (0.5 - CoastlineMap.gb) / Distance;
    Attributes.Mask      = saturate(Distance * -4.54545 + 2.159091);

    return Attributes;
}


CoastlineHeight MF_SampleCoastlineHeight(float2 WorldPosition)
{
    CoastlineHeight Attributes = (CoastlineHeight)0;

    float2 CoastlineUV = MF_FluxWorldToCoastlineUV(WorldPosition).UV;
    float  Height      = SAMPLE_TEXTURE2D_LOD(_FluxWorldGroundMap, SamplerLinearRepeat, CoastlineUV, 0).r;

    // Height *= 0.01;

    Attributes.GroundRelativeZ = Height * (-1.0);
    Attributes.ReferencePlaneZ = MF_FluxWorldToCoastlineUV(WorldPosition).ReferencePlaneHeight;
    Attributes.GroundWorldZ    = Attributes.ReferencePlaneZ - Height;

    // debug
    // Attributes.GroundWorldZ = Height;

    return Attributes;
}


CoastlineOffsets MF_CoastlineOffsets(float Distance, float2 Direction, float2 WorldPosition, bool Details = true)
{
    CoastlineOffsets Offsets = (CoastlineOffsets)0;

    // Noise
    float  SmoothNoiseA = SAMPLE_TEXTURE2D_LOD(_SmoothNoiseMap, SamplerLinearRepeat, WorldPosition * 0.5, 0).r - 0.5;
    float  SmoothNoiseB = SAMPLE_TEXTURE2D_LOD(_SmoothNoiseMap, SamplerLinearRepeat, WorldPosition * 1.5, 0).r - 1.0;

    float3 Factor       = (WorldPosition + (Distance * Direction)).y * float3(0.121, 0.242, 0.752);

    float SineFactor    = sin(Factor.y * 2 * PI);
    float CosineFactor  = cos(Factor.z * 2 * PI);
    float Time          = Factor.x + SineFactor * (-0.135) + CosineFactor * (-0.038);
          Time         += ((Details > 0) ? (_NoiseTime * SmoothNoiseA * saturate(Distance * 0.35 - 0.05)) : 0.0);
          Offsets.Time  = Time;

    // Detail
    float DetailsFloat          = SineFactor * (-0.25) + CosineFactor * (0.15);
          DetailsFloat         += ((Details > 0) ? (_NoiseScale * SmoothNoiseB) : 0.0);
          Offsets.DetailsFloat  = DetailsFloat;

    return Offsets;
}

float2 MF_CoastlineProfileUV(CoastlineData CData, float2 WorldPosition, float TimeOffset, bool UseDistortion)
{
    CoastlineOffsets Offsets = MF_CoastlineOffsets(CData.Distance * (1 / _WaveProfileWidth), CData.Direction, WorldPosition * (1 / _WaveProfileWidth), UseDistortion);

    float WaveDistance = _WaveProfileDistance - CData.Distance * (1 / _WaveProfileWidth);

    float WaveDistanceDetail = WaveDistance + Offsets.DetailsFloat;

    WaveDistance = WaveDistance - (_WaveProfileSpeed * _Time.y + TimeOffset + Offsets.Time);
    float WaveDistanceSpeed = (WaveDistanceDetail - frac(WaveDistance)) * _WaveProfileAnimationSpeed;

    return float2(WaveDistance, WaveDistanceSpeed);
}


WaveProfile MF_SampleWaveProfile(float2 UV, Texture2D WaveMap, bool Precise = false, float Mipmap = 0.0, float Scale = 1.0, float Width = 1000.0)
{
    WaveProfile Profile = (WaveProfile)0;


    float4 Wave = SAMPLE_TEXTURE2D_LOD(WaveMap, sampler_FluxWaveProfileMap, UV, Mipmap);

    Profile.Foam = Wave.b * Scale;

    // Direction
    Profile.ForwardNormalized = Wave.x * _FluxWaveProfileDecode.x + _FluxWaveProfileDecode.z;
    Profile.ForwardUpward = (Wave.xy + _FluxWaveProfileDecode.xy) * (_FluxWaveProfileDecode.zw * Scale * Width);

    // Profile.ForwardUpward = Wave.rg;  //debug

    Profile.Forward = Profile.ForwardUpward.x;
    Profile.Upward = Profile.ForwardUpward.y;

    float P_0_5 = Wave.z + _FluxWaveProfileDecode.x;
    float P_1_0 = Wave.x + _FluxWaveProfileDecode.x;
    Profile.ForwardInverted = MF_PolynomialHalf(P_0_5, P_1_0, Scale) * (_FluxWaveProfileDecode.z * Width);

    // Offset
    Profile.Offset = float3(Profile.Forward, Profile.Upward, 0);	// Caution!!!!! UE_Unity XYZ Problem here.

    // Data
    Profile.DataSource = Wave;

    // Profile.Foam = abs(UV.y);

    return Profile;
}


CoastSlope MF_CoastSlope(CoastlineData CData, float Forward, float Upward, float3 Normal, float Prediction)
{
    CoastSlope Slope = (CoastSlope)0;

    // Normal
    Slope.Normal = Normal;
    
    // Offset
    float Factor = saturate( (CData.Distance - 10) / Prediction );
    float3 Offset = lerp(Normal, float3(CData.Direction.x, CData.Direction.y, 0), Factor);
    Slope.Offset = Offset * Forward + (float3(0, 0, 1) * Upward);	// Caution!!!!! UE_Unity XYZ Problem here.

    // Slope.Offset = Offset;

    return Slope;
}

float3 MF_SlopeNormal(CoastlineData Data, float2 WorldPosition, float Prediction)
{
    float2 Direction = Data.Direction * Prediction;

    float2 SlopePosition = Direction + WorldPosition; 

    CoastlineHeight H1 = MF_SampleCoastlineHeight(SlopePosition);
    CoastlineHeight H2 = MF_SampleCoastlineHeight(WorldPosition);

    float3 SlopeNormal = float3(Direction, H1.GroundRelativeZ - H2.GroundRelativeZ);
    return normalize(SlopeNormal);
}

float MF_CoastlineColor(float Distance, float2 WorldPosition)
{
    float2 CoastlineUV     = MF_FluxWorldToCoastlineUV(WorldPosition).UV;
    float  GroundRelativeZ = MF_SampleCoastlineHeight(WorldPosition).GroundRelativeZ;

    float ScatteringHeight   = saturate(-_CoastlineScattringHeight * GroundRelativeZ);
    float ScatteringDistance = saturate(Distance * _CoastlineScattringDistance);
    float Shoreline          = 1 - max(ScatteringHeight, ScatteringDistance);

    Shoreline = _UseCoastline ? Shoreline : 0;
    Shoreline = _UseOcean ? Shoreline : 0;
    return Shoreline;
}

CoastlineData MF_CoastlineTransform(bool LocalSpace, float2 Offset, CoastlineData CData)
{
    CoastlineData Result = CData;

    float Distance1 = Offset.x + CData.Distance;
    float2 Distance2 = CData.Distance - dot(Offset, CData.Direction); 

    Result.Distance = LocalSpace ? Distance1 : Distance2;
    return Result;
}

float MF_SurfaceFlux_CoastlineBlend(CoastlineData Data)
{
    float Blend;
    Blend = min( saturate((Data.Distance + _ShoreWaveWidth) * _ShoreWaveScale) + Data.Mask, 1);
    return Blend;
}


CoastlineWater MF_CoastlineWater(CoastlineData CData, float2 WorldPosition, float3 SlopeNormal, float2 WorldOffset = 0.0, float TimeOffset = 0.0, bool UseDistortion = true, bool PreciseProfile = false)
{
    CoastlineWater CWater = (CoastlineWater)0;

    float2      ProfileUV = MF_CoastlineProfileUV(CData, WorldPosition + WorldOffset, TimeOffset, UseDistortion);
    WaveProfile WProfile  = MF_SampleWaveProfile(ProfileUV, _FluxWaveProfileMap, PreciseProfile, 0, CData.Scale, _WaveProfileWidth);
    CoastSlope  CSlope    = MF_CoastSlope(CData, WProfile.ForwardUpward.x, WProfile.ForwardUpward.y, SlopeNormal, _WaveGroundPrediction);

    CWater.Foam = WProfile.Foam;
    CWater.ForwardUpward = WProfile.ForwardUpward;

    // CWater.Foam = ProfileUV; // debug

    CWater.WPO = CSlope.Offset;
    CWater.WPO_World = CWater.WPO + float3(WorldOffset, 0);

    // CWater.WPO = WProfile.ForwardUpward.y.xxx; // debug

    return CWater;
}


EdgeCorrection MF_EdgeCorrection(CoastlineData CData, float2 WorldPosition, float3 WorldPositionOffset)
{
    EdgeCorrection Edge = (EdgeCorrection)0;

    CoastlineHeight Height      = MF_SampleCoastlineHeight(WorldPosition + WorldPositionOffset.rg);
    float           Z           = lerp(Height.GroundRelativeZ - 5.0, WorldPositionOffset.b, saturate(CData.Distance * 0.025 - 0.5));
                    Z           = min(Z, WorldPositionOffset.b);
                    Edge.Offset = float3(WorldPositionOffset.rg, Z);

    Edge.PositionWorldHeight = Z + MF_FluxWorldToCoastlineUV(WorldPosition).ReferencePlaneHeight;

    return Edge;
}


SurfaceFlux_Coastline MF_SurfaceFlux_Coastline(float3 WorldPosition)
{
    SurfaceFlux_Coastline Attributes = (SurfaceFlux_Coastline)0;

    CoastlineData Data = MF_CoastlineSample(WorldPosition.xy);
    Attributes.Distance = Data.Distance;
    Attributes.Intensity = Data.Scale;
    Attributes.Shoreline = MF_CoastlineColor(Attributes.Distance, WorldPosition.xy);
    Attributes.Blend = MF_SurfaceFlux_CoastlineBlend(Data);
    Attributes.SurfaceLayer = (MaterialAttributes)0;


    SurfaceFlux Flux = (SurfaceFlux)0;

    // Normal
    float3 SlopeNormal = MF_SlopeNormal(Data, WorldPosition.xy, _WaveGroundPrediction);
    CoastlineWater W0 = MF_CoastlineWater(Data, WorldPosition.xy, SlopeNormal);

    CoastlineData CoastlineData1 = MF_CoastlineTransform(false, float2(_CoastlineNormalRange, 0), Data);
    CoastlineWater W1 = MF_CoastlineWater(CoastlineData1, WorldPosition.xy, SlopeNormal, float2(_CoastlineNormalRange, 0));

    CoastlineData CoastlineData2 = MF_CoastlineTransform(false, float2(0, _CoastlineNormalRange), Data);
    CoastlineWater W2 = MF_CoastlineWater(CoastlineData2, WorldPosition.xy, SlopeNormal, float2(0, _CoastlineNormalRange));

    float3 Normal = MF_TriangleNormal(W0.WPO_World, W1.WPO_World, W2.WPO_World);


    // Offset
    EdgeCorrection Edge = MF_EdgeCorrection(Data, WorldPosition.xy, W0.WPO);
    FluxWorldToCoastlineUV UV = MF_FluxWorldToCoastlineUV(WorldPosition.xy);
    float3 Offset = float3(Edge.Offset.xy, UV.ReferencePlaneHeight - WorldPosition.z + Edge.Offset.z);


    // Foam
    float Foam = _CoastlineFoamScale * (1 - saturate(Data.Distance / _CoastlineFoamDistance));
    Foam = Foam + max(W0.Foam * 1.3 - 0.5, -0.1);
    Foam = saturate(Foam);


    // Mask
    float2 MaskXY = UV.Scale * UV.TexelSize;
    float Mask = max(MaskXY.x, MaskXY.y) * 0.5 + Data.Distance + (_WaveProfileWidth * 0.2);


    // Velocity
    float2 Velocity = Data.Direction * ( (saturate(Data.Distance * 0.005) - 0.5) * 0.1 );
    Velocity += W0.WPO.xy * ( (saturate(Data.Distance * 0.004) - 0.08) * _CoastlineVelocityScale );


    // Divergence
    float Divergence = lerp( 0.1, saturate(W0.ForwardUpward.g * 0.025 + 0.35), saturate(Data.Distance * 0.001) );
    Divergence *= saturate(1 - (W0.Foam * 3.0));


    // Color
    float Color = 0;


    // Offset correction
    float OffsetCorrection = saturate( (Data.Distance / _WaveProfileWidth) + 1 );


    Flux.Normal           = Normal;
    Flux.Offset           = Offset;
    Flux.Foam             = Foam;
    Flux.Mask             = Mask;
    Flux.Velocity         = Velocity;
    Flux.Divergence       = Divergence;
    Flux.Color            = Color;
    Flux.OffsetCorrection = OffsetCorrection;

    MF_SurfaceFluxSet(Attributes.SurfaceLayer, Flux);

    // debug
    // Attributes.SurfaceLayer.BaseColor = SlopeNormal;
    // Attributes.SurfaceLayer.BaseColor = float3(Mask.xxx);
    // Attributes.SurfaceLayer.BaseColor = Attributes.SurfaceLayer.WorldPositionOffset;

    Attributes.SurfaceLayer.OpacityMask = 1.0;
    Attributes.SurfaceLayer.AmbientOcclusion = 0.0;

    return Attributes;
}


// ===================================================================================================================
// ===================================================================================================================
// =================================               MF_SurfaceFlux_WaveTexture        ================================= 
// ===================================================================================================================
// ===================================================================================================================


DecodeNormaDerivate MF_DecodeNormaDerivate (float NormalScale, bool IsDerivate, float2 NormalXY)
{
    DecodeNormaDerivate Derivate = (DecodeNormaDerivate)0;

    float2 XY = (NormalXY.rg - 0.5) * (1.0 / NormalScale);
    float Z  = sqrt(1 - (XY.x * XY.x + XY.y * XY.y));

    Derivate.Normal = float3(XY, Z);

    Derivate.DerivateXY = (IsDerivate ? (Derivate.Normal.rg / Derivate.Normal.b) : XY);

    return Derivate;
    
}

WaveTextureInfo MF_WaveTextureInfo (bool DistantFade, float Intensity, float2 WorldPosition, FSurfacePositionData PosData)
{
    WaveTextureInfo Info = (WaveTextureInfo)0;

    Info.Wind         = _WaveTextureWind.rg;
    Info.Time         = (_WaveTextureWind * _Time.y).b;

    Info.UV           = WorldPosition.rg - ((_WaveTextureWind * _Time.y).rg + (_WaveTextureOffsetScale.xy));
    Info.UV          *= _WaveTextureOffsetScale.zw;

    Info.WaveUVScale  = _WaveTextureOffsetScale.zw;

    float Fade = saturate(distance(PosData.CameraPositionWS, PosData.PositionWS) * (1.0 / _WaveTextureDistanceBlend) - 0.25);
    Fade = (DistantFade ? Fade : 0.0);

    Info.LOD = Fade * 4;
    Info.Scale = (1 - Fade) * Intensity;

    return Info;
}

WaveSampleDecode MF_WaveSampleDecode (float4 Sample, float2 WaveLength, float WaveHeight, float WaveChoppiness, float WaveOffset, float WaveOffsetZ, float DecodeHeight, float DecodeNormal, bool SampleIsDerivate = 0)
{
    WaveSampleDecode Decode = (WaveSampleDecode)0;

    float2 Derivate_XY = MF_DecodeNormaDerivate(DecodeNormal, SampleIsDerivate, Sample.rg).DerivateXY;

    Decode.SampleHeight = Sample.b;
    Decode.SampleFoam = Sample.a;

    Decode.Derivate = Derivate_XY * WaveLength * DecodeHeight * WaveHeight;
    Decode.Normal = normalize(float3(Decode.Derivate, 1.0));

    Decode.OffsetZ = WaveOffsetZ + ((Decode.SampleHeight + WaveOffset) * WaveHeight);
    Decode.Offset = float3(Derivate_XY * (-WaveChoppiness * (1 - Decode.SampleHeight)), Decode.OffsetZ);

    return Decode;
}


SurfaceFlux_WaveTexture MF_SurfaceFlux_WaveTexture (bool DistantFade, float Intensity, float2 WorldPosition, float Distance, bool Precise, FSurfacePositionData PosData)
{
    SurfaceFlux_WaveTexture WaveTexture = (SurfaceFlux_WaveTexture)0;

    WaveTextureInfo Info = MF_WaveTextureInfo(DistantFade, Intensity, WorldPosition, PosData);

    float4 Sample2D                 = SAMPLE_TEXTURE2D_LOD(_WaveTextureRenderTarget, SamplerLinearRepeat, Info.UV, 0);
    float4 Sample3D                 = SAMPLE_TEXTURE2D_LOD(_WaveTextureAnimation, SamplerLinearRepeat, FlipbookUV(abs(frac(Info.UV)), 0, Info.Time), 0); // sample the tile, then inverse Y
    WaveTexture.SampleResult = (_UseWaveTextureRenderTarget ? Sample2D : Sample3D);

    WaveSampleDecode Decode = MF_WaveSampleDecode(WaveTexture.SampleResult, Info.WaveUVScale, Info.Scale * _WaveTextureHeight, _WaveTextureChoppiness, -0.5, _WaveTextureOffsetZ, _WaveTextureDecodeHeight, _WaveTextureDecodeNormal, 0);
    
    SurfaceFlux Flux_A = (SurfaceFlux)0;
    SurfaceFlux Flux_B = (SurfaceFlux)0;

    // Flux_A
    Flux_A.Normal           = float3(0, 0, 1);
    Flux_A.Offset           = float3(float2(0.0, 0.0), _WaveTextureOffsetZ - PosData.PositionWS.b);
    Flux_A.Foam             = 0.0;
    Flux_A.Mask             = 1000.0;
    Flux_A.Velocity         = float2(0.0, 0.0);
    Flux_A.OffsetCorrection = 0.5;
    
    // Flux_B
    Flux_B.Normal     = Decode.Normal;
    Flux_B.Offset     = float3(Decode.Offset.rg, (Decode.Offset.b - PosData.PositionWS.b));
    
    Flux_B.Divergence = Decode.SampleHeight * _WaveTextureDivergenceScale + _WaveTextureDivergenceOffset + Decode.SampleFoam * _WaveTextureDivergenceFoam;
    Flux_B.Divergence *= Info.Scale;

    float Foam_A      = ((Decode.SampleFoam + _WaveTextureFoamOffset) * _WaveTextureFoamScale) * Info.Scale;
    float Foam_B      = min(1.0, (Distance * (-0.002) + 0.5)) * 0.6;
    Flux_B.Foam = max(Foam_A, Foam_B);

    Flux_B.Velocity = lerp(_WaveTextureVelocityScaleBottom, _WaveTextureVelocityScaleTop, Decode.SampleHeight) * Decode.Normal.rg + Info.Wind * _WaveTextureVelocityWind;
    
    Flux_B.OffsetCorrection = 0.5;

    WaveTexture.SurfaceLayer = (MaterialAttributes)0;

    if (_UseFluxWaveDistant)
    {
        MF_SurfaceFluxSet(WaveTexture.SurfaceLayer, Flux_A);
    }
    else
    {
        MF_SurfaceFluxSet(WaveTexture.SurfaceLayer, Flux_B);
    }

    WaveTexture.SurfaceLayer.OpacityMask = 1.0;
    WaveTexture.SurfaceLayer.AmbientOcclusion = 1.0;

    // WaveTexture.SurfaceLayer.BaseColor = float3(Flux_B.Normal); //debug

    return WaveTexture;
}

// =============================================================================================================
// =============================================================================================================
// =================================               MF_SurfaceFlux_Blend        ================================= 
// =============================================================================================================
// =============================================================================================================

MaterialAttributes MF_SurfaceFlux_Blend (MaterialAttributes MA, MaterialAttributes MB, float Alpha)
{
    MaterialAttributes Result = (MaterialAttributes)0;
    SurfaceFlux        Flux   = (SurfaceFlux)0;

    SurfaceFlux Flux_A = MF_SurfaceFluxGet(MA);
    SurfaceFlux Flux_B = MF_SurfaceFluxGet(MB);

    Flux.Normal           = lerp(Flux_A.Normal,           Flux_B.Normal,           Alpha);
    Flux.Offset           = MF_Lerp(Flux_A.Offset,        Flux_B.Offset,           Alpha);
    Flux.Foam             = lerp(Flux_A.Foam,             Flux_B.Foam,             Alpha);
    Flux.Mask             = lerp(Flux_A.Mask,             Flux_B.Mask,             Alpha);
    Flux.Velocity         = lerp(Flux_A.Velocity,         Flux_B.Velocity,         Alpha);
    Flux.Divergence       = lerp(Flux_A.Divergence,       Flux_B.Divergence,       Alpha);
    Flux.Color            = lerp(Flux_A.Color,            Flux_B.Color,            Alpha);
    Flux.OffsetCorrection = lerp(Flux_A.OffsetCorrection, Flux_B.OffsetCorrection, Alpha);

    MF_SurfaceFluxSet(Result, Flux);

    Result.OpacityMask      = 1.0;
    // Result.AmbientOcclusion = Flux.OffsetCorrection; //debug

    return Result;
}

// =============================================================================================================
// =============================================================================================================
// =================================               MF_WaterlineCorrection        ===============================
// =============================================================================================================
// =============================================================================================================

RectMask MF_RectMask (float2 Position, float2 Size, float2 UV)
{
    RectMask Rect = (RectMask)0;

    float2 X = abs(UV - Position);
    float2 Y = Size * 0.5;

    Rect.MaskIn = min(step(X, Y).r, step(X, Y).g);
    Rect.MaskOut = max(step(Y, X).r, step(Y, X).g);
    return Rect;
}

void MF_WaterlineCorrection (inout MaterialAttributes SurfaceLayer, FSurfacePositionData PosData)
{
    SurfaceFlux Flux = MF_SurfaceFluxGet(SurfaceLayer);

    float3 WorldPosition = PosData.PositionWS;
    WorldPosition = float3(WorldPosition.x, WorldPosition.z, WorldPosition.y); // -- UE to UNITY -- (Chirality)

    // Offset
    float3 CameraRelativePositionWS = PosData.PositionWS - PosData.CameraPositionWS;

    // Common
    float Distance = distance((Flux.Offset + CameraRelativePositionWS), float3(0, 0, 0));

    float OffsetCorrection = Flux.OffsetCorrection + saturate( distance((CameraRelativePositionWS + Flux.Offset) * _CameraRadius.xyz, 0) - _CameraRadius.w );
    float3 Offset = float3(Flux.Offset.xy * saturate(OffsetCorrection), Flux.Offset.z);

    // Foam
    float Foam = Flux.Foam * saturate(Distance * -0.000015 + 1);

    SurfaceFlux Flux2 = MF_SurfaceFluxGet(SurfaceLayer);
    Flux2.Foam = Foam;
    Flux2.Offset = Offset;
    MF_SurfaceFluxSet(SurfaceLayer, Flux2);

    // UseFluxWaveDistant
    float OffsetDenom = (((Flux.Mask - min((100000.0 - Distance), -100.0 )) > 0.00001) ? 1.0 : 0.0);
    float3 WorldPositionOffset = Offset / OffsetDenom;
    SurfaceLayer.WorldPositionOffset = _UseFluxWaveDistant ? SurfaceLayer.WorldPositionOffset : WorldPositionOffset;

    // UseCutMask
    float WorldPositionOffsetDenom = MF_RectMask(_SurfaceCutMask.xy, _SurfaceCutMask.zw, WorldPosition.xy).MaskOut;
    SurfaceLayer.WorldPositionOffset = (_UseCutMask ? (SurfaceLayer.WorldPositionOffset / WorldPositionOffsetDenom) : (SurfaceLayer.WorldPositionOffset));
}

// ========================================================================================================
// ========================================================================================================
// =================================               MF_SurfaceLayer        ================================= 
// ========================================================================================================
// ========================================================================================================

FFMain_SurfaceLayer MF_SurfaceLayer(float3 WorldPosition, FSurfacePositionData PosData)
{
    FFMain_SurfaceLayer Result = (FFMain_SurfaceLayer)0;

    float CoastlineDistance  = MF_SurfaceFlux_Coastline(WorldPosition).Distance;
    float CoastlineIntensity = MF_SurfaceFlux_Coastline(WorldPosition).Intensity;

    MaterialAttributes MA_Coastline   = MF_SurfaceFlux_Coastline(WorldPosition).SurfaceLayer;
    MaterialAttributes MA_WaveTexture = MF_SurfaceFlux_WaveTexture(1, CoastlineIntensity, WorldPosition.xy, CoastlineDistance, 0, PosData).SurfaceLayer;
    float              Blend_Alpha    = MF_SurfaceFlux_Coastline(WorldPosition).Blend;

    Result.SurfaceLayerVS = MF_SurfaceFlux_Blend(MA_Coastline, MA_WaveTexture, Blend_Alpha);

    // Result.SurfaceLayerVS = MA_Coastline; // debug

    Result.SurfaceLayerVS.AmbientOcclusion = 0.0; // Color

    Result.Shoreline      = MF_SurfaceFlux_Coastline(WorldPosition).Shoreline;

    MF_WaterlineCorrection(Result.SurfaceLayerVS, PosData);

    // Result.SurfaceLayerVS = MA_Coastline; // debug

    return Result;
}
