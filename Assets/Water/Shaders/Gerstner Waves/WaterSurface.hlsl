#ifndef WATER_SURFACE_INCLUDED
#define WATER_SURFACE_INCLUDED

#include "WaterColor.hlsl"
#include "WaterSSS.hlsl"

void InitializeInputData(Varyings input, out InputData inputData) {
    inputData = (InputData)0;
    inputData.normalWS = normalize(input.normalWS);
    inputData.viewDirectionWS = input.viewDirectionWS;
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, input.normalWS);
    inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
}

void InitializeSurfaceData(Varyings input, out SurfaceData surfaceData) {
    surfaceData = (SurfaceData)0;
    half4 albedo = tex2D(_BaseMap, input.uv);
    surfaceData.albedo = albedo.rgb * _BaseColor.rgb;
    surfaceData.metallic = _Metallic;
    surfaceData.smoothness = _Smoothness;
    surfaceData.occlusion = 1;
    surfaceData.alpha = albedo.a * _BaseColor.a;

    half4 waterColor = WaterColor(input.screenPos, input.uv);
    surfaceData.albedo = waterColor.rgb;
    surfaceData.alpha = waterColor.a * _BaseColor.a;
}

half4 Surface(Varyings input) {
    InputData inputData;
    InitializeInputData(input, inputData);

    SurfaceData surfaceData;
    InitializeSurfaceData(input, surfaceData);

    half4 lightColor = UniversalFragmentPBR(inputData, surfaceData);

    Light light = GetMainLight(inputData.shadowCoord);
    float sss = SubsurfaceScattering(inputData.normalWS, inputData.viewDirectionWS, light.direction, input.heightOS);
    sss *= light.shadowAttenuation;
    half3 sssColor = sss * light.color;

    lightColor.rgb += sssColor;

    return lightColor;
}
#endif