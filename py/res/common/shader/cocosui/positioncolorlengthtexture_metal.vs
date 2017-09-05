#include <metal_graphics>
#include <metal_texture>
#include <metal_matrix>
#include <metal_common>
using namespace metal;
struct VSConstants
{
float4x4 CC_MVPMatrix;
};
struct VS_INPUT
{
float4 a_position [[attribute(POSITION)]];
float2 a_texture0 [[attribute(TEXTURE0)]];
float4 a_diffuse [[attribute(DIFFUSE)]];
};
struct PS_INPUT
{
float4 final_position [[position]];
float2 v_texture0;
float4 v_texture1;
};
vertex PS_INPUT metal_main(
#ifndef NEOX_METAL_NO_ATTR
VS_INPUT vsIN[[stage_in]],
#endif
constant VSConstants &constants[[buffer(0)]])
{
PS_INPUT psIN;
#ifndef NEOX_METAL_NO_ATTR
psIN.v_texture0 = vsIN.a_texture0;
float3 local_0 = vsIN.a_diffuse.xyz;
float local_1 = vsIN.a_diffuse.w;
float3 local_2 = local_0 * local_1;
float4 local_3 = {local_2.x, local_2.y, local_2.z, local_1};
psIN.v_texture1 = local_3;
float4 local_4 = constants.CC_MVPMatrix * vsIN.a_position;
psIN.final_position = local_4;
#endif
return psIN;
}
