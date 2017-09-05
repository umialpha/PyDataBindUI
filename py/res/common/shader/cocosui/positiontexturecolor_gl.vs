uniform mat4 CC_MVPMatrix;
POSITION attribute vec4 position;
TEXCOORD0 attribute vec2 texcoord0;
COLOR0 attribute vec4 diffuse;
varying lowp vec4 use_color;
varying mediump vec2 v_texture0;
void main()
{
vec4 local_0 = CC_MVPMatrix * position;
gl_Position = local_0;
use_color = diffuse;
v_texture0 = texcoord0;
}
