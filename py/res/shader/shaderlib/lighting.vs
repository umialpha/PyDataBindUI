#if LIT_ENABLE

#ifndef NEED_WORLD
#define NEED_WORLD
#endif

#ifndef NEED_NORMAL
#define NEED_NORMAL
#endif

float4 ShadowLightAttr[LIGHT_ATTR_ITEM_NUM ];
float4 Ambient;

//////////////////		

//比trunk简化，没有dir light，没有specular，没有ambient
float3 PointLightLit(
					in float4 light_diffuse,       //diffuse和类型
					in float4 light_attr,			 //方向光xyz为方向，点光xyz为位置，w为范围
					in float4 light_attr_custom,	 //点光特有的
					in float3 position,			 //受光点的位置
				    in float3 normal_dir			 //受光点的法线方向
					)		
{
		float3 light_dir = 0;
		float light_atten = 0;	//距离衰减因子
		
		light_dir = position.xyz - light_attr.xyz;
		//	light_atten = saturate( 1 - dot(light_dir/light_attr.w,light_dir/light_attr.w)); 
		light_atten =  saturate( 1 - dot(light_dir/light_attr.w,light_dir/light_attr.w)); 
		light_atten = pow(light_atten, light_attr_custom.x + 0.001);
	
		light_dir = normalize(light_dir);

		float normal_dot_light = saturate(dot(normal_dir, -light_dir));
		return light_atten * light_diffuse.xyz * normal_dot_light ;		
}

float3 ShadowLightLit(
					in float4 light_diffuse_type, //diffuse和类型
					in float4 light_attr,			 //方向光xyz为方向，点光xyz为位置，w为范围
					in float4 light_attr_custom,	 //点光特有的
					in float3 position,			 //受光点的位置
				    in float3 normal_dir			 //受光点的法线方向
					)	 //输出specular
{

		float3 light_dir = 0;
		float light_atten = 1;	//距离衰减因子
		if (light_diffuse_type.w == 3)
		{
			//方向光	
			light_dir = light_attr.xyz; //点光的lightdir已经normal过的
		}else if (light_diffuse_type.w == 1)
		{
			//点光
			light_dir = position.xyz - light_attr.xyz;
		//	light_atten = saturate( 1 - dot(light_dir/light_attr.w,light_dir/light_attr.w)); 
			light_atten = saturate( 1 - pow( abs(dot(light_dir/light_attr.w,light_dir/light_attr.w)), 2/(light_attr_custom.x))); 		//此处使用简化强度计算，按距离衰减
			light_dir = normalize(light_dir);
		}
		
		float normal_dot_light = saturate(dot(normal_dir, -light_dir));
		return light_atten * light_diffuse_type.xyz * normal_dot_light;
	
}

#endif 	//litenable