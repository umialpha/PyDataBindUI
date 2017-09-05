uniform mat4 CC_PMatrix;
POSITION attribute vec4 position;
TEXCOORD0 attribute vec2 texcoord0;
COLOR0 attribute vec4 diffuse;
varying lowp vec4 v_diffuse;
varying mediump vec2 v_texture0;
void main()
{
vec4 local_0 = CC_PMatrix * position;
gl_Position = local_0;
v_diffuse = diffuse;
v_texture0 = texcoord0;
}
