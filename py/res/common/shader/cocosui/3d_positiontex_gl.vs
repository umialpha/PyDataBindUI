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

varying vec2 TextureCoordOut;

void main(void)
{
    gl_Position = CC_MVPMatrix * position;
    TextureCoordOut = texcoord0;
    TextureCoordOut.y = 1.0 - TextureCoordOut.y;
}
