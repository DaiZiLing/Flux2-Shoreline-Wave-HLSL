// MF_FluidNormalCorrection

void MF_FluidNormalCorrection (inout MaterialAttributes InputLayer, in FSurfacePositionData PosData)
{
    InputLayer.Normal = MF_ImposibleNormalFix(InputLayer.Normal, PosData.CameraVectorWS);
}