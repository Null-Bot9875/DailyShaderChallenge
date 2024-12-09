Shader "Unlit/func_diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt ("Light Intensity", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _LightInt;
            float4 _LightColor0;

            // LambertShading 函数返回了一个的三维向量，用来表示颜色。函数的输入参数有光源反射颜色（colorRefl RGB）、光源强度（lightInt [0, 1]）、模型表面法线（normal XYZ）和光源方向（lightDir XYZ）。
            float3 LambertShading(float3 colRefl,// Dr,光源反射颜色
                                  float lightInt,// Dl 光源强度
                                  float3 normal,// N 法线
                                  float3 lightDir)// L 光线方向
            {
                // tips:当两个向量是单位向量时，点积的值表示两个向量的夹角的余弦值
                return colRefl * lightInt * max(0, dot(normal, lightDir));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = normalize(UnityObjectToWorldNormal(v.normal));
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // 内置变量 _WorldSpaceLightPos0 表示光源的世界坐标
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 colRefl = _LightColor0.rgb;
                half3 diffuse = LambertShading(colRefl,_LightInt,i.normal_world,lightDir);

                // 漫反射应用
                col.rgb *= diffuse;
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
