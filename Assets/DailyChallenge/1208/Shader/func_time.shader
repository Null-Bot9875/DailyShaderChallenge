Shader "Unlit/func_time"
{
    // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
    /*
        Name	              Type	        Value
        _Time	              float4	    Time since level load (t/20, t, t*2, t*3), use to animate things inside the shaders.
        _SinTime	          float4	    Sine of time: (t/8, t/4, t/2, t).
        _CosTime	          float4	    Cosine of time: (t/8, t/4, t/2, t).
        unity_DeltaTime	      float4	    Delta time: (dt, 1/dt, smoothDt, 1/smoothDt).
    */
    Properties
    {
        _Skin01 ("Skin 01",2D) = "white" {}
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                
                float2 uv_skin01 : TEXCOORD0;
            };

            sampler2D _Skin01;
            float4 _Skin01_ST;


            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_skin01 = TRANSFORM_TEX(v.uv_skin01, _Skin01);

                return o;
            }

            //如果我们为_Skin[n]的每个属性指定两个不同的纹理，则在这每种情况下，每个纹理都会有0.5f的透明度，最终混合在一起。
            fixed4 frag (v2f i) : SV_Target
            {
                // 简单的uv动画
                /*
                i.uv_skin01.x += _Time.y;
                float4 skin01 = tex2D(_Skin01, i.uv_skin01);
                return skin01;
                */

                // return fixed4(_SinTime.w, _CosTime.w, _Time.w, 1);

                i.uv_skin01.x += _SinTime.w;
                i.uv_skin01.y += _CosTime.w;

                float4 skin01 = tex2D(_Skin01, i.uv_skin01);
                return skin01;
            }
            ENDCG
        }
    }
}
