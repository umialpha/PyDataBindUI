#include "shaderlib/skin_gl.vs"

POSITION attribute vec4 position;
TEXCOORD0 attribute vec4 texcoord0;

uniform highp mat4 wvp;
varying  vec2 uv;
uniform highp mat4 SprTrans;
void main_VS()
{
	vec4 pos = position;
	vec4 nor = vec4(0);
#if GPU_SKIN_ENABLE
    GetSkin(blendWeights, blendIndices, pos, nor);
#endif
 	gl_Position =  wvp * pos;	
	mediump vec4 texc = vec4(texcoord0.xy, 1.0, 0.0);
	uv = (SprTrans * texc).xy;
}