        
int GlobalParameter : SasGlobal
<
	string SasSuportedMacros = "UnSupported LIGHT_MAP_ENABLE UnSupported FALSE;";
>;
float ScalarParameter1
<
string SasUiLabel = "speed";
string SasUiControl = "FloatPicker";
> = 2;

float turblence_intensity
<
string SasUiLabel = "turblence_intensity";
string SasUiControl = "FloatPicker";
> = 0.2;

float color_intensity
<
string SasUiLabel = "color_intensity";
string SasUiControl = "FloatPicker";
> = 2;

float ScalarParameter4
<
string SasUiLabel = "fresnel_exponent";
string SasUiControl = "FloatPicker";
> = 15;

float turblence_tilling
<
string SasUiLabel = "turblence_tilling";
string SasUiControl = "FloatPicker";
> = 1;

float4 VectorParameter1
<
string SasUiLabel = "color";
string SasUiControl = "ColorPicker";
> = float4(1, 1, 1, 1);

float4 VectorParameter2
<
string SasUiLabel = "VectorParameter2";
string SasUiControl = "ColorPicker";
> = float4(1, 1, 1, 0);

texture Tex0
<
string SasUiLabel = "tex1";
string SasUiControl = "FilePicker";
>;

texture Tex1
<
string SasUiLabel = "tex2";
string SasUiControl = "FilePicker";
>;

texture Tex2
<
string SasUiLabel = "texture_mask";
string SasUiControl = "FilePicker";
>;

texture Tex3
<
string SasUiLabel = "diffuse";
string SasUiControl = "FilePicker";
>;

sampler Tex0Sampler = sampler_state
{
	Texture = Tex0;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
	MipMapLodBias = -1.0f;
};

sampler Tex1Sampler = sampler_state
{
	Texture = Tex1;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
	MipMapLodBias = -1.0f;
};

sampler Tex2Sampler = sampler_state
{
	Texture = Tex2;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
	MipMapLodBias = -1.0f;
};

sampler Tex3Sampler = sampler_state
{
	Texture = Tex3;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
	MipMapLodBias = -1.0f;
};

float4x4 World  : World ;
float4x4 View  : View ;
float4x4 InvWorld  : InverseWorld ;
float4x4 InvView  : InverseView ;
float4x4 Projection  : Projection ;
float4x4 ViewProjection  : ViewProjection ;
float4 CameraPos  : CameraPosition ;
float4 PlayerPos  : PlayerPosition ;
float4 ShadowLightAttr[ 5 ]  : ShadowLightAttr ;
float4 DirLightAttr[ 5 ]  : DirLightAttr ;
float4 Ambient  : Ambient ;
float4 ScreenSize4  : ScreenSize ;
float4 FogInfo  : FogInfo ;
float4 FogColor  : FogColor ;
bool FogEnable  : FogEnable ;
float4x4 LightViewProjMatrix  : LightViewProj ;


float3 LightDir  : LightDirection ;






float FarPlane;
float InvFarPlane;
float GetFog( float PostWorldViewProjPosZ, float WorldY )
{
	if ( FogEnable )
	{

		float fog_begin_in_view = mul( float4( 0, 0, FogInfo.x, 1 ), Projection ).z;
		float fog_end_in_view = mul( float4( 0, 0, FogInfo.y, 1 ), Projection ).z;
		return saturate( smoothstep( fog_begin_in_view, fog_end_in_view, PostWorldViewProjPosZ ) );
	}
	else
	{
		return 0;
	}
}
const static float PI = 3.1415926535897932f;
const static float DualPI = 6.283185307179586f;


float Square(float A)
{
	return A * A;
}
float2 Square(float2 A)
{
	return A * A;
}
float3 Square(float3 A)
{
	return A * A;
}
float4 Square(float4 A)
{
	return A * A;
}


float BiasedNDotL(float NDotLWithoutSaturate)
{
	return saturate(NDotLWithoutSaturate * 1.08f - 0.08f);
}
float Luminance(float3 LinearColor)
{
	return dot(LinearColor, float3(0.3, 0.59, 0.11));
}

float  length2(  float2  v )
{
	return dot( v, v );
}
float  length2(  float3  v )
{
	return dot( v, v );
}
float  length2(  float4  v )
{
	return dot( v, v );
}


float  ClampedPow( float  X,  float  Y)
{
	return pow(max(abs(X), 0.000001f), Y);
}
float2  ClampedPow( float2  X,  float2  Y)
{
	return pow(max(abs(X),  float2 (0.000001f, 0.000001f)), Y);
}
float3  ClampedPow( float3  X,  float3  Y)
{
	return pow(max(abs(X),  float3 (0.000001f, 0.000001f, 0.000001f)), Y);
}
float4  ClampedPow( float4  X,  float4  Y)
{
	return pow(max(abs(X),  float4 (0.000001f, 0.000001f, 0.000001f, 0.000001f)), Y);
}

float DDX(float Input)
{



	return ddx(Input);

}

float2 DDX(float2 Input)
{



	return ddx(Input);

}

float3 DDX(float3 Input)
{



	return ddx(Input);

}

float4 DDX(float4 Input)
{



	return ddx(Input);

}

float DDY(float Input)
{



	return ddy(Input);

}

float2 DDY(float2 Input)
{



	return ddy(Input);

}

float3 DDY(float3 Input)
{



	return ddy(Input);

}

float4 DDY(float4 Input)
{



	return ddy(Input);

}

float3  RGBMDecode(  float4  rgbm,  float  MaxValue )
{
	return rgbm.rgb * ( rgbm.a * MaxValue );
}

float3  RGBMDecode(  float4  rgbm )
{
	return rgbm.rgb * ( rgbm.a * 64.0f );
}

float  SRGBToLinearApproximate(  float  inColor )
{
	return inColor * inColor;


}

float  LinearToSRGBApproximate(  float  inColor )
{
	return sqrt( inColor );


}

