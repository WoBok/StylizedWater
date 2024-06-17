#ifndef WATER_COLOR_INCLUDED
#define WATER_COLOR_INCLUDED

sampler2D _CameraDepthTexture;

half4 _ShallowCollor;
half4 _DeepColor;
float _DepthRange;

float4 _FoamColor;
float _FoamIntensity;
float _FoamDistance;

sampler2D _WaveTex;
sampler2D _NoiseTex ;
float _WaveSpeed2;
float _WaveRange;
float _WaveRangeA;
float _WaveDelta;

half4 WaterColor(float4 screenPos, float2 uv) {

    float backgroundDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, screenPos), _ZBufferParams);
    float depthDifference = backgroundDepth - screenPos.z;

    half4 color;
    float depth = saturate(depthDifference / _DepthRange);
    color = lerp(_ShallowCollor, _DeepColor, depth);
    color.a *= saturate(depthDifference / _DepthRange);

    float foamOffset = tex2D(_FoamMap, uv * _FoamMap_ST.xy + _Time.x).x;
    float foamFactor = pow(saturate(_FoamIntensity * foamOffset -depthDifference) * 20, 20) * saturate(depthDifference / _FoamDistance);
    color.rgb = lerp(color, _FoamColor.rgb, foamFactor);

    //half waveB = 1 - saturate(depthDifference / _WaveRangeA) ;
    //half4 noiserColor = tex2D(_NoiseTex, uv);
    //half4 waveColor = tex2D(_WaveTex, float2(waveB + _WaveRange * sin(_Time.x * _WaveSpeed2 + noiserColor.r), 1));
    //waveColor.rgb *= (1 - (sin(_Time.x * _WaveSpeed2 + noiserColor.r) + 1) / 2) * noiserColor.r;
    //half4 waveColor2 = tex2D(_WaveTex, float2(waveB + _WaveRange * sin(_Time.x * _WaveSpeed2 + _WaveDelta + noiserColor.r), 1));
    //waveColor2.rgb *= (1 - (sin(_Time.x * _WaveSpeed2 + _WaveDelta + noiserColor.r) + 1) / 2) * noiserColor.r;

    //color.rgb += (waveColor.rgb + waveColor2.rgb) * waveB;

    return color;
}

#endif