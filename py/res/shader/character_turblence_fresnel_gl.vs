// Compiled by HLSLCC 0.63
// @Inputs: f4;-1:position,f4;-1:normal,f4;-1:tangent,f4;-1:blendIndices,f4;-1:blendWeights,f2;-1:texcoord0
// @Outputs: f4;-1:var_TEXCOORD10,f4;-1:var_TEXCOORD11,f2;-1:var_TEXCOORD0,f4;-1:var_TEXCOORD5,f1;-1:var_TEXCOORD7,f4;-1:gl_Position
// @Uniforms: b1;-1:FogEnable,f4;-1:FogInfo,f4[4];-1:ViewProjection,f4[4];-1:Projection,f4[4];-1:World,f4[180];-1:worldPalette
//#version 100 
#ifndef TOON_ENABLE
#define TOON_ENABLE FALSE
#endif

uniform bool FogEnable;
uniform highp vec4 FogInfo;
uniform highp vec4 ViewProjection[4];
uniform highp vec4 Projection[4];
uniform highp vec4 World[4];
uniform highp vec4 worldPalette[180];
uniform highp vec4 CameraPos;

#if TOON_ENABLE
uniform highp float outline_width;
#endif

POSITION attribute highp vec4 position;
NORMAL attribute vec4 normal;
TANGENT attribute vec4 tangent;
BLENDINDICES attribute highp vec4 blendIndices;
BLENDWEIGHT attribute highp vec4 blendWeights;
TEXCOORD0 attribute highp vec2 texcoord0;

varying highp vec4 var_TEXCOORD11;
varying highp vec2 var_TEXCOORD0;
varying highp vec4 var_TEXCOORD5;
varying highp float var_TEXCOORD7;

