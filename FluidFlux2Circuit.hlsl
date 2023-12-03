// FluidFlux2Common.hlsl

// MF_FluxSurfaceOver.hlsl as main framework

#ifndef FLUID_FLUX_2_COMMON_INCLUDED

    #define FLUID_FLUX_2_COMMON_INCLUDED

    #include "FluidFlux2HelperStruct.hlsl"
    #include "FluidFlux2HelperFunction.hlsl"

    //--------------------------------------------------------------------------------------------

    #include "./Surface/Layers/MF_SurfaceLayer.hlsl"

    // #include "./Surface/Detail/MF_FluidDetailWave.hlsl"

    #include "./Surface/Fluid/MF_WaterTransition.hlsl"

    #include "./Surface/Fluid/MF_FluidWaterLayer.hlsl"

    #include "./Surface/Foam/MF_FluidFoam.hlsl"

    #include "./Surface/Fluid/MF_FluidNormalCorrection.hlsl"

    #include "./Surface/Fluid/MF_FluidTranslucent.hlsl"

    #include "./Surface/Fluid/MF_FluidScattering.hlsl"

    #include "./Surface/Fluid/MF_SingleLayerWater.hlsl"

    //--------------------------------------------------------------------------------------------

    #include "MF_FluxSurfaceOver.hlsl"

    //--------------------------------------------------------------------------------------------

#endif // FLUID_FLUX_2_COMMON_INCLUDED