#ifndef WORLD_SPACE_DEPTH_INCLUDED
#define WORLD_SPACE_DEPTH_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

float WorldSpaceDepth(float4 positionCS, float3 positionWS) {

    float2 uv = positionCS.xy / _ScaledScreenParams.xy;

    #if UNITY_REVERSED_Z
        real depth = SampleSceneDepth(uv);
    #else
        real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
    #endif

    float3 worldPos = ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_VP);

    return positionWS.y - worldPos.y;
}

#endif