#if TOON_ENABLE
void outline()
{
	highp vec4 pos = position;
	highp vec4 nor = normal;

	highp vec4 v0;
	highp vec4 v1;
	highp vec4 v2;
	highp ivec4 v3;
	v3.xyzw = ivec4(blendIndices);
	vec4 v4;
	v4.xyzw = normal;
	vec4 v5;
	v5.xyzw = tangent;
	highp vec4 v6;
	highp vec4 v7;
	highp vec3 v8;
	highp vec3 v9;
	highp vec3 v10;
	v10.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	v9.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	v8.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	highp int i11;
	i11 = 0;
	for (;i11<4;)
	{
		if ((v3[i11]<90))
		{
			highp int i12;
			i12 = 1;
			highp float f13;
			f13 = dot(worldPalette[(v3.x*2)],worldPalette[(v3[i11]*2)]);
			if (((i11>0)&&(f13<0.000000e+000)))
			{
				i12 = -1;
			}
			highp float f14;
			f14 = float(i12);
			v6.xyzw = (vec4(f14)*worldPalette[(v3[i11]*2)]);
			v7.xyzw = worldPalette[((v3[i11]*2)+1)];
		}
		highp vec3 v15;
		v15.xyz = (position.xyz*v7.www);
		highp vec3 v16;
		highp vec3 v17;
		v17.xyz = normal.xyz;
		v16.xyz = v17;
		highp vec3 v18;
		highp vec3 v19;
		v19.xyz = tangent.xyz;
		v18.xyz = v19;
		v10.xyz = (v10+((((cross(v6.xyz,((v6.www*v15)+cross(v6.xyz,v15)))*vec3(2.000000e+000,2.000000e+000,2.000000e+000))+v15)+v7.xyz)*vec3(blendWeights[i11])));
		v9.xyz = (v9+(((cross(v6.xyz,((v6.www*v16)+cross(v6.xyz,v16)))*vec3(2.000000e+000,2.000000e+000,2.000000e+000))+v16)*vec3(blendWeights[i11])));
		v8.xyz = (v8+(((cross(v6.xyz,((v6.www*v18)+cross(v6.xyz,v18)))*vec3(2.000000e+000,2.000000e+000,2.000000e+000))+v18)*vec3(blendWeights[i11])));
		i11 = (i11+1);
	}
	vec3 v20;
	v20.xyz = v9;
	v4.xyz = v20;
	vec3 v21;
	v21.xyz = v8;
	v5.xyz = v21;
	vec3 v22;
	v22.xyz = v5.xyz;
	float h23;
	h23 = 1.000000e+000;
	float h24;
	h24 = length(v22);
	if ((h24>1.500000e+000))
	{
		h23 = -1.000000e+000;
		v22.xyz = normalize(v5.xyz);
	}
	vec3 v25;
	vec3 v26;
	v25.xyz = cross(cross(v4.xyz,v22),v4.xyz);
	v26.xyz = v4.xyz;
	vec3 v27;
	vec3 v28;
	vec3 v29;
	vec3 v30;
	v30.xyz = World[0].xyz;
	v27.xyz = v30;
	vec3 v31;
	v31.xyz = World[1].xyz;
	v28.xyz = v31;
	vec3 v32;
	v32.xyz = World[2].xyz;
	v29.xyz = v32;
	highp vec3 v33;
	highp vec3 v34;
	highp vec3 v35;
	v35.xyz = ((v25.zzz*v29)+((v25.yyy*v28)+(v25.xxx*v27)));
	v33.xyz = v35;
	highp vec3 v36;
	v36.xyz = ((v26.zzz*v29)+((v26.yyy*v28)+(v26.xxx*v27)));
	v34.xyz = v36;
	highp vec4 v37;
	v37.xyzw = (World[3]+((World[2]*v10.zzzz)+((World[1]*v10.yyyy)+(World[0]*v10.xxxx))));

	highp vec4 wpos = v37;
	highp float camDis = length(CameraPos.xyz - wpos.xyz); 
	camDis *= 0.01;
	mediump float disIndex = 1.0 + min(5.0,camDis); 
	mediump vec4 pos_offset = vec4(normalize(nor.rgb) * outline_width * disIndex, 0.0);
	
	pos = vec4(v10 + pos_offset.xyz, 1.0);
	wpos = (World[3]+((World[2]*pos.zzzz)+((World[1]*pos.yyyy)+(World[0]*pos.xxxx))));
	gl_Position = (ViewProjection[3]+((ViewProjection[2]*wpos.zzzz)+((ViewProjection[1]*wpos.yyyy)+(ViewProjection[0]*wpos.xxxx))));
}
#endif


