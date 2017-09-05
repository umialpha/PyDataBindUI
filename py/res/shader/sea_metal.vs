using namespace metal;
#define EQUAL(x,y) !(x-y)
#include "shaderlib/fog_metal.vs"
#include "shaderlib/skin_metal.vs"
#include "shaderlib/lighting_metal.vs"

// ATTRIBUTE
struct VertexInput
{	
	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 texcoord1 [[attribute(TEXTURE1)]];
	float4 diffuse [[attribute(DIFFUSE)]];
	float4 position [[attribute(POSITION)]];

#ifdef NEED_NORMAL
	float4 normal [[attribute(NORMAL)]];
	float4 tangent [[attribute(TANGENT)]];
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

#if SHADOW_MAP_ENABLE
	float4x4 lvp;
	float4x4 invLightView;
#endif

#if LIT_ENABLE
	float4 PointLightAttrs[10];
#endif

#if FOG_ENABLE
	float4 FogInfo;
	float4x4 proj;
#endif

};


// VARYING
struct VertexOutput
{
	float4 position [[position]];
	
#if LIGHT_MAP_ENABLE
	float4 UV1;
#endif
	float4 UV0;
// float4 Color;
#ifdef NEED_WORLD_INFO
	float4 PosWorld;
	float3 NormalWorld;
	float3 TangentWorld;
	float3 BinormalWorld;
#endif

#ifdef NEED_POS_SCREEN
	float4 PosScreen;
	float4 RAWUV0;
#endif

#if SHADOW_MAP_ENABLE
	float4 PosLightProj;
#endif

#if LIT_ENABLE
	float3 Lighting;
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
	output.TangentWorld = normalize(worldNormalMat * vData.tangent.xyz).xyz;

	float3 bino = normalize(cross(nor.xyz, vData.tangent.xyz));
	if(length(vData.tangent.xyz)>1.5) bino*=-1.0;
	output.BinormalWorld = normalize(worldNormalMat * bino.xyz).xyz;
#endif
#endif 

	output.position = (constants.wvp * pos);
#ifdef NEED_POS_SCREEN
	output.PosScreen = output.position;
	output.RAWUV0 = vData.texcoord0;
#endif
	float4 texc = float4(vData.texcoord0.xy, 1, 0);
#ifdef TERRAIN_TECH_TYPE
	output.UV0 = vData.texcoord0;
#else
	output.UV0 = constants.texTrans0 * texc;
#endif
	// Color = vData.diffuse;
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
	//Lighting = Ambient.xyz;
	/*output.Lighting += ShadowLightLit(
		ShadowLightAttr[1], //diffuse和类型
		ShadowLightAttr[3], //方向光xyz为方向，点光xyz为位置，w为范围
		ShadowLightAttr[4], //点光特有的
		posWorld.xyz,		//受光点的位置
		normalWorld.xyz	//受光点的法线方向
		);*/
	output.Lighting += PointLightLit(
		constants.PointLightAttrs[1], //diffuse和类型
		constants.PointLightAttrs[3], //方向光xyz为方向，点光xyz为位置，w为范围
		constants.PointLightAttrs[4], //点光特有的
		output.PosWorld.xyz,		//受光点的位置
		output.NormalWorld.xyz	//受光点的法线方向
		);
	output.Lighting += PointLightLit(
		constants.PointLightAttrs[5+1], //diffuse和类型
		constants.PointLightAttrs[5+3], //方向光xyz为方向，点光xyz为位置，w为范围
		constants.PointLightAttrs[5+4], //点光特有的
		output.PosWorld.xyz,		//受光点的位置
		output.NormalWorld.xyz	//受光点的法线方向
		);
#endif

#if SHADOW_MAP_ENABLE
	output.PosLightProj = constants.lvp * (constants.world * pos);
#endif

#endif
	return output;
}