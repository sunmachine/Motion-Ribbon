Shader "Custom Mobile/Motion Ribbon (Unlit Transparent)" {

    // OpenGL ES 2.0 Compatible shader, used to
    // animate UVs in a not-so-usual way.

    // Default Material Properties
    Properties {
        [NoScaleOffset] _MainTex ("Texture (RGBA)", 2D) = "white" {}
        [NoScaleOffset] _MotionPathTex ("Path Mask (RG)", 2D) = "black" {}
    }

    SubShader {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
        }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            CGPROGRAM
            #pragma exclude_renderers xbox360 xboxone ps3 ps4 psp2 n3ds wiiu
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }

    Fallback "Unlit/Texture"


    CGINCLUDE
    #include "UnityCG.cginc"

    uniform sampler2D _MainTex;
	uniform sampler2D _MotionPathTex;

    struct vertexInput {
        float4 vertex : POSITION;
        float4 texcoord : TEXCOORD0;
    };

    struct vertexOutput {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };


    vertexOutput vert(vertexInput v) {
        vertexOutput o;

		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

        // Normally I utilize TRANSFORM_TEX, but the CustomEditor
        // will remove the ability to adjust tiling. The tex_ST
        // has been moved to the motion path LUT's control.
        o.uv = v.texcoord.xy;

        return o;
    }


    fixed4 frag(vertexOutput i) : SV_Target {

        // A simple example of using color channels to
        // drive the motion direction of
        half4 motionSample = tex2D(_MotionPathTex, i.uv);
        motionSample.y += _Time.y;

        fixed4 mainTex = tex2D(_MainTex, motionSample);

        mainTex.a = motionSample.a;

        return mainTex;
    }
    ENDCG
}
