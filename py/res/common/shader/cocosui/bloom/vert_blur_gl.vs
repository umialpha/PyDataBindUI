precision mediump float;

POSITION attribute vec4 position;

uniform float u_invPixelHeight;
uniform float u_bloomScale;

varying vec2 v_texCoord0;
varying vec2 v_texCoord1;
varying vec2 v_texCoord2;
varying vec2 v_texCoord3;
varying vec2 v_texCoord4;

void main()
{
    gl_Position = position;

    vec2 uv = (position.xy + 1.0) * 0.5;
    v_texCoord0 = uv;
    v_texCoord1 = uv + vec2(0.0, -0.0026) * u_bloomScale;
    v_texCoord2 = uv + vec2(0.0, 0.0026) * u_bloomScale;
    v_texCoord3 = uv + vec2(0.0, -0.0053) * u_bloomScale;
    v_texCoord4 = uv + vec2(0.0, 0.0053) * u_bloomScale;
}
