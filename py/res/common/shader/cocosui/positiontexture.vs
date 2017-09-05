float4x4 CC_MVPMatrix;
struct VS_INPUT
{
float4 a_position: POSITION;
float2 a_texture0: TEXCOORD0;
};
struct PS_INPUT
{
float4 final_position: POSITION;
float2 v_texture0: TEXCOORD0;
};
PS_INPUT main(VS_INPUT vsIN)
{
PS_INPUT psIN = (PS_INPUT)0;
float4 local_0 = mul(vsIN.a_position, CC_MVPMatrix);
psIN.final_position = local_0;
psIN.v_texture0 = vsIN.a_texture0;
return psIN;
}
