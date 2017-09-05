#define EQUAL(x,y) !(x-y)

TEXCOORD0 attribute vec4 texcoord0;
POSITION attribute vec4 position;

uniform highp mat4 wvp;
varying mediump vec4 RAWUV0;

void main ()
{
	gl_Position = (wvp * position);
	RAWUV0 = texcoord0;
}

