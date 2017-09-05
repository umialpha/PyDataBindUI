#define FOG_TYPE_NONE 		0
#define FOG_TYPE_LINER 		1
#define FOG_TYPE_HEIGHT 	2

#if FOG_ENABLE

#if EQUAL(FOG_TYPE, FOG_TYPE_LINER)
float GetFog(float4 PosWorldViewProj, float4 PosWorld, constant float4 FogInfo, constant float4x4 proj)
{
	float fog_begin_in_view = (float4(0, 0, FogInfo.x, 1) * proj).z;
	float fog_end_in_view = (float4(0, 0, FogInfo.y, 1) * proj).z;
	return saturate(smoothstep(fog_begin_in_view, fog_end_in_view, PosWorldViewProj.z));	
}
#elif EQUAL(FOG_TYPE, FOG_TYPE_HEIGHT)
#ifndef NEED_WORLD
#define NEED_WORLD
#endif
float CustomSlerp(float begin, float end, float value)
{
	return (value - begin) / (end - begin);
}

float GetFog(float4 PosWorldViewProj, float4 PosWorld, constant float4& FogInfo, constant float4x4& proj)
{
	float fog_begin_in_view = (float4(0, 0,FogInfo.x,1) * proj).z; 
	float fog_end_in_view= (float4(0, 0,FogInfo.y,1) * proj).z;
	float distance_factor = saturate(smoothstep(fog_begin_in_view, fog_end_in_view, PosWorldViewProj.z));
	
	float fog_begin_in_height = FogInfo.z;
	float fog_end_in_height = FogInfo.w;
	//float height_factor = saturate(smoothstep(fog_begin_in_height, fog_end_in_height, vs_general.PosWorld.y));
	float height_factor = saturate(CustomSlerp(fog_begin_in_height, fog_end_in_height, PosWorld.y));

	return max(height_factor, distance_factor);
}
#elif EQUAL(FOG_TYPE, FOG_TYPE_NONE)
float GetFog(float4 PosWorldViewProj, float4 PosWorld)
{
	return 0;
}
#endif
#endif //FOG_ENABLE