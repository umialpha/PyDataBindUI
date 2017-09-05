#include <metal_graphics>
#include <metal_geometric>
#include <metal_matrix>
#include <metal_texture>
using namespace metal;
#ifndef NEOX_METAL_NO_ATTR
struct VertexInput
{
	float4 position [ [attribute(POSITION)] ];
	float4 diffuse [ [attribute(DIFFUSE)] ];
	float2 texcoord0 [ [attribute(TEXTURE0)] ];
};
#endif
struct VSConstants
{
	float4x4 CC_MVPMatrix;
};
struct VertexOutput
{
	float4 gl_Position [ [position] ];
	float2 v_texCoord;
	float4 v_fragmentColor;
};
vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
				VertexInput  vData [ [stage_in] ],
#endif
				constant VSConstants &constants[ [buffer(0)] ])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	output.gl_Position = constants.CC_MVPMatrix * vData.position;
	output.v_fragmentColor = vData.diffuse;
	output.v_texCoord = vData.texcoord0;
#endif
	return output;
}
