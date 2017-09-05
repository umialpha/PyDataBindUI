#ifndef FOG_TYPE_NONE
 #define FOG_TYPE_NONE 0
#endif

#ifndef FOG_TYPE_LINEAR
 #define FOG_TYPE_LINEAR 1
#endif

#ifndef FOG_TYPE_HEIGHT
 #define FOG_TYPE_HEIGHT 2
#endif

#ifndef FOG_TYPE
 #define FOG_TYPE FOG_TYPE_NONE
#endif

#ifndef TEX_COUNT_1
 #define TEX_COUNT_1 0
#endif

#ifndef TEX_COUNT_2
 #define TEX_COUNT_2 1
#endif

#ifndef TEX_COUNT
 #define TEX_COUNT TEX_COUNT_1
#endif

#if FOG_TYPE == FOG_TYPE_LINEAR || 1
void get_fog_linear(const highp float fog_begin,const highp float fog_end,const highp float wvp_z,const highp mat4 proj,out highp float fog_factor);
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT
void get_fog_height(const highp float fog_begin,const highp float fog_end,const highp float wvp_z,const highp float fog_height_begin,const highp float fog_height_end,const highp float view_y,const highp mat4 proj,out highp float fog_factor);
#endif
#if FOG_TYPE == FOG_TYPE_LINEAR || 1
void get_fog_linear(const highp float fog_begin,const highp float fog_end,const highp float wvp_z,const highp mat4 proj,out highp float fog_factor)
{
const float local_0 = 0.00;
const float local_1 = 1.00;
vec4 local_2 = vec4(local_0, local_0, fog_end, local_1);
vec4 local_3 = proj * local_2;
vec2 local_4 = local_3.xy;
float local_5 = local_3.z;
float local_6 = local_3.w;
vec4 local_7 = vec4(local_0, local_0, fog_begin, local_1);
vec4 local_8 = proj * local_7;
vec2 local_9 = local_8.xy;
float local_10 = local_8.z;
float local_11 = local_8.w;
float local_12 = smoothstep(local_10, local_5, wvp_z);
float local_13 = clamp(local_12, 0.0, 1.0);
fog_factor = local_13;
}
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT
void get_fog_height(const highp float fog_begin,const highp float fog_end,const highp float wvp_z,const highp float fog_height_begin,const highp float fog_height_end,const highp float view_y,const highp mat4 proj,out highp float fog_factor)
{
float local_0 = fog_height_end - fog_height_begin;
float local_1 = view_y - fog_height_begin;
float local_2 = local_1 / local_0;
float local_3 = clamp(local_2, 0.0, 1.0);
highp float local_4;
get_fog_linear(fog_begin,fog_end,wvp_z,proj,local_4);
float local_5 = max(local_4, local_3);
fog_factor = local_5;
}
#endif
uniform highp mat4 WorldViewProjection;
uniform highp mat4 TexTransform0;
#if FOG_TYPE == FOG_TYPE_LINEAR || FOG_TYPE == FOG_TYPE_HEIGHT
uniform highp mat4 Projection;
#endif
#if FOG_TYPE == FOG_TYPE_LINEAR || FOG_TYPE == FOG_TYPE_HEIGHT
uniform vec4 FogInfo;
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT
uniform highp mat4 World;
#endif
POSITION attribute vec4 position;
COLOR0 attribute vec4 diffuse;
TEXCOORD0 attribute vec4 texcoord0;
#if TEX_COUNT == TEX_COUNT_2
COLOR1 attribute vec4 specular;
#endif
#if TEX_COUNT == TEX_COUNT_2
TEXCOORD1 attribute vec4 texcoord1;
#endif
varying lowp vec4 v_diffuse;
#if TEX_COUNT == TEX_COUNT_2
varying lowp vec4 v_specular;
#endif
varying mediump vec4 v_texture0;
#if TEX_COUNT == TEX_COUNT_2
varying mediump vec4 v_texture1;
#endif
void vs_main()
{
vec4 local_0 = WorldViewProjection * position;
float local_1;
#if FOG_TYPE==FOG_TYPE_NONE
const float local_2 = 0.00;
local_1 = local_2;
#elif FOG_TYPE==FOG_TYPE_LINEAR
float local_3 = FogInfo.x;
float local_4 = FogInfo.y;
vec2 local_5 = FogInfo.zw;
const int local_6 = 2;
float local_7 = local_0[local_6];
highp float local_8;
get_fog_linear(local_3,local_4,local_7,Projection,local_8);
local_1 = local_8;
#elif FOG_TYPE==FOG_TYPE_HEIGHT
const int local_9 = 1;
vec4 local_10 = World * position;
float local_11 = local_10[local_9];
float local_12 = FogInfo.x;
float local_13 = FogInfo.y;
float local_14 = FogInfo.z;
float local_15 = FogInfo.w;
const int local_16 = 2;
float local_17 = local_0[local_16];
highp float local_18;
get_fog_height(local_12,local_13,local_17,local_14,local_15,local_11,Projection,local_18);
local_1 = local_18;
#endif
vec2 local_19 = vec2(texcoord0.x, texcoord0.y);
const vec2 local_20 = vec2(1.0, 0.0);
vec4 local_21 = vec4(local_19.x, local_19.y, local_20.x, local_20.y);
vec4 local_22 = TexTransform0 * local_21;
vec3 local_23 = vec3(local_22.x, local_22.y, local_22.z);
vec4 local_24 = vec4(local_23.x, local_23.y, local_23.z, local_1);
#if TEX_COUNT==TEX_COUNT_1
#elif TEX_COUNT==TEX_COUNT_2
v_texture1 = texcoord1;
v_specular = specular;
#endif
v_diffuse = diffuse;
gl_Position = local_0;
v_texture0 = local_24;
}