float PhongShadingPow(float X, float Y)
{
	return ClampedPow(X, Y);
}
float4  Texture2DSample(  texture  tex, sampler sam,  float2  UV )
{
	return tex2D(sam, UV);
}

float4  Texture2DSampleLevel(  texture  tex, sampler sam,  float2  UV,  float  mip )
{
	return tex2Dlod( sam,  float4 ( UV, 0, mip ) );
}

float4  Texture2DSampleBias(  texture  tex, sampler sam,  float2  UV,  float  mipBias )
{
	return tex2Dbias( sam,  float4 ( UV, 0, mipBias ) );
}

float4  Texture2DSampleGrad(  texture  tex, sampler sam,  float2  UV,  float2  DDX,  float2  DDY )
{
	return tex2Dgrad( sam, UV, DDX, DDY );
}

float4  TextureCubeSample(  texture  tex, sampler sam,  float3  UV )
{
	return texCUBE(sam, UV);
}

float4  TextureCubeSampleLevel(  texture  tex, sampler sam,  float3  UV,  float  mip )
{
	return texCUBElod( sam,  float4 ( UV, mip ) );
}

float4  TextureCubeSampleBias(  texture  tex, sampler sam,  float3  UV,  float  mipBias )
{
	return texCUBEbias( sam,  float4 ( UV, mipBias ) );
}

float4  TextureCubeSampleGrad(  texture  tex, sampler sam,  float3  UV,  float3  DDX,  float3  DDY )
{
	return texCUBEgrad( sam, UV, DDX, DDY );
}



float3x3  GetLocalToWorld3x3()
{
	return ( float3x3 )World;
}


float2 CalcScreenUVFromOffsetFraction(float4 ScreenPosition, float2 OffsetFraction)
{
	float2 NDC = ScreenPosition.xy / ScreenPosition.w;



	float2 OffsetNDC = clamp(NDC + OffsetFraction * float2(2, -2), -.999f, .999f);
	return float2(OffsetNDC * float2(0.5, -0.5) + 0.5);
}
float4  ScreenAlignedPosition( float4 ScreenPosition )
{



	return  float4 (ScreenPosition.xy / ScreenPosition.w *  float2 (0.5, -0.5) + 0.5, ScreenPosition.z/ScreenPosition.w,1);

}
float2  ScreenAlignedUV(  float2  UV )
{
	return (UV* float2 (2,-2) +  float2 (-1,1))* float2 (0.5, -0.5) + 0.5;
}


float3  TransformTangentVectorToWorld(  float3x3  TangentToWorld,  float3  InTangentVector )
{


	return mul( InTangentVector, TangentToWorld );
}


float3  TransformWorldVectorToTangent(  float3x3  TangentToWorld,  float3  InWorldVector )
{

	return mul( TangentToWorld, InWorldVector );
}


float4  UnpackNormalMap(  float4  textureSample )
{



	float2  normalXY = textureSample.rg;
	normalXY = normalXY * 2 - 1;
	float  normalZ = sqrt( saturate( 1.0f - dot( normalXY, normalXY ) ) );
	return  float4 (  float3 ( normalXY.xy, normalZ ), 1.0f );

}



float AntialiasedTextureMask(  texture  Tex, SamplerState Sampler, float2 UV, float ThresholdConst, int Channel )
{

	float4  MaskConst =  float4 (Channel == 0, Channel == 1, Channel == 2, Channel == 3);


	const float WidthConst = 1.0f;
	float InvWidthConst = 1 / WidthConst;
	float Result;
	{

		float Sample1 = dot(MaskConst, Texture2DSample(Tex, Sampler, UV));


		float2 TexDD = float2(DDX(Sample1), DDY(Sample1));

		float TexDDLength = max(abs(TexDD.x), abs(TexDD.y));
		float Top = InvWidthConst * (Sample1 - ThresholdConst);
		Result = Top / TexDDLength + ThresholdConst;
	}

	Result = saturate(Result);

	return Result;
}
float PseudoRandom(float2 xy)
{
	float2 pos = frac(xy / 128.0f) * 128.0f + float2(-64.340622f, -72.465622f);


	return frac(dot(pos.xyx * pos.xyy, float3(20.390625f, 60.703125f, 2.4281209f)));
}
void FindBestAxisVectors(float3 In, out float3 Axis1, out float3 Axis2 )
{
	const float3 N = abs(In);


	if( N.z > N.x && N.z > N.y )
	{
		Axis1 = float3(1, 0, 0);
	}
	else
	{
		Axis1 = float3(0, 0, 1);
	}

	Axis1 = normalize(Axis1 - In * dot(Axis1, In));
	Axis2 = cross(Axis1, In);
}
uint2 ScrambleTEA(uint2 v, uint IterationCount = 3)
{

	uint k[4] ={ 0xA341316Cu , 0xC8013EA4u , 0xAD90777Du , 0x7E95761Eu };

	uint y = v[0];
	uint z = v[1];
	uint sum = 0;

	 for(uint i = 0; i < IterationCount; ++i)
	{
		sum += 0x9e3779b9;
		y += (z << 4u) + k[0] ^ z + sum ^ (z >> 5u) + k[1];
		z += (y << 4u) + k[2] ^ y + sum ^ (y >> 5u) + k[3];
	}

	return uint2(y, z);
}




float ComputeRandomFrom2DPosition(uint2 v)
{
	return (ScrambleTEA(v).x & 0xffff ) / (float)(0xffff) * 2 - 1;
}




float ComputeRandomFrom3DPosition(int3 v)
{

	return ComputeRandomFrom2DPosition(v.xy ^ (uint2(0x123456, 0x23446) * v.zx) );
}




float4 PerlinRamp(float4 t)
{
	return t * t * t * (t * (t * 6 - 15) + 10);
}




