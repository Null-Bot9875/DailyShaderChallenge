Shader "Unlit/func_ambient_color"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //让我们从在着色器中创建一个用于增加或减少环境光总量的范围（range）开始。让我们将范围设置成 0 ~ 1，其中 0 代表环境光为 0%；1 表示环境光为 100%。这样，我们就可以动态更改环境光的值。
        _Ambient ("Ambient Color", Range(0, 1)) = 1
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

            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // 因为环境光是高精度，所以我们需要将其转换成 float3 类型。 
                float3 ambientColor = _Ambient * UNITY_LIGHTMODEL_AMBIENT.rgb;
                col.rgb += ambientColor;
                return col;
            }
            ENDCG
        }
    }
}
