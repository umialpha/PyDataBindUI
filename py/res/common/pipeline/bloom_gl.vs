POSITION attribute vec4 position;
TEXCOORD0 attribute vec4 texcoord0;

varying mediump vec2 TexCoord0;
varying mediump vec2 TexCoord1;
varying mediump vec2 TexCoord2;
varying mediump vec2 TexCoord3;
// varying mediump vec2 TexCoord4;
varying mediump vec2 TexCoord5;
// varying mediump vec2 TexCoord6;
// varying mediump vec2 TexCoord7;
varying vec3 vdir;

uniform vec4 dynamicRT;

uniform vec4 DownSampleOffsets[16]; 
           
uniform float HorizontalBloomSampleOffsets[5];     

uniform float VerticalBloomSampleOffsets[5];   

uniform int BloomWidth;	//控制bloom的宽度

uniform vec4 CameraPos;
uniform vec4 ViewDirs[4];
uniform mat4 InverseViewaMatrix;

void VSMain()
{
	gl_Position = position;
	TexCoord0 = texcoord0.xy;
	TexCoord0.x = dynamicRT.z * TexCoord0.x;
	TexCoord0.y = dynamicRT.w * (TexCoord0.y - 1.0) + 1.0;
}



void DownSamplePass()
{
	gl_Position = position;
	vec4 tmp_texcoord0 = texcoord0;
	tmp_texcoord0.x = dynamicRT.z * texcoord0.x;
	tmp_texcoord0.y = dynamicRT.w * (texcoord0.y - 1.0) + 1.0;
	TexCoord0 = tmp_texcoord0.xy + vec2(DownSampleOffsets[0 ].x, DownSampleOffsets[0 ].y);
	TexCoord1 = tmp_texcoord0.xy + vec2(DownSampleOffsets[3 ].x, DownSampleOffsets[3 ].y);
	TexCoord2 = tmp_texcoord0.xy + vec2(DownSampleOffsets[5 ].x, DownSampleOffsets[5 ].y);
	TexCoord3 = tmp_texcoord0.xy + vec2(DownSampleOffsets[6 ].x, DownSampleOffsets[6 ].y);
	/*TexCoord4 = tmp_texcoord0.xy + vec2(DownSampleOffsets[9 ].x, DownSampleOffsets[9 ].y);
	TexCoord5 = tmp_texcoord0.xy + vec2(DownSampleOffsets[10 ].x, DownSampleOffsets[10 ].y);
	TexCoord6 = tmp_texcoord0.xy + vec2(DownSampleOffsets[12 ].x, DownSampleOffsets[12 ].y);
	TexCoord7 = tmp_texcoord0.xy + vec2(DownSampleOffsets[15 ].x, DownSampleOffsets[15 ].y);*/
}
       
void HorizontalBlurPass()
{
	gl_Position = position;
	float bloomwidth = float(BloomWidth);
	vec4 tmp_texcoord0 = texcoord0;
	tmp_texcoord0.x = dynamicRT.z * texcoord0.x;
	tmp_texcoord0.y = dynamicRT.w * (texcoord0.y - 1.0) + 1.0;
	TexCoord0.xy = tmp_texcoord0.xy + vec2( HorizontalBloomSampleOffsets[0] * bloomwidth, 0.0 );
	TexCoord1.xy = tmp_texcoord0.xy + vec2( HorizontalBloomSampleOffsets[1] * bloomwidth, 0.0 );
	TexCoord2.xy = tmp_texcoord0.xy + vec2( HorizontalBloomSampleOffsets[2] * bloomwidth, 0.0 );
	/*TexCoord3.xy = tmp_texcoord0.xy + vec2( HorizontalBloomSampleOffsets[3] * bloomwidth, 0.0 );
	TexCoord4.xy = tmp_texcoord0.xy + vec2( HorizontalBloomSampleOffsets[4] * bloomwidth, 0.0 );*/
}

            

void VerticalBlurPass()
{
	gl_Position = position;
	float bloomwidth = float(BloomWidth);
	vec4 tmp_texcoord0 = texcoord0;
	tmp_texcoord0.x = dynamicRT.z * texcoord0.x;
	tmp_texcoord0.y = dynamicRT.w * (texcoord0.y - 1.0) + 1.0;	
	TexCoord0.xy = tmp_texcoord0.xy + vec2( 0.0, VerticalBloomSampleOffsets[0] * bloomwidth );
	TexCoord1.xy = tmp_texcoord0.xy + vec2( 0.0, VerticalBloomSampleOffsets[1] * bloomwidth );
	TexCoord2.xy = tmp_texcoord0.xy + vec2( 0.0, VerticalBloomSampleOffsets[2] * bloomwidth );
	/*TexCoord3.xy = tmp_texcoord0.xy + vec2( 0.0, VerticalBloomSampleOffsets[3] * bloomwidth );
	TexCoord4.xy = tmp_texcoord0.xy + vec2( 0.0, VerticalBloomSampleOffsets[4] * bloomwidth );*/
	TexCoord5 = tmp_texcoord0.xy;
}