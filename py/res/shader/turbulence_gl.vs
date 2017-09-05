#ifndef GPU_SKIN_ENABLE
#define GPU_SKIN_ENABLE FALSE
#endif

#include "shaderlib/skin_gl.vs"

TEXCOORD2 attribute vec4 texcoord2;
TEXCOORD1 attribute vec4 texcoord1;
TEXCOORD0 attribute vec4 texcoord0;
COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;

uniform highp mat4 wvp;
uniform highp mat4 texTrans0;

varying mediump vec4 UV0;
varying mediump vec4 UV1;
varying mediump vec4 UV2;
varying lowp vec4 Color;

uniform highp float time;

uniform mediump vec3 vx_vy_scale1;
uniform mediump vec3 vx_vy_scale2;

void VS_OneTex()
{
	vec4 pos = position;
	vec4 nor = vec4(0);
#if GPU_SKIN_ENABLE
    GetSkin(blendWeights, blendIndices, pos, nor);
#endif
	gl_Position = (wvp * pos);
	Color = diffuse;
	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
	UV0 = texTrans0 * texc;
	UV1.xy = texcoord0.xy * vx_vy_scale1.z + vx_vy_scale1.xy * time;
	UV2.xy = texcoord0.xy * vx_vy_scale2.z + vx_vy_scale2.xy * time;
}