POSITION attribute vec4 position;
TEXCOORD0 attribute vec4 texcoord0;

varying mediump vec2 TexCoord0;
varying mediump vec2 TexCoord1;
varying mediump vec2 TexCoord2;

uniform vec4 dynamicRT;


void VSMain()
{
	gl_Position = position;
	TexCoord0 = texcoord0.xy;
	TexCoord0.x = dynamicRT.z * TexCoord0.x;
	TexCoord0.y = dynamicRT.w * (TexCoord0.y - 1.0) + 1.0;
}