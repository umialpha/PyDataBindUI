float4x4 wvp;
float4x4 texTrans0;

struct VS_INPUT
{
	float4 v_pos:		POSITION;
	float4 v_texcoord0: TEXCOORD0;
	float4 v_color:		COLOR;
};

struct PS_INPUT
{
	float4 Color:		COLOR0;			//¶¥µãÉ«
	float4 Position:	POSITION;			//Êä³öÎ»ÖÃ
	float4 TexCoord0:	TEXCOORD0;		//µÚÒ»²ãuv£¬Ò»°ãÓÃÓÚdiffuse
};

PS_INPUT main(VS_INPUT IN)
{
	PS_INPUT OUT = (PS_INPUT)0;
	OUT.Color	= IN.v_color;
	OUT.Position = mul(IN.v_pos,wvp);
	OUT.TexCoord0.xyz = mul(float3(IN.v_texcoord0.xy,1), (float3x3)texTrans0);
	
	return OUT;
}
