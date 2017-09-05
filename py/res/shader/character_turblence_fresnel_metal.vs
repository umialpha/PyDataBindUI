// ! ForwardPassVS.hlsl.usf:MainVS

#include <metal_stdlib>

using namespace metal;

struct VSOut
{
	float4 OUT_TEXCOORD10 ;
	float4 OUT_TEXCOORD11 ;
	float2 OUT_TEXCOORD0 ;
	float4 OUT_TEXCOORD5 ;
	float OUT_TEXCOORD7 ;
	float4 Position [[ position ]];
};

  struct VSConstants
{
        bool FogEnable;
    float4 FogInfo;
    float4x4 ViewProjection;
    float4x4 Projection;
    float4x4 World;

};

#ifndef NEOX_METAL_NO_ATTR
struct VertexInput
{
        float4 IN_POSITION [[attribute(POSITION)]];
    float3 IN_NORMAL0 [[attribute(NORMAL)]];
    float3 IN_TANGENT0 [[attribute(TANGENT)]];
    float2 IN_TEXCOORD0 [[attribute(TEXTURE0)]];

};
#endif

vertex VSOut metal_main(
#ifndef NEOX_METAL_NO_ATTR
				VertexInput  vData [ [stage_in] ],
#endif
				constant VSConstants &constants[ [buffer(0)] ])

{
    VSOut tempOUT;
#ifndef NEOX_METAL_NO_ATTR

	half3 v0;
	half3 v1;
	v1.xyz = half3(vData.IN_TANGENT0);
	v0.xyz = v1;
	half3 v2;
	half3 v3;
	v3.xyz = half3(vData.IN_NORMAL0);
	v2.xyz = v3;
	float4 v4;
	float4 v5;
	half3 v6;
	v6.xyz = v0;
	half h7;
	half h8;
	h8 = half(1.0);
	h7 = h8;
	half3 v9;
	half h10;
	h10 = length(v0);
	half h11;
	h11 = half(1.50000000);
	if (h10>h11)
	{
		half h12;
		h12 = half(-1.0);
		h7 = h12;
		v6.xyz = normalize(v0);
	}
	v9.xyz = cross(cross(v2,v6),v2);
	half3 v13;
	half3 v14;
	half3 v15;
	half3 v16;
	v16.xyz = half3(constants.World[0].xyz);
	v13.xyz = v16;
	half3 v17;
	v17.xyz = half3(constants.World[1].xyz);
	v14.xyz = v17;
	half3 v18;
	v18.xyz = half3(constants.World[2].xyz);
	v15.xyz = v18;
	half3 v19;
	half3 v20;
	v19.xyz = ((v9.zzz*v15)+((v9.yyy*v14)+(v9.xxx*v13)));
	v20.xyz = ((v2.zzz*v15)+((v2.yyy*v14)+(v2.xxx*v13)));
	float4 v21;
	v21.xyzw = (constants.World[3]+((constants.World[2]*vData.IN_POSITION.zzzz)+((constants.World[1]*vData.IN_POSITION.yyyy)+(constants.World[0]*vData.IN_POSITION.xxxx))));
	float4 v22;
	v22.w = 1.0;
	v22.xyz = v21.xyz;
	v5.xyzw = v22;
	half3 v23;
	v23.xyz = half3(0.0,0.0,0.0);
	float3 v24;
	v24.xyz = float3(v23);
	v5.xyz = (v21.xyz+v24);
	float4 v25;
	v25.xyzw = (constants.ViewProjection[3]+((constants.ViewProjection[2]*v5.zzzz)+((constants.ViewProjection[1]*v5.yyyy)+(constants.ViewProjection[0]*v5.xxxx))));
	v4.xyzw = v5;
	v4.w = v25.w;
	float f26;
	if (constants.FogEnable)
	{
		f26 = precise::clamp(smoothstep((constants.Projection[3]+(constants.Projection[2]*constants.FogInfo.xxxx)).z,(constants.Projection[3]+(constants.Projection[2]*constants.FogInfo.yyyy)).z,v25.z),0.0,1.0);
	}
	else
	{
		f26 = 0.0;
	}
	float4 v27;
	v27.w = 0.0;
	float3 v28;
	v28.xyz = float3(v19);
	v27.xyz = v28;
	float4 v29;
	float3 v30;
	v30.xyz = float3(v20);
	v29.xyz = v30;
	float f31;
	f31 = float(h7);
	v29.w = f31;
	VSOut t32;
	t32.OUT_TEXCOORD10.xyzw = v27;
	t32.OUT_TEXCOORD11.xyzw = v29;
	t32.OUT_TEXCOORD0.xy = vData.IN_TEXCOORD0;
	t32.OUT_TEXCOORD5.xyzw = v4;
	t32.OUT_TEXCOORD7 = f26;
	t32.Position.xyzw = v25;
	return t32;

#endif
    return tempOUT;
}

