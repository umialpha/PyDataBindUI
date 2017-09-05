float4x4 wvp;

struct VS_INPUT
{
	float4 Position:	POSITION;
#if GPU_SKIN_ENABLE
	float4 Normal: 		NORMAL;
	float4 BoneWeights: BLENDWEIGHT;
	uint4   BoneIndices: BLENDINDICES;
#endif 
};

struct PS_INPUT
{
	float4 Position:	POSITION;
};

#if GPU_SKIN_ENABLE
float4 BoneVec[MAX_BONES*2];
float3 _DQ_Rot_Vec3(const float4 quat, const float3 v) 
{
    float3 r2,r3;  
    r2 = cross(quat.xyz, v);       //mul+mad 
    r2 = quat.w*v + r2;            //mad 
    r3 = cross(quat.xyz, r2);      //mul+mad 
    r3 = r3 * 2 + v;               //mad 
    return r3;
}

//蒙皮函数
void GetSkin(in float4 bone_weight, in uint4 bone_index, inout float4 position, inout float4 normal)
{
	float3 pos = {0,0,0}, nor = {0,0,0};
	float4 blend_dq[2];
	for (int i = 0; i < 4; ++i)
	{
		if (bone_index[i] < MAX_BONES)
		{
			int sign = 1; // 要考虑四元数的相容性，保证任意2个点积的符号为正
			if (i > 0 && dot(BoneVec[bone_index[0] * 2], BoneVec[bone_index[i] * 2]) < 0)
			{
				sign = -1;
			}
			
			blend_dq[0] = sign * BoneVec[bone_index[i] * 2 + 0];
			blend_dq[1] = BoneVec[bone_index[i] * 2 + 1];
			
			float3 p, n;
			p = position.xyz * blend_dq[1].w; // 缩放
			p = _DQ_Rot_Vec3(blend_dq[0], p); // 旋转
			p += blend_dq[1].xyz; // 平移
			n = _DQ_Rot_Vec3(blend_dq[0], normal.xyz);
			pos += p * bone_weight[i];
			nor += n * bone_weight[i];
		}
	}

	position.xyz = pos;
	normal.xyz = nor;
}
#endif

//todo：传入缩放值，控制范围
PS_INPUT main(VS_INPUT IN)
{
	PS_INPUT OUT = (PS_INPUT)0;

#if GPU_SKIN_ENABLE
	GetSkin(IN.BoneWeights, IN.BoneIndices, IN.Position, IN.Normal);
#endif 
	//将position沿着normal方向缩放
	OUT.Position = mul(IN.Position , wvp);

	return OUT;
}
