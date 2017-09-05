using namespace metal;

// ATTRIBUTE
struct VertexInput
{	
	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 position [[attribute(POSITION)]];
};


// UNIFORM
struct VSConstants
{
	float4x4 world;

	float flare_rotate;
	float flare_tranx;
	float flare_trany;
	float flare_scale;
	float hw_ratio;
};


// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float2 UV0;
	
};

float2 func_scale(float s, float4 pos)
{
	return pos.xy * s;
}

float2 func_translate(float x, float y, float4 pos)
{
	return pos.xy + float2(x, y);
}

float4 func_rotate(float r, float4 pos)
{
	float sinr = sin(r);
	float cosr = cos(r);
	float4x4 mxr = float4x4(	float4(cosr, sinr, 0.0, 0.0),
								float4(-sinr, cosr, 0.0, 0.0),
								float4(0.0, 0.0, 1.0, 0.0),
								float4(0.0, 0.0, 0.0, 1.0));
	return mxr * pos;
}

vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput  vData [ [stage_in] ],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR

	float4 world_pos = float4(vData.position.x-0.5, vData.position.y-0.5, 0, 1.0);
	world_pos.xy = func_scale(constants.flare_scale, world_pos); 
	world_pos = func_rotate(constants.flare_rotate, world_pos);
	world_pos.x *= constants.hw_ratio;
	world_pos.xy = func_translate(constants.flare_tranx, constants.flare_trany, world_pos);
	output.position = float4(world_pos.x, world_pos.y, 0.0, 1.0);//绘制在最前面
    output.UV0 = vData.texcoord0.xy;
	

#endif
	return output;
}
