#if GPU_SKIN_ENABLE

BLENDWEIGHT attribute vec4 blendWeights;
BLENDINDICES attribute vec4 blendIndices;

uniform highp vec4 BoneVec[MAX_BONES*2];
vec3 _DQ_Rot_Vec3(const vec4 quat, const vec3 v) 
{
    vec3 r2,r3;  
    r2 = cross(quat.xyz, v);       //mul+mad 
    r2 = quat.w*v + r2;            //mad 
    r3 = cross(quat.xyz, r2);      //mul+mad 
    r3 = r3 * 2.0 + v;               //mad 
    return r3;
}

//蒙皮函数
void GetSkin(in vec4 bone_weight, in vec4 bone_index, inout vec4 position, inout vec4 normal)
{
	vec3 pos = vec3(0,0,0), nor = vec3(0,0,0);
	vec4 blend_dq[2];
	lowp int boneIdx0 = int(bone_index[0]) * 2;
	
	//0
	blend_dq[0] = BoneVec[boneIdx0];
	blend_dq[1] = BoneVec[boneIdx0 + 1];

	vec3 p, n;
	p = position.xyz * blend_dq[1].w; // 缩放
	p = _DQ_Rot_Vec3(blend_dq[0], p); // 旋转
	p += blend_dq[1].xyz; // 平移
	pos += p * bone_weight[0];
#ifdef NEED_NORMAL
	n = _DQ_Rot_Vec3(blend_dq[0], normal.xyz);
	nor += n * bone_weight[0];
#endif
	
	//1
	lowp int boneIdx = int(bone_index[1]) * 2;
	if (boneIdx < MAX_BONES * 2)
	{
		float signNum = 1.0; // 要考虑四元数的相容性，保证任意2个点积的符号为正
		if (dot(BoneVec[boneIdx0], BoneVec[boneIdx]) < 0.0)
		{
			signNum = -1.0;
		}

		blend_dq[0] = signNum * BoneVec[boneIdx];
		blend_dq[1] = BoneVec[boneIdx + 1];

		vec3 p, n;
		p = position.xyz * blend_dq[1].w; // 缩放
		p = _DQ_Rot_Vec3(blend_dq[0], p); // 旋转
		p += blend_dq[1].xyz; // 平移
		pos += p * bone_weight[1];
#ifdef NEED_NORMAL
		n = _DQ_Rot_Vec3(blend_dq[0], normal.xyz);
		nor += n * bone_weight[1];
#endif
	}

	//2
	boneIdx = int(bone_index[2]) * 2;
	if (boneIdx < MAX_BONES * 2)
	{
		float signNum = 1.0; // 要考虑四元数的相容性，保证任意2个点积的符号为正
		if (dot(BoneVec[boneIdx0], BoneVec[boneIdx]) < 0.0)
		{
			signNum = -1.0;
		}

		blend_dq[0] = signNum * BoneVec[boneIdx];
		blend_dq[1] = BoneVec[boneIdx + 1];

		vec3 p, n;
		p = position.xyz * blend_dq[1].w; // 缩放
		p = _DQ_Rot_Vec3(blend_dq[0], p); // 旋转
		p += blend_dq[1].xyz; // 平移
		pos += p * bone_weight[2];
#ifdef NEED_NORMAL
		n = _DQ_Rot_Vec3(blend_dq[0], normal.xyz);
		nor += n * bone_weight[2];
#endif
	}

	//3
	boneIdx = int(bone_index[3]) * 2;
	if (boneIdx < MAX_BONES * 2)
	{
		float signNum = 1.0; // 要考虑四元数的相容性，保证任意2个点积的符号为正
		if (dot(BoneVec[boneIdx0], BoneVec[boneIdx]) < 0.0)
		{
			signNum = -1.0;
		}

		blend_dq[0] = signNum * BoneVec[boneIdx];
		blend_dq[1] = BoneVec[boneIdx + 1];

		vec3 p, n;
		p = position.xyz * blend_dq[1].w; // 缩放
		p = _DQ_Rot_Vec3(blend_dq[0], p); // 旋转
		p += blend_dq[1].xyz; // 平移
		pos += p * bone_weight[3];
#ifdef NEED_NORMAL
		n = _DQ_Rot_Vec3(blend_dq[0], normal.xyz);
		nor += n * bone_weight[3];
#endif
	}

	position.xyz = pos;
	normal.xyz = nor;
}
#endif