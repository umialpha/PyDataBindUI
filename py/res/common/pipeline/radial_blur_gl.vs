POSITION attribute vec4 position;
TEXCOORD0 attribute vec4 texcoord0;

varying mediump vec2 TexCoord0;
varying mediump vec2 TexCoord1;
varying mediump vec2 TexCoord2;
varying mediump vec2 TexCoord3;
varying mediump vec2 TexCoord4;
varying mediump vec2 TexCoord5;
varying mediump vec2 TexCoord6;
varying mediump vec2 TexCoord7;

uniform lowp float radial_center_u;
uniform lowp float radial_center_v;

uniform highp float fSampleDist;

uniform vec4 dynamicRT;

void VSMain()
{
	gl_Position = position;

   // 0.5,0.5 is the center of the screen   
   // so substracting uv from it will result in   
   // a vector pointing to the middle of the screen   
	vec2 dir = vec2(radial_center_u, radial_center_v) - texcoord0.xy;  

   // calculate the distance to the center of the screen   
   float dist = length(dir);  
   // normalize the direction (reuse the distance)   
   dir /= dist;  
     
   	vec4 tmp_texcoord0 = texcoord0;
	tmp_texcoord0.x = dynamicRT.z * texcoord0.x;
	tmp_texcoord0.y = dynamicRT.w * (texcoord0.y - 1.0) + 1.0;
	TexCoord0 = tmp_texcoord0.xy;
	TexCoord1 = tmp_texcoord0.xy + dir * -0.08 * fSampleDist;
	TexCoord2 = tmp_texcoord0.xy + dir * -0.05 * fSampleDist;
	TexCoord3 = tmp_texcoord0.xy + dir * -0.02 * fSampleDist;
	TexCoord4 = tmp_texcoord0.xy + dir * -0.01 * fSampleDist;
	TexCoord5 = tmp_texcoord0.xy + dir * 0.02 * fSampleDist;
	TexCoord6 = tmp_texcoord0.xy + dir * 0.05 * fSampleDist;
	TexCoord7 = tmp_texcoord0.xy + dir * 0.08 * fSampleDist;
}