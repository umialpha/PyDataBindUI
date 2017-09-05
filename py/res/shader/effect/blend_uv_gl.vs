#ifndef MASK_ENABLE
#define MASK_ENABLE 0
#endif

TEXCOORD2 attribute vec4 texcoord2;
TEXCOORD1 attribute vec4 texcoord1;
TEXCOORD0 attribute vec4 texcoord0;
COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;

uniform highp mat4 wvp;
uniform highp mat4 texTrans0;

varying mediump vec4 UV0;
#if MASK_ENABLE
varying mediump vec4 UV1;
#endif
varying lowp vec4 Color;

uniform highp float time;

uniform mediump vec3 vx_vy_scale1;
uniform mediump vec3 vx_vy_scale2;

uniform mediump float scale_x;
uniform mediump float scale_y;
uniform mediump float offset_x;
uniform mediump float offset_y;

void VS_OneTex()
{
	gl_Position = (wvp * position);
	Color = diffuse;
	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
	UV0 = texTrans0 * texc;
#if MASK_ENABLE
	UV1 = texc;
#endif
	UV0.xy += vec2(offset_x, offset_y);
	UV0.xy *= vec2(scale_x, scale_y);
}