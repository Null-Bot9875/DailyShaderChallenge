Shader "Unlit/func_floor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // 用于多个分割
        [IntRange] _Sections ("Sections", Range(2, 10)) = 5
        // 增加输出的颜色
        _Gamma ("Gamma", Range(0, 1)) = 0
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

            float _Sections;
            float _Gamma;

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

                // float fv = floor(i.uv.y * _Sections) * (_Sections/ 100);
                float fv = floor(i.uv.y * _Sections) * (1/_Sections);
                // float fv = floor(i.uv.y*_Sections);
                // float4 col = tex2D(_MainTex, i.uv);
                // return col;

                return float4(fv, fv, fv, 1) + _Gamma;
            }
            ENDCG
        }
    }
}
