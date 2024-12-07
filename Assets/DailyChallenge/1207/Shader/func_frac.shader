Shader "Unlit/func_frac"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size ("Size", Range(0,0.5)) = 0.1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Size;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                /* 
                i.uv *= 3;
                // 只取小数，如果图片设置的是clamp而不是repeat，那么这个效果就是不断的重复
                //返回一个值的小数部分，也就是说，它的十进制值，例如，1.534f的frac返回0.534f；
                float2 fuv = frac(i.uv);
                fixed4 col = tex2D(_MainTex, fuv);
                return col;
                */
                
                i.uv *= 3;
                // // 0->1
                float2 fuv = frac(i.uv);
                float circle = length(fuv - 0.5);
                // floor : 向下取整
                float wCircle = floor(_Size/circle);
                wCircle = clamp(wCircle, 0, 1);
                return float4(wCircle, wCircle, wCircle, 1);
            }
            ENDCG
        }
    }
}
