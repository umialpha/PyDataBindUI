#include <metal_graphics>
#include <metal_texture>
#include <metal_matrix>
#include <metal_common>
using namespace metal;
struct VSConstants
{
float4x4 CC_PMatrix;
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
float4 use_color;
float2 v_texture1;
};
vertex PS_INPUT metal_main(
#ifndef NEOX_METAL_NO_ATTR
VS_INPUT vsIN[[stage_in]],
#endif
constant VSConstants &constants[[buffer(0)]])
{
PS_INPUT psIN;
#ifndef NEOX_METAL_NO_ATTR
psIN.v_texture1 = vsIN.a_texture0;
psIN.use_color = vsIN.a_diffuse;
float4 local_0 = constants.CC_PMatrix * vsIN.a_position;
psIN.final_position = local_0;
#endif
return psIN;
}
