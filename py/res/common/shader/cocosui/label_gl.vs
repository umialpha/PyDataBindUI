precision highp float;

uniform mat4 CC_PMatrix;
uniform mat4 CC_MVMatrix;
uniform mat4 CC_MVPMatrix;
uniform vec4 CC_Time;
uniform vec4 CC_SinTime;
uniform vec4 CC_CosTime;
uniform vec4 CC_Random01;
uniform sampler2D CC_Texture0;
uniform sampler2D CC_Texture1;
uniform sampler2D CC_Texture2;
uniform sampler2D CC_Texture3;


POSITION attribute vec4 position;
TEXCOORD0 attribute vec2 texcoord0;
COLOR0 attribute vec4 diffuse;

#ifdef GL_ES

varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
#else

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
#endif


void main()
{
    gl_Position = CC_MVPMatrix * position;
    v_fragmentColor = diffuse;
    v_texCoord = texcoord0;
}
