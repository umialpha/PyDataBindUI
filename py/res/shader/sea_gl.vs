#define EQUAL(x,y) !(x-y)
#include "shaderlib/fog.vs"
#include "shaderlib/skin.vs"
#include "shaderlib/lighting.vs"

TEXCOORD1 attribute vec4 texcoord1;
TEXCOORD0 attribute vec4 texcoord0;
COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;

#ifdef NEED_NORMAL
NORMAL attribute vec4 normal;
TANGENT attribute vec4 tangent;
#endif
#ifdef NEED_WORLD
uniform highp mat4 world;
#endif

uniform highp mat4 wvp;
uniform highp mat4 texTrans0;
#if LIGHT_MAP_ENABLE
uniform highp mat4 lightmapTrans;
#endif
// uniform lowp int flipUV;

#if SHADOW_MAP_ENABLE
uniform highp mat4 lvp;
uniform highp mat4 invLightView;
#endif

#if LIGHT_MAP_ENABLE
varying highp vec4 UV1;
#endif
varying highp vec4 UV0;
// varying lowp vec4 Color;
#ifdef NEED_WORLD_INFO
varying highp vec4 PosWorld;
varying highp vec3 NormalWorld;
varying highp vec3 TangentWorld;
varying highp vec3 BinormalWorld;
#endif
#ifdef NEED_POS_SCREEN
varying highp vec4 PosScreen;
varying highp vec4 RAWUV0;
#endif

#if SHADOW_MAP_ENABLE
varying highp vec4 PosLightProj;
#endif

#if LIT_ENABLE
uniform highp vec4 PointLightAttrs[10];
#endif
void main ()
{
	vec4 pos = position;
	vec4 nor = vec4(0);
#ifdef NEED_NORMAL
	nor = normal;
#endif

#ifdef NEED_WORLD
	vec4 posWorld;
	vec3 normalWorld;
	posWorld = world * pos;
#ifdef NEED_NORMAL
	mat3 worldNormalMat = mat3(world);
	normalWorld = normalize(worldNormalMat * nor.xyz).xyz;
#endif
#ifdef NEED_WORLD_INFO
	PosWorld = posWorld;
	NormalWorld = normalWorld;
	TangentWorld = normalize(worldNormalMat * tangent.xyz).xyz;

	mediump vec3 bino = normalize(cross(nor.xyz, tangent.xyz));
	if(length(tangent.xyz)>1.5) bino*=-1.0;
	BinormalWorld = normalize(worldNormalMat * bino.xyz).xyz;
#endif
#endif 

	gl_Position = (wvp * pos);
#ifdef NEED_POS_SCREEN
	PosScreen = gl_Position;
	RAWUV0 = texcoord0;
#endif
	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
#ifdef TERRAIN_TECH_TYPE
	UV0 = texcoord0;
#else
	UV0 = texTrans0 * texc;
#endif
	// Color = diffuse;
#if FOG_ENABLE
#if EQUAL(FOG_TYPE, FOG_TYPE_HEIGHT)
	UV0.w = GetFog(gl_Position, posWorld);
#else
	UV0.w = GetFog(gl_Position, vec4(1.0));
#endif
#endif //FOG_ENABLE
#if LIGHT_MAP_ENABLE
	texc = vec4(texcoord1.xy, 1, 0);
	UV1 = lightmapTrans * texc;
#endif
#if LIT_ENABLE 
	//Lighting = Ambient.xyz;
	/*Lighting += ShadowLightLit(
		ShadowLightAttr[1], //diffuse和类型
		ShadowLightAttr[3], //方向光xyz为方向，点光xyz为位置，w为范围
		ShadowLightAttr[4], //点光特有的
		posWorld.xyz,		//受光点的位置
		normalWorld.xyz	//受光点的法线方向
		);*/
	Lighting += PointLightLit(
		PointLightAttrs[1], //diffuse和类型
		PointLightAttrs[3], //方向光xyz为方向，点光xyz为位置，w为范围
		PointLightAttrs[4], //点光特有的
		PosWorld.xyz,		//受光点的位置
		NormalWorld.xyz	//受光点的法线方向
		);
	Lighting += PointLightLit(
		PointLightAttrs[5+1], //diffuse和类型
		PointLightAttrs[5+3], //方向光xyz为方向，点光xyz为位置，w为范围
		PointLightAttrs[5+4], //点光特有的
		PosWorld.xyz,		//受光点的位置
		NormalWorld.xyz	//受光点的法线方向
		);
#endif

#if SHADOW_MAP_ENABLE
	PosLightProj = lvp * (world * pos);
#endif
}

