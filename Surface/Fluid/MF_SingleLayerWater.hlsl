// MF_SingleLayerWater

MF_SingleLayerWater_Attributes MF_SingleLayerWater(float FoamScattering, float WaveScattering, float Painter, float Shoreline)
{
    WaterTransition TempAttributes = MF_WaterTransition(Painter, Shoreline);

    ZERO_INITIALIZE(MF_SingleLayerWater_Attributes, OutputAttributes);

    OutputAttributes.ColorBehind = TempAttributes.ColorBehind;
    OutputAttributes.Absorption  = TempAttributes.SurfaceAbsorption / (WaveScattering * 1.0 + 1.0);
    OutputAttributes.Scattering  = TempAttributes.SurfaceScattering * (WaveScattering * 1.0 + 1.0) + TempAttributes.FoamScattering * FoamScattering;
    OutputAttributes.PhaseG      = TempAttributes.PhaseG;
    
    return OutputAttributes;
}

