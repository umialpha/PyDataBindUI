#if LIT_ENABLE

float3 ShadowLightLit(
					const float4 light_diffuse_type,
					const float4 light_attr,
					const float4 light_attr_custom,
					const float3 position,
					const float3 normal_dir
					)
{
	float3 light_dir = float3(0.0);
	float light_atten = 1.0;
	if (light_diffuse_type.w == 3.0)
	{
		light_dir = light_attr.xyz;
	} else if (light_diffuse_type.w == 1.0)
	{
		light_dir = position.xyz - light_attr.xyz;
		light_atten = clamp(1.0 - pow(abs(dot(light_dir/light_attr.w, light_dir/light_attr.w)), 2.0/(light_attr_custom.x)), 0.0, 1.0);
		light_dir = normalize(light_dir);
	}

	float normal_dot_light = clamp(dot(normal_dir, -light_dir), 0.0, 1.0);
	return light_atten * light_diffuse_type.xyz * normal_dot_light;
}

#endif 	//litenable