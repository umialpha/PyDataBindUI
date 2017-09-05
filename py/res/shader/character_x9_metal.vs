#define EQUAL(x,y) !(x-y)

using namespace metal;

#include "shaderlib/fog_metal.vs"
#include "shaderlib/skin_metal.vs"
#include "shaderlib/lighting_metal.vs"


#ifndef NEED_POS_WORLD
#define NEED_POS_WORLD TRUE
#endif

#ifndef NEED_NORMAL_WORLD
#define NEED_NORMAL_WORLD TRUE
#endif


struct VertexInput
{
	float4 position [ [attribute(POSITION)] ];
	float4 texcoord0 [ [attribute(TEXTURE0)] ];
	float4 texcoord1 [ [attribute(TEXTURE1)] ];
	float4 diffuse [ [attribute(DIFFUSE)] ];
#ifdef NEED_NORMAL
	float4 normal [ [attribute(NORMAL)] ];
	float4 tangent [ [attribute(TANGENT)] ];
#endif

#if GPU_SKIN_ENABLE
	float4 blendWeights [[attribute(BLENDWEIGHT)]];
    uint4 blendIndices [[attribute(BLENDINDICES)]];
#endif
};

struct VSConstants
{
	float4x4 wvp;
	float4x4 world;
	float4x4 view;
	float4x4 viewProjection;
	float4x4 wv;
	
	float4x4 texTrans0;

	float3 model_offset;

#if LIGHT_MAP_ENABLE
	float4x4 lightmapTrans;
#endif

#if SHADOW_MAP_ENABLE
	float4x4 lightViewProj;
#endif

#if GPU_SKIN_ENABLE
	float4 BoneVec[MAX_BONES*2];
#endif

#if FOG_ENABLE
	float4 FogInfo;
	float4x4 proj;
#endif

#if LIT_ENABLE
    float4 PointLightAttrs[POINT_LIGHT_ATTR_ITEM_NUM];
    float4 ShadowLightAttr[LIGHT_ATTR_ITEM_NUM];
    float4 Ambient;
#endif

};

struct VertexOutput
{
	float4 position [ [position] ];
	float4 UV0;
	
#ifdef NEED_POS_WORLD
	float4 PosWorld;
#endif

#ifdef NEED_NORMAL_WORLD
	float3 NormalWorld;
	float3 TangentWorld;
	float3 BinormalWorld;
#endif

#if SHADOW_MAP_ENABLE
	float4 PosLightProj;
#endif

#if FOG_ENABLE
	float4 FogResult;
#endif

#if LIT_ENABLE
	float3 Lighting;
#endif

};

vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
				VertexInput  vData [ [stage_in] ],
#endif
				constant VSConstants &constants[ [buffer(0)] ])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	// output.position = constants.viewProjection * (constants.world * vData.position +  float4(constants.model_offset, 0.0));
	// return output;

	float4 pos = vData.position;
	float4 nor = float4(0);
	float4 bino = float4(0);
	float4 tang = float4(0);

#ifdef NEED_NORMAL
	nor = vData.normal;
#endif


#if GPU_SKIN_ENABLE
	SkinOutput skin_out = GetSkin(vData.blendWeights, vData.blendIndices, vData.position, nor, constants.BoneVec);
    pos = float4(skin_out.pos, 1);
    nor = float4(skin_out.nor, 0);
#endif

#ifdef NEED_NORMAL
	tang = vData.tangent;
	bino.xyz = cross(nor.xyz, tang.xyz);
#endif

#ifdef NEED_POS_WORLD
	output.PosWorld = constants.world * pos + float4(constants.model_offset, 0.0);
#endif

#ifdef NEED_NORMAL_WORLD
	float3x3 worldNormalMat = float3x3(constants.world[0].xyz, constants.world[1].xyz, constants.world[2].xyz);
	output.NormalWorld = normalize(worldNormalMat * nor.xyz).xyz;

	output.TangentWorld = normalize(worldNormalMat * tang.xyz).xyz;
	output.BinormalWorld = normalize(worldNormalMat * bino.xyz).xyz;

	if (length(tang.xyz) > 1.0) {
		output.BinormalWorld *= -1.0;
	}
#endif

	output.PosWorld = constants.world * pos + float4(constants.model_offset, 0.0);
	output.position = (constants.viewProjection * output.PosWorld);
	float4 texc = float4(vData.texcoord0.xy, 1, 0);
	output.UV0 = constants.texTrans0 * texc;

#if FOG_ENABLE
	float4 PosWorldFog = constants.world * pos;
	float4 PosView = constants.view * PosWorldFog;
	output.FogResult = GetFog(output.position, output.PosWorld, constants.FogInfo, constants.proj);
#endif //FOG_ENABLE

#if LIT_ENABLE
#if NEED_POS_WORLD
#if NEED_NORMAL_WORLD
	output.Lighting = constants.Ambient.xyz;
	// 第1盏灯
	//output.Lighting = ShadowLightLit(
	//	ShadowLightAttr[1], //diffuse和类型
	//	ShadowLightAttr[3], //方向光xyz为方向，点光xyz为位置，w为范围
	//	ShadowLightAttr[4], //点光特有的
	//	PosWorld.xyz,		//受光点的位置
	//	NormalWorld.xyz	//受光点的法线方向
	//	);
	// 第2盏灯
	output.Lighting += ShadowLightLit(
		constants.PointLightAttrs[1], //diffuse和类型
		constants.PointLightAttrs[3], //方向光xyz为方向，点光xyz为位置，w为范围
		constants.PointLightAttrs[4], //点光特有的
		output.PosWorld.xyz,		//受光点的位置
		output.NormalWorld.xyz	//受光点的法线方向
		);
	// output.Lighting.r = 0.0;
	// output.Lighting.g = 1.0;
	// output.Lighting.b = 1.0;
	// 第3盏灯
	output.Lighting += ShadowLightLit(
		constants.PointLightAttrs[5 + 1], //diffuse和类型
		constants.PointLightAttrs[5 + 3], //方向光xyz为方向，点光xyz为位置，w为范围
		constants.PointLightAttrs[5 + 4], //点光特有的
		output.PosWorld.xyz,		//受光点的位置
		output.NormalWorld.xyz	//受光点的法线方向
		);
#endif
#endif
#endif


#if SHADOW_MAP_ENABLE
	output.PosLightProj = constants.lightViewProj * output.PosWorld;

	float4 temp = constants.lightViewProj * (output.PosWorld);
    temp = temp / temp.w*0.5 + 0.5;
    temp.y = 1 - temp.y;
    output.PosLightProj = temp;
#endif

	// output.position =  constants.wvp * vData.position;

#if GPU_SKIN_ENABLE
	// output.position =  constants.wvp * pos;
#endif

#endif
	return output;
}


