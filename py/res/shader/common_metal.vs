#include <metal_graphics>
#include <metal_geometric>
#include <metal_matrix>
#include <metal_texture>

using namespace metal;
#define EQUAL(x,y) !(x-y)

#ifndef INSTANCE_TYPE_NONE
#define INSTANCE_TYPE_NONE 0
#define INSTANCE_TYPE_PRS 1
#define INSTANCE_TYPE_PRS_LM 2
#define INSTANCE_TYPE_VEGETATION 3
#define INSTANCE_TYPE_PRS_SHADER 4
#define INSTANCE_TYPE_PRS_LM_SHADER 5
#endif

#ifndef INSTANCE_TYPE
#define INSTANCE_TYPE INSTANCE_TYPE_NONE
#endif

//#include "shaderlib/fog_metal.vs"
#include "shaderlib/skin_metal.vs"
#include "shaderlib/lighting_metal.vs"

//MACROS
#ifndef SPECULAR_MAP_ENABLE
#define SPECULAR_MAP_ENABLE FALSE
#endif

#ifndef NORMAL_MAP_ENABLE
#define NORMAL_MAP_ENABLE FALSE
#endif

#ifndef USE_NORMAL_MAP
#define USE_NORMAL_MAP FALSE
#endif

#ifndef NEED_POS_WORLD
#define NEED_POS_WORLD TRUE
#endif

#ifndef CUBE_MAP_ENABLE
#define CUBE_MAP_ENABLE FALSE
#endif

#ifndef NEED_NORMAL_WORLD
#define NEED_NORMAL_WORLD TRUE
#endif


#ifndef RECEIVE_SHADOW
#define RECEIVE_SHADOW True
#endif


//ATTRIBUTE
struct VertexInput
{
	float4 position [[attribute(POSITION)]];

	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 texcoord1 [[attribute(TEXTURE1)]];

	//float4 diffuse [[attribute(COLOR0)]];

#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS) || EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM)
	//float4 texcoord4 [[attribute(TEXTURE4)]];
	//float4 texcoord5 [[attribute(TEXTURE5)]];
	//float4 texcoord6 [[attribute(TEXTURE6)]];
	//float4 texcoord7 [[attribute(TEXTURE7)]];
#endif
	
#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_SHADER)
	//float texcoord7 [[attribute(TEXTURE7)]];
#endif

#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM_SHADER)
	//float texcoord7 [[attribute(TEXTURE7)]];
#endif

#ifdef NEED_NORMAL
	float4 normal [[attribute(NORMAL)]];
	//float4 binormal [[attribute(BINORMAL)]];
	float4 tangent [[attribute(TANGENT)]];
#endif

#if GPU_SKIN_ENABLE
    float4 blendWeights [[attribute(BLENDWEIGHT)]];
    uint4 blendIndices [[attribute(BLENDINDICES)]];
#endif

};


// UNIFORM
struct VSConstants
{
#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_SHADER)
	float4 instData[3 * MAX_SHADER_INST_NUM];
#endif

#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM_SHADER)
	float4 instData[4 * MAX_SHADER_INST_NUM];
#endif

#if LIT_ENABLE
    float4 PointLightAttrs[POINT_LIGHT_ATTR_ITEM_NUM];
#endif

	float4x4 viewProj;

	float4x4 world;
	float4x4 view;

	float4x4 wvp;
	float4x4 texTrans0;
#if LIGHT_MAP_ENABLE
	float4x4 lightmapTrans;
#endif
	
#if RECEIVE_SHADOW
    float4x4 lightViewProj;
#endif

#if GPU_SKIN_ENABLE
    float4 BoneVec[MAX_BONES*2];
#endif

};

//VARYING
struct VertexOutput
{
	float4 position [[position]];
	
	float4 UV0;
#if LIGHT_MAP_ENABLE
    float4 UV1;
#endif	

#if NEED_POS_WORLD
    float4 PosWorld;
#endif

#if NEED_NORMAL_WORLD
    float3 NormalWorld;
    #if USE_NORMAL_MAP
        float3 TangentWorld;
        float3 BinormalWorld;
    #endif
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
	float4 nor = float4(0.0);
	float4 bino = float4(0.0);
	float4 tang = float4(0.0);

#ifdef NEED_NORMAL
	nor = vData.normal;
#endif


#if GPU_SKIN_ENABLE
    SkinOutput skin_out = GetSkin(vData.blendWeights, vData.blendIndices, vData.position, nor, constants.BoneVec);
    pos = float4(skin_out.pos, 1);
    nor = float4(skin_out.nor, 0);
#endif

//#if 1
#ifdef NEED_NORMAL
    tang = vData.tangent;
    bino.xyz = cross(nor.xyz, tang.xyz);
#endif
//#endif

#if NEED_POS_WORLD
	output.PosWorld = constants.world * pos;
#endif

#if 1
#if NEED_NORMAL_WORLD
	float3x3 worldNormalMat = float3x3(constants.world[0].xyz, constants.world[1].xyz, constants.world[2].xyz);
	output.NormalWorld = normalize(worldNormalMat * nor.xyz).xyz;
#if USE_NORMAL_MAP
	output.TangentWorld = normalize(worldNormalMat * tang.xyz).xyz;
	output.BinormalWorld = normalize(worldNormalMat * bino.xyz).xyz;
#endif
#endif
#endif

#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS)
    float4x4 instWorldMat = float4x4(vData.texcoord5.x, vData.texcoord6.x, vData.texcoord7.x, 0,
        vData.texcoord5.y, vData.texcoord6.y, vData.texcoord7.y, 0,
        vData.texcoord5.z, vData.texcoord6.z, vData.texcoord7.z, 0,
        vData.texcoord5.w, vData.texcoord6.w, vData.texcoord7.w, 1);
 
