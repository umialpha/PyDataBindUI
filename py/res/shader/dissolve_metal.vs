#define EQUAL(x,y) !(x-y)
using namespace metal;

#include "shaderlib/fog_metal.vs"
#include "shaderlib/skin_metal.vs"

// ATTRIBUTE
struct VertexInput
{
	float4 position[[attribute(POSITION)]];
	float4 texcoord0[[attribute(TEXTURE0)]];
	float4 normal[[attribute(NORMAL)]];

#if GPU_SKIN_ENABLE
	float4 blendWeights [[attribute(BLENDWEIGHT)]];
    uint4 blendIndices [[attribute(BLENDINDICES)]];
#endif
};


// UNIFORM
struct VSConstants
{
	float4x4 world;

	float4x4 wvp;
	float4x4 texTrans0;

#if LIT_ENABLE
    float4 PointLightAttrs[POINT_LIGHT_ATTR_ITEM_NUM];
    float4 ShadowLightAttr[LIGHT_ATTR_ITEM_NUM];
    float4 Ambient;
#endif

#if FOG_ENABLE
	float4 FogInfo;
	float4x4 proj;
#endif


#if GPU_SKIN_ENABLE
	float4 BoneVec[MAX_BONES*2];
#endif

};

// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float4 UV0;
	float4 RAWUV0;

	float4 PosWorld;

	float3 NormalWorld;
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

	float3x3 worldNormalMat = float3x3(constants.world[0].xyz, constants.world[1].xyz, constants.world[2].xyz);
    output.NormalWorld = normalize(worldNormalMat * vData.normal.xyz).xyz;

#if GPU_SKIN_ENABLE
	SkinOutput skin_out = GetSkin(vData.blendWeights, vData.blendIndices, vData.position, nor, constants.BoneVec);
    pos = float4(skin_out.pos, 1);
    nor = float4(skin_out.nor, 0);
#endif

	output.PosWorld = constants.world * pos;

	output.position = constants.wvp * pos;

	float4 texc = float4(vData.texcoord0.xy, 1.0, 0.0);

#ifdef TERRAIN_TECH_TYPE
	output.UV0 = vData.texcoord0;
#else
	output.UV0 = constants.texTrans0 * texc;
#endif
	output.RAWUV0 = texc;

	// Color = diffuse;
#if FOG_ENABLE
#if EQUAL(FOG_TYPE, FOG_TYPE_HEIGHT)
	output.UV0.w = GetFog(output.position, output.PosWorld, constants.FogInfo, constants.proj);
#else
	output.UV0.w = GetFog(output.position, float4(1.0), constants.FogInfo, constants.proj);
#endif
#endif //FOG_ENABLE

#endif

	return output;


}