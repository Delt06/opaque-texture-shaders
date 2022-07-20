Shader "Custom/BlackHole"
{
    Properties
    {
        _DistortionStrength ("Distortion Strength", Float) = 1
        _FresnelPower ("Fresnel Power", Float) = 1
        _HoleSize ("Hole Size 1", Float) = 0.5
        _HoleSmoothness ("Hole Smoothness 2", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            struct appdata
            {
                float4 position_os : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_os : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 position_cs : SV_POSITION;
                float3 position_ws : POSITION_WS;
                float3 normal_ws : NORMAL_WS;
            };

            CBUFFER_START(UnityPerMaterial)

            float _DistortionStrength;
            float _FresnelPower;
            float _HoleSize;
            float _HoleSmoothness;
            
            CBUFFER_END

            v2f vert (const appdata input)
            {
                v2f output;
                output.position_ws = TransformObjectToWorld(input.position_os.xyz);
                output.position_cs = TransformWorldToHClip(output.position_ws);
                output.uv = input.uv;
                output.normal_ws = TransformObjectToWorldNormal(input.normal_os);
                return output;
            }

            float fresnel(const float3 normal_ws, const float3 view_dir_ws)
            {
                return 1.0 - saturate(dot(normal_ws, view_dir_ws));
            }

            float4 frag (const v2f input) : SV_Target
            {
                const float3 normal_ws = normalize(input.normal_ws);
                float3 normal_vs = TransformWorldToViewDir(normal_ws);
                float2 color_sample_uv = GetNormalizedScreenSpaceUV(input.position_cs);
                float2 distortion = -normal_vs.xy * _DistortionStrength;

                const half3 view_dir_ws = GetWorldSpaceNormalizeViewDir(input.position_ws);
                const float fresnel_value = fresnel(normal_ws, view_dir_ws);
                distortion *= 1.0 - pow(fresnel_value, _FresnelPower);
                
                color_sample_uv += distortion;
                const float3 scene_color = SampleSceneColor(color_sample_uv);
                const float hole_t = smoothstep(_HoleSize + _HoleSmoothness, _HoleSize, fresnel_value);
                float3 resulting_color = lerp(scene_color, half3(0, 0, 0), hole_t);
                
                return float4(resulting_color, 1);
            }
            ENDHLSL
        }
    }
}
