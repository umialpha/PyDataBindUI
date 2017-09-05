#include "shaderlib/common.fxl"

#include "shaderlib\vardefination.fxl"

///////////////所支持的宏
//控制移动方向

//控制颜色混合方式
#define COLOR_CONTROL_WHOLE_TIME					1
#define COLOR_CONTROL_LIFESPAN					2
#define COLOR_CONTROL_MULTIPLY_WHOLE_PARTICLE	3
#define COLOR_CONTROL_INTRP_WHOLE_PARTICLE		4


//控制宽高比方式
#define SCALE_CONTROL_RATION					1
#define SCALE_CONTROL_WIDTH_HEIGHT			2


//spr模式
#define SPR_MODE_PARTICLE_LIFE				0
#define SPR_MODE_SPR_LIFE						1
#define SPR_MODE_NONE							2
///////////////////

//宏的默认值
int GlobalParameter : SasGlobal
<
	int3 SasVersion = {1,0,0};
	
	NEOX_SASEFFECT_SUPPORT_MACRO_BEGIN  
	NEOX_SASEFFECT_MACRO("UnSupported", "COLOR_CONTROL_MODE", "UnSupported", "COLOR_CONTROL_LIFESPAN")  
	NEOX_SASEFFECT_MACRO("UnSupported", "SCALE_CONTROL_MODE", "UnSupported", "SCALE_CONTROL_WIDTH_HEIGHT")   	
	NEOX_SASEFFECT_MACRO("UnSupported", "SPR_MODE", "UnSupported", "SPR_MODE_NONE")
	NEOX_SASEFFECT_SUPPORT_MACRO_END
    

>;


struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color:		Color0;
	float2 Texcoord0 : TEXCOORD0;	
};

//////////////////////所有instance都相同的值
float3 forward_dir;
float4x4 mViewProjection : ViewProjection;	
float4 blend_op = { 5.0, 2.0, 1.0, 0};
//float script_alpha = 1;
float4 spr_info;	//.x为 总的子图数目 , .y为spr总长时间, .z为播放速度
#define CURVE_KEY_NUM  32
float4 color_key[CURVE_KEY_NUM];	//颜色曲线
float4 wh_key[CURVE_KEY_NUM];		//横宽高曲线
#define SPR_KEY_NUM  64
float4 spr_key[SPR_KEY_NUM];	//spr的所有值，todo：考虑spr也重采样算了

//////////////////////每个instance都不同的值
static const int MAX_INST_NUM = 20;		//最大instance数受register所限
float4 InstWorldMat[MAX_INST_NUM * 3];	//齐次矩阵去掉最后一列
float4 InstColor_g[MAX_INST_NUM];		//xyz为颜色，alpha为透明度
float4 InstUpDir[MAX_INST_NUM];			//xyz为up，alpha为emitter的scale.x 
float4 InstRightDir[MAX_INST_NUM];		//xyz为right，alpha为emitter的scale.y

float4 GetSprTransform(float spr_percent)
{
	float spr_idx = spr_percent * spr_info.x;
	//获得此帧spr和插值rate，todo：实际可以直接支持前后帧插值
	int spr_cur;
	float spr_inter;
	spr_inter = modf(spr_idx, spr_cur);
	
	float4 spr_transform = spr_key[spr_idx];
	return spr_transform;
}