float2 PerlinNoise2D_ALU(float2 fv)
{

	int2 iv = int2(floor(fv));

	float2 a = ComputeRandomFrom2DPosition(iv + int2(0, 0));
	float2 b = ComputeRandomFrom2DPosition(iv + int2(1, 0));
	float2 c = ComputeRandomFrom2DPosition(iv + int2(0, 1));
	float2 d = ComputeRandomFrom2DPosition(iv + int2(1, 1));

	float2 Weights = PerlinRamp(float4(frac(fv), 0, 0)).xy;

	float2 e = lerp(a, b, Weights.x);
	float2 f = lerp(c, d, Weights.x);

	return lerp(e, f, Weights.y);
}




float PerlinNoise3D_ALU(float3 fv)
{

	int3 iv = int3(floor(fv));

	float2 a = ComputeRandomFrom3DPosition(iv + int3(0, 0, 0));
	float2 b = ComputeRandomFrom3DPosition(iv + int3(1, 0, 0));
	float2 c = ComputeRandomFrom3DPosition(iv + int3(0, 1, 0));
	float2 d = ComputeRandomFrom3DPosition(iv + int3(1, 1, 0));
	float2 e = ComputeRandomFrom3DPosition(iv + int3(0, 0, 1));
	float2 f = ComputeRandomFrom3DPosition(iv + int3(1, 0, 1));
	float2 g = ComputeRandomFrom3DPosition(iv + int3(0, 1, 1));
	float2 h = ComputeRandomFrom3DPosition(iv + int3(1, 1, 1));

	float3 Weights = PerlinRamp(frac(float4(fv, 0))).xyz;

	float2 i = lerp(lerp(a, b, Weights.x), lerp(c, d, Weights.x), Weights.y);
	float2 j = lerp(lerp(e, f, Weights.x), lerp(g, h, Weights.x), Weights.y);

	return lerp(i, j, Weights.z).x;
}
texture  PerlinNoiseGradientTexture;
SamplerState PerlinNoiseGradientTextureSampler;


Texture3D PerlinNoise3DTexture;
SamplerState PerlinNoise3DTextureSampler;




float GradientNoise3D_TEX(float3 fv)
{
	float3 iv = floor(fv);
	float3 Frac = fv - iv;

	const int2 ZShear = int2(17, 89);

	float2 OffsetA = iv.z * ZShear;
	float2 OffsetB = OffsetA + ZShear;

	float2 TexA = (iv.xy + OffsetA + 0.5f) / 128.0f;
	float2 TexB = (iv.xy + OffsetB + 0.5f) / 128.0f;


	float3 A = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexA + float2(0, 0) / 128.0f, 0).xyz * 2 - 1;
	float3 B = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexA + float2(1, 0) / 128.0f, 0).xyz * 2 - 1;
	float3 C = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexA + float2(0, 1) / 128.0f, 0).xyz * 2 - 1;
	float3 D = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexA + float2(1, 1) / 128.0f, 0).xyz * 2 - 1;
	float3 E = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexB + float2(0, 0) / 128.0f, 0).xyz * 2 - 1;
	float3 F = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexB + float2(1, 0) / 128.0f, 0).xyz * 2 - 1;
	float3 G = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexB + float2(0, 1) / 128.0f, 0).xyz * 2 - 1;
	float3 H = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexB + float2(1, 1) / 128.0f, 0).xyz * 2 - 1;

	float a = dot(A, Frac - float3(0, 0, 0));
	float b = dot(B, Frac - float3(1, 0, 0));
	float c = dot(C, Frac - float3(0, 1, 0));
	float d = dot(D, Frac - float3(1, 1, 0));
	float e = dot(E, Frac - float3(0, 0, 1));
	float f = dot(F, Frac - float3(1, 0, 1));
	float g = dot(G, Frac - float3(0, 1, 1));
	float h = dot(H, Frac - float3(1, 1, 1));

	float3 Weights = PerlinRamp(frac(float4(Frac, 0))).xyz;

	float i = lerp(lerp(a, b, Weights.x), lerp(c, d, Weights.x), Weights.y);
	float j = lerp(lerp(e, f, Weights.x), lerp(g, h, Weights.x), Weights.y);

	return lerp(i, j, Weights.z);
}
float3 ComputeSimplexWeights2D(float2 OrthogonalPos, out float2 PosA, out float2 PosB, out float2 PosC)
{
	float2 OrthogonalPosFloor = floor(OrthogonalPos);
	PosA = OrthogonalPosFloor;
	PosB = PosA + float2(1, 1);

	float2 LocalPos = OrthogonalPos - OrthogonalPosFloor;

	PosC = PosA + ((LocalPos.x > LocalPos.y) ? float2(1,0) : float2(0,1));

	float b = min(LocalPos.x, LocalPos.y);
	float c = abs(LocalPos.y - LocalPos.x);
	float a = 1.0f - b - c;

	return float3(a, b, c);
}



float4 ComputeSimplexWeights3D(float3 OrthogonalPos, out float3 PosA, out float3 PosB, out float3 PosC, out float3 PosD)
{
	float3 OrthogonalPosFloor = floor(OrthogonalPos);

	PosA = OrthogonalPosFloor;
	PosB = PosA + float3(1, 1, 1);

	OrthogonalPos -= OrthogonalPosFloor;

	float Largest = max(OrthogonalPos.x, max(OrthogonalPos.y, OrthogonalPos.z));
	float Smallest = min(OrthogonalPos.x, min(OrthogonalPos.y, OrthogonalPos.z));

	PosC = PosA + float3(Largest == OrthogonalPos.x, Largest == OrthogonalPos.y, Largest == OrthogonalPos.z);
	PosD = PosA + float3(Smallest != OrthogonalPos.x, Smallest != OrthogonalPos.y, Smallest != OrthogonalPos.z);

	float4 ret;

	float RG = OrthogonalPos.x - OrthogonalPos.y;
	float RB = OrthogonalPos.x - OrthogonalPos.z;
	float GB = OrthogonalPos.y - OrthogonalPos.z;

	ret.b =
		  min(max(0, RG), max(0, RB))
		+ min(max(0, -RG), max(0, GB))
		+ min(max(0, -RB), max(0, -GB));

	ret.a =
		  min(max(0, -RG), max(0, -RB))
		+ min(max(0, RG), max(0, -GB))
		+ min(max(0, RB), max(0, GB));

	ret.g = Smallest;
	ret.r = 1.0f - ret.g - ret.b - ret.a;

	return ret;
}

