uniform mat4 CC_MVPMatrix;
POSITION attribute vec4 position;
COLOR0 attribute vec4 diffuse;
varying lowp vec4 v_diffuse;
void main()
{
vec4 local_0 = CC_MVPMatrix * position;
gl_Position = local_0;
v_diffuse = diffuse;
}
