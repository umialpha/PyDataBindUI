#include <metal_stdlib>
#include <metal_math>

using namespace metal;

#define EQUAL(x,y) !(x-y)

//控制颜色混合方式
#define COLOR_CONTROL_WHOLE_TIME				1
#define COLOR_CONTROL_LIFESPAN					2
#define COLOR_CONTROL_MULTIPLY_WHOLE_PARTICLE	3
#define COLOR_CONTROL_INTRP_WHOLE_PARTICLE		4

//变色开关
#define USE_HSV_OFFSET_TRUE						1
#define USE_HSV_OFFSET_FALSE					2

//spr模式
#define SPR_MODE_PARTICLE_LIFE					0
#define SPR_MODE_SPR_LIFE						1
#define SPR_MODE_NONE							2


#ifndef NEOX_METAL_NO_ATTR
struct VertexInput
{
	float4 vPos [[attribute(POSITION)]];
	float4 UV [[attribute(TEXTURE0)]];
	float4 localpos_spr [[attribute(TEXTURE4)]];
	float4 w_h_percent [[attribute(TEXTURE5)]];
	float4 temp [[attribute(TEXTURE6)]];
	uchar4 meg_idx [[attribute(TEXTURE7)]];
};
#endif


#define CURVE_KEY_NUM  32
#define SPR_KEY_NUM  64
#define MAX_INST_NUM  20		//最大instance数受register所限

struct VSConstants
{
	bool scale_control_ration_wh;

	//////////////////////所有instance都相同的值
	float3 forward_dir;
	float4x4 mViewProjection;
	float script_alpha;
	float4 spr_info;
	float4 color_key[CURVE_KEY_NUM];	//颜色曲线
	float4 wh_key[CURVE_KEY_NUM];		//横宽高曲线
	float4 spr_key[SPR_KEY_NUM];	//spr的所有值，todo：考虑spr也重采样算了

	//////////////////////每个instance都不同的值
	float4 InstWorldMat[MAX_INST_NUM * 3];	//齐次矩阵去掉最后一列
	float4 InstColor_g[MAX_INST_NUM];		//xyz为颜色，alpha为透明度
	float4 InstUpDir[MAX_INST_NUM];			//xyz为up，alpha为emitter的scale.x 
	float4 InstRightDir[MAX_INST_NUM];		//xyz为right，alpha为emitter的scale.y
};


struct VertexOutput
{
	float4 Position [[position]];
	float4 Color;
	float4 Texcoord0;
};


static float4 GetSprTransform(float spr_percent, constant float4 *spr_key, float4 spr_info)
{
	float spr_idx = spr_percent * spr_info.x;
	//获得此帧spr和插值rate，todo：实际可以直接支持前后帧插值
	float spr_cur_f;
	float spr_inter;
	spr_inter = modf(spr_idx, spr_cur_f);
	int spr_cur = (int)spr_cur_f;
	
	float4 spr_transform = spr_key[spr_cur];
	return spr_transform;
}


