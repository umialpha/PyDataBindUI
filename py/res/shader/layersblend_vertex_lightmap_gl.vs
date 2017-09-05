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
#endif

#if LIGHT_MAP_ENABLE
varying highp vec4 UV1;
#endif
varying highp vec4 UV0;

//#if NEOX_MIX_TEX3_ENABLE
varying lowp vec4 Color;
//#endif

#ifdef NEED_WORLD_INFO
varying highp vec4 PosWorld;
varying highp vec3 NormalWorld;
#endif
// #ifdef NEED_POS_SCREEN
// varying highp vec4 PosScreen;
// varying mediump vec4 RAWUV0;
// #endif
#if CUBEMAP_ENABLE
varying mediump vec4 PosScreen;
#endif

#if RECEIVE_SHADOW
varying highp vec4 PosLightProj;
uniform highp mat4 lightViewProj;
#endif

void main ()
{
	vec4 pos = position;
	vec4 nor = vec4(0);
#ifdef NEED_NORMAL
	nor = normal;
#endif
#if GPU_SKIN_ENABLE
	GetSkin(blendWeights, blendIndices, pos, nor);
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
#endif
#endif 

	gl_Position = (wvp * pos);
// #ifdef NEED_POS_SCREEN
	// PosScreen = gl_Position;
	// RAWUV0 = texcoord0;
// #endif
#if CUBEMAP_ENABLE 
	PosScreen = vec4(gl_Position.xyz / gl_Position.w, 1.0);
#endif

	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);

	UV0 = texTrans0 * texc;

//#if NEOX_MIX_TEX3_ENABLE
	Color = diffuse;
//#endif

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
	Lighting = Ambient.xyz;
	Lighting += ShadowLightLit(
		ShadowLightAttr[1], //diffuse和类型
		ShadowLightAttr[3], //方向光xyz为方向，点光xyz为位置，w为范围
		ShadowLightAttr[4], //点光特有的
		posWorld.xyz,		//受光点的位置
		normalWorld.xyz	//受光点的法线方向
		);
#endif

#if RECEIVE_SHADOW
	PosLightProj = lightViewProj * (world * pos);
#endif

}

