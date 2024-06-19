#ifndef WATER_NORMAL_INCLUDED
#define WATER_NORMAL_INCLUDED

sampler2D _NormalMap;
float4 _WaveNormal, _NormalMap_ST;
float _NormalScale;

float3 BlendNormals(float3 n1, float3 n2) {
    return normalize(float3(n1.xy + n2.xy, n1.z * n2.z));
}

float3 GetNormal(float3 normalWS, float2 uv) {
    float2 uv1 = _Time.y * _WaveNormal.xy + uv * _NormalMap_ST.xy;
    float2 uv2 = _Time.y * _WaveNormal.zw + uv * _NormalMap_ST.xy;
    float3 normal1 = UnpackNormal(tex2D(_NormalMap, uv1));
    float3 normal2 = UnpackNormal(tex2D(_NormalMap, uv2));
    float3 normal = BlendNormals(normal1, normal2);
    normal = lerp(half3(0, 0, 1), normal, _NormalScale);
    return BlendNormals(normal, normalWS);
}

#endif