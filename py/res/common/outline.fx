float4x4 WvpMat: WorldViewProjection;

int OutlineColor
<
	string SasUiLabel = "勾边颜色"; 
	string SasUiControl = "ListPicker_ColorOp";
> = 0xFFFFFF00;

texture TexDiffuse
<
	string SasUiLabel = "Alpha通道贴图"; 
	string SasUiControl = "FilePicker";
>;

sampler SamplerDiffuse = sampler_state
{
	texture = (TexDiffuse);
};

struct VS_OUTPUT
{
	float4 position : POSITION;
};

//todo：传入缩放值，控制范围
VS_OUTPUT vs_main(float4 v_pos :POSITION)
{
	VS_OUTPUT result = (VS_OUTPUT)0;
	//将position沿着normal方向缩放
	result.position = mul(v_pos , WvpMat);

	return result;
}

float Width = 1.0f;

int stencil_ref = 1;
int stencil_pass = 1;
int stencil_fail = 1;
int stencil_func = 3;
int color_write= 0x0F;

technique TNoShader
{
	pass P0
	{
		ColorWriteEnable = color_write;
		CullMode = CW;
		ZENABLE = FALSE;
		ZFunc = LESS;

		Sampler[0] = (SamplerDiffuse);
		
		TextureFactor = (OutlineColor);
		ColorOp[0] = SELECTARG1;
		ColorArg1[0] = TFACTOR;
		AlphaOp[0] = MODULATE;
		AlphaArg1[0] = TFACTOR;
		AlphaArg2[0] = TEXTURE;

		ColorOp[1] = DISABLE;
		AlphaOp[1] = DISABLE;

		AlphaTestEnable = TRUE;
		AlphaFunc = GREATER;
		AlphaRef = 0;
		
		StencilEnable = TRUE;
		StencilRef = stencil_ref;
		StencilFunc = stencil_func;
		StencilPass = stencil_pass;
		StencilFail = stencil_fail;

		VertexShader = compile vs_2_0 vs_main();
		PixelShader	 = NULL;
	}
}
