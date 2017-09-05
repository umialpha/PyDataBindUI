texture Tex0
<
    string SasUiLabel = "Texture"; 
    string SasUiControl = "FilePicker"; 
>;
sampler SamplerTexture = sampler_state
{
    Texture   = (Tex0);
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
}; 
int ScreenWidth
<
    string SasUiLabel = "ScreenWidth"; 
    string SasUiControl = "IntPicker";
    int SasUiMin = 1;
    int SasUiMax = 10000;
    int SasUiSteps = 1;
> = 1665;
int ScreenHeight
<
    string SasUiLabel = "ScreenHeight"; 
    string SasUiControl = "IntPicker";
    int SasUiMin = 1;
    int SasUiMax = 10000;
    int SasUiSteps = 1;
> = 953;

// float4 Translation
// <
    // string SasUiLabel = "Translation"; 
    // string SasUiControl = "FloatXPicker";
    // float SasUiMin = -1.0;
    // float SasUiMax = 1.0;
    // float SasUiSteps = 0.05;
// > = (0.0, 0.0, 0.0, 0.0);

// float Alpha
// <
    // string SasUiLabel = "Alpha"; 
    // string SasUiControl = "FloatPicker";
    // float SasUiMin = 0;
    // float SasUiMax = 3.14;
    // float SasUiSteps = 0.05;
// > = 0.1;

struct VS_INPUT
{
    float4 Position:        POSITION;
    float4 TexCoord0:       TEXCOORD0;
};


struct VS_OUTPUT
{
    float4 Position:        POSITION;
    float2 TexCoord0 :      TEXCOORD0;
};


///////////////////////////////////////////////////
// vs
VS_OUTPUT mainVS(VS_INPUT IN)
{
    VS_OUTPUT OUT;
    // float2 position = float2(IN.Position.x * 2.0 * ScreenHeight / ScreenWidth, IN.Position.z * 2.0);
    // position += Translation.xy;
    // float2 sc = float2(sin(Alpha), cos(Alpha));
    //OUT.Position = float4(IN.Position.x, IN.Position.z, 0, 1);
    OUT.Position = float4(IN.Position.x * 2.0 , IN.Position.y * 2.0 , 0, 1);
    // OUT.Position = float4(position.x * sc.x + position.y * sc.y, position.x * sc.y - position.y * sc.x, 0.0, 1.0);
    // OUT.Position = float4(Scale.x * (position.x * sc.x + position.y * sc.y), Scale.y * (position.x * sc.y - position.y * sc.x), 0.0, 1.0);
    OUT.TexCoord0 = IN.TexCoord0.xy;
    return OUT;
}


///////////////////////////////////////////////////
// ps 

float4 mainPS(VS_OUTPUT IN) : COLOR 
{
    return tex2D(SamplerTexture, IN.TexCoord0);
}

technique technique0
<
    string Description = "make sure model is from (-1,-1) to (1,1)";
> 
{
    pass p0 
    {
        VertexShader = compile vs_3_0 mainVS();
        PixelShader = compile ps_3_0 mainPS();
    }
}
