// 菲涅尔（Fresnel）效应（由奥古斯丁-让·菲涅耳发现）也被称为边缘效应（Rim effect），是一种反射，其大小与物体法线与相机方向的夹角成正比。
// 模型表面距离相机越远，菲涅尔反射就越多，因为入射方向（相机）与物体法线之间的角度越大。
Shader "Unlit/func_fresnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FresnelPower ("Fresnel Power", Range(0, 10)) = 1
        _FresnelIntensity ("Fresnel Intensity", Range(0, 1)) = 1
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
                float2 uv : TEXCOORD0;

                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            float3 FresnelEffect(float3 normal, float3 viewDir, float power)
            {
                return pow(1 - saturate(dot(normal, viewDir)), power);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _FresnelPower;
            float _FresnelIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);

                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
                float3 fresnel = FresnelEffect(i.normal_world, viewDir, _FresnelPower) * _FresnelIntensity;
                return fixed4(fresnel,1);
                // col.rgb += fresnel;
                // return col;
            }
            ENDCG
        }
    }
}
