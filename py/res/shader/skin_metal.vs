#if GPU_SKIN_ENABLE

struct SkinOutput
{
	float3 pos;
	float3 nor;	
};


static float3 _DQ_Rot_Vec3(float4 quat, float3 v) 
{
    float3 r2,r3;  
    r2 = cross(quat.xyz, v);       //mul+mad 
    r2 = quat.w*v + r2;            //mad 
    r3 = cross(quat.xyz, r2);      //mul+mad 
    r3 = r3 * 2 + v;               //mad 
    return r3;
}

//蒙皮函数
static SkinOutput GetSkin(float4 bone_weight, uint4 bone_index, float4 position, float4 normal, constant float4* BoneVec)
{
	SkinOutput output;
	output.pos = float3(0, 0, 0);
	output.nor = float3(0, 0, 0);

	for (int i = 0; i < 4; ++i)
	{
		if (bone_index[i] < 90)
		{
			int bi = bone_index[i] * 4;
			float3 p, n;
			p.x = dot(position, BoneVec[bi]);
			p.y = dot(position, BoneVec[bi+1]);
			p.z = dot(position, BoneVec[bi+2]);
			n.x = dot(normal.xyz, float3(BoneVec[bi]));
			n.y = dot(normal.xyz, float3(BoneVec[bi+1]));
			n.z = dot(normal.xyz, float3(BoneVec[bi+2]));
			output.pos += p * bone_weight[i];
			output.nor += n * bone_weight[i];
		}
	}
	return output;
}
#endif