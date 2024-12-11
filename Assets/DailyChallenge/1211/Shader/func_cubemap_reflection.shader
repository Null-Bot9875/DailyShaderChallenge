// https://learnopengl-cn.github.io/04%20Advanced%20OpenGL/06%20Cubemaps/
// 立方体贴图

// 在 Unity 中，我们可以通过反射探针（Reflection Probe）组件生成立方贴图。这个组件类似于一台相机，可以以球体的视角无死角地捕捉周围的环境，并生成一张可以用作反射贴图的 Cube 类型的贴图。

// https://zhuanlan.zhihu.com/p/140822208 texCUBElod 函数
// https://zhuanlan.zhihu.com/p/152561125 reflect 函数

Shader "Unlit/func_cubemap_reflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _ReflectionTex ("Reflection Cubemap", CUBE) = "" {}
        _ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 1
        _ReflectionMetallic ("Reflection Metallic", Range(0, 1)) = 0 // 金属度
        _ReflectionDetail ("Reflection Detail", Range(1, 9)) = 1 // 细节
        _ReflectionExposure ("Reflection Exposure", Range(1, 3)) = 1 // 曝光度

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            samplerCUBE _ReflectionTex;
            float _ReflectionIntensity;
            float _ReflectionMetallic;
            float _ReflectionDetail;
            float _ReflectionExposure;

            float3 AmbientReflection(samplerCUBE colorRefl, float3 reflectionInt,half reflectionDet,float3 normal,float3 viewDir,float reflectionExp)
            {
                float3 reflection_world = reflect(viewDir, normal); 
                float4 cubemap = texCUBElod(colorRefl, float4(reflection_world, reflectionDet)); 
                return reflectionInt * cubemap.rgb * (cubemap.a * reflectionExp); 
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.vertex_world = UnityObjectToWorldDir(v.vertex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col

                float3 normal = normalize(i.normal_world);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex_world));

                float3 reflection = AmbientReflection(_ReflectionTex,_ReflectionIntensity,_ReflectionDetail,normal,-viewDir,_ReflectionExposure);

                col.rgb *= reflection + _ReflectionMetallic;
                return col;
                

                // UNITY_SAMPLE_TEXCUBE 函数，该函数将自动分配场景中配置的环境反射，这意味着如果我们在照明窗口（Lighting）中配置了天空盒，那么反射将作为纹理保存在着色器中，我们可以立即使用它，而无需独立生成 Cubemap 纹理。
                // UNITY_SAMPLE_TEXCUBE 宏使用反射坐标（reflect_world）采样了数据，将其通过 UnityCg.cginc 内置的 DecodeHDR 函数解码为HDR形式的颜色

                // fixed4 col = tex2D(_MainTex, i.uv); 
                // half3 normal = i.normal_world; 
                // half3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex_world)); 
                // half3 reflect_world = reflect(-viewDir, normal); 
                // // 该过程表示上面的部分已被函数替换
                // // UNITY_SAMPLE_TEXCUBE 
                // half4 reflectionData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect_world ); 
                // half3 reflectionColor = DecodeHDR(reflectionData, unity_SpecCube0_HDR); 
            
                // return float4(reflectionColor, 1);
                // col.rgb = reflectionColor; 
                // return col; 
            }
            ENDCG
        }
    }
}
