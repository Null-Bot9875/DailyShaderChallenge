// 这次我们将在程序中使用一些函数来画一个圆。我们将首先添加一些属性用于稍后放大、居中和平滑形状。
Shader "Unlit/func_lenth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Range(0, 1)) = 0.5
        _Center ("Center", Range(0, 1)) = 0.5
        _Smooth ("Smooth", Range(0, 1)) = 0.01
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Radius;
            float _Center;
            float _Smooth;

            float circle(float2 p, float center, float radius, float smooth)
            {
                // float c = length(p -center) - radius;
                // return c;
                float c = length(p - center);
                return smoothstep(c - smooth, c + smooth, radius);

                
                /*
                    smoothstep(edge0, edge1, x) 是一个平滑插值函数，它的作用是:

                    创建一个平滑的过渡区域
                    当 x 小于 edge0 时返回 0
                    当 x 大于 edge1 时返回 1
                    在 edge0 和 edge1 之间使用平滑的 Hermite 插值
                */
            }

            // float length (float n)
            // {
            //     // sqrt是开方函数，返回n点乘n的平方根
            //     return sqrt(dot(n, n));
            // }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // return col;

                float c = circle(i.uv,_Center, _Radius, _Smooth);
                return float4(c.xxx, 1);
            }
            ENDCG
        }
    }
}
