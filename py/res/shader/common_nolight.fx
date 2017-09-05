int Alpha = 0xFFFFFFFF;

texture	Tex0 : DiffuseMap
<
	string SasUiLabel = "ÑÕÉ«ÌùÍ¼"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse1 = sampler_state
{
	Texture	  =	(Tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
	MipMapLodBias = -0.5f;
};

technique TShader
{
	pass P0
	{
		Sampler[0] = (SamplerDiffuse1);

		TextureFactor = (Alpha);

		ColorOp[0] = MODULATE;
		ColorArg1[0] = TEXTURE;
		ColorArg2[0] = TFACTOR;
		AlphaOp[0] = MODULATE;
		AlphaArg1[0] = TEXTURE;
		AlphaArg2[0] = TFACTOR;
		TexCoordIndex[0] = 0;

		ColorOp[1] = DISABLE;
		AlphaOp[1] = DISABLE;

		VertexShader = NULL;
		PixelShader	 = NULL;
	}
}
