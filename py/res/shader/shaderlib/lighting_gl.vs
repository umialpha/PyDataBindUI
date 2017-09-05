#if LIT_ENABLE

varying lowp vec3 Lighting;

#ifndef NEED_WORLD
#define NEED_WORLD
#endif

#ifndef NEED_NORMAL
#define NEED_NORMAL
#endif

uniform highp vec4 ShadowLightAttr[LIGHT_ATTR_ITEM_NUM];
uniform lowp vec4 Ambient;
uniform highp vec4 PointLightAttrs[POINT_LIGHT_ATTR_ITEM_NUM];


lowp vec3 ShadowLightLit(
					in mediump vec4 light_diffuse_type,
					in highp vec4 light_attr,
					in highp vec4 light_attr_custom,
					in highp vec3 position,
					in highp vec3 normal_dir
					)
{
	highp vec3 light_dir = vec3(0.0);
	lowp float light_atten = 1.0;
	if (light_diffuse_type.w == 3.0)
	{
		light_dir = light_attr.xyz;
	} else if (light_diffuse_type.w == 1.0)
	{
		light_dir = position.xyz - light_attr.xyz;
		light_atten = clamp(1.0 - pow(abs(dot(light_dir/light_attr.w, light_dir/light_attr.w)), 2.0/(light_attr_custom.x)), 0.0, 1.0);
		light_dir = normalize(light_dir);
	}

	lowp float normal_dot_light = clamp(dot(normal_dir, -light_dir), 0.0, 1.0);
	return light_atten * light_diffuse_type.xyz * normal_dot_light;
}

#endif 	//litenable