using namespace metal;

#ifndef NEOX_METAL_NO_ATTR
//ATTRIBUTE
struct VertexInput
{
	float4 Pos [[attribute(POSITION)]];
	float4 v_lightattr [[attribute(TEXTURE3)]];
	float4 v_light_color [[attribute(TEXTURE4)]];
	float4 v_prs_mat0 [[attribute(TEXTURE5)]];
	float4 v_prs_mat1 [[attribute(TEXTURE6)]];
	float4 v_prs_mat2 [[attribute(TEXTURE7)]];
};
#endif

// UNIFORM
struct VSConstants
{
	float4x4 MatrixVP;
	float4x4 MatrixV;
};

// VARYING
struct VertexOutput
{
	float4 Pos [[position]];
	float3 HPos;
	float3 PosView;
	float4 LightAttrs;
	float4 LightColor;
};


vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
	VertexOutput Output;
#ifndef NEOX_METAL_NO_ATTR
	Output.LightAttrs = vData.v_lightattr;	//xyz位置，w范围
	Output.LightAttrs.xyz = (constants.MatrixV * float4(vData.v_lightattr.xyz,1)).xyz;
	
	Output.LightColor = vData.v_light_color;	//xyz颜色×强度，w衰减指数

	float4x4 WorldMatrixInstance;
	WorldMatrixInstance[0] = vData.v_prs_mat0;
	WorldMatrixInstance[1] = vData.v_prs_mat1;
	WorldMatrixInstance[2] = vData.v_prs_mat2;
	WorldMatrixInstance[3] = float4(0, 0, 0, 1);
	WorldMatrixInstance = transpose(WorldMatrixInstance);
	
	float4x4 MatrixWV  = constants.MatrixV * WorldMatrixInstance;
	float4x4 MatrixWVP = constants.MatrixVP * WorldMatrixInstance;
	
	float4 hpos = MatrixWVP * vData.Pos;
	Output.Pos = hpos;
	Output.HPos = hpos.xyw;
	Output.PosView = (MatrixWV * vData.Pos).xyz;
#endif
	return Output;
}