float2 GetPerlinNoiseGradientTextureAt(float2 v)
{
	float2 TexA = (v.xy + 0.5f) / 128.0f;


	float3 p = Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexA, 0).xyz * 2 - 1;
	return normalize(p.xy + p.z * 0.33f);
}

float3 GetPerlinNoiseGradientTextureAt(float3 v)
{
	const float2 ZShear = int2(17, 89);

	float2 OffsetA = v.z * ZShear;
	float2 TexA = (v.xy + OffsetA + 0.5f) / 128.0f;

	return Texture2DSampleLevel(PerlinNoiseGradientTexture, PerlinNoiseGradientTextureSampler, TexA , 0).xyz * 2 - 1;
}

float2 SkewSimplex(float2 In)
{
	return In + dot(In, (sqrt(3.0f) - 1.0f) * 0.5f );
}
float2 UnSkewSimplex(float2 In)
{
	return In - dot(In, (3.0f - sqrt(3.0f)) / 6.0f );
}
float3 SkewSimplex(float3 In)
{
	return In + dot(In, 1.0 / 3.0f );
}
float3 UnSkewSimplex(float3 In)
{
	return In - dot(In, 1.0 / 6.0f );
}




float GradientSimplexNoise2D_TEX(float2 EvalPos)
{
	float2 OrthogonalPos = SkewSimplex(EvalPos);

	float2 PosA, PosB, PosC, PosD;
	float3 Weights = ComputeSimplexWeights2D(OrthogonalPos, PosA, PosB, PosC);


	float2 A = GetPerlinNoiseGradientTextureAt(PosA);
	float2 B = GetPerlinNoiseGradientTextureAt(PosB);
	float2 C = GetPerlinNoiseGradientTextureAt(PosC);

	PosA = UnSkewSimplex(PosA);
	PosB = UnSkewSimplex(PosB);
	PosC = UnSkewSimplex(PosC);

	float DistanceWeight;

	DistanceWeight = saturate(0.5f - length2(EvalPos - PosA)); DistanceWeight *= DistanceWeight; DistanceWeight *= DistanceWeight;
	float a = dot(A, EvalPos - PosA) * DistanceWeight;
	DistanceWeight = saturate(0.5f - length2(EvalPos - PosB)); DistanceWeight *= DistanceWeight; DistanceWeight *= DistanceWeight;
	float b = dot(B, EvalPos - PosB) * DistanceWeight;
	DistanceWeight = saturate(0.5f - length2(EvalPos - PosC)); DistanceWeight *= DistanceWeight; DistanceWeight *= DistanceWeight;
	float c = dot(C, EvalPos - PosC) * DistanceWeight;

	return 70 * (a + b + c);
}






float SimplexNoise3D_TEX(float3 EvalPos)
{
	float3 OrthogonalPos = SkewSimplex(EvalPos);

	float3 PosA, PosB, PosC, PosD;
	float4 Weights = ComputeSimplexWeights3D(OrthogonalPos, PosA, PosB, PosC, PosD);


	float3 A = GetPerlinNoiseGradientTextureAt(PosA);
	float3 B = GetPerlinNoiseGradientTextureAt(PosB);
	float3 C = GetPerlinNoiseGradientTextureAt(PosC);
	float3 D = GetPerlinNoiseGradientTextureAt(PosD);

	PosA = UnSkewSimplex(PosA);
	PosB = UnSkewSimplex(PosB);
	PosC = UnSkewSimplex(PosC);
	PosD = UnSkewSimplex(PosD);

	float DistanceWeight;

	DistanceWeight = saturate(0.6f - length2(EvalPos - PosA)); DistanceWeight *= DistanceWeight; DistanceWeight *= DistanceWeight;
	float a = dot(A, EvalPos - PosA) * DistanceWeight;
	DistanceWeight = saturate(0.6f - length2(EvalPos - PosB)); DistanceWeight *= DistanceWeight; DistanceWeight *= DistanceWeight;
	float b = dot(B, EvalPos - PosB) * DistanceWeight;
	DistanceWeight = saturate(0.6f - length2(EvalPos - PosC)); DistanceWeight *= DistanceWeight; DistanceWeight *= DistanceWeight;
	float c = dot(C, EvalPos - PosC) * DistanceWeight;
	DistanceWeight = saturate(0.6f - length2(EvalPos - PosD)); DistanceWeight *= DistanceWeight; DistanceWeight *= DistanceWeight;
	float d = dot(D, EvalPos - PosD) * DistanceWeight;

	return 32 * (a + b + c + d);
}

float Noise3D_Multiplexer(int Function, float3 Position)
{

	switch(Function)
	{
		case 0:
			return SimplexNoise3D_TEX(Position);
		case 1:
			return GradientNoise3D_TEX(Position);
		case 2:
			return PerlinNoise3D_ALU(Position);




		default:
			return ComputeRandomFrom3DPosition((int3)Position).x;
	}
	return 0;
}



float MaterialExpressionNoise(float3 Position, float Scale, int Quality, int Function, bool bTurbulence, uint Levels, float OutputMin, float OutputMax, float LevelScale, float FilterWidth)
{
	Position *= Scale;
	FilterWidth *= Scale;

	float Out = 0.0f;
	float OutScale = 1.0f;
	float InvLevelScale = 1.0f / LevelScale;

	 for(uint i = 0; i < Levels; ++i)
	{

		OutScale *= saturate(1.0 - FilterWidth);

		if(bTurbulence)
		{
			Out += abs(Noise3D_Multiplexer(Function, Position)) * OutScale;
		}
		else
		{
			Out += Noise3D_Multiplexer(Function, Position) * OutScale;
		}

		Position *= LevelScale;
		OutScale *= InvLevelScale;
		FilterWidth *= LevelScale;
	}

	if(!bTurbulence)
	{

		Out = Out * 0.5f + 0.5f;
	}


	return lerp(OutputMin, OutputMax, Out);
}









