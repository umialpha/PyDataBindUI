#ifndef USE_NO_MV
 #define USE_NO_MV 0
#endif

#if USE_NO_MV
float4x4 CC_PMatrix;
#endif
#if !(USE_NO_MV)
float4x4 CC_MVPMatrix;
#endif
struct VS_INPUT
{
#if USE_NO_MV || !(USE_NO_MV)
float4 a_position: POSITION;
#endif
float2 a_texture0: TEXCOORD0;
float4 a_diffuse: COLOR0;
};
struct PS_INPUT
{
float4 final_position: POSITION;
float4 v_diffuse: TEXCOORD0;
float2 v_texture0: TEXCOORD1;
};
PS_INPUT main(VS_INPUT vsIN)
{
PS_INPUT psIN = (PS_INPUT)0;
float4 local_0;
#if USE_NO_MV
float4 local_1 = mul(vsIN.a_position, CC_PMatrix);
local_0 = local_1;
#else
float4 local_2 = mul(vsIN.a_position, CC_MVPMatrix);
local_0 = local_2;
#endif
psIN.final_position = local_0;
psIN.v_diffuse = vsIN.a_diffuse;
psIN.v_texture0 = vsIN.a_texture0;
return psIN;
}
