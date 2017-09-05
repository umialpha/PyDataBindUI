#include <metal_graphics>
#include <metal_texture>
#include <metal_matrix>
#include <metal_common>
using namespace metal;
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
static void get_fog_linear(const float fog_begin,const float fog_end,const float wvp_z,const float4x4 proj,thread float& fog_factor);
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT
static void get_fog_height(const float fog_begin,const float fog_end,const float wvp_z,const float fog_height_begin,const float fog_height_end,const float view_y,const float4x4 proj,thread float& fog_factor);
#endif
#if FOG_TYPE == FOG_TYPE_LINEAR || 1
static void get_fog_linear(const float fog_begin,const float fog_end,const float wvp_z,const float4x4 proj,thread float& fog_factor)
{
const float local_0 = 0.00f;
const float local_1 = 1.00f;
float4 local_2 = {local_0, local_0, fog_end, local_1};
float4 local_3 = proj * local_2;
float2 local_4 = local_3.xy;
float local_5 = local_3.z;
float local_6 = local_3.w;
float4 local_7 = {local_0, local_0, fog_begin, local_1};
float4 local_8 = proj * local_7;
float2 local_9 = local_8.xy;
float local_10 = local_8.z;
float local_11 = local_8.w;
float local_12 = smoothstep(local_10, local_5, wvp_z);
float local_13 = saturate(local_12);
fog_factor = local_13;
}
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT
static void get_fog_height(const float fog_begin,const float fog_end,const float wvp_z,const float fog_height_begin,const float fog_height_end,const float view_y,const float4x4 proj,thread float& fog_factor)
{
float local_0 = fog_height_end - fog_height_begin;
float local_1 = view_y - fog_height_begin;
float local_2 = local_1 / local_0;
float local_3 = saturate(local_2);
float local_4;
get_fog_linear(fog_begin,fog_end,wvp_z,proj,local_4);
float local_5 = max(local_4, local_3);
fog_factor = local_5;
}
#endif
struct VSConstants
{
float4x4 WorldViewProjection;
float4x4 TexTransform0;
#if FOG_TYPE == FOG_TYPE_LINEAR || FOG_TYPE == FOG_TYPE_HEIGHT
float4x4 Projection;
#endif
#if FOG_TYPE == FOG_TYPE_LINEAR || FOG_TYPE == FOG_TYPE_HEIGHT
float4 FogInfo;
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT
float4x4 World;
#endif
};
struct VS_INPUT
{
float4 a_position [[attribute(POSITION)]];
float4 a_diffuse [[attribute(DIFFUSE)]];
float4 a_texture0 [[attribute(TEXTURE0)]];
#if TEX_COUNT == TEX_COUNT_2
float4 a_specular [[attribute(SPECULAR)]];
#endif
#if TEX_COUNT == TEX_COUNT_2
float4 a_texture1 [[attribute(TEXTURE1)]];
#endif
};
struct PS_INPUT
{
float4 final_position [[position]];
float4 v_diffuse;
#if TEX_COUNT == TEX_COUNT_2
float4 v_specular;
#endif
float4 v_texture0;
#if TEX_COUNT == TEX_COUNT_2
float4 v_texture1;
#endif
};
vertex PS_INPUT vs_main(
#ifndef NEOX_METAL_NO_ATTR
VS_INPUT vsIN[[stage_in]],
#endif
constant VSConstants &constants[[buffer(0)]])
{
PS_INPUT psIN;
#ifndef NEOX_METAL_NO_ATTR
float4 local_0 = constants.WorldViewProjection * vsIN.a_position;
float local_1;
#if FOG_TYPE==FOG_TYPE_NONE
const float local_2 = 0.00f;
local_1 = local_2;
#elif FOG_TYPE==FOG_TYPE_LINEAR
float local_3 = constants.FogInfo.x;
float local_4 = constants.FogInfo.y;
float2 local_5 = constants.FogInfo.zw;
const uint local_6 = 2;
float local_7 = local_0[local_6];
float local_8;
get_fog_linear(local_3,local_4,local_7,constants.Projection,local_8);
local_1 = local_8;
#elif FOG_TYPE==FOG_TYPE_HEIGHT
const uint local_9 = 1;
float4 local_10 = constants.World * vsIN.a_position;
float local_11 = local_10[local_9];
float local_12 = constants.FogInfo.x;
float local_13 = constants.FogInfo.y;
float local_14 = constants.FogInfo.z;
float local_15 = constants.FogInfo.w;
const uint local_16 = 2;
float local_17 = local_0[local_16];
float local_18;
get_fog_height(local_12,local_13,local_17,local_14,local_15,local_11,constants.Projection,local_18);
local_1 = local_18;
#endif
float2 local_19 = {vsIN.a_texture0.x, vsIN.a_texture0.y};
const float2 local_20 = {1.0f, 0.0f};
float4 local_21 = {local_19.x, local_19.y, local_20.x, local_20.y};
float4 local_22 = constants.TexTransform0 * local_21;
float3 local_23 = {local_22.x, local_22.y, local_22.z};
float4 local_24 = {local_23.x, local_23.y, local_23.z, local_1};
#if TEX_COUNT==TEX_COUNT_1
#elif TEX_COUNT==TEX_COUNT_2
psIN.v_texture1 = vsIN.a_texture1;
psIN.v_specular = vsIN.a_specular;
#endif
psIN.v_diffuse = vsIN.a_diffuse;
psIN.final_position = local_0;
psIN.v_texture0 = local_24;
#endif
return psIN;
}
