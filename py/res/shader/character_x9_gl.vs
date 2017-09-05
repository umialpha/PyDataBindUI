#define EQUAL(x,y) !(x-y)

// #include "shaderlib/fog.vs"
#include "shaderlib/skin_gl.vs"
#include "shaderlib/lighting.vs"

#include "shaderlib/extension.ps"

TEXCOORD1 attribute vec4 texcoord1;
TEXCOORD0 attribute vec4 texcoord0;
COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;

#ifndef NEED_POS_WORLD
#define NEED_POS_WORLD TRUE
#endif

#ifndef NEED_NORMAL_WORLD
#define NEED_NORMAL_WORLD TRUE
#endif

#ifndef TOON_ENABLE
#define TOON_ENABLE FALSE
#endif

#ifdef NEED_NORMAL
NORMAL attribute vec4 normal;
BINORMAL attribute vec4 binormal;
TANGENT attribute vec4 tangent;
#endif

uniform highp mat4 world;
uniform highp mat4 view;
uniform highp mat4 viewProjection;
uniform highp mat4 wv;
uniform highp vec4 camera_pos;
uniform highp mat4 wvp;
uniform highp mat4 texTrans0;

uniform highp vec3 model_offset;

#if TOON_ENABLE
uniform highp float outline_width;
#endif


#if LIGHT_MAP_ENABLE
uniform highp mat4 lightmapTrans;
#endif
// uniform lowp int flipUV;
#if SHADOW_MAP_ENABLE
uniform highp mat4 lightViewProj;
#endif

varying mediump vec4 UV0;
//varying lowp vec4 Color;
#ifdef NEED_POS_WORLD
varying highp vec4 PosWorld;
#endif

#ifdef NEED_NORMAL_WORLD
varying highp vec3 NormalWorld;
varying highp vec3 TangentWorld;
varying highp vec3 BinormalWorld;
#endif

#if SHADOW_MAP_ENABLE
varying highp vec4 PosLightProj;
#endif

#if FOG_ENABLE
varying highp vec4 FogResult;
#endif



#if TOON_ENABLE
void outline()
{
	highp vec4 pos = position;
	highp vec4 nor = normal;

#if GPU_SKIN_ENABLE
    GetSkin(blendWeights, blendIndices, pos, nor);
#endif
	highp vec4 wpos = world * pos;
	highp float camDis = length(camera_pos.xyz - wpos.xyz); 
	camDis *= 0.01;
	mediump float disIndex = 1.0 + min(5.0,camDis); 
	mediump vec4 pos_offset = vec4(normalize(nor.rgb) * outline_width * disIndex, 0.0);

	pos = vec4((pos + pos_offset).xyz, 1.0);
	wpos = world * pos;
	gl_Position = (viewProjection * wpos);

	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
	UV0 = texTrans0 * texc;
}
#endif


void base_main ()
{
	vec4 pos = position;
	vec4 nor = vec4(0);
	vec4 bino = vec4(0);
	vec4 tang = vec4(0);

#ifdef NEED_NORMAL
	nor = normal;
#endif

#ifdef NEED_NORMAL
	nor = normal;
#endif

#if GPU_SKIN_ENABLE
	GetSkin(blendWeights, blendIndices, pos, nor);
#endif

#ifdef NEED_NORMAL
	tang = tangent;
	bino.xyz = cross(nor.xyz, tang.xyz);
#endif

#ifdef NEED_POS_WORLD
	PosWorld = world * pos + vec4(model_offset, 0.0);
#endif

#ifdef NEED_NORMAL_WORLD
	mat3 worldNormalMat = mat3(world);
	NormalWorld = normalize(worldNormalMat * nor.xyz).xyz;

	TangentWorld = normalize(worldNormalMat * tang.xyz).xyz;
	BinormalWorld = normalize(worldNormalMat * bino.xyz).xyz;

	if (length(tang.xyz) > 1.0) {
		BinormalWorld *= -1.0;
	}
#endif

	gl_Position = (viewProjection * PosWorld);
	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
	UV0 = texTrans0 * texc;

#if FOG_ENABLE
	highp vec4 PosWorldFog = world * pos;
	highp vec4 PosView = view * PosWorldFog;
	FogResult = GetFogEx(PosWorldFog, PosView);
#endif //FOG_ENABLE
	
#if LIT_ENABLE
#if NEED_POS_WORLD
#if NEED_NORMAL_WORLD
	Lighting = Ambient.xyz;
	// 第1盏灯
	//Lighting = ShadowLightLit(
	//	ShadowLightAttr[1], //diffuse和类型
	//	ShadowLightAttr[3], //方向光xyz为方向，点光xyz为位置，w为范围
	//	ShadowLightAttr[4], //点光特有的
	//	PosWorld.xyz,		//受光点的位置
	//	NormalWorld.xyz	//受光点的法线方向
	//	);
	// 第2盏灯
	Lighting += ShadowLightLit(
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

#if SHADOW_MAP_ENABLE
	// PosLightProj = lightViewProj * PosWorld;

 	vec4 temp = lightViewProj * PosWorld;
    temp = temp / temp.w*0.5 + 0.5;
    
    PosLightProj = temp;
#endif
}