VS_OUTPUT vs_main( float4 vPos : POSITION, float4 UV: TEXCOORD0,
					float4 localpos_spr: TEXCOORD4,
					float4 w_h_percent: TEXCOORD5, 
					float4 temp: TEXCOORD6,
					int4   meg_idx :COLOR1)
{

    VS_OUTPUT Output = (VS_OUTPUT)0;
	
	//计算当前的关键帧和插值factor
	float life_time = w_h_percent.w;
	float life_percent = w_h_percent.z;
	
	if(life_percent > 1.0f)
	{
		Output.Position = float4(0,0,-1,1);	//移到近屏幕以内，剔除掉
		return Output;
	}
	
	float4x4 mWorld = (float4x4)0;
	mWorld[0]= InstWorldMat[meg_idx[0]*3 + 0];
	mWorld[1]= InstWorldMat[meg_idx[0]*3 + 1];
	mWorld[2]= InstWorldMat[meg_idx[0]*3 + 2];
	mWorld = transpose(mWorld);
	mWorld[3].w = 1;
	
  
	//本地位置转为世界位置
	float3 pos_world = mul(float4(localpos_spr.xyz,1), mWorld).xyz;
	
	
	
	//w和h按照 r_angle进行旋转
	float r_angle =  temp.x + temp.y * life_time;
	float sin_r_angle = sin(r_angle);
	float cos_r_angle = cos(r_angle);
	
	float key_idx = life_percent * (CURVE_KEY_NUM - 1) ;
	int key_cur;
	float key_inter;
	key_inter = modf(key_idx, key_cur);
	int key_next = key_cur + 1;
	
		//颜色计算，前后两个关键帧插值得到
	float4 color_local = lerp(color_key[key_cur], color_key[key_next], key_inter);
#if EQUAL(COLOR_CONTROL_MODE, COLOR_CONTROL_WHOLE_TIME)
	Output.Color = InstColor_g[meg_idx[0]];
#elif  EQUAL(COLOR_CONTROL_MODE ,COLOR_CONTROL_LIFESPAN)
	Output.Color = color_local;
#elif  EQUAL(COLOR_CONTROL_MODE ,COLOR_CONTROL_MULTIPLY_WHOLE_PARTICLE)
	Output.Color = InstColor_g[meg_idx[0]] * color_local;
#elif  EQUAL(COLOR_CONTROL_MODE ,COLOR_CONTROL_INTRP_WHOLE_PARTICLE)
	Output.Color = (InstColor_g[meg_idx[0]] + color_local) * 0.5;
#endif
	//Output.Color.a *=script_alpha;
	
	//宽高scale计算，算法同颜色
	float4 wh_scale_local =  lerp(wh_key[key_cur], wh_key[key_next], key_inter);
	float2 w_h_scale = wh_scale_local.xy;
	
#if  EQUAL(SCALE_CONTROL_MODE ,SCALE_CONTROL_RATION)
	w_h_scale.y *= wh_scale_local.x;
#elif  EQUAL(SCALE_CONTROL_MODE ,SCALE_CONTROL_WIDTH_HEIGHT)
	
#endif	

	w_h_scale.xy *= w_h_percent.xy;
	w_h_scale.x *= InstUpDir[meg_idx[0]].w;
	w_h_scale.y *=  InstRightDir[meg_idx[0]].w;


	float3 up = InstUpDir[meg_idx[0]];
	float3 right = InstRightDir[meg_idx[0]];

	//计算uv延伸方向
	float3 u = up * sin_r_angle + right *cos_r_angle;
	float3 v = up * cos_r_angle - right * sin_r_angle;
	
	//缩放
	u *= w_h_scale.x;
	v *= w_h_scale.y;
	
	//组装4个点位置
	pos_world += vPos.x * u.xyz + vPos.y *v.xyz ;
	Output.Position = mul(float4(pos_world,1), mViewProjection);
	
	//spr
#if  EQUAL(SPR_MODE, SPR_MODE_NONE)
	//无spr	
	Output.Texcoord0.xy = UV.xy;
	
#elif  EQUAL(SPR_MODE ,SPR_MODE_PARTICLE_LIFE)
	//粒子生命期平铺
	float spr_init_time = localpos_spr.w;
	float spr_init_percent = spr_init_time/spr_info.y;
	float spr_percent = fmod(life_percent + spr_init_percent, 1.0f);
	
	float4 spr_transform = GetSprTransform( spr_percent);
	Output.Texcoord0.xy = lerp(spr_transform.xy, spr_transform.zw, UV.xy);

#elif  EQUAL(SPR_MODE ,SPR_MODE_SPR_LIFE)
	//spr自己运转
	float spr_init_time = localpos_spr.w;
	float spr_percent = fmod(spr_init_time + life_time * spr_info.z * 1000.0f, spr_info.y)/spr_info.y;
	
	float4 spr_transform = GetSprTransform( spr_percent);
	Output.Texcoord0.xy = lerp(spr_transform.xy, spr_transform.zw, UV.xy);
#endif	

    return Output;    
}

texture tex0:diffusemap
<
	string SasUiLabel = "贴"; 
	string SasUiControl = "FilePicker";
>;

sampler	SamplerDiffuse = sampler_state
{
	Texture	  =	(tex0);
	MipFilter =	LINEAR;
	MinFilter =	LINEAR;
	MagFilter =	LINEAR;
};
   
float4 ps_main( VS_OUTPUT In ) : COLOR
{ 
	float4 texcolor = tex2D(SamplerDiffuse, In.Texcoord0.xy);
	if(blend_op[3] == 0)
	{
		texcolor.xyz *= In.Color.xyz;
	}else
	{
		texcolor.xyz += In.Color.xyz;
	}
	
	texcolor.a *= In.Color.a;
	texcolor *= blend_op[2];
	return texcolor;
}


technique TShader
<
	string Description = "粒子渲染";
>
{
	pass p0
	{	
		CullMode = NONE;
	
		AlphaBlendEnable = TRUE;
		
		SrcBlend         = blend_op[0];
		DestBlend        = blend_op[1];
		
		AlphaTestEnable = true;
		AlphaRef = 0;
		AlphaFunc = Greater;
		ZWriteEnable = false;
	
		VertexShader = compile vs_3_0 vs_main();
		PixelShader	 = compile ps_3_0 ps_main();	
	}
}
