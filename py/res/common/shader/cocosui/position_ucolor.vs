float4x4 CC_MVPMatrix;
float4 u_color;
struct VS_INPUT
{
float4 a_position: POSITION;
};
struct PS_INPUT
{
float4 final_position: POSITION;
float4 v_diffuse: TEXCOORD0;
};
PS_INPUT main(VS_INPUT vsIN)
{
PS_INPUT psIN = (PS_INPUT)0;
float4 local_0 = mul(vsIN.a_position, CC_MVPMatrix);
psIN.final_position = local_0;
psIN.v_diffuse = u_color;
return psIN;
}
