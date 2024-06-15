Shader "URP Shader/Water2" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)

        [Header(PBR)]
        [Space(5)]
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0

        [Header(Wave)]
        [Space(5)]
        _WaveSpeed ("Wave Speed", Float) = 1
        _Wave1 ("Wave 1 Wavelength, Steepness, Direction", Vector) = (10, 0.5, 1, 0)
        _Wave2 ("Wave 2 Wavelength, Steepness, Direction", Vector) = (20, 0.25, 0, 1)
        _Wave3 ("Wave 3 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave4 ("Wave 4 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave5 ("Wave 5 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave6 ("Wave 6 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave7 ("Wave 7 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave8 ("Wave 8 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave9 ("Wave 9 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave10 ("Wave 10 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave11 ("Wave 11 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave12 ("Wave 12 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)

        [Header(Water)]
        [Space(5)]
        _ShallowCollor ("Shallow Color", Color) = (1, 1, 1, 1)
        _DeepColor ("Deep Color", Color) = (1, 1, 1, 1)
        _DepthRange ("Depth Range", Float) = 1
        _TransDepthRange ("Trans Depth Range", Float) = 1

        [Header(Tessellation)]
        [Space(5)]
        _TessellationUniform ("Tessellation Uniform", Range(1, 64)) = 1
        _TessellationEdgeLength ("Tessellation Edge Length", Range(5, 100)) = 50
        [Toggle]_Tessellation_Edge ("Tessellation Edge", float) = 1

        [Enum(UnityEngine.Rendering.CullMode)]_Cull ("Cull", Float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull[_Cull]

            HLSLPROGRAM

            #pragma vertex  TessellationVertexProgram
            #pragma fragment Fragment
            #pragma hull  HullProgram
            #pragma domain  DomainProgram

            #pragma shader_feature _TESSELLATION_EDGE_ON

            #pragma multi_compile  _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            //#pragma multi_compile  _SHADOWS_SOFT
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            //#include "WaterForwardPass.hlsl"
            
            //#include "WaterInput.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float2 staticLightmapUV : TEXCOORD1;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 viewDirectionWS : TEXCOORD3;
                float4 screenPos : TEXCOORD4;
                float4 positionCS : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 5);
            };

            sampler2D _BaseMap;
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _Smoothness, _Metallic;

            //#include "GerstnerWave.hlsl"

            float _WaveSpeed;
            float4 _Wave1, _Wave2, _Wave3, _Wave4, _Wave5, _Wave6, _Wave7, _Wave8, _Wave9, _Wave10, _Wave11, _Wave12;

            float3 GerstnerWave(float4 wave, float3 p, inout float3 tangent, inout float3 binormal) {
                //将位置和法线计算分开
                float period = 2 * PI;
                float k = period / wave.x;
                float c = sqrt(9.8 / k) * _WaveSpeed;
                float2 d = normalize(wave.zw);
                float f = k * (dot(d, p.xz) - c * _Time.y);

                tangent += float3(
                    - d.x * d.x * wave.y * sin(f),
                    d.x * wave.y * cos(f),
                    - d.x * d.y * wave.y * sin(f)
                );

                binormal += float3(
                    - d.x * d.y * wave.y * sin(f),
                    d.y * wave.y * cos(f),
                    - d.y * d.y * wave.y * sin(f)
                );

                float a = wave.y / k;

                return float3(
                    d.x * a * cos(f),
                    a * sin(f),
                    d.y * a * cos(f)
                );
            }

            #define GERSTNER_WAVE(wave) input.positionOS.xyz += GerstnerWave(wave, position, tangent, binormal);

            //#include "WaterSurface.hlsl"
            
            //#include "LookingThroughWater.hlsl"

            //sampler2D _CameraDepthTexture;

            half3 _ShallowCollor;
            half3 _DeepColor;
            float _DepthRange;
            float _TransDepthRange;

            //half4 ColorBelowWater(float4 screenPos) {
            //    float2 uv = screenPos.xy / screenPos.w;

            //    float backgroundDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, screenPos), _ZBufferParams);
            //    float depthDifference = backgroundDepth - screenPos.z;

            //    half4 color;
            //    float depth = saturate(depthDifference / _DepthRange);
            //    color.rgb = lerp(_ShallowCollor, _DeepColor, depth);
            //    color.a = saturate(depthDifference / _TransDepthRange);

            //    return color;
            //}

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

                //half4 waterColor = ColorBelowWater(input.screenPos);
                //surfaceData.albedo = waterColor.rgb;
                //surfaceData.alpha = waterColor.a * _BaseColor.a;
            }

            half4 Surface(Varyings input) {
                InputData inputData;
                InitializeInputData(input, inputData);

                SurfaceData surfaceData;
                InitializeSurfaceData(input, surfaceData);

                return UniversalFragmentPBR(inputData, surfaceData);
            }

            Varyings Vertex(Attributes input) {
                Varyings output;
                
                float3 tangent = float3(1, 0, 0);
                float3 binormal = float3(0, 0, 1);
                float3 position = input.positionOS.xyz;

                GERSTNER_WAVE(_Wave1) GERSTNER_WAVE(_Wave2) GERSTNER_WAVE(_Wave3) GERSTNER_WAVE(_Wave4)
                GERSTNER_WAVE(_Wave5) GERSTNER_WAVE(_Wave6)GERSTNER_WAVE(_Wave7) GERSTNER_WAVE(_Wave8)
                GERSTNER_WAVE(_Wave9) GERSTNER_WAVE(_Wave10) GERSTNER_WAVE(_Wave11) GERSTNER_WAVE(_Wave12)

                float3 normal = normalize(cross(binormal, tangent));

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionWS = positionWS;
                output.viewDirectionWS = normalize(_WorldSpaceCameraPos - positionWS);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                //output.screenPos = ComputeScreenPos(output.positionCS);
                //output.screenPos.z = -TransformWorldToView(TransformObjectToWorld(input.positionOS)).z;

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                return output;
            }

            //#include "Tessellation.hlsl"

            float _TessellationUniform;
            float _TessellationEdgeLength;

            struct TessellationControlPoint {
                float4 positionOS : INTERNALTESSPOS;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct TessellationFactors {
                float edge[3] : SV_TessFactor;
                float inside : SV_InsideTessFactor;
            };

            TessellationControlPoint TessellationVertexProgram(Attributes v) {
                TessellationControlPoint p;
                p.positionOS = v.positionOS;
                p.normalOS = v.normalOS;
                p.texcoord = v.texcoord;
                return p;
            }

            float TessellationEdgeFactor(float3 p0, float3 p1) {
                #if defined(_TESSELLATION_EDGE_ON)
                    float edgeLength = distance(p0, p1);

                    float3 edgeCenter = (p0 + p1) * 0.5;
                    float viewDistance = distance(edgeCenter, _WorldSpaceCameraPos);

                    return edgeLength * _ScreenParams.y /
                    (_TessellationEdgeLength * viewDistance);
                #else
                    return _TessellationUniform;
                #endif
            }

            TessellationFactors  PatchConstantFunction(
                InputPatch < TessellationControlPoint, 3 > patch
            ) {
                float3 p0 = mul(unity_ObjectToWorld, patch[0].positionOS).xyz;
                float3 p1 = mul(unity_ObjectToWorld, patch[1].positionOS).xyz;
                float3 p2 = mul(unity_ObjectToWorld, patch[2].positionOS).xyz;
                TessellationFactors f;
                f.edge[0] = TessellationEdgeFactor(p1, p2);
                f.edge[1] = TessellationEdgeFactor(p2, p0);
                f.edge[2] = TessellationEdgeFactor(p0, p1);
                f.inside =
                (TessellationEdgeFactor(p1, p2) +
                TessellationEdgeFactor(p2, p0) +
                TessellationEdgeFactor(p0, p1)) * (1 / 3.0);
                return f;
            }

            [domain("tri")]
            [outputcontrolpoints(3)]
            [outputtopology("triangle_cw")]
            [partitioning("fractional_odd")]
            [patchconstantfunc("PatchConstantFunction")]
            TessellationControlPoint HullProgram(
                InputPatch < TessellationControlPoint, 3 > patch,
                uint id : SV_OutputControlPointID
            ) {
                return patch[id];
            }

            [domain("tri")]
            Varyings  DomainProgram(
                TessellationFactors factors,
                OutputPatch < TessellationControlPoint, 3 > patch,
                float3 barycentricCoordinates : SV_DomainLocation
            ) {
                Attributes data;

                #define  DOMAIN_PROGRAM_INTERPOLATE(fieldName) data.fieldName = \
                patch[0].fieldName * barycentricCoordinates.x + \
                patch[1].fieldName * barycentricCoordinates.y + \
                patch[2].fieldName * barycentricCoordinates.z;

                DOMAIN_PROGRAM_INTERPOLATE(positionOS)
                DOMAIN_PROGRAM_INTERPOLATE(normalOS)
                DOMAIN_PROGRAM_INTERPOLATE(texcoord)

                return Vertex(data);
            }

            half4 Fragment(Varyings input) : SV_Target {
                return Surface(input);
            }

            ENDHLSL
        }
    }
}