TEXCOORD0 attribute vec4 texcoord0;
COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;
uniform highp mat4 wvp;
uniform highp mat4 texTrans0;
varying mediump vec4 UV0;
varying lowp vec4 Color;
void main ()
{
	gl_Position = (wvp * position);
	Color = diffuse;
	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
	UV0 = texTrans0 * texc;
    
}