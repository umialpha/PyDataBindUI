float4x4 CC_MVPMatrix;
struct VS_INPUT
{
float4 a_position: POSITION;
float2 a_texture0: TEXCOORD0;
float4 a_diffuse: COLOR0;
};
struct PS_INPUT
{
float4 final_position: POSITION;
float2 v_texture0: TEXCOORD0;
float4 v_texture1: TEXCOORD1;
};
PS_INPUT main(VS_INPUT vsIN)
{
PS_INPUT psIN = (PS_INPUT)0;
float4 local_0 = mul(vsIN.a_position, CC_MVPMatrix);
psIN.final_position = local_0;
float3 local_1 = vsIN.a_diffuse.xyz;
float local_2 = vsIN.a_diffuse.w;
float3 local_3 = mul(local_1, local_2);
float4 local_4 = {local_3.x, local_3.y, local_3.z, local_2};
psIN.v_texture1 = local_4;
psIN.v_texture0 = vsIN.a_texture0;
return psIN;
}
