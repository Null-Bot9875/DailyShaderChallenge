/*

在继续定义一些函数之前，让我们简单了解一下标准表面着色器（Standard Surface shader）的结构。与无光照着色器不同的是，其特点是结构简化，仅在内置渲染管线（Built-in RP）中与光照互动。

在前面几个小节中所编写的反射函数均已包含在标准表面着色器的程序内部，这意味着该着色器在默认情况下具有全局照明、漫反射、反射和菲涅尔反射的功能。


struct SurfaceOutputStandard
{
    fixed3 Albedo;      // 基础（漫射或镜面反射）颜色
    fixed3 Normal;      // 切线空间法线（如果已写入）
    half3 Emission;
    half Metallic;      // 0=非金属，1=金属
    half Smoothness;    // 0=粗糙，1=平滑
    half Occlusion;     // 遮挡（默认为 1）
    fixed Alpha;        // 透明度 Alpha
};

*/

// 默认有很多照明效果
Shader "Custom/func_standard_surface"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="UniversalForward" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