texture  SceneDepthTexture;
SamplerState SceneDepthTextureSampler;

texture  SceneColorTexture;
SamplerState SceneColorTextureSampler;

texture  SceneAlphaCopyTexture;
SamplerState SceneAlphaCopyTextureSampler;



float3  CalcSceneColor(  float2  ScreenUV )
{
	return Texture2DSampleLevel( SceneColorTexture, SceneColorTextureSampler, ScreenUV, 0 ).rgb;
}


float4  CalcFullSceneColor(  float2  ScreenUV )
{
	return Texture2DSample( SceneColorTexture, SceneColorTextureSampler, ScreenUV );
}


float3  EncodeSceneColorForMaterialNode(  float3  LinearSceneColor )
{


	return pow( LinearSceneColor * .1f, .25f );
}





float ConvertFromDeviceZ( float DeviceZ )
{
	return ( DeviceZ * FarPlane );
}


float ConvertToDeviceZ( float SceneDepth )
{
	return SceneDepth * InvFarPlane;
}


float CalcSceneDepth( float2 ScreenUV )
{
		return ConvertFromDeviceZ(Texture2DSampleLevel(SceneDepthTexture, SceneDepthTextureSampler, ScreenUV, 0).r);


}
float3 Multiply( float3 A, float3 B )
{
	return A * B;
}

float3 ColorBurn( float3 A, float3 B )
{
	return saturate( 1 - ( 1 - B ) / ( A + 0.0001 ) );
}

float3 ColorDodge( float3 A, float3 B )
{
	return saturate( B / ( 1 - A + 0.0001 ) );
}

float3 VividLight( float3 A, float3 B )
{
	return ( A <= 0.5 ) ? ColorBurn( max( A*0.5, 1 ), B ) : ColorDodge( A, B*0.5 );
}
struct MaterialParticleParameters
{

	half4 Color;


	float2 ParticleSize;


	float2 SubUVCoords[2];
	float FrameBlend;

};
struct MaterialPixelParameters
{

	float2 TexCoords[ 1 ];


	half4 VertexColor;


	half3 WorldNormal;

	half3 TangentNormal;



	half3x3 TangentToWorld;


	half3 CameraVector;

	half3 ReflectionVector;

	half3 LightVector;

	half TwoSidedSign;


	float4 ScreenPosition;

	float3 WorldPosition;

	float3 WorldPosition_CamRelative;


	float3 WorldPosition_NoOffsets;


	float3 WorldPosition_NoOffsets_CamRelative;
	MaterialParticleParameters Particle;
};

MaterialPixelParameters InitMaterialPixelParams()
{
	MaterialPixelParameters Parameters = (MaterialPixelParameters)0;
	Parameters.TangentToWorld = float3x3( 1, 0, 0, 0, 1, 0, 0, 0, 1 );
	Parameters.VertexColor = half4( 1, 1, 1, 1 );
	Parameters.TwoSidedSign = 0;

	return Parameters;
}
struct MaterialVertexParameters
{
	float3 WorldPosition;

	half3x3 TangentToWorld;
	half4 VertexColor;

	float2 TexCoords[ 1 ];


	MaterialParticleParameters Particle;
};





float3 GetTranslatedWorldPosition( MaterialVertexParameters Parameters )
{
	return Parameters.WorldPosition -  CameraPos.xyz ;
}

float3 GetWorldPosition( MaterialVertexParameters Parameters )
{
	return Parameters.WorldPosition;
}

float3 GetWorldPosition( MaterialPixelParameters Parameters )
{
	return Parameters.WorldPosition;
}

float3 GetWorldPosition_NoOffsets( MaterialPixelParameters Parameters )
{
	return Parameters.WorldPosition_NoOffsets;
}

float3 GetTranslatedWorldPosition( MaterialPixelParameters Parameters )
{
	return Parameters.WorldPosition_CamRelative;
}

float3 GetTranslatedWorldPosition_NoOffsets( MaterialPixelParameters Parameters )
{
	return Parameters.WorldPosition_NoOffsets_CamRelative;
}


float3  TransformTangentVectorToView( MaterialPixelParameters Parameters,  float3  InTangentVector )
{

	return mul( mul( InTangentVector, Parameters.TangentToWorld ), ( float3x3 )View );
}


float3  TransformLocalVectorToWorld( MaterialVertexParameters Parameters,  float3  InLocalVector )
{

	return mul( InLocalVector, GetLocalToWorld3x3() );

}


float3  TransformLocalVectorToWorld( MaterialPixelParameters Parameters,  float3  InLocalVector )
{
	return mul( InLocalVector, GetLocalToWorld3x3() );
}


float3  TransformWorldVectorToLocal(  float3  InWorldVector )
{
	return mul( InWorldVector, ( float3x3 )InvWorld );
}


float3 TransformLocalPositionToWorld( MaterialPixelParameters Parameters, float3 InLocalPosition )
{
	return mul( float4( InLocalPosition, 1 ), World ).xyz;
}


float3 TransformLocalPositionToWorld( MaterialVertexParameters Parameters, float3 InLocalPosition )
{

	return mul( float4( InLocalPosition, 1 ), World ).xyz;
}




float3 GetObjectWorldPosition( MaterialVertexParameters Parameters )
{
	return float3( 0, 0, 0 );
}

float2  GetLightmapUVs( MaterialPixelParameters Parameters )
{



	return  float2 ( 0, 0 );

}
float  UnMirror(  float  Coordinate, MaterialPixelParameters Parameters )
{
	return ( (Coordinate)*( 1 )*0.5 + 0.5 );
}
float2  UnMirrorU(  float2  UV, MaterialPixelParameters Parameters )
{
	return  float2 ( UnMirror( UV.x, Parameters ), UV.y );
}
float2  UnMirrorV(  float2  UV, MaterialPixelParameters Parameters )
{
	return  float2 ( UV.x, UnMirror( UV.y, Parameters ) );
}
float2  UnMirrorUV(  float2  UV, MaterialPixelParameters Parameters )
{
	return  float2 ( UnMirror( UV.x, Parameters ), UnMirror( UV.y, Parameters ) );
}
float4  ProcessMaterialColorTextureLookup( float4  TextureValue)
{
	TextureValue.rgb *= TextureValue.rgb;

	return TextureValue;
}

