// from point
POSITION attribute vec4 position;
TEXCOORD0 attribute vec4 texcoord0;

// from app
// uniform highp float ScreenWidth_SreenHeight_Ratio;
uniform highp mat4 world;

uniform mediump float flare_rotate;
uniform mediump float flare_tranx;
uniform mediump float flare_trany;
uniform mediump float flare_scale;
uniform mediump float hw_ratio;

// to ps
varying highp vec2 UV0;

void func_scale(in mediump float s, inout mediump vec4 pos)
{
	pos.xy = pos.xy * s;
}

void func_translate(in mediump float x, in mediump float y, inout mediump vec4 pos)
{
	pos.xy = pos.xy + vec2(x, y);
}

void func_rotate(in mediump float r, inout mediump vec4 pos)
{
	mediump float sinr = sin(r);
	mediump float cosr = cos(r);
	mediump mat4 mxr = mat4(	vec4(cosr, sinr, 0.0, 0.0),
								vec4(-sinr, cosr, 0.0, 0.0),
								vec4(0.0, 0.0, 1.0, 0.0),
								vec4(0.0, 0.0, 0.0, 1.0));
	pos = mxr * pos;
}

void main ()
{ 
	mediump vec4 world_pos = vec4(position.x-0.5, position.y-0.5, 0, 1.0);
	func_scale(flare_scale, world_pos); 
	func_rotate(flare_rotate, world_pos);
	world_pos.x *= hw_ratio;
	func_translate(flare_tranx, flare_trany, world_pos);
	gl_Position = vec4(world_pos.x, world_pos.y, 0.0, 1.0);//绘制在最前面
    UV0 = texcoord0.xy;
}



