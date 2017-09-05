#define EQUAL(x,y) !(x-y)

#include "shaderlib/fog.vs"

float4x4 wvp;
float4x4 texTrans0;
#if LIGHT_MAP_ENABLE
float4x4 lightmapTrans;
#endif

struct VS_INPUT
{
	float4 Color:		COLOR0;
	float4 Position:	POSITION;
	float4 TexCoord0:	TEXCOORD0;
	float4 TexCoord1:	TEXCOORD1;
#ifdef NEED_NORMAL
	float4 Normal: 		NORMAL;
#endif
};

struct PS_INPUT
{
	float4 Color:		COLOR0;
	float4 Position:	POSITION;
	float4 TexCoord0:	TEXCOORD0;
	float4 TexCoord1:	TEXCOORD1;
	float4 RawTexCoord0: TEXCOORD2;
#ifdef NEED_WORLD_INFO
	float4 PosWorld:	TEXCOORD3;
	float3 NormalWorld: TEXCOORD4;
#endif
};


float4x4 world;




PS_INPUT main(VS_INPUT IN)
{
	PS_INPUT OUT = (PS_INPUT)0;
	float4 normal = 0;
#ifdef NEED_NORMAL
	normal = IN.Normal;
#endif

#ifdef NEED_WORLD
	float4 posWorld = mul(IN.Position, world);
	float3 normalWorld = normalize(mul(normal.xyz, (float3x3)world)).xyz;
#ifdef NEED_WORLD_INFO
	OUT.PosWorld = posWorld;
	OUT.NormalWorld = normalWorld; 
#endif 
#endif

	OUT.Color	= IN.Color;
	OUT.Position = mul(IN.Position, wvp);
	OUT.RawTexCoord0 = IN.TexCoord0;
	OUT.TexCoord0.xyz =  mul(float3(IN.TexCoord0.xy,1), (float3x3)texTrans0);
#if FOG_ENABLE
#if EQUAL(FOG_TYPE, FOG_TYPE_HEIGHT)
	OUT.TexCoord0.w = GetFog(OUT.Position, posWorld);
#else
	OUT.TexCoord0.w = GetFog(OUT.Position, 1.0);
#endif
#endif //FOG_ENABLE
#if LIGHT_MAP_ENABLE
	OUT.TexCoord1.xy = mul(float3(IN.TexCoord1.xy,1), (float3x3)lightmapTrans).xy;
#else
	OUT.TexCoord1 = IN.TexCoord1;
#endif
	return OUT;
}
