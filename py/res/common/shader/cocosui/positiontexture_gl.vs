uniform mat4 CC_MVPMatrix;
POSITION attribute vec4 position;
TEXCOORD0 attribute vec2 texcoord0;
varying mediump vec2 v_texture0;
void main()
{
vec4 local_0 = CC_MVPMatrix * position;
gl_Position = local_0;
v_texture0 = texcoord0;
}