float4  ProcessMaterialLinearColorTextureLookup( float4  TextureValue)
{
	return TextureValue;
}

float  ProcessMaterialGreyscaleTextureLookup( float  TextureValue)
{
	TextureValue *= TextureValue;

	return TextureValue;
}

float  ProcessMaterialLinearGreyscaleTextureLookup( float  TextureValue)
{
	return TextureValue;
}

float4 SceneTextureLookup(float2 UV, int SceneTextureIndex, bool bFiltered)
{
	switch ( SceneTextureIndex )
	{



		case 0: return float4( CalcSceneColor( UV ), 0 );

		case 1: return float4( CalcSceneDepth( UV ), 0, 0, 0 );
	}
}


float3  ReflectionAboutCustomWorldNormal( MaterialPixelParameters Parameters,  float3  WorldNormal, bool bNormalizeInputNormal )
{
	if ( bNormalizeInputNormal )
	{
		WorldNormal = normalize( WorldNormal );
	}

	return -Parameters.CameraVector + WorldNormal * dot( WorldNormal, Parameters.CameraVector ) * 2.0;
}

float  GetDistanceCullFade()
{

	return 1;
}


float3 RotateAboutAxis(float4 NormalizedRotationAxisAndAngle, float3 PositionOnAxis, float3 Position)
{

	float3 ClosestPointOnAxis = PositionOnAxis + NormalizedRotationAxisAndAngle.xyz * dot(NormalizedRotationAxisAndAngle.xyz, Position - PositionOnAxis);

	float3 UAxis = Position - ClosestPointOnAxis;
	float3 VAxis = cross(NormalizedRotationAxisAndAngle.xyz, UAxis);
	float CosAngle;
	float SinAngle;
	sincos(NormalizedRotationAxisAndAngle.w, SinAngle, CosAngle);

	float3 R = UAxis * CosAngle + VAxis * SinAngle;

	float3 RotatedPosition = ClosestPointOnAxis + R;

	return RotatedPosition - Position;
}



half3 GetNormal( MaterialPixelParameters Parameters );
half GetClipMask( MaterialPixelParameters Parameters );

void ClipLODTransition( MaterialPixelParameters Parameters )
{

}








void CoverageAndClipping( MaterialPixelParameters Parameters )
{
	ClipLODTransition( Parameters );
}



half3x3 AssembleTangentToWorld( half3 TangentToWorld0, half3 TangentToWorld2 )
{






	half3 TangentToWorld1 = cross( TangentToWorld2.xyz, TangentToWorld0 );

	return half3x3( TangentToWorld0, TangentToWorld1, TangentToWorld2.xyz );
}
float4 TransformWorldToClip( float4 input )
{

	return mul( input, ViewProjection );
}
half3x3 CalcTangentToWorld( half3x3 TangentToLocal )
{
	half3x3 LocalToWorld = GetLocalToWorld3x3();



	return mul( TangentToLocal, LocalToWorld );
}


half3x3 CalcTangentToLocal( half3 Tangent, half3 Normal, inout half TangentToWorldSign )
{
	half3x3 tangentToLocal;




	if ( length( Tangent.xyz ) > 1.5f )
	{
		TangentToWorldSign = -1;
		Tangent = normalize( Tangent );
	}


	half3 Binormal = cross( Normal, Tangent );



	tangentToLocal[0] = cross( Binormal, Normal );
	tangentToLocal[1] = Binormal * TangentToWorldSign;
	tangentToLocal[2] = Normal;
	return tangentToLocal;
}
half GetFloatFacingSign( float  bIsFrontFace)
{

	return sign( bIsFrontFace );
}









void CalcMaterialParameters(
	in out MaterialPixelParameters Parameters
	,  float  bIsFrontFace
	, float4 PixelPosition
	)
{

	Parameters.WorldPosition = PixelPosition.xyz;
	Parameters.WorldPosition_CamRelative = PixelPosition.xyz -  CameraPos.xyz ;
	Parameters.ScreenPosition = TransformWorldToClip( float4(Parameters.WorldPosition, 1) );
	Parameters.CameraVector = normalize(  CameraPos.xyz  - Parameters.WorldPosition );
	Parameters.LightVector =  -LightDir ;
	Parameters.TwoSidedSign = 1.0f;
	Parameters.TangentNormal = GetNormal( Parameters );

	Parameters.TangentNormal *= Parameters.TwoSidedSign;
	Parameters.WorldNormal = normalize( float3(TransformTangentVectorToWorld( Parameters.TangentToWorld, Parameters.TangentNormal )) );

	Parameters.ReflectionVector = ReflectionAboutCustomWorldNormal( Parameters, Parameters.WorldNormal, false );
}


















float4 ScalarUniformExpressions  ;

float4 VectorUniformExpressions[4]  ;



half3 GetBaseColorRaw( MaterialPixelParameters Parameters )
{
	return float3(0.00000000,0.00000000,0.00000000);
}

half3 GetBaseColor( MaterialPixelParameters Parameters )
{
	return saturate( GetBaseColorRaw( Parameters ) );
}

half GetSpecularRaw( MaterialPixelParameters Parameters )
{
	return 0.50000000;
}

half GetSpecular( MaterialPixelParameters Parameters )
{
	return saturate( GetSpecularRaw( Parameters ) );
}


half GetMetallicRaw( MaterialPixelParameters Parameters )
{
	return 0.00000000;
}

half GetMetallic( MaterialPixelParameters Parameters )
{
	return saturate( GetMetallicRaw( Parameters ) );
}

half GetRoughnessRaw( MaterialPixelParameters Parameters )
{
	return 0.50000000;
}

