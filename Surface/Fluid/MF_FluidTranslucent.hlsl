// MF_FluidTranslucent

CombinePremultiplied MF_CombinePremultiplied (float3 TopRGB, float TopA, float3 BottomRGB, float BottomA)
{
    CombinePremultiplied Premultiplied = (CombinePremultiplied)0;

    Premultiplied.OutA = BottomA * (1 - TopA) + TopA;
    Premultiplied.OutRGB = BottomRGB * (1 - TopA) + TopRGB;

    return Premultiplied;
}

void MF_FluidTranslucent (inout MaterialAttributes FluidLayer, bool UseColor = false, bool UsePremultiplied = false)
{
    
}