vertex VertexOutput metal_main(
#ifndef NEOX_METAL_NO_ATTR
	VertexInput vData[[stage_in]],
#endif
	constant VSConstants &constants[[buffer(0)]])
{
    VertexOutput Output;
#ifndef NEOX_METAL_NO_ATTR

	//计算当前的关键帧和插值factor
	float life_time = vData.w_h_percent.w;
	float life_percent = vData.w_h_percent.z;
	
	if (life_percent > 1.0f)
	{
		Output.Position = float4(0,0,-1,1);	//移到近屏幕以内，剔除掉
		return Output;
	}
	
	float4x4 mWorld;
	mWorld[0]= constants.InstWorldMat[vData.meg_idx[0]*3 + 0];
	mWorld[1]= constants.InstWorldMat[vData.meg_idx[0]*3 + 1];
	mWorld[2]= constants.InstWorldMat[vData.meg_idx[0]*3 + 2];
	mWorld[3]= float4(0,0,0,1);
	mWorld = transpose(mWorld);
	
  
	//本地位置转为世界位置
	float3 pos_world = (mWorld * float4(vData.localpos_spr.xyz,1)).xyz;
	
	
	
	//w和h按照 r_angle进行旋转
	float r_angle =  vData.temp.x + vData.temp.y * life_time;
	float sin_r_angle = sin(r_angle);
	float cos_r_angle = cos(r_angle);
	
	float key_idx = life_percent * (CURVE_KEY_NUM - 1) ;
	float key_cur_f;
	float key_inter;
	key_inter = modf(key_idx, key_cur_f);
	int key_cur = (int)key_cur_f;
	int key_next = key_cur + 1;
	
		//颜色计算，前后两个关键帧插值得到
	float4 color_local = mix(constants.color_key[key_cur], constants.color_key[key_next], key_inter);
#if EQUAL(COLOR_CONTROL_MODE, COLOR_CONTROL_WHOLE_TIME)
	Output.Color = constants.InstColor_g[vData.meg_idx[0]];
#elif  EQUAL(COLOR_CONTROL_MODE ,COLOR_CONTROL_LIFESPAN)
	Output.Color = color_local;
#elif  EQUAL(COLOR_CONTROL_MODE ,COLOR_CONTROL_MULTIPLY_WHOLE_PARTICLE)
	Output.Color = constants.InstColor_g[vData.meg_idx[0]] * color_local;
#elif  EQUAL(COLOR_CONTROL_MODE ,COLOR_CONTROL_INTRP_WHOLE_PARTICLE)
	Output.Color = (constants.InstColor_g[vData.meg_idx[0]] + color_local) * 0.5;
#endif
	Output.Color.a *= constants.script_alpha;
	
	//宽高scale计算，算法同颜色
	float4 wh_scale_local = mix(constants.wh_key[key_cur], constants.wh_key[key_next], key_inter);
	float2 w_h_scale = wh_scale_local.xy;
	
	if (constants.scale_control_ration_wh)
	{
		w_h_scale.y *= wh_scale_local.x;
	}

	w_h_scale.xy *= vData.w_h_percent.xy;
	w_h_scale.x *= constants.InstUpDir[vData.meg_idx[0]].w;
	w_h_scale.y *=  constants.InstRightDir[vData.meg_idx[0]].w;


	float3 up = constants.InstUpDir[vData.meg_idx[0]].xyz;
	float3 right = constants.InstRightDir[vData.meg_idx[0]].xyz;

	//计算uv延伸方向
	float3 u = up * sin_r_angle + right * cos_r_angle;
	float3 v = up * cos_r_angle - right * sin_r_angle;
	
	//缩放
	u *= w_h_scale.x;
	v *= w_h_scale.y;
	
	//组装4个点位置
	pos_world += vData.vPos.x * u.xyz + vData.vPos.y *v.xyz ;
	Output.Position = constants.mViewProjection * float4(pos_world,1);
	
	//spr
#if  EQUAL(SPR_MODE, SPR_MODE_NONE)
	//无spr	
	Output.Texcoord0.xy = vData.UV.xy;
	
#elif  EQUAL(SPR_MODE ,SPR_MODE_PARTICLE_LIFE)
	//粒子生命期平铺
	float spr_init_time = vData.localpos_spr.w;
	float spr_init_percent = spr_init_time / constants.spr_info.y;
	float spr_percent = fmod(life_percent + spr_init_percent, 1.0f);
	
	float4 spr_transform = GetSprTransform(spr_percent, constants.spr_key, constants.spr_info);
	Output.Texcoord0.xy = mix(spr_transform.xy, spr_transform.zw, vData.UV.xy);

#elif  EQUAL(SPR_MODE ,SPR_MODE_SPR_LIFE)
	//spr自己运转
	float spr_init_time = vData.localpos_spr.w;
	float spr_percent = fmod(spr_init_time + life_time * constants.spr_info.z * 1000.0f, constants.spr_info.y) / constants.spr_info.y;
	
	float4 spr_transform = GetSprTransform(spr_percent, constants.spr_key, constants.spr_info);
	Output.Texcoord0.xy = mix(spr_transform.xy, spr_transform.zw, vData.UV.xy);
#endif	

#endif
    return Output;    
}
