#define EQUAL(x,y) !(x-y)

using namespace metal;

#include "shaderlib/fog_metal.vs"
#include "shaderlib/skin_metal.vs"
#include "shaderlib/lighting_metal.vs"

// ATTRIBUTE
struct VertexInput
{
	float4 texcoord1 [[attribute(TEXTURE1)]];
	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 diffuse [[attribute(DIFFUSE)]];
	float4 position [[attribute(POSITION)]];

	#ifdef NEED_NORMAL
	float4 normal [[attribute(NORMAL)]];
	#endif

	#if GPU_SKIN_ENABLE
    float4 blendWeights [[attribute(BLENDWEIGHT)]];
    uint4 blendIndices [[attribute(BLENDINDICES)]];
	#endif
};

// UNIFORM
struct VSConstants
{
#ifdef NEED_WORLD
	float4x4 world;
#endif
	
	float4x4 wvp;
	float4x4 texTrans0;
#if LIGHT_MAP_ENABLE
	float4x4 lightmapTrans;
#endif

#if LIT_ENABLE
    float4 PointLightAttrs[POINT_LIGHT_ATTR_ITEM_NUM];
    float4 ShadowLightAttr[LIGHT_ATTR_ITEM_NUM];
    float4 Ambient;
#endif

#if SHADOW_MAP_ENABLE
	float4x4 lvp;
#endif

#if RECEIVE_SHADOW
	float4x4 lightViewProj;
#endif

#if FOG_ENABLE
	float4 FogInfo;
	float4x4 proj;
#endif

#if GPU_SKIN_ENABLE
    float4 BoneVec[MAX_BONES*2];
#endif

};

// 
struct VertexOutput
{
	float4 position [[position]];
#if LIGHT_MAP_ENABLE
	float4 UV1;
#endif
	float4 UV0;
	
//#if NEOX_MIX_TEX3_ENABLE
	float4 Color;
//#endif

#ifdef NEED_WORLD_INFO
	float4 PosWorld;
	float3 NormalWorld;
#endif

#if LIT_ENABLE
	float3 Lighting;
#endif


#if RECEIVE_SHADOW
	float4 PosLightProj;
#endif
};

vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput  vData [ [stage_in] ],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	float4 pos = vData.position;
	float4 nor = float4(0);
#ifdef NEED_NORMAL
	nor = vData.normal;
#endif
#if GPU_SKIN_ENABLE
    SkinOutput skin_out = GetSkin(vData.blendWeights, vData.blendIndices, vData.position, nor, constants.BoneVec);
    pos = float4(skin_out.pos, 1);
    nor = float4(skin_out.nor, 0);
#endif 

#ifdef NEED_WORLD
	float4 posWorld;
	float3 normalWorld;
	posWorld = constants.world * pos;
#ifdef NEED_NORMAL
	float3x3 worldNormalMat = float3x3(constants.world[0].xyz, constants.world[1].xyz, constants.world[2].xyz);
	normalWorld = normalize(worldNormalMat * nor.xyz).xyz;
#endif
#ifdef NEED_WORLD_INFO
	output.PosWorld = posWorld;
	output.NormalWorld = normalWorld;
#endif
#endif 

	output.position = (constants.wvp * pos);
// #ifdef NEED_POS_SCREEN
	// PosScreen = output.position;
	// RAWUV0 = vData.texcoord0;
// #endif
#if CUBEMAP_ENABLE 
	PosScreen = float4(output.position.xyz / output.position.w, 1.0);
#endif

	float4 texc = float4(vData.texcoord0.xy, 1, 0);

	output.UV0 = constants.texTrans0 * texc;

//#if NEOX_MIX_TEX3_ENABLE
	output.Color = vData.diffuse;
//#endif

#if FOG_ENABLE
#if EQUAL(FOG_TYPE, FOG_TYPE_HEIGHT)
	output.UV0.w = GetFog(output.position, posWorld, constants.FogInfo, constants.proj);
#else
	output.UV0.w = GetFog(output.position, float4(1.0), constants.FogInfo, constants.proj);
#endif
#endif //FOG_ENABLE
#if LIGHT_MAP_ENABLE
	texc = float4(vData.texcoord1.xy, 1, 0);
	output.UV1 = constants.lightmapTrans * texc;
#endif
#if LIT_ENABLE 
	output.Lighting = constants.Ambient.xyz;
	output.Lighting += ShadowLightLit(
		constants.ShadowLightAttr[1], //diffuse和类型
		constants.ShadowLightAttr[3], //方向光xyz为方向，点光xyz为位置，w为范围
		constants.ShadowLightAttr[4], //点光特有的
		posWorld.xyz,		//受光点的位置
		normalWorld.xyz	//受光点的法线方向
		);
#endif

#if RECEIVE_SHADOW
	// output.PosLightProj = (constants.lightViewProj * posWorld);
	float4 temp = constants.lightViewProj * posWorld;
	temp = temp / temp.w*0.5 + 0.5;
	temp.y = 1 - temp.y;
	output.PosLightProj = temp;
#endif

#endif

	return output;
}