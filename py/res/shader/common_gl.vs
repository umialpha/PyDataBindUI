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
#include "shaderlib/fog.vs"
#include "shaderlib/skin_gl.vs"
#include "shaderlib/lighting.vs"

TEXCOORD1 attribute vec4 texcoord1;
TEXCOORD0 attribute vec4 texcoord0;

COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;


#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS) || EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM)
TEXCOORD4 attribute vec4 texcoord4;
TEXCOORD5 attribute vec4 texcoord5;
TEXCOORD6 attribute vec4 texcoord6;
TEXCOORD7 attribute vec4 texcoord7;
#endif

//for shader instancing
#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_SHADER)
TEXCOORD7 attribute float texcoord7;
uniform highp vec4 instData[3 * MAX_SHADER_INST_NUM];
#endif
#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM_SHADER)
TEXCOORD7 attribute float texcoord7;
uniform highp vec4 instData[4 * MAX_SHADER_INST_NUM];
#endif

uniform highp mat4 viewProj;


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

#ifndef HIGH_LEVEL_ENABLE
#define HIGH_LEVEL_ENABLE TRUE
#endif


#ifdef NEED_NORMAL
NORMAL attribute vec4 normal;
BINORMAL attribute vec4 binormal;
TANGENT attribute vec4 tangent;
#endif

uniform highp mat4 world;
uniform highp mat4 view;

uniform highp mat4 wvp;
uniform highp mat4 texTrans0;
#if LIGHT_MAP_ENABLE
uniform highp mat4 lightmapTrans;
#endif
// uniform lowp int flipUV;
#ifndef RECEIVE_SHADOW
#define RECEIVE_SHADOW FALSE
#endif

#if RECEIVE_SHADOW
    uniform highp mat4 lightViewProj;
#endif



varying mediump vec4 UV0;

#if LIGHT_MAP_ENABLE
    varying mediump vec4 UV1;
#endif
//varying lowp vec4 Color;
#if NEED_POS_WORLD
    varying highp vec4 PosWorld;
#endif

#if NEED_NORMAL_WORLD
    varying highp vec3 NormalWorld;
    #if USE_NORMAL_MAP
        varying highp vec3 TangentWorld;
        varying highp vec3 BinormalWorld;
    #endif
#endif

#if RECEIVE_SHADOW
    varying highp vec4 PosLightProj;
#endif

void main ()
{
	vec4 pos = position;
	vec4 nor = vec4(0.0);
	vec4 bino = vec4(0.0);
	vec4 tang = vec4(0.0);

#ifdef NEED_NORMAL
	nor = normal;
#endif


#if GPU_SKIN_ENABLE
    GetSkin(blendWeights, blendIndices, pos, nor);
#endif

#if HIGH_LEVEL_ENABLE
#ifdef NEED_NORMAL
    tang = tangent;
    bino.xyz = cross(nor.xyz, tang.xyz);
#endif
#endif

#if NEED_POS_WORLD
	PosWorld = world * pos;
#endif

#if HIGH_LEVEL_ENABLE
#if NEED_NORMAL_WORLD
	mat3 worldNormalMat = mat3(world);
	NormalWorld = normalize(worldNormalMat * nor.xyz).xyz;
#if USE_NORMAL_MAP
	TangentWorld = normalize(worldNormalMat * tang.xyz).xyz;
	BinormalWorld = normalize(worldNormalMat * bino.xyz).xyz;
#endif
#endif
#endif

#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS)
    mat4 instWorldMat = mat4(texcoord5.x, texcoord6.x, texcoord7.x, 0,
        texcoord5.y, texcoord6.y, texcoord7.y, 0,
        texcoord5.z, texcoord6.z, texcoord7.z, 0,
        texcoord5.w, texcoord6.w, texcoord7.w, 1);
 
    vec4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    PosWorld = world_pos;
    #endif
    gl_Position = (viewProj * world_pos);
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM)
    mat4 instWorldMat = mat4(texcoord5.x, texcoord6.x, texcoord7.x, 0,
        texcoord5.y, texcoord6.y, texcoord7.y, 0,
        texcoord5.z, texcoord6.z, texcoord7.z, 0,
        texcoord5.w, texcoord6.w, texcoord7.w, 1);
    vec4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    PosWorld = world_pos;
    #endif
    gl_Position = (viewProj * world_pos);
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_SHADER)
    lowp int ix = int(texcoord7) * 3;
    lowp int iy = ix + 1;
    lowp int iz = ix + 2;
    mat4 instWorldMat = mat4(instData[ix].x, instData[iy].x, instData[iz].x, 0,
        instData[ix].y, instData[iy].y, instData[iz].y, 0,
        instData[ix].z, instData[iy].z, instData[iz].z, 0,
        instData[ix].w, instData[iy].w, instData[iz].w, 1);
 
    vec4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    PosWorld = world_pos;
    #endif
    gl_Position = (viewProj * world_pos);
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM_SHADER)
    lowp int inst_id =  int(texcoord7) * 4;
    lowp int ix = inst_id + 1;
    lowp int iy = inst_id + 2;
    lowp int iz = inst_id + 3;
    mat4 instWorldMat = mat4(instData[ix].x, instData[iy].x, instData[iz].x, 0,
        instData[ix].y, instData[iy].y, instData[iz].y, 0,
        instData[ix].z, instData[iy].z, instData[iz].z, 0,
        instData[ix].w, instData[iy].w, instData[iz].w, 1);
    vec4 world_pos = instWorldMat * pos;
    #if NEED_POS_WORLD
    PosWorld = world_pos;
    #endif
    gl_Position = (viewProj * world_pos);
