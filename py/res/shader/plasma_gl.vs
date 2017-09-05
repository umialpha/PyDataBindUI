TEXCOORD0 attribute vec4 texcoord0;
COLOR0 attribute vec4 diffuse;
POSITION attribute vec4 position;
NORMAL attribute vec3 normal;

uniform highp mat4 wvp;
uniform highp mat4 texTrans0;

uniform highp float time;
uniform mediump float frequency;
uniform mediump float amplitude;
uniform mediump float wave_size;
uniform mediump float displace_offset;

varying mediump vec4 UV0;
varying lowp vec4 Color;
varying mediump vec4 weight;

mediump vec3 point_noise(mediump vec3 p, highp float time)
{
	mediump vec3 p2 = (p + time) * vec3(1.0, 1.5, 2.0);
	return sin(p2);
}

void VS_OneTex()
{
	// Noise Generation
	mediump vec4 np = position / wave_size;
	highp float t = time * frequency;
	mediump vec3 p2 = (np.xyz - np.yzx);
	
	mediump vec3 noise = point_noise(p2, t) + 1.0;
	mediump float sum_noise = noise.x + noise.y + noise.z;

	// Output noise to PS
	weight.xyz = noise / sum_noise;
	weight.w = sum_noise / 6.0;

	// Move vertices based on noise
	mediump vec4 pos = position;
	pos.xyz += (sum_noise - 3.0 + displace_offset) * normal * amplitude;
	
	// Calculate other stuff
	gl_Position = (wvp * pos);
	mediump vec4 texc = vec4(texcoord0.xy, 1, 0);
	UV0 = texTrans0 * texc;
	Color = diffuse;
}