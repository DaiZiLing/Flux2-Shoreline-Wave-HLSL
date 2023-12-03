// MF_WaterTransition

WaterTransition MF_WaterTransition(float Painter, float Shoreline)
{
    ZERO_INITIALIZE(WaterTransition, Attributes);

    // === UE to Unity degamma ===
    
    _SurfaceAbsorption0.rgb = pow((_SurfaceAbsorption0.rgb / 255.0), 0.45) * 255.0;
    _SurfaceAbsorption1.rgb = pow((_SurfaceAbsorption1.rgb / 255.0), 0.45) * 255.0;
    _SurfaceAbsorptionShoreline.rgb = pow((_SurfaceAbsorptionShoreline.rgb / 255.0), 0.45) * 255.0;

    // === UE to Unity degamma End ===

    float3 MF_Lerp3Vecto3_Result_1 = MF_Lerp3Vecto3(_SurfaceOverlay0, _SurfaceOverlay1, _SurfaceOverlayShoreline, Shoreline, Painter);

    float3 SurfaceAbsorption0Inverse         = 1.0 / (_SurfaceAbsorption0.rgb * _SurfaceAbsorption0.a);
    float3 SurfaceAbsorption1Inverse         = 1.0 / (_SurfaceAbsorption1.rgb * _SurfaceAbsorption1.a);
    float3 SurfaceAbsorptionShorelineInverse = 1.0 / (_SurfaceAbsorptionShoreline.rgb * _SurfaceAbsorptionShoreline.a);

    float3 MF_Lerp3Vecto3_Result_2 = MF_Lerp3Vecto3(SurfaceAbsorption0Inverse, SurfaceAbsorption1Inverse, SurfaceAbsorptionShorelineInverse, Shoreline, Painter);

    float3 MF_Lerp3Vecto3_Result_3 = MF_Lerp3Vecto3(_SurfaceScattering0.rgb * _SurfaceScattering0.a, _SurfaceScattering1.rgb * _SurfaceScattering1.a, _SurfaceScatteringShoreline.rgb * _SurfaceScatteringShoreline.a, Pow2(Shoreline), Painter);

    float3 MF_Lerp3Vecto3_Result_4 = MF_Lerp3Vecto3(_ColorBehind0.rgb * _ColorBehind0.a, _ColorBehind1.rgb * _ColorBehind1.a, _ColorBehindShoreline.rgb * _ColorBehindShoreline.a, Shoreline, Painter);

    Attributes.UnderwaterFog       = MF_Lerp3Vecto3_Result_1 * 0.35;
    Attributes.SuraceLineColor     = saturate(MF_Lerp3Vecto3_Result_1 * 3.0);
    Attributes.FoamWetColor        = MF_Lerp3Vecto3_Result_1 * 1.0;
    Attributes.SurfaceOverlayColor = MF_Lerp3Vecto3_Result_1 * 0.1;
    Attributes.SurfaceAbsorption   = MF_Lerp3Vecto3_Result_2;
    Attributes.SurfaceScattering   = MF_Lerp3Vecto3_Result_3;
    Attributes.FoamScattering      = MF_Lerp3Vecto3_Result_3 * _FoamScatteringScale;
    Attributes.ColorBehind         = MF_Lerp3Vecto3_Result_4;

    // Attributes.FoamWetColor        = Attributes.SurfaceOverlayColor; //debug

    // Magic PhaseG
    float  OutputPhaseGAlpha         = lerp(lerp(_SurfacePhaseG0, _SurfacePhaseG1, Painter), _SurfacePhaseGShoreline, Pow2(Pow2(Shoreline)));
    float3 DirectionalLightDirection = _DirectionalLightDirection;                                                                // UE preview window lightDir   
    float  OutputPhaseG_1            = lerp(_PhaseGDeepSunLow, _PhaseGDeepSunHigh, saturate(_DirectionalLightDirection.y));
    float  OutputPhaseG_2            = lerp(_PhaseGShallowSunLow, _PhaseGShallowSunHigh, saturate(_DirectionalLightDirection.y));
           Attributes.PhaseG         = lerp(OutputPhaseG_1, OutputPhaseG_2, OutputPhaseGAlpha);

    return Attributes;
}

