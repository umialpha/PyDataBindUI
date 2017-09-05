
#ifndef GL_ES
	#define texture2DLodEXT texture2DLod
	#define textureCubeLodEXT textureCubeLod
#else
	#ifdef GL_EXT_shader_texture_lod 
		#extension GL_EXT_shader_texture_lod : enable
	#else
		#define texture2DLodEXT texture2D
		#define textureCubeLodEXT textureCube
	#endif
#endif
// @Inputs: f4;-1:position,f3;-1:normal,f3;-1:tangent,f2;-1:texcoord0
// @Outputs: f4;-1:var_TEXCOORD10,f4;-1:var_TEXCOORD11,f2;-1:var_TEXCOORD0,f4;-1:var_TEXCOORD5,f1;-1:var_TEXCOORD7,f4;-1:gl_Position
// @Uniforms: b1;-1:FogEnable,f4;-1:FogInfo,f4[4];-1:ViewProjection,f4[4];-1:Projection,f4[4];-1:World
//#version 100 
uniform bool FogEnable;
uniform highp vec4 FogInfo;
uniform highp vec4 ViewProjection[4];
uniform highp vec4 Projection[4];
uniform highp vec4 World[4];
POSITION attribute highp vec4 position;
NORMAL attribute vec3 normal;
TANGENT attribute vec3 tangent;
TEXCOORD0 attribute highp vec2 texcoord0;

varying highp vec4 var_TEXCOORD11;
varying highp vec2 var_TEXCOORD0;
varying highp vec4 var_TEXCOORD5;

void main()
{
	highp vec4 v0;
	highp vec4 v1;
	highp vec4 v2;
	vec3 v3;
	v3.xyz = tangent;
	float h4;
	h4 = 1.000000e+000;
	vec3 v5;
	float h6;
	h6 = length(tangent);
	if ((h6>1.500000e+000))
	{
		h4 = -1.000000e+000;
		v3.xyz = normalize(tangent);
	}
	v5.xyz = cross(cross(normal,v3),normal);
	vec3 v7;
	vec3 v8;
	vec3 v9;
	vec3 v10;
	v10.xyz = World[0].xyz;
	v7.xyz = v10;
	vec3 v11;
	v11.xyz = World[1].xyz;
	v8.xyz = v11;
	vec3 v12;
	v12.xyz = World[2].xyz;
	v9.xyz = v12;
	vec3 v13;
	vec3 v14;
	v13.xyz = ((v5.zzz*v9)+((v5.yyy*v8)+(v5.xxx*v7)));
	v14.xyz = ((normal.zzz*v9)+((normal.yyy*v8)+(normal.xxx*v7)));
	highp vec4 v15;
	v15.xyzw = (World[3]+((World[2]*position.zzzz)+((World[1]*position.yyyy)+(World[0]*position.xxxx))));
	highp vec4 v16;
	v16.w = 1.000000e+000;
	v16.xyz = v15.xyz;
	v2.xyzw = v16;
	highp vec3 v17;
	v17.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	v2.xyz = (v15.xyz+v17);
	highp vec4 v18;
	v18.xyzw = (ViewProjection[3]+((ViewProjection[2]*v2.zzzz)+((ViewProjection[1]*v2.yyyy)+(ViewProjection[0]*v2.xxxx))));
	v1.xyzw = v2;
	v1.w = v18.w;
	highp float f19;
	if (FogEnable)
	{
		f19 = clamp(smoothstep((Projection[3]+(Projection[2]*FogInfo.xxxx)).z,(Projection[3]+(Projection[2]*FogInfo.yyyy)).z,v18.z),0.000000e+000,1.000000e+000);
	}
	else
	{
		f19 = 0.000000e+000;
	}
	highp vec4 v20;
	v20.w = 0.000000e+000;
	highp vec3 v21;
	v21.xyz = v13;
	v20.xyz = v21;
	highp vec4 v22;
	highp vec3 v23;
	v23.xyz = v14;
	v22.xyz = v23;
	highp float f24;
	f24 = h4;
	v22.w = f24;
	v0.xyzw = v18;

	var_TEXCOORD11.xyzw = v22;
	var_TEXCOORD0.xy = texcoord0;
	var_TEXCOORD5.xyzw = v1;



	gl_Position.xyzw = v0;
}



