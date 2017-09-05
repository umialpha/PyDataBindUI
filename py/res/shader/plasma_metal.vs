using namespace metal;

// ATTRIBUTE
struct VertexInput
{
	float4 texcoord0 [[attribute(TEXTURE0)]];
	float4 diffuse [[attribute(DIFFUSE)]];
	float4 position [[attribute(POSITION)]];
	float3 normal [[attribute(NORMAL)]];
};


// UNIFORM
struct VSConstants
{
	float4x4 wvp;
	float4x4 texTrans0;

	float time;
	float frequency;
	float amplitude;
	float wave_size;
	float displace_offset;
};


// VARYING
struct VertexOutput
{
	float4 position [[position]];
	float4 UV0;
	float4 Color;
	float4 weight;
};

float3 point_noise(float3 p, float time)
{
	float3 p2 = (p + time) * float3(1.0, 1.5, 2.0);
	return sin(p2);
}

vertex VertexOutput VS_OneTex(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput  vData [ [stage_in] ],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput output;
#ifndef NEOX_METAL_NO_ATTR
	// Noise Generation
	float4 np = vData.position / constants.wave_size;
	float t = constants.time * constants.frequency;
	float3 p2 = (np.xyz - np.yzx);
	
	float3 noise = point_noise(p2, t) + 1.0;
	float sum_noise = noise.x + noise.y + noise.z;

	// Output noise to PS
	output.weight.xyz = noise / sum_noise;
	output.weight.w = sum_noise / 6.0;

	// Move vertices based on noise
	float4 pos = vData.position;
	pos.xyz += (sum_noise - 3.0 + constants.displace_offset) * vData.normal * constants.amplitude;
	
	// Calculate other stuff
	output.position = (constants.wvp * pos);
	float4 texc = float4(vData.texcoord0.xy, 1, 0);
	output.UV0 = constants.texTrans0 * texc;
	output.Color = vData.diffuse;

#endif
	return output;
}