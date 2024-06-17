#ifndef WATER_SSS_INCLUDED
#define WATER_SSS_INCLUDED

float _FrontSubsurfaceDistortion;
float _BackSubsurfaceDistortion;
float _FrontSSSIntensity;
float _HeightCorrection;

float SubsurfaceScattering(float3 normal, float3 viewDir, float3 lightDir, float heightOS) {
    float3 frontLitDir = normal * _FrontSubsurfaceDistortion - lightDir;
    float3 backLitDir = normal * _BackSubsurfaceDistortion + lightDir;
    float frontsss = saturate(dot(viewDir, -frontLitDir));
    float backsss = saturate(dot(viewDir, -backLitDir));
    
    float result = saturate(frontsss * _FrontSSSIntensity + backsss) * saturate(heightOS - _HeightCorrection);
    return result;
}

#endif