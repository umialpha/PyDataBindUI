#include <metal_graphics>
#include <metal_geometric>
#include <metal_matrix>
#include <metal_texture>
using namespace metal;
#ifndef NEOX_METAL_NO_ATTR
struct VertexInput
{
	float4 position [ [attribute(POSITION)] ];
	float4 texcoord0 [ [attribute(TEXTURE0)] ];
};
#endif
struct VSConstants
{
	float4x4 wvp;
	float4x4 texTrans0;
#ifdef POSI_SCREEN
	float4x4 revView;
#endif
};
struct VertexOutput
{
	float4 position [ [position] ];
	float4 UV0;
	float4 Color;
};
vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
				VertexInput  vData [ [stage_in] ],
#endif
				constant VSConstants &constants[ [buffer(0)] ])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.position = (constants.wvp * vData.position);
	float4 texc = float4(vData.texcoord0.xy, 1, 0);
	output.UV0 = constants.texTrans0 * texc;
#endif
	return output;
}