half GetRoughness( MaterialPixelParameters Parameters )
{
	return saturate( GetRoughnessRaw( Parameters ) );
}

half3 GetDiffuseColorRaw( MaterialPixelParameters Parameters )
{
	return float3(0.00000000,0.00000000,0.00000000);
}

half3 GetDiffuseColor( MaterialPixelParameters Parameters )
{
	return saturate( GetDiffuseColorRaw( Parameters ) );
}

half GetDiffusePower( MaterialPixelParameters Parameters )
{
	return 1.00000000;
}

half3 GetSpecularColorRaw( MaterialPixelParameters Parameters )
{
	return float3(0.00000000,0.00000000,0.00000000);
}

half3 GetSpecularColor( MaterialPixelParameters Parameters )
{
	return saturate( GetSpecularColorRaw( Parameters ) );
}

half GetSpecularPower( MaterialPixelParameters Parameters )
{
	return 15.00000000;
}

half3 GetNormal( MaterialPixelParameters Parameters )
{
	return float3(0.00000000,0.00000000,1.00000000);
}

half3 GetEmissiveRaw( MaterialPixelParameters Parameters )
{
	float4  Local0 = ProcessMaterialColorTextureLookup(Texture2DSample(Tex3,Tex3Sampler,Parameters.TexCoords[0].xy));
	float2  Local1 = (Parameters.TexCoords[0].xy * float2(2.00000000,1.00000000));
	float2  Local2 = (Local1 * ScalarUniformExpressions.x);
	float2  Local3 = (VectorUniformExpressions[0].rg + Local2);
	float4  Local4 = ProcessMaterialColorTextureLookup(Texture2DSample(Tex0,Tex0Sampler,Local3));
	float2  Local5 = (VectorUniformExpressions[1].rg + Local2);
	float4  Local6 = ProcessMaterialColorTextureLookup(Texture2DSample(Tex1,Tex1Sampler,Local5));
	float3  Local7 = (Local4.rgb * Local6.rgb);
	float2  Local8 = (Local7.rg * ScalarUniformExpressions.y);
	float2  Local9 = (Local8 + Parameters.TexCoords[0].xy);
	float4  Local10 = ProcessMaterialColorTextureLookup(Texture2DSample(Tex2,Tex2Sampler,Local9));
	float  Local11 = (Local10.a * ScalarUniformExpressions.z);
	float3  Local12 = (Local11 * VectorUniformExpressions[2].rgb);
	float3  Local13 = (Local0.rgb + Local12);
	float  Local14 = dot(Parameters.WorldNormal, Parameters.CameraVector);
	float  Local15 = max(0.00000000,Local14);
	float  Local16 = (1.00000000 - Local15);
	float  Local17 = ClampedPow(Local16,ScalarUniformExpressions.w);
	float  Local18 = (Local17 * 1.00000000 );
	float  Local19 = (Local18 + 0.00000000);
	float3  Local20 = (Local19 * VectorUniformExpressions[3].rgb);
	float3  Local21 = (Local13 + Local20);
	return Local21;
}

half3 GetEmissive( MaterialPixelParameters Parameters )
{
	return max( GetEmissiveRaw( Parameters ), 0.0f );
}

half GetOpacityRaw( MaterialPixelParameters Parameters )
{
	return 1.00000000;
}

half GetOpacity( MaterialPixelParameters Parameters )
{
	return saturate( GetOpacityRaw( Parameters ) );
}

half GetOpacityMaskRaw( MaterialPixelParameters Parameters )
{
	return 1.00000000;
}



half GetMaterialOpacityMaskClipValue()
{
	return 0.33000;
}

half GetClipMask( MaterialPixelParameters Parameters )
{
	return GetOpacityMaskRaw( Parameters ) - GetMaterialOpacityMaskClipValue();
}

float3 GetWorldPositionOffset( MaterialVertexParameters Parameters )
{
	return  float4 (float3(0.00000000,0.00000000,0.00000000),0).rgb;
}

half GetMaterialAmbientOcclusionRaw( MaterialPixelParameters Parameters )
{
	return 1.00000000;;
}

half GetMaterialAmbientOcclusion( MaterialPixelParameters Parameters )
{
	return saturate( GetMaterialAmbientOcclusionRaw( Parameters ) );
}

half2 GetMaterialRefraction( MaterialPixelParameters Parameters )
{
	return 0;;
}

float GetMaterialPixelDepthOffset( MaterialPixelParameters Parameters )
{
	return 0.00000000;;
}








void GetMaterialCustomizedUVs( MaterialVertexParameters Parameters, out float2 outTexCoords[ 1 ] )
{
	outTexCoords[0] = Parameters.TexCoords[0].xy;

}
float3 TransformPositionToWorld( float3 input )
{
	return mul(float4(input, 1.0f), World).xyz;
}
struct VertexInput
{
	float4 Position : POSITION;
	half4 Color : COLOR0;

	half3 Normal : NORMAL0;
	half3 Tangent : TANGENT0;
	float2 TexCoords[ 1 ] : TEXCOORD0;
};
struct VertexFactoryLocals
{
	half3x3 TangentToLocal;
	half3x3 TangentToWorld;
	half TangentToWorldSign;
	half4 Color;
};
struct VertexFactoryOutput
{
	float4 TangentToWorld0 : TEXCOORD10 ; float4 TangentToWorld2 : TEXCOORD11 ;
	float2 TexCoords[ 1 ] : TEXCOORD0;
};


VertexFactoryLocals GetVertexFactoryLocals( VertexInput Input )
{
	VertexFactoryLocals locals;
	locals.Color = Input.Color;


	locals.TangentToWorldSign = 1.f;


	locals.TangentToLocal = CalcTangentToLocal( Input.Tangent, Input.Normal, locals.TangentToWorldSign );
	locals.TangentToWorld = CalcTangentToWorld( locals.TangentToLocal );
	return locals;
}
MaterialVertexParameters GetMaterialVertexParameters( VertexInput Input, VertexFactoryLocals Locals, float3 WorldPosition, half3x3 TengentToLocal )
{
	MaterialVertexParameters params = (MaterialVertexParameters)0;
	params.WorldPosition = WorldPosition;
	params.TangentToWorld = Locals.TangentToWorld;
	params.VertexColor = Input.Color;


	for ( int CoordinateIndex = 0; CoordinateIndex <  1 ; ++CoordinateIndex )
	{
		params.TexCoords[CoordinateIndex] = Input.TexCoords[CoordinateIndex];
	}

	return params;
}





