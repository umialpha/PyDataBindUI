#define FOG_TYPE_NONE     0
#define FOG_TYPE_LINER    1
#define FOG_TYPE_HEIGHT   2

#if FOG_ENABLE
	uniform mediump vec4 FogInfo;
	uniform highp mat4 proj;
	#if EQUAL(FOG_TYPE, FOG_TYPE_LINER)
		float GetFog(vec4 PosWorldViewProj, vec4 PosWorld)
		{
			float fog_begin_in_view = (proj * vec4(0.0, 0.0, FogInfo.x, 1)).z;
			float fog_end_in_view = (proj * vec4(0.0, 0.0, FogInfo.y, 1)).z;
			return clamp(smoothstep(fog_begin_in_view, fog_end_in_view, PosWorldViewProj.z), 0.0, 1.0);  
		}
	#elif EQUAL(FOG_TYPE, FOG_TYPE_HEIGHT)
		#ifndef NEED_WORLD
		#define NEED_WORLD
		#endif
		
		float CustomSlerp(float begin, float end, float value)
		{
			return (value - begin) / (end - begin);
		}

		float GetFog(vec4 PosWorldViewProj, vec4 PosWorld)
		{
			float fog_begin_in_view = (proj * vec4(0.0, 0.0, FogInfo.x, 1)).z;
			float fog_end_in_view = (proj * vec4(0.0, 0.0, FogInfo.y, 1)).z;
			float distance_factor = clamp(smoothstep(fog_begin_in_view, fog_end_in_view, PosWorldViewProj.z), 0.0, 1.0);
			
			float fog_begin_in_height = FogInfo.z;
			float fog_end_in_height = FogInfo.w;
			//float height_factor = saturate(smoothstep(fog_begin_in_height, fog_end_in_height, vs_general.PosWorld.y));
			float height_factor = clamp(CustomSlerp(fog_begin_in_height, fog_end_in_height, PosWorld.y), 0.0, 1.0);

			return max(height_factor, distance_factor);
		}
	#elif EQUAL(FOG_TYPE, FOG_TYPE_NONE)
		float GetFog(vec4 PosWorldViewProj, vec4 PosWorld)
		{
			return 0.0;
		}
	#endif
#endif //FOG_ENABLE
