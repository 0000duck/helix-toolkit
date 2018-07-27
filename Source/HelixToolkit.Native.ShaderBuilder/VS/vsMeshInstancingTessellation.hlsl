#ifndef VSMESHINSTANCINGTESSELLATION_HLSL
#define VSMESHINSTANCINGTESSELLATION_HLSL

#define MESH
#include"..\Common\CommonBuffers.hlsl"
#include"..\Common\DataStructs.hlsl"
#pragma pack_matrix( row_major )

//--------------------------------------------------------------------------------------
// VERTEX SHADER function
// called per incoming vertex/control point
//--------------------------------------------------------------------------------------
HSInput main(VSInstancingInput input)
{
	HSInput output = (HSInput) 0;
	float4 inputp = input.p;
	float3 inputn = input.n;
	float3 inputt1 = input.t1;
	float3 inputt2 = input.t2;
	if (bInvertNormal)
	{
		inputn = -inputn;
	}
	if (bHasInstances)
	{
        matrix mInstance =
        {
            input.mr0,
			input.mr1,
			input.mr2,
			input.mr3
        };
		inputp = mul(input.p, mInstance);
		inputn = mul(inputn, (float3x3) mInstance);
		if (bHasNormalMap)
		{
			inputt1 = mul(inputt1, (float3x3) mInstance);
			inputt2 = mul(inputt2, (float3x3) mInstance);
		}
	}
    if (!bHasInstanceParams)
    {
        output.t = mul(float4(input.t.xy, 0, 1), (float4x2) uvTransform).xy;
        output.c = vMaterialDiffuse;
        output.c2 = mad(vMaterialAmbient, vLightAmbient, vMaterialEmissive);
    }
    else
    {
		//set texture coords and color
        output.t = mul(float4(input.t.xy, 0, 1), (float4x2) uvTransform).xy + input.tOffset;
        output.c = input.diffuseC;
        output.c2 = mad(input.ambientC, vLightAmbient, input.emissiveC);
    }
    output.p = mul(inputp, mWorld).xyz;
	output.n = inputn;
	output.t1 = inputt1;
	output.t2 = inputt2;
    float tess = saturate((minTessDistance - distance(output.p, vEyePos)) / (minTessDistance - maxTessDistance));
    output.tessF = mad(tess, (maxTessFactor - minTessFactor), minTessFactor);
	return output;
}
#endif