float4 VF_GetWorldPosition( VertexInput input, VertexFactoryLocals locals )
{










	return float4( TransformPositionToWorld( input.Position.xyz ), 1 );

}

half3x3 VF_GetTangentToLocal( VertexInput input, VertexFactoryLocals locals )
{
	return locals.TangentToLocal;
}

VertexFactoryOutput VF_GetVertexFactoryOutput( VertexInput Input, VertexFactoryLocals Locals, MaterialVertexParameters Params )
{
	VertexFactoryOutput Output = (VertexFactoryOutput)0;
	Output.TangentToWorld0 = float4(Locals.TangentToWorld[0], 0);
	Output.TangentToWorld2 = float4(Locals.TangentToWorld[2], Locals.TangentToWorldSign);



	for ( int CoordinateIndex = 0; CoordinateIndex <  1 ; ++CoordinateIndex )
	{
		Output.TexCoords[CoordinateIndex] = Input.TexCoords[CoordinateIndex];
	}
	return Output;
}







MaterialPixelParameters GetMaterialPixelParameters( VertexFactoryOutput Input )
{
	MaterialPixelParameters Parameters = InitMaterialPixelParams();



	for ( int CoordinateIndex = 0; CoordinateIndex <  1 ; CoordinateIndex++ )
	{
		Parameters.TexCoords[CoordinateIndex] = Input.TexCoords[CoordinateIndex];
	}
	Parameters.TangentToWorld = AssembleTangentToWorld( Input.TangentToWorld0.xyz, Input.TangentToWorld2.xyz );
	Parameters.TangentToWorld[1] *= Input.TangentToWorld2.w;
	Parameters.Particle.Color = half4( 1, 1, 1, 1 );
	Parameters.TwoSidedSign = 1;

	return Parameters;
}
struct ForwardPassOutput
{
	float4 PixelPosition : TEXCOORD5;
	float FogFactor : TEXCOORD7;

};

struct BaseOutputVSToPS
{
	VertexFactoryOutput VF_Output;
	ForwardPassOutput ForwardOutput;



	float4 Position : SV_POSITION;

};

void MainVS( VertexInput Input,
		   out BaseOutputVSToPS Output )
{
	VertexFactoryLocals Locals = GetVertexFactoryLocals( Input );
	float4 WorldPositionExcludingWPO = VF_GetWorldPosition( Input, Locals );
	float4 WorldPosition = WorldPositionExcludingWPO;
	half3x3 TangentToLocal = VF_GetTangentToLocal( Input, Locals );

	MaterialVertexParameters Parameters = GetMaterialVertexParameters( Input, Locals, WorldPosition.xyz, TangentToLocal );
	half3 WorldPositionOffset = GetWorldPositionOffset( Parameters );
	WorldPosition.xyz += WorldPositionOffset;

	Output.Position = TransformWorldToClip( WorldPosition );



	Output.ForwardOutput.PixelPosition = WorldPosition;
	Output.ForwardOutput.PixelPosition.w = Output.Position.w;
	Output.ForwardOutput.FogFactor = GetFog( Output.Position.z, WorldPosition.y );


	Output.VF_Output = VF_GetVertexFactoryOutput( Input, Locals, Parameters );
}
texture SMAP : ShadowMap;
sampler sam_smap = sampler_state
{
	texture = (SMAP);
};





	float4 CameraZPlanes;

	float calc_shadow(float4 pos)
	{
		pos = mul( pos, LightViewProjMatrix );

		float3 lPos = pos.xyz / pos.w * 0.5 + 0.5;

		float depthInTex = Texture2DSample(SMAP, sam_smap, lPos.xy).r;

		if (lPos.x > 0.0 && lPos.x < 1.0 && lPos.y > 0.0 && lPos.y < 1.0)
		{
			return (depthInTex < lPos.z) ? 0.f : 1.0;
		}
		else
			return 1.0;

	}

	float4 sample_shadowmap(float4 lookup)
	{
		return Texture2DSample(SMAP, sam_smap, lookup.xy);
	}
float UnpackRGBA2Float(float4 v)
{
	const float4 vUnpack = float4(1.0, 1.0/256.0, 1.0/65536.0, 1.0/16777216.0);
	return dot(v, vUnpack);
}
void MainPS( VertexFactoryOutput VF_Input,
		   ForwardPassOutput ForwardInput,
		   in float2 PixelShaderScreenPosition : VPOS,
		   in float bIsFrontFace : VFACE ,
		   out half4 OutColor : SV_Target )

{




	MaterialPixelParameters Parameters = GetMaterialPixelParameters( VF_Input );
	CalcMaterialParameters( Parameters, bIsFrontFace, ForwardInput.PixelPosition
	);

	Parameters.ScreenPosition.xy = PixelShaderScreenPosition *  ScreenSize4.zw ;


	CoverageAndClipping( Parameters );

	half3 Color = 0;
	half Opacity = GetOpacity(Parameters);
	half3 Emissive = GetEmissive( Parameters );
	Color += Emissive;
		Color = sqrt( Color );
	if ( FogEnable )
	{
		half fogFactor = FogColor.a * ForwardInput.FogFactor;
		fogFactor = saturate( fogFactor );
		Color = Color *( 1 - fogFactor ) + FogColor.xyz* fogFactor;
	}





	OutColor = half4( Color, 1 );

}
technique TShader
{
	pass Pass1
	{
		
		VertexShader = compile vs_3_0 MainVS();
		PixelShader = compile ps_3_0 MainPS();
	}
}
