uniform mat4 CC_PMatrix;
POSITION attribute vec4 position;
TEXCOORD0 attribute vec2 texcoord0;
varying mediump vec2 v_texCoord;
void main()
{
vec4 local_0 = CC_PMatrix * position;
gl_Position = local_0;
v_texCoord = texcoord0;
}