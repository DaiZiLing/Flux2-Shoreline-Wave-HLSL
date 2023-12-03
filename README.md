# Flux2-Shoreline-Wave-HLSL

![image](https://github.com/DaiZiLing/Flux2-Shoreline-Wave-HLSL/blob/main/1201_1.gif)
![image](https://github.com/DaiZiLing/Flux2-Shoreline-Wave-HLSL/blob/main/1201_2.gif)
![image](https://github.com/DaiZiLing/Flux2-Shoreline-Wave-HLSL/blob/main/1203_2.gif)
![image](https://github.com/DaiZiLing/Flux2-Shoreline-Wave-HLSL/blob/main/1203_20.gif)
![image](https://github.com/DaiZiLing/Flux2-Shoreline-Wave-HLSL/blob/main/1203_23.gif)
![image](https://github.com/DaiZiLing/Flux2-Shoreline-Wave-HLSL/blob/main/1203_9.gif)

This is a repo which contains the HLSL codes ported from Unreal 5 plugin -- Fluid Flux 2

Only M_FluxSurfaceOver's material function translated to HLSL.

**Notes**

Only most of the key nodes in the FF2 water surface material M_FluxSurfaceOver are translated into hlsl functions and cannot be used as shader directly.

The translation has been completed with the help of my colleague IRIN, thus saving readers this step.

Repo does not contain the code of the SingleLayerWater shading model. If readers want to use it, they need to write a SingleLayerWater shading model from Unreal into Unity.

Repo does not contain any light function related to PBR. My calculation results output the same MaterialAttributes as Unreal. Readers need to use the parameters such as BaseColor and Roughness output for their own PBR.

It does not include any copying or distribution of any assets in Fluid Flux 2, including but not limited to scene terrain mesh and texture assets.
