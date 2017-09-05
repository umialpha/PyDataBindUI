uniform mat4 CC_MVPMatrix;
POSITION attribute vec4 position;
TEXCOORD0 attribute vec2 texcoord0;
COLOR0 attribute vec4 diffuse;
varying mediump vec2 v_texture0;
varying lowp vec4 v_texture1;
void main()
{
vec4 local_0 = CC_MVPMatrix * position;
gl_Position = local_0;
vec3 local_1 = diffuse.xyz;
float local_2 = diffuse.w;
vec3 local_3 = local_1 * local_2;
vec4 local_4 = vec4(local_3.x, local_3.y, local_3.z, local_2);
v_texture1 = local_4;
v_texture0 = texcoord0;
}