void base_main()
{
	highp vec4 v0;
	highp vec4 v1;
	highp vec4 v2;
	highp ivec4 v3;
	v3.xyzw = ivec4(blendIndices);
	vec4 v4;
	v4.xyzw = normal;
	vec4 v5;
	v5.xyzw = tangent;
	highp vec4 v6;
	highp vec4 v7;
	highp vec3 v8;
	highp vec3 v9;
	highp vec3 v10;
	v10.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	v9.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	v8.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	highp int i11;
	i11 = 0;
	for (;i11<4;)
	{
		if ((v3[i11]<90))
		{
			highp int i12;
			i12 = 1;
			highp float f13;
			f13 = dot(worldPalette[(v3.x*2)],worldPalette[(v3[i11]*2)]);
			if (((i11>0)&&(f13<0.000000e+000)))
			{
				i12 = -1;
			}
			highp float f14;
			f14 = float(i12);
			v6.xyzw = (vec4(f14)*worldPalette[(v3[i11]*2)]);
			v7.xyzw = worldPalette[((v3[i11]*2)+1)];
		}
		highp vec3 v15;
		v15.xyz = (position.xyz*v7.www);
		highp vec3 v16;
		highp vec3 v17;
		v17.xyz = normal.xyz;
		v16.xyz = v17;
		highp vec3 v18;
		highp vec3 v19;
		v19.xyz = tangent.xyz;
		v18.xyz = v19;
		v10.xyz = (v10+((((cross(v6.xyz,((v6.www*v15)+cross(v6.xyz,v15)))*vec3(2.000000e+000,2.000000e+000,2.000000e+000))+v15)+v7.xyz)*vec3(blendWeights[i11])));
		v9.xyz = (v9+(((cross(v6.xyz,((v6.www*v16)+cross(v6.xyz,v16)))*vec3(2.000000e+000,2.000000e+000,2.000000e+000))+v16)*vec3(blendWeights[i11])));
		v8.xyz = (v8+(((cross(v6.xyz,((v6.www*v18)+cross(v6.xyz,v18)))*vec3(2.000000e+000,2.000000e+000,2.000000e+000))+v18)*vec3(blendWeights[i11])));
		i11 = (i11+1);
	}
	vec3 v20;
	v20.xyz = v9;
	v4.xyz = v20;
	vec3 v21;
	v21.xyz = v8;
	v5.xyz = v21;
	vec3 v22;
	v22.xyz = v5.xyz;
	float h23;
	h23 = 1.000000e+000;
	float h24;
	h24 = length(v22);
	if ((h24>1.500000e+000))
	{
		h23 = -1.000000e+000;
		v22.xyz = normalize(v5.xyz);
	}
	vec3 v25;
	vec3 v26;
	v25.xyz = cross(cross(v4.xyz,v22),v4.xyz);
	v26.xyz = v4.xyz;
	vec3 v27;
	vec3 v28;
	vec3 v29;
	vec3 v30;
	v30.xyz = World[0].xyz;
	v27.xyz = v30;
	vec3 v31;
	v31.xyz = World[1].xyz;
	v28.xyz = v31;
	vec3 v32;
	v32.xyz = World[2].xyz;
	v29.xyz = v32;
	highp vec3 v33;
	highp vec3 v34;
	highp vec3 v35;
	v35.xyz = ((v25.zzz*v29)+((v25.yyy*v28)+(v25.xxx*v27)));
	v33.xyz = v35;
	highp vec3 v36;
	v36.xyz = ((v26.zzz*v29)+((v26.yyy*v28)+(v26.xxx*v27)));
	v34.xyz = v36;
	highp vec4 v37;
	v37.xyzw = (World[3]+((World[2]*v10.zzzz)+((World[1]*v10.yyyy)+(World[0]*v10.xxxx))));
	highp vec4 v38;
	v38.w = 1.000000e+000;
	v38.xyz = v37.xyz;
	v2.xyzw = v38;
	highp vec3 v39;
	v39.xyz = vec3(0.000000e+000,0.000000e+000,0.000000e+000);
	v2.xyz = (v37.xyz+v39);
	highp vec4 v40;
	v40.xyzw = (ViewProjection[3]+((ViewProjection[2]*v2.zzzz)+((ViewProjection[1]*v2.yyyy)+(ViewProjection[0]*v2.xxxx))));
	v1.xyzw = v2;
	v1.w = v40.w;
	highp float f41;
	if (FogEnable)
	{
		f41 = clamp(smoothstep((Projection[3]+(Projection[2]*FogInfo.xxxx)).z,(Projection[3]+(Projection[2]*FogInfo.yyyy)).z,v40.z),0.000000e+000,1.000000e+000);
	}
	else
	{
		f41 = 0.000000e+000;
	}
	highp vec4 v42;
	v42.w = 0.000000e+000;
	v42.xyz = v33;
	highp vec4 v43;
	v43.xyz = v34;
	highp float f44;
	f44 = h23;
	v43.w = f44;
	v0.xyzw = v40;

	var_TEXCOORD11.xyzw = v43;
	var_TEXCOORD0.xy = texcoord0;
	var_TEXCOORD5.xyzw = v1;
	var_TEXCOORD7 = f41;


	gl_Position.xyzw = v0;
}