    float4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    output.PosWorld = world_pos;
    #endif
    output.position = (constants.viewProj * world_pos);
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM)
    float4x4 instWorldMat = float4x4(vData.texcoord5.x, vData.texcoord6.x, vData.texcoord7.x, 0,
        vData.texcoord5.y, vData.texcoord6.y, vData.texcoord7.y, 0,
        vData.texcoord5.z, vData.texcoord6.z, vData.texcoord7.z, 0,
        vData.texcoord5.w, vData.texcoord6.w, vData.texcoord7.w, 1);
    float4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    output.PosWorld = world_pos;
    #endif
    output.position = (constants.viewProj * world_pos);
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_SHADER)
    int ix = int(vData.texcoord7) * 3;
    int iy = ix + 1;
    int iz = ix + 2;
    float4x4 instWorldMat = float4x4(constants.tangent[ix].x, constants.tangent[iy].x, constants.tangent[iz].x, 0,
        constants.tangent[ix].y, constants.tangent[iy].y, constants.tangent[iz].y, 0,
        constants.tangent[ix].z, constants.tangent[iy].z, constants.tangent[iz].z, 0,
        constants.tangent[ix].w, constants.tangent[iy].w, constants.tangent[iz].w, 1);
 
    float4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    output.PosWorld = world_pos;
    #endif
    output.position = (constants.viewProj * world_pos);
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM_SHADER)
    int inst_id =  int(vData.texcoord7) * 4;
    int ix = inst_id + 1;
    int iy = inst_id + 2;
    int iz = inst_id + 3;
    float4x4 instWorldMat = float4x4(constants.tangent[ix].x, constants.tangent[iy].x, constants.tangent[iz].x, 0,
        constants.tangent[ix].y, constants.tangent[iy].y, constants.tangent[iz].y, 0,
        constants.tangent[ix].z, constants.tangent[iy].z, constants.tangent[iz].z, 0,
        constants.tangent[ix].w, constants.tangent[iy].w, constants.tangent[iz].w, 1);
    float4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    output.PosWorld = world_pos;
    #endif
    output.position = (constants.viewProj * world_pos);
#else
    output.position = (constants.wvp * pos);
#endif

	float4 texc = float4(vData.texcoord0.xy, 1, 0);
	output.UV0 = constants.texTrans0 * texc;

#if LIGHT_MAP_ENABLE
    texc = float4(vData.texcoord1.xy, 1, 0);
#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM)
    float4x4 instLightmapTrans = float4x4(vData.texcoord4.x, 0, 0, 0,
                0, vData.texcoord4.y, 0, 0,
                vData.texcoord4.z, vData.texcoord4.w, 1, 0,
                0, 0, 0, 1);
    
    output.UV1 = instLightmapTrans * texc;
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM_SHADER)
    float4x4 instLightmapTrans = float4x4(constants.tangent[inst_id].x, 0, 0, 0,
        0, constants.tangent[inst_id].y, 0, 0,
        constants.tangent[inst_id].z, constants.tangent[inst_id].w, 1, 0,
        0, 0, 0, 1);
 
    output.UV1 = instLightmapTrans * texc;
#else
    output.UV1 = constants.lightmapTrans * texc;
#endif
#endif

#if LIT_ENABLE
#if NEED_POS_WORLD
#if NEED_NORMAL_WORLD
    // 第2盏灯
    output.Lighting = ShadowLightLit(
       constants.PointLightAttrs[1], //diffuse和类型
        constants.PointLightAttrs[3], //方向光xyz为方向，点光xyz为位置，w为范围
        constants.PointLightAttrs[4], //点光特有的
        output.PosWorld.xyz,		//受光点的位置
        output.NormalWorld.xyz	//受光点的法线方向
        );
    // Lighting.r = 0.0;
    // Lighting.g = 1.0;
    // Lighting.b = 1.0;
    // 第3盏灯
    output.Lighting += ShadowLightLit(
        constants.PointLightAttrs[5 + 1], //diffuse和类型
        constants.PointLightAttrs[5 + 3], //方向光xyz为方向，点光xyz为位置，w为范围
        constants.PointLightAttrs[5 + 4], //点光特有的
        output.PosWorld.xyz,		//受光点的位置
        output.NormalWorld.xyz	//受光点的法线方向
        );
     //output.Lighting = float3(1.0);
#endif
#endif
#endif

//#if 1
#if RECEIVE_SHADOW
	output.PosLightProj = constants.lightViewProj * (constants.world * pos);

    float4 temp = constants.lightViewProj * (constants.world * pos);
    temp = temp / temp.w*0.5 + 0.5;
    temp.y = 1 - temp.y;

    output.PosLightProj = temp;

    // float depthToLight =  (lightProjPos.z / lightProjPos.w + 1.0) / 2.0;
    // float2 shadowMapCoord = (lightProjPos.xy / lightProjPos.w + 1.0) / 2.0;
    // shadowMapCoord.y = 1 - shadowMapCoord.y;

#endif
//#endif

#endif

	return output;
}