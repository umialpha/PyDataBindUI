precision mediump float;

POSITION attribute vec4 position;
COLOR0 attribute vec4 diffuse;
TEXCOORD0 attribute vec2 texCoord;

uniform float u_invPixelWidth;
uniform float u_bloomScale;

varying vec2 v_texCoord0;
varying vec2 v_texCoord1;
varying vec2 v_texCoord2;
varying vec2 v_texCoord3;
varying vec2 v_texCoord4;

void main()
{
    gl_Position =  position;

    vec2 uv = (position.xy + 1.0) * 0.5;
    v_texCoord0 = uv;
    v_texCoord1 = uv + vec2(-0.0026, 0.0) * u_bloomScale;
    v_texCoord2 = uv + vec2(0.0026, 0.0) * u_bloomScale;
    v_texCoord3 = uv + vec2(-0.0053, 0.0) * u_bloomScale;
    v_texCoord4 = uv + vec2(0.0053, 0.0) * u_bloomScale;
}
