#include <metal_graphics>
#include <metal_texture>
#include <metal_matrix>
#include <metal_common>
using namespace metal;
#ifndef LIGHT_MAP_ENABLE
 #define LIGHT_MAP_ENABLE 0
#endif

#ifndef LIT_ENABLE
 #define LIT_ENABLE 0
#endif

#ifndef GPU_SKIN_ENABLE
 #define GPU_SKIN_ENABLE 0
#endif

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
 #define FOG_TYPE FOG_TYPE_LINEAR
#endif

#ifndef MAX_BONES
 #define MAX_BONES 90
#endif

#ifndef SKIN_VEC_PER_BONE_QUAT
 #define SKIN_VEC_PER_BONE_QUAT 2
#endif

#ifndef SKIN_VEC_PER_BONE_MAT
 #define SKIN_VEC_PER_BONE_MAT 4
#endif

#ifndef SKIN_VEC_PER_BONE
 #define SKIN_VEC_PER_BONE SKIN_VEC_PER_BONE_QUAT
#endif

#ifndef BONE_VEC_COUNT
 #define BONE_VEC_COUNT MAX_BONES*SKIN_VEC_PER_BONE_QUAT
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_1
 #define LIGHT_ATTR_ITEM_NUM_1 1
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_2
 #define LIGHT_ATTR_ITEM_NUM_2 2
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_3
 #define LIGHT_ATTR_ITEM_NUM_3 3
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_4
 #define LIGHT_ATTR_ITEM_NUM_4 4
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_5
 #define LIGHT_ATTR_ITEM_NUM_5 5
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_6
 #define LIGHT_ATTR_ITEM_NUM_6 6
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_7
 #define LIGHT_ATTR_ITEM_NUM_7 7
#endif

#ifndef LIGHT_ATTR_ITEM_NUM_8
 #define LIGHT_ATTR_ITEM_NUM_8 8
#endif

#ifndef LIGHT_ATTR_ITEM_NUM
 #define LIGHT_ATTR_ITEM_NUM LIGHT_ATTR_ITEM_NUM_5
#endif

#ifndef SHADOW_MAP_ENABLE
 #define SHADOW_MAP_ENABLE 0
#endif

#ifndef SHADOW_MAP_ESM
 #define SHADOW_MAP_ESM 0
#endif

#ifndef SYSTEM_UV_ORIGIN_LEFT_BOTTOM
 #define SYSTEM_UV_ORIGIN_LEFT_BOTTOM 0
#endif

