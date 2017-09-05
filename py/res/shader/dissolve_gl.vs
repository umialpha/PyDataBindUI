#define EQUAL(x,y) !(x-y)

#include "shaderlib/fog.vs"
#include "shaderlib/skin_gl.vs"
// #include "shaderlib/lighting.vs"
POSITION attribute vec4 position;

TEXCOORD0 attribute vec4 texcoord0;
POSITION attribute vec4 pos;

NORMAL attribute vec4 normal;

uniform highp mat4 world;

uniform highp mat4 wvp;
uniform highp mat4 texTrans0;


//#if LIGHT_MAP_ENABLE
//uniform highp mat4 lightmapTrans;
//#endif
// uniform lowp int flipUV;

//#if LIGHT_MAP_ENABLE
//varying mediump vec4 UV1;
//#endif

varying mediump vec4 UV0;
varying mediump vec4 RAWUV0;
// varying lowp vec4 Color;

varying highp vec4 PosWorld;

varying highp vec3 NormalWorld;


//#ifdef NEED_POS_SCREEN
//varying highp vec4 PosScreen;
//varying mediump vec4 RAWUV0;
//#endif

void main ()
{	
	vec4 pos = position;
	vec4 nor = vec4(0);

	mat3 worldNormalMat = mat3(world);
    NormalWorld = normalize(worldNormalMat * normal.xyz).xyz;

#if GPU_SKIN_ENABLE
	GetSkin(blendWeights, blendIndices, pos, nor);
#endif

	PosWorld = world * pos;

	gl_Position = wvp * pos;

//#ifdef NEED_POS_SCREEN
//	PosScreen = gl_Position;
//	RAWUV0 = texcoord0;
//#endif
	mediump vec4 texc = vec4(texcoord0.xy, 1.0, 0.0);

#ifdef TERRAIN_TECH_TYPE
	UV0 = texcoord0;
#else
	UV0 = texTrans0 * texc;
#endif
	RAWUV0 = texc;

	// Color = diffuse;
#if FOG_ENABLE
#if EQUAL(FOG_TYPE, FOG_TYPE_HEIGHT)
	UV0.w = GetFog(gl_Position, PosWorld);
#else
	UV0.w = GetFog(gl_Position, vec4(1.0));
#endif
#endif //FOG_ENABLE

//#if LIGHT_MAP_ENABLE
//	texc = vec4(texcoord1.xy, 1.0, 0.0);
//	UV1 = lightmapTrans * texc;
//#endif
}

