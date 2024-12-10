Shader "Unlit/func_specular_reflection"
{

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpecularTex ("Specular Texture", 2D) = "black" {}
        _SpecularInt ("Specular Intensity", Range(0, 1)) = 1
        _SpecularPower ("Specular Power", Range(0, 128)) = 64
    }
    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque" 
            "LightMode" = "ForwardBase" 
        }
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

            sampler2D _SpecularTex;
            // float4 _SpecularTex_ST; // 连接变量末尾的“_ST”为纹理加上了平铺和偏移，而一般来说，高光贴图 _SpecularTex 不需要这两种变换。
            float _SpecularInt;
            float _SpecularPower;
            float4 _LightColor0;

            float3 SpecularShading
            (
                float3 colorRefl,// 反射颜色
                float specularInt ,// 镜面反射强度
                float3 normal,// 法线
                float3 lightDir,// 光线方向
                float3 viewDir,// 视线方向
                float specularPower// 镜面反射强度
            )
            {
                // 半程向量 :https://geodoer.github.io/A-%E8%AE%A1%E7%AE%97%E6%9C%BA%E5%9B%BE%E5%BD%A2%E5%AD%A6/2-%E6%B8%B2%E6%9F%93%E6%A6%82%E8%BF%B0/%E6%A6%82%E5%BF%B5/%E5%8D%8A%E7%A8%8B%E5%90%91%E9%87%8F/
                /*
                半程向量(Halfway Vector)，即光线与视线夹角一半方向上的一个单位向量（如图中的 H ）。

                当半程向量与法线向量越接近时，镜面光分量就越大
                当视线正好与反射向量对齐时，半程向量就会与法线完美契合。所以当观察者视线越接近于原本反射光线的方向时，镜面高光就会越强。
                */                
                float3 h = normalize(lightDir + viewDir); // 半程向量
                return colorRefl * specularInt * pow(max(0, dot(normal, h)), specularPower);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal_world = normalize(UnityObjectToWorldNormal(v.normal));
                // unity_ObjectToWorld 当前模型矩阵
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 normal = i.normal_world;
                fixed3 colRefl = _LightColor0.rgb;
                fixed3 specCol = tex2D(_SpecularTex, i.uv) * colRefl;

                half3 specular = SpecularShading(specCol,_SpecularInt,normal,lightDir,viewDir,_SpecularPower);
                col.rgb += specular;
                return col;

                // return fixed4(_SpecularInt ,_SpecularInt ,_SpecularInt ,1);
            }
            ENDCG
        }
    }
}
