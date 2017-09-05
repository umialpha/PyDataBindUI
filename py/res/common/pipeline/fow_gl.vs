POSITION attribute vec4 position;
TEXCOORD0 attribute vec4 texcoord0;

varying mediump vec2 TexCoord0;

varying vec3 vdir;

uniform vec4 dynamicRT;
uniform vec4 CameraPos;
uniform vec4 ViewDirs[4];
uniform mat4 InverseViewaMatrix;

void FOWMain()
{
	gl_Position = position;
	TexCoord0 = texcoord0.xy;
	TexCoord0.x = dynamicRT.z * TexCoord0.x;
	TexCoord0.y = dynamicRT.w * (TexCoord0.y - 1.0) + 1.0;

	int index = int(TexCoord0.x * 2.0 + TexCoord0.y + 0.01);

	// viewDir: view direction in world space 
	vec4 viewDir = vec4(ViewDirs[index].x, ViewDirs[index].y, ViewDirs[index].z, 0);
	viewDir = InverseViewaMatrix * viewDir;

	// vdir: view direction in camera space
	// vdir =  viewDir.xyz - CameraPos.xyz;
	vdir = vec3(ViewDirs[index].x, ViewDirs[index].y, ViewDirs[index].z) - CameraPos.xyz;
	//vdir = vec3(TexCoord0.x, TexCoord0.y, 0);
}
