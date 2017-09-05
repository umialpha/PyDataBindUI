#define EQUAL(x,y) !(x-y)

TEXCOORD0 attribute vec4 texcoord0;
COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;

uniform highp mat4 wvp;
uniform highp mat4 texTrans0;

varying mediump vec4 UV0;

void main ()
{
	vec4 pos = position;
	vec4 nor = vec4(0);

	gl_Position = (wvp * pos);
	UV0 = texcoord0;
}

