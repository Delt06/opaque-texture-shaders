Shader "Custom/Shockwave"
{
    Properties
    {
        _Strength ("Strength", Float) = 1.0
        _Progress ("Progress", Float) = 0.5
        _Smoothness ("Smoothness", Float) = 0.1
        _Noise ("Noise", 2D) = "gray" {}
        _NoiseStrength ("Noise Strength", Float) = 0.1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 position_cs : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)

            float _Strength;
            float _Progress;
            float _Smoothness;
            float _NoiseStrength;
            float4 _Noise_ST;

            CBUFFER_END

            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);

            v2f vert (const appdata input)
            {
                v2f output;
                output.position_cs = TransformObjectToHClip(input.position_os.xyz);
                output.uv = input.uv;
                return output;
            }

            float2 safe_normalize(float2 in_vec)
            {
                const float dp = max(REAL_MIN, dot(in_vec, in_vec));
                return in_vec * rsqrt(dp);
            }

            float4 frag (const v2f input) : SV_Target
            {
                float2 color_sample_uv = GetNormalizedScreenSpaceUV(input.position_cs);

                const float2 symmetric_uv = (input.uv - 0.5) * 2; 
                const float2 direction = safe_normalize(symmetric_uv);

                const float uv_len = length(symmetric_uv);
                const float progress_multiplier = smoothstep(_Smoothness, 0, abs(_Progress - uv_len));
                const float fade = max(1 - uv_len, 0);

                const float2 noise_uv = input.uv * _Noise_ST.xy + _Noise_ST.zw;
                const float noise_sample = SAMPLE_TEXTURE2D(_Noise, sampler_Noise, noise_uv);
                const float noise_multiplier = 1 + (noise_sample - 0.5) * 2 * _NoiseStrength;
                
                color_sample_uv -= direction * _Strength * progress_multiplier * fade * noise_multiplier;
                
                return float4(SampleSceneColor(color_sample_uv), 1);
            }
            ENDHLSL
        }
    }
}
