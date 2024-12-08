Shader "Unlit/func_lerp"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        _Skin01 ("Skin 01",2D) = "white" {}
        _Skin02 ("Skin 02",2D) = "white" {}
        _Lerp ("Lerp", Range(0, 1)) = 0.5
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
            // #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;

                float2 uv_skin01 : TEXCOORD0;
                float2 uv_skin02 : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                
                float2 uv_skin01 : TEXCOORD0;
                float2 uv_skin02 : TEXCOORD1;
            };

            sampler2D _Skin01;
            float4 _Skin01_ST;

            sampler2D _Skin02;
            float4 _Skin02_ST;

            float _Lerp;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv_skin01 = TRANSFORM_TEX(v.uv_skin01, _Skin01);
                o.uv_skin02 = TRANSFORM_TEX(v.uv_skin02, _Skin02);

                return o;
            }

            //如果我们为_Skin[n]的每个属性指定两个不同的纹理，则在这每种情况下，每个纹理都会有0.5f的透明度，最终混合在一起。
            fixed4 frag (v2f i) : SV_Target
            {
                float4 skin01 = tex2D(_Skin01, i.uv_skin01);
                float4 skin02 = tex2D(_Skin02, i.uv_skin02);

                fixed4 col = lerp(skin01, skin02, _Lerp);
                return col;
            }
            ENDCG
        }
    }
}
