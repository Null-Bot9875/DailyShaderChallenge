Shader "Unlit/func_light"
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                /*
                    为什么我们需要同时在顶点输入和顶点输出中声明法线呢？
                    因为我们不仅要连接属性与顶点着色器，还要将法线传入片元着色器。
                    根据 HLSL 官方文档，片元着色器阶段并没有 NORMAL 语义，因此我们得用一个能够存储至少三维的向量的语义，这就是为什么我们在上面的代码中选择使用 TEXCOORD1。
                    这个语义有四个维度（XYZW），是存储法线信息的理想载体。
                */
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            void unity_light(in float3 noramls, out float3 Out)
            {
                // Out = [Op] (noramls);
                Out = noramls;
            }

            half3 normalWorld (half3 normal) 
            { 
                return normalize(mul(unity_ObjectToWorld, float4(normal, 0))).xyz;
            } 


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                // UNITY_TRANSFER_FOG(o,o.vertex);

                //上述坐标空间转换的过程也可以在顶点着色器阶段进行，操作方法基本相同。但如果我们在顶点着色器中进行该操作的话可以优化程序，因为法线是按顶点而不是按像素计算的。
                // 因此，我们可以在顶点着色器中计算法线，然后将其传递到片元着色器阶段。这样可以减少计算量，提高性能。

                o.normal = normalWorld(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // return col;

                // 光照计算必须在世界空间中进行，因为入射光是在世界空间中的。同样的，场景中的物体的位置是根据网格中心确定的，因此我们必须在片元着色器阶段将法线的坐标空间变换到世界空间。
                // half3 noramls = normalWorld(i.normal);
                half3 noramls = i.normal;
                half3 light = 0;
                unity_light(noramls, light);
                return float4(light.rgb, 1.0);
                
            }
            ENDCG
        }
    }
}
