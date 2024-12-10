Shader "Unlit/func_frac"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size ("Size", Range(0,0.5)) = 0.1
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
            float _Smooth;

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

                /*
                
                i.uv *= 3;
                // // 0->1
                float2 fuv = frac(i.uv);
                float circle = length(fuv - 0.5);
                // floor : 向下取整
                float wCircle = floor(_Size/circle);
                wCircle = clamp(wCircle, 0, 1);
                return float4(wCircle, wCircle, wCircle, 1);
                */

                // 扩展思考，怎么画一个圆环？
                float c = length(i.uv - 0.5);
                // float circle = smoothstep(_Size - 0.1, _Size + 0.1, c);
                float circle = floor(_Size/c);
                // 圆环
                if (circle >= 1)
                {
                    // 圆环内圆
                    float c2 = length(i.uv - 0.5);
                    float newRadius = _Size - 0.1;
                    float circle2 = floor(newRadius/c2);
                    // float smooth = .5;
                    circle2 = smoothstep(c - _Smooth, c + _Smooth, newRadius);

                    // 反转
                    circle2 = 1 - circle2;

                    circle = circle2;
                }

                // float c2 = length(i.uv - 0.5);
                // float newRadius = _Size - 0.1;
                // float circle2 = floor(newRadius/c2);
                // float smooth = 0.1;
                // circle2 = smoothstep(c - smooth, c + smooth, newRadius);

                // // 反转
                // circle2 = 1 - circle2;
                // return float4(circle2.xxx, 1);

                return float4(circle, circle, circle, 1);
            }
            ENDCG
        }
    }
}