#if GPU_SKIN_ENABLE
static void get_skin_pos_normal(const float4 bone_weight,const uint4 bone_index,const float4 pos,const float4 norm,const constant float4* bone_vec,thread float4& position_out,thread float4& normal_out);
#endif
#if FOG_TYPE == FOG_TYPE_LINEAR || 1
static void get_fog_linear(const float fog_begin,const float fog_end,const float wvp_z,const float4x4 proj,thread float& fog_factor);
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT
static void get_fog_height(const float fog_begin,const float fog_end,const float wvp_z,const float fog_height_begin,const float fog_height_end,const float view_y,const float4x4 proj,thread float& fog_factor);
#endif
#if LIT_ENABLE
static void shadow_light_lit(const float4 light_diffuse_type,const float4 light_attr,const float4 light_attr_custom,const float3 position,const float3 normal_dir,thread float3& lit);
#endif
#if (LIT_ENABLE && SHADOW_MAP_ENABLE)
static void calc_shadow_info(const float4 pos_world,const float3 normal_world,const float4x4 light_view_proj,const float3 light_dir,thread float2& uv_out,thread float& depth_out,thread float& factor_out);
#endif
#if SKIN_VEC_PER_BONE == SKIN_VEC_PER_BONE_QUAT || SKIN_VEC_PER_BONE == SKIN_VEC_PER_BONE_QUAT
static void quat_rot_vec3(const float4 quat,const float3 v,thread float3& result);
#endif
#if GPU_SKIN_ENABLE
static void get_skin_pos_normal(const float4 bone_weight,const uint4 bone_index,const float4 pos,const float4 norm,const constant float4* bone_vec,thread float4& position_out,thread float4& normal_out)
{
const float3 local_0 = {0.0f, 0.0f, 0.0f};
float3 local_1 = local_0;
float3 local_2 = local_0;
int local_3;
local_3 = 0;
float local_4 = bone_weight[local_3];
const int local_5 = 0;
uint local_6 = bone_index[local_5];
uint local_7 = bone_index[local_3];
float3 local_8;
float3 local_9;
if (local_7 < MAX_BONES)
{
float3 local_10;
float3 local_11;
#if SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_QUAT
float3 local_12 = {norm.x, norm.y, norm.z};
const uint local_13 = SKIN_VEC_PER_BONE_QUAT;
uint local_14 = local_7 * local_13;
float4 local_15 = bone_vec[local_14];
uint local_16 = local_6 * local_13;
float4 local_17 = bone_vec[local_16];
float local_18 = dot(local_15, local_17);
float local_19 = sign(local_18);
float4 local_20 = local_15 * local_19;
float3 local_21;
quat_rot_vec3(local_20,local_12,local_21);
float3 local_22 = local_4 * local_21;
const uint local_23 = 1;
uint local_24 = local_14 + local_23;
float4 local_25 = bone_vec[local_24];
float3 local_26 = local_25.xyz;
float local_27 = local_25.w;
float3 local_28 = {pos.x, pos.y, pos.z};
float3 local_29 = local_27 * local_28;
float3 local_30;
quat_rot_vec3(local_20,local_29,local_30);
float3 local_31 = local_26 + local_30;
float3 local_32 = local_4 * local_31;
local_10 = local_32;
local_11 = local_22;
#elif SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_MAT
const float local_33 = 0.00f;
float3 local_34 = norm.xyz;
float local_35 = norm.w;
float4 local_36 = {local_34.x, local_34.y, local_34.z, local_33};
const uint local_37 = SKIN_VEC_PER_BONE_MAT;
const uint local_38 = 1;
uint local_39 = local_37 * local_7;
uint local_40 = local_38 + local_39;
uint local_41 = local_40 + local_38;
float4 local_42 = bone_vec[local_41];
float local_43 = dot(local_36, local_42);
float4 local_44 = bone_vec[local_40];
float local_45 = dot(local_36, local_44);
float4 local_46 = bone_vec[local_39];
float local_47 = dot(local_36, local_46);
float3 local_48 = {local_47, local_45, local_43};
float3 local_49 = local_4 * local_48;
float local_50 = dot(pos, local_42);
float local_51 = dot(pos, local_44);
float local_52 = dot(pos, local_46);
float3 local_53 = {local_52, local_51, local_50};
float3 local_54 = local_4 * local_53;
local_10 = local_54;
local_11 = local_49;
#endif
local_8 = local_10;
local_9 = local_11;
}
else
{
const float3 local_55 = {0.0f, 0.0f, 0.0f};
local_8 = local_55;
local_9 = local_55;
}
local_1 += local_8;
local_2 += local_9;
local_3 = 1;
float local_56 = bone_weight[local_3];
const int local_57 = 0;
uint local_58 = bone_index[local_57];
uint local_59 = bone_index[local_3];
float3 local_60;
float3 local_61;
if (local_59 < MAX_BONES)
{
float3 local_62;
float3 local_63;
#if SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_QUAT
float3 local_64 = {norm.x, norm.y, norm.z};
const uint local_65 = SKIN_VEC_PER_BONE_QUAT;
uint local_66 = local_59 * local_65;
float4 local_67 = bone_vec[local_66];
uint local_68 = local_58 * local_65;
float4 local_69 = bone_vec[local_68];
float local_70 = dot(local_67, local_69);
float local_71 = sign(local_70);
float4 local_72 = local_67 * local_71;
float3 local_73;
quat_rot_vec3(local_72,local_64,local_73);
float3 local_74 = local_56 * local_73;
const uint local_75 = 1;
uint local_76 = local_66 + local_75;
float4 local_77 = bone_vec[local_76];
float3 local_78 = local_77.xyz;
float local_79 = local_77.w;
float3 local_80 = {pos.x, pos.y, pos.z};
float3 local_81 = local_79 * local_80;
float3 local_82;
quat_rot_vec3(local_72,local_81,local_82);
float3 local_83 = local_78 + local_82;
float3 local_84 = local_56 * local_83;
local_62 = local_84;
local_63 = local_74;
#elif SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_MAT
const float local_85 = 0.00f;
float3 local_86 = norm.xyz;
float local_87 = norm.w;
float4 local_88 = {local_86.x, local_86.y, local_86.z, local_85};
const uint local_89 = SKIN_VEC_PER_BONE_MAT;
const uint local_90 = 1;
uint local_91 = local_89 * local_59;
uint local_92 = local_90 + local_91;
uint local_93 = local_92 + local_90;
float4 local_94 = bone_vec[local_93];
float local_95 = dot(local_88, local_94);
float4 local_96 = bone_vec[local_92];
float local_97 = dot(local_88, local_96);
float4 local_98 = bone_vec[local_91];
float local_99 = dot(local_88, local_98);
float3 local_100 = {local_99, local_97, local_95};
float3 local_101 = local_56 * local_100;
float local_102 = dot(pos, local_94);
float local_103 = dot(pos, local_96);
float local_104 = dot(pos, local_98);
float3 local_105 = {local_104, local_103, local_102};
float3 local_106 = local_56 * local_105;
local_62 = local_106;
local_63 = local_101;
#endif
local_60 = local_62;
local_61 = local_63;
}
else
{
const float3 local_107 = {0.0f, 0.0f, 0.0f};
local_60 = local_107;
local_61 = local_107;
}
local_1 += local_60;
local_2 += local_61;
local_3 = 2;
float local_108 = bone_weight[local_3];
const int local_109 = 0;
uint local_110 = bone_index[local_109];
uint local_111 = bone_index[local_3];
float3 local_112;
float3 local_113;
if (local_111 < MAX_BONES)
{
float3 local_114;
float3 local_115;
#if SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_QUAT
float3 local_116 = {norm.x, norm.y, norm.z};
const uint local_117 = SKIN_VEC_PER_BONE_QUAT;
uint local_118 = local_111 * local_117;
float4 local_119 = bone_vec[local_118];
uint local_120 = local_110 * local_117;
float4 local_121 = bone_vec[local_120];
float local_122 = dot(local_119, local_121);
float local_123 = sign(local_122);
float4 local_124 = local_119 * local_123;
float3 local_125;
quat_rot_vec3(local_124,local_116,local_125);
float3 local_126 = local_108 * local_125;
const uint local_127 = 1;
uint local_128 = local_118 + local_127;
float4 local_129 = bone_vec[local_128];
float3 local_130 = local_129.xyz;
float local_131 = local_129.w;
float3 local_132 = {pos.x, pos.y, pos.z};
float3 local_133 = local_131 * local_132;
float3 local_134;
quat_rot_vec3(local_124,local_133,local_134);
float3 local_135 = local_130 + local_134;
float3 local_136 = local_108 * local_135;
local_114 = local_136;
local_115 = local_126;
#elif SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_MAT
const float local_137 = 0.00f;
float3 local_138 = norm.xyz;
float local_139 = norm.w;
float4 local_140 = {local_138.x, local_138.y, local_138.z, local_137};
const uint local_141 = SKIN_VEC_PER_BONE_MAT;
const uint local_142 = 1;
uint local_143 = local_141 * local_111;
uint local_144 = local_142 + local_143;
uint local_145 = local_144 + local_142;
float4 local_146 = bone_vec[local_145];
float local_147 = dot(local_140, local_146);
float4 local_148 = bone_vec[local_144];
float local_149 = dot(local_140, local_148);
float4 local_150 = bone_vec[local_143];
float local_151 = dot(local_140, local_150);
float3 local_152 = {local_151, local_149, local_147};
float3 local_153 = local_108 * local_152;
float local_154 = dot(pos, local_146);
float local_155 = dot(pos, local_148);
float local_156 = dot(pos, local_150);
float3 local_157 = {local_156, local_155, local_154};
float3 local_158 = local_108 * local_157;
local_114 = local_158;
local_115 = local_153;
#endif
local_112 = local_114;
local_113 = local_115;
}
else
{
const float3 local_159 = {0.0f, 0.0f, 0.0f};
local_112 = local_159;
local_113 = local_159;
}
local_1 += local_112;
local_2 += local_113;
local_3 = 3;
float local_160 = bone_weight[local_3];
const int local_161 = 0;
uint local_162 = bone_index[local_161];
uint local_163 = bone_index[local_3];
float3 local_164;
float3 local_165;
if (local_163 < MAX_BONES)
{
float3 local_166;
float3 local_167;
#if SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_QUAT
float3 local_168 = {norm.x, norm.y, norm.z};
const uint local_169 = SKIN_VEC_PER_BONE_QUAT;
uint local_170 = local_163 * local_169;
float4 local_171 = bone_vec[local_170];
uint local_172 = local_162 * local_169;
float4 local_173 = bone_vec[local_172];
float local_174 = dot(local_171, local_173);
float local_175 = sign(local_174);
float4 local_176 = local_171 * local_175;
float3 local_177;
quat_rot_vec3(local_176,local_168,local_177);
float3 local_178 = local_160 * local_177;
const uint local_179 = 1;
uint local_180 = local_170 + local_179;
float4 local_181 = bone_vec[local_180];
float3 local_182 = local_181.xyz;
float local_183 = local_181.w;
float3 local_184 = {pos.x, pos.y, pos.z};
float3 local_185 = local_183 * local_184;
float3 local_186;
quat_rot_vec3(local_176,local_185,local_186);
float3 local_187 = local_182 + local_186;
float3 local_188 = local_160 * local_187;
local_166 = local_188;
local_167 = local_178;
#elif SKIN_VEC_PER_BONE==SKIN_VEC_PER_BONE_MAT
const float local_189 = 0.00f;
float3 local_190 = norm.xyz;
float local_191 = norm.w;
float4 local_192 = {local_190.x, local_190.y, local_190.z, local_189};
const uint local_193 = SKIN_VEC_PER_BONE_MAT;
const uint local_194 = 1;
uint local_195 = local_193 * local_163;
uint local_196 = local_194 + local_195;
uint local_197 = local_196 + local_194;
float4 local_198 = bone_vec[local_197];
float local_199 = dot(local_192, local_198);
float4 local_200 = bone_vec[local_196];
float local_201 = dot(local_192, local_200);
float4 local_202 = bone_vec[local_195];
float local_203 = dot(local_192, local_202);
float3 local_204 = {local_203, local_201, local_199};
float3 local_205 = local_160 * local_204;
float local_206 = dot(pos, local_198);
float local_207 = dot(pos, local_200);
float local_208 = dot(pos, local_202);
float3 local_209 = {local_208, local_207, local_206};
float3 local_210 = local_160 * local_209;
local_166 = local_210;
local_167 = local_205;
#endif
local_164 = local_166;
local_165 = local_167;
}
else
{
const float3 local_211 = {0.0f, 0.0f, 0.0f};
local_164 = local_211;
local_165 = local_211;
}
local_1 += local_164;
local_2 += local_165;
float4 local_212 = {local_2.x, local_2.y, local_2.z, 0.0f};
float3 local_213 = pos.xyz;
float local_214 = pos.w;
float4 local_215 = {local_1.x, local_1.y, local_1.z, local_214};
position_out = local_215;
normal_out = local_212;
}
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
float4 local_7 = {local_1, local_1, fog_begin, local_0};
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
#if LIT_ENABLE
static void shadow_light_lit(const float4 light_diffuse_type,const float4 light_attr,const float4 light_attr_custom,const float3 position,const float3 normal_dir,thread float3& lit)
{
float3 local_0 = light_diffuse_type.xyz;
float local_1 = light_diffuse_type.w;
int local_2 = static_cast<int>(local_1);
float3 local_3;
float local_4;
if (local_2 == 1)
{
float3 local_5 = light_attr.xyz;
float local_6 = light_attr.w;
float3 local_7 = position - local_5;
float3 local_8 = normalize(local_7);
const float local_9 = 1.00f;
const float local_10 = 2.00f;
float local_11 = light_attr_custom.x;
float local_12 = local_10 / local_11;
float3 local_13 = {local_6, local_6, local_6};
float3 local_14 = local_7 / local_13;
float local_15 = dot(local_14, local_14);
float local_16 = pow(local_15, local_12);
float local_17 = local_9 - local_16;
float local_18 = saturate(local_17);
local_3 = local_8;
local_4 = local_18;
}
else if (local_2 == 3)
{
float3 local_19 = {light_attr.x, light_attr.y, light_attr.z};
const float local_20 = 1.00f;
local_3 = local_19;
local_4 = local_20;
}
else
{
const float local_21 = 1.00f;
const float3 local_22 = {0.0f, 0.0f, 0.0f};
local_3 = local_22;
local_4 = local_21;
}
float3 local_23 = -(local_3);
float local_24 = dot(normal_dir, local_23);
float local_25 = saturate(local_24);
float local_26 = local_4 * local_25;
float3 local_27 = local_0 * local_26;
lit = local_27;
}
#endif
#if (LIT_ENABLE && SHADOW_MAP_ENABLE)
static void calc_shadow_info(const float4 pos_world,const float3 normal_world,const float4x4 light_view_proj,const float3 light_dir,thread float2& uv_out,thread float& depth_out,thread float& factor_out)
{
float2 local_0;
#if SYSTEM_UV_ORIGIN_LEFT_BOTTOM
const float2 local_1 = {0.5f, 0.5f};
local_0 = local_1;
#else
const float2 local_2 = {0.5f, -0.5f};
local_0 = local_2;
#endif
float4 local_3 = light_view_proj * pos_world;
float3 local_4 = local_3.xyz;
float local_5 = local_3.w;
float3 local_6 = {local_5, local_5, local_5};
const float2 local_7 = {0.5f, 0.5f};
float3 local_8 = local_4 / local_6;
float2 local_9 = local_8.xy;
float local_10 = local_8.z;
float2 local_11 = local_9 * local_0;
float2 local_12 = local_7 + local_11;
float3 local_13 = -(normal_world);
float3 local_14 = normalize(light_dir);
float local_15 = dot(local_13, local_14);
float local_16 = saturate(local_15);
uv_out = local_12;
depth_out = local_10;
factor_out = local_16;
}
#endif
#if SKIN_VEC_PER_BONE == SKIN_VEC_PER_BONE_QUAT || SKIN_VEC_PER_BONE == SKIN_VEC_PER_BONE_QUAT
static void quat_rot_vec3(const float4 quat,const float3 v,thread float3& result)
{
const float local_0 = 2.00f;
float3 local_1 = quat.xyz;
float local_2 = quat.w;
float3 local_3 = local_2 * v;
float3 local_4 = cross(local_1, v);
float3 local_5 = local_3 + local_4;
float3 local_6 = cross(local_1, local_5);
float3 local_7 = local_6 * local_0;
float3 local_8 = local_7 + v;
result = local_8;
}
#endif
struct VSConstants
{
float4x4 WorldViewProjection;
float4x4 TexTransform0;
#if LIT_ENABLE
float4 Ambient;
#endif
#if GPU_SKIN_ENABLE
float4 SkinBones[MAX_BONES*SKIN_VEC_PER_BONE_QUAT];
#endif
#if FOG_TYPE == FOG_TYPE_LINEAR || FOG_TYPE == FOG_TYPE_HEIGHT
float4x4 Projection;
#endif
#if FOG_TYPE == FOG_TYPE_LINEAR || FOG_TYPE == FOG_TYPE_HEIGHT
float4 FogInfo;
#endif
#if FOG_TYPE == FOG_TYPE_HEIGHT || LIT_ENABLE
float4x4 World;
#endif
#if LIGHT_MAP_ENABLE
float4x4 LightMapTransform;
#endif
#if LIT_ENABLE
float4 ShadowLightAttr[LIGHT_ATTR_ITEM_NUM];
#endif
#if (LIT_ENABLE && SHADOW_MAP_ENABLE)
float4x4 LightViewProj;
#endif
#if (LIT_ENABLE && SHADOW_MAP_ENABLE)
float4 ShadowInfo;
#endif
};
struct VS_INPUT
{
float4 a_position [[attribute(POSITION)]];
#if LIT_ENABLE
float4 a_normal [[attribute(NORMAL)]];
#endif
#if GPU_SKIN_ENABLE
float4 a_blendweight [[attribute(BLENDWEIGHT)]];
#endif
#if GPU_SKIN_ENABLE
float4 a_blendindices [[attribute(BLENDINDICES)]];
#endif
float4 a_texture0 [[attribute(TEXTURE0)]];
#if LIGHT_MAP_ENABLE
float4 a_texture1 [[attribute(TEXTURE1)]];
#endif
};
struct PS_INPUT
{
float4 final_position [[position]];
float4 v_texture0;
#if LIGHT_MAP_ENABLE
float4 v_texture1;
#endif
#if (LIT_ENABLE && SHADOW_MAP_ENABLE)
float4 v_texture2;
#endif
#if LIT_ENABLE
float3 v_lighting;
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
const float2 local_0 = {1.0f, 0.0f};
float2 local_1 = {vsIN.a_texture0.x, vsIN.a_texture0.y};
float4 local_2 = {local_1.x, local_1.y, local_0.x, local_0.y};
float4 local_3 = constants.TexTransform0 * local_2;
#if SHADOW_MAP_ESM
#else
#endif
float4 local_4;
#if LIT_ENABLE
local_4 = vsIN.a_normal;
#else
const float4 local_5 = {0.0f, 0.0f, 0.0f, 0.0f};
local_4 = local_5;
#endif
float4 local_6;
float4 local_7;
#if GPU_SKIN_ENABLE
uint4 local_8 = {static_cast<uint>(vsIN.a_blendindices.x), static_cast<uint>(vsIN.a_blendindices.y), static_cast<uint>(vsIN.a_blendindices.z), static_cast<uint>(vsIN.a_blendindices.w)};
float4 local_9;
float4 local_10;
get_skin_pos_normal(vsIN.a_blendweight,local_8,vsIN.a_position,local_4,constants.SkinBones,local_9,local_10);
local_6 = local_9;
local_7 = local_10;
#else
local_6 = vsIN.a_position;
local_7 = local_4;
#endif
#if LIT_ENABLE
float3 local_11 = {local_6.x, local_6.y, local_6.z};
float3x3 local_12 = float3x3(constants.World[0].xyz, constants.World[1].xyz, constants.World[2].xyz);
float3 local_13 = local_12 * local_11;
float4 local_14 = constants.World * local_6;
#if SHADOW_MAP_ENABLE
float3 local_15 = {constants.ShadowInfo.x, constants.ShadowInfo.y, constants.ShadowInfo.z};
float2 local_16;
float local_17;
float local_18;
calc_shadow_info(local_14,local_13,constants.LightViewProj,local_15,local_16,local_17,local_18);
float4 local_19 = {local_16.x, local_16.y, local_17, local_18};
psIN.v_texture2 = local_19;
#else
#endif
float3 local_20 = {constants.Ambient.x, constants.Ambient.y, constants.Ambient.z};
float3 local_21 = {local_14.x, local_14.y, local_14.z};
const uint local_22 = 4;
const uint local_23 = 3;
const uint local_24 = 1;
float4 local_25 = constants.ShadowLightAttr[local_22];
float4 local_26 = constants.ShadowLightAttr[local_23];
float4 local_27 = constants.ShadowLightAttr[local_24];
float3 local_28;
shadow_light_lit(local_27,local_26,local_25,local_21,local_13,local_28);
float3 local_29 = local_20 + local_28;
psIN.v_lighting = local_29;
#else
#endif
#if LIGHT_MAP_ENABLE
float2 local_30 = {vsIN.a_texture1.x, vsIN.a_texture1.y};
const float2 local_31 = {1.0f, 0.0f};
float4 local_32 = {local_30.x, local_30.y, local_31.x, local_31.y};
float4 local_33 = constants.LightMapTransform * local_32;
psIN.v_texture1 = local_33;
#else
#endif
float3 local_34 = {local_3.x, local_3.y, local_3.z};
float4 local_35 = constants.WorldViewProjection * local_6;
float local_36;
#if FOG_TYPE==FOG_TYPE_NONE
const float local_37 = 0.00f;
local_36 = local_37;
#elif FOG_TYPE==FOG_TYPE_LINEAR
float local_38 = constants.FogInfo.x;
float local_39 = constants.FogInfo.y;
float2 local_40 = constants.FogInfo.zw;
const uint local_41 = 2;
float local_42 = local_35[local_41];
float local_43;
get_fog_linear(local_38,local_39,local_42,constants.Projection,local_43);
local_36 = local_43;
#elif FOG_TYPE==FOG_TYPE_HEIGHT
const uint local_44 = 1;
float4 local_45 = constants.World * vsIN.a_position;
float local_46 = local_45[local_44];
float local_47 = constants.FogInfo.x;
float local_48 = constants.FogInfo.y;
float local_49 = constants.FogInfo.z;
float local_50 = constants.FogInfo.w;
const uint local_51 = 2;
float local_52 = local_35[local_51];
float local_53;
get_fog_height(local_47,local_48,local_52,local_49,local_50,local_46,constants.Projection,local_53);
local_36 = local_53;
#endif
float4 local_54 = {local_34.x, local_34.y, local_34.z, local_36};
psIN.final_position = local_35;
psIN.v_texture0 = local_54;
#endif
return psIN;
}
