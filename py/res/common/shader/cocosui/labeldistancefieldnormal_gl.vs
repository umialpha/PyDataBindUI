#ifndef USE_NO_MV
 #define USE_NO_MV 0
#endif

#if USE_NO_MV
uniform mat4 CC_PMatrix;
#endif
#if !(USE_NO_MV)
uniform mat4 CC_MVPMatrix;
#endif
#if USE_NO_MV || !(USE_NO_MV)
POSITION attribute vec4 position;
#endif
TEXCOORD0 attribute vec2 texcoord0;
COLOR0 attribute vec4 diffuse;
varying lowp vec4 v_diffuse;
varying mediump vec2 v_texture0;
void main()
{
vec4 local_0;
#if USE_NO_MV
vec4 local_1 = CC_PMatrix * position;
local_0 = local_1;
#else
vec4 local_2 = CC_MVPMatrix * position;
local_0 = local_2;
#endif
gl_Position = local_0;
v_diffuse = diffuse;
v_texture0 = texcoord0;
}