#else
    gl_Position = (wvp * pos);
#endif

	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
	UV0 = texTrans0 * texc;

#if LIGHT_MAP_ENABLE
    texc = vec4(texcoord1.xy, 1, 0);
#if EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM)
    mat4 instLightmapTrans = mat4(texcoord4.x, 0, 0, 0,
                0, texcoord4.y, 0, 0,
                texcoord4.z, texcoord4.w, 1, 0,
                0, 0, 0, 1);
    
    UV1 = instLightmapTrans * texc;
#elif EQUAL(INSTANCE_TYPE, INSTANCE_TYPE_PRS_LM_SHADER)
    mat4 instLightmapTrans = mat4(instData[inst_id].x, 0, 0, 0,
        0, instData[inst_id].y, 0, 0,
        instData[inst_id].z, instData[inst_id].w, 1, 0,
        0, 0, 0, 1);
 
    UV1 = instLightmapTrans * texc;
#else
    UV1 = lightmapTrans * texc;
#endif
#endif

#if LIT_ENABLE
#if NEED_POS_WORLD
#if NEED_NORMAL_WORLD
    // Lighting = Ambient.xyz;
    // 第1盏灯
    // Lighting += ShadowLightLit(
    //     ShadowLightAttr[1], //diffuse和类型
    //     ShadowLightAttr[3], //方向光xyz为方向，点光xyz为位置，w为范围
    //     ShadowLightAttr[4], //点光特有的
    //     PosWorld.xyz,		//受光点的位置
    //     NormalWorld.xyz	//受光点的法线方向
    //     );
    // 第2盏灯
    Lighting = ShadowLightLit(
        PointLightAttrs[1], //diffuse和类型
        PointLightAttrs[3], //方向光xyz为方向，点光xyz为位置，w为范围
        PointLightAttrs[4], //点光特有的
        PosWorld.xyz,		//受光点的位置
        NormalWorld.xyz	//受光点的法线方向
        );
    // Lighting.r = 0.0;
    // Lighting.g = 1.0;
    // Lighting.b = 1.0;
    // 第3盏灯
    Lighting += ShadowLightLit(
        PointLightAttrs[5 + 1], //diffuse和类型
        PointLightAttrs[5 + 3], //方向光xyz为方向，点光xyz为位置，w为范围
        PointLightAttrs[5 + 4], //点光特有的
        PosWorld.xyz,		//受光点的位置
        NormalWorld.xyz	//受光点的法线方向
        );
#endif
#endif
#endif

#if HIGH_LEVEL_ENABLE
#if RECEIVE_SHADOW
	PosLightProj = lightViewProj * (world * pos);
#endif
#endif
}

