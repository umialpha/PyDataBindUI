uniform mat4 CC_MVPMatrix;
uniform vec4 u_color;
POSITION attribute vec4 position;
varying lowp vec4 v_diffuse;
void main()
{
vec4 local_0 = CC_MVPMatrix * position;
gl_Position = local_0;
v_diffuse = u_color;
}
