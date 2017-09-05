
struct VS_INPUT { 
	float4 pos			: POSITION;
	float4 tex0			: TEXCOORD0; 
}; 

VS_INPUT VSMain(VS_INPUT In)
{
	VS_INPUT Out = (VS_INPUT)0;
	Out.pos = In.pos;
	Out.tex0.xyz = In.tex0.xyz;
	
	return Out;
}

VS_INPUT DownSamplePass(VS_INPUT In)
{
	VS_INPUT Out = (VS_INPUT)0;
	Out.pos = In.pos;
	Out.tex0.xyz = In.tex0.xyz;
	
	return Out;
}

VS_INPUT HorizontalBlurPass(VS_INPUT In)
{
	VS_INPUT Out = (VS_INPUT)0;
	Out.pos = In.pos;
	Out.tex0.xyz = In.tex0.xyz;
	
	return Out;
}

VS_INPUT VerticalBlurPass(VS_INPUT In)
{
	VS_INPUT Out = (VS_INPUT)0;
	Out.pos = In.pos;
	Out.tex0.xyz = In.tex0.xyz;
	
	return Out;
}
