#ifndef WATER_COLOR_INCLUDED
#define WATER_COLOR_INCLUDED

sampler2D _CameraDepthTexture;

half3 _ShallowCollor;
half3 _DeepColor;
float _DepthRange;
float4 _FoamColor;
float _FoamIntensity;
float _FoamDistance;

half4 WaterColor(float4 screenPos, float2 uv) {

    float backgroundDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, screenPos), _ZBufferParams);
    float depthDifference = backgroundDepth - screenPos.z;

    half4 color;
    float depth = saturate(depthDifference / _DepthRange);
    color.rgb = lerp(_ShallowCollor, _DeepColor, depth);
    color.a = saturate(depthDifference / _DepthRange);

    float foamOffset = tex2D(_FoamMap, uv * _FoamMap_ST.xy + _Time.x).x;
    float foamFactor = pow(saturate(_FoamIntensity * foamOffset -depthDifference) * 20, 20) * saturate(depthDifference / _FoamDistance);
    color.rgb = lerp(color, float3(1,1,1), foamFactor);

    return color;
}

#endif