precision highp float;

uniform vec4 rtSize;

POSITION attribute vec4 position;
TEXCOORD0 attribute vec4 texcoord0;

varying mediump vec2 TexCoord0;
varying mediump vec2 TexCoord1;
varying mediump vec2 TexCoord2;
varying mediump vec2 TexCoord3;
varying mediump vec2 TexCoord4;

uniform float horBlurGaussOffset[5];
uniform float verBlurGaussOffset[5];
uniform float width;
uniform vec4 dynamicRT;

void VerBlurVS()
{
	gl_Position = position;

	float pixelSize = rtSize.w;
	float blurWidth = pixelSize * width;
	vec4 tmp_texcoord0 = texcoord0;
	tmp_texcoord0.x = dynamicRT.z * texcoord0.x;
	tmp_texcoord0.y = dynamicRT.w * (texcoord0.y - 1.0) + 1.0;
	TexCoord0 = tmp_texcoord0.xy + vec2(0.0,blurWidth * verBlurGaussOffset[0]);	
	TexCoord1 = tmp_texcoord0.xy + vec2(0.0,blurWidth * verBlurGaussOffset[1]);
	TexCoord2 = tmp_texcoord0.xy + vec2(0.0,blurWidth * verBlurGaussOffset[2]);
	TexCoord3 = tmp_texcoord0.xy + vec2(0.0,blurWidth * verBlurGaussOffset[3]);
	TexCoord4 = tmp_texcoord0.xy + vec2(0.0,blurWidth * verBlurGaussOffset[4]);
}


void HorBlurVS()
{
	gl_Position = position;
	float pixelSize = rtSize.z;

	float blurWidth = pixelSize * width;
	vec4 tmp_texcoord0 = texcoord0;
	tmp_texcoord0.x = dynamicRT.z * texcoord0.x;
	tmp_texcoord0.y = dynamicRT.w * (texcoord0.y - 1.0) + 1.0;
	TexCoord0 = tmp_texcoord0.xy + vec2(blurWidth * horBlurGaussOffset[0], 0.0);	
	TexCoord1 = tmp_texcoord0.xy + vec2(blurWidth * horBlurGaussOffset[1], 0.0);
	TexCoord2 = tmp_texcoord0.xy + vec2(blurWidth * horBlurGaussOffset[2], 0.0);
	TexCoord3 = tmp_texcoord0.xy + vec2(blurWidth * horBlurGaussOffset[3], 0.0);
	TexCoord4 = tmp_texcoord0.xy + vec2(blurWidth * horBlurGaussOffset[4], 0.0);
}

void BlendVS()
{
	gl_Position = position;
	TexCoord0 = texcoord0.xy;
	TexCoord0.x = dynamicRT.z * TexCoord0.x;
	TexCoord0.y = dynamicRT.w * (TexCoord0.y - 1.0) + 1.0;
}