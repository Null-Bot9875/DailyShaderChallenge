Shader "Unlit/func_step"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            // step会返回一个阶梯函数，小于edge返回0，否则返回1
            // step(edge, x) = x < edge ? 0 : 1

            // smoothstep会返回一个平滑的阶梯函数，小于edge0返回0，大于edge1返回1，edge0到edge1之间返回0到1之间的值
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
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // return col;


                // step
                /*
                float edge = 0.5;
                fixed3 sstep = 0;
                // 小于edge返回1，否则返回0
                sstep = step(i.uv.y, edge);
                return fixed4(sstep, 1);
                */

                // smoothstep
                float edge = 0.5;
                float smooth = 0.1;
                fixed3 sstep = 0;

                // smoothstep函数的行为与前一个没有太大区别；其唯一的区别在于在返回值之间生成线性插值。
                // 第三个值比第一个值小，返回0；第三个值比第二个值大，返回1；第三个值在第一个值和第二个值之间，返回线性插值。
                sstep = smoothstep(i.uv.y - smooth, i.uv.y + smooth, edge);
                // sstep = 0.5;
                return fixed4(sstep, 1);
            }
            ENDCG
        }
    }
}
