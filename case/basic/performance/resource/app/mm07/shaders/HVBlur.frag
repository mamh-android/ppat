uniform sampler2D tex0;
uniform mediump vec4 fm_viewport_x_y_width_height;
uniform mediump float luminance;

varying mediump vec2 v_T2d;

const lowp int KernelSize = 13;

mediump vec2 PixelKernelV[KernelSize];
mediump vec2 PixelKernelH[KernelSize];

mediump float Weights[KernelSize];


void main(void)
{
    mediump vec2 size;
    size.x = fm_viewport_x_y_width_height.z;
    size.y = fm_viewport_x_y_width_height.w;

    PixelKernelH[0]  = vec2(-6.0, 0.0);
    PixelKernelH[1]  = vec2(-5.0, 0.0);
    PixelKernelH[2]  = vec2(-4.0, 0.0);
    PixelKernelH[3]  = vec2(-3.0, 0.0);
    PixelKernelH[4]  = vec2(-2.0, 0.0);
    PixelKernelH[5]  = vec2(-1.0, 0.0);
    PixelKernelH[6]  = vec2( 0.0, 0.0);
    PixelKernelH[7]  = vec2( 1.0, 0.0);
    PixelKernelH[8]  = vec2( 2.0, 0.0);
    PixelKernelH[9]  = vec2( 3.0, 0.0);
    PixelKernelH[10] = vec2( 4.0, 0.0);
    PixelKernelH[11] = vec2( 5.0, 0.0);
    PixelKernelH[12] = vec2( 6.0, 0.0);

    PixelKernelV[0]  = vec2(0.0, -6.0);
    PixelKernelV[1]  = vec2(0.0, -5.0);
    PixelKernelV[2]  = vec2(0.0, -4.0);
    PixelKernelV[3]  = vec2(0.0, -3.0);
    PixelKernelV[4]  = vec2(0.0, -2.0);
    PixelKernelV[5]  = vec2(0.0, -1.0);
    PixelKernelV[6]  = vec2(0.0,  0.0);
    PixelKernelV[7]  = vec2(0.0,  1.0);
    PixelKernelV[8]  = vec2(0.0,  2.0);
    PixelKernelV[9]  = vec2(0.0,  3.0);
    PixelKernelV[10] = vec2(0.0,  4.0);
    PixelKernelV[11] = vec2(0.0,  5.0);
    PixelKernelV[12] = vec2(0.0,  6.0);

    Weights[0]  = 0.002216;
    Weights[1]  = 0.008764;
    Weights[2]  = 0.026995;
    Weights[3]  = 0.064759;
    Weights[4]  = 0.120985;
    Weights[5]  = 0.176033;
    Weights[6]  = 0.199471;
    Weights[7]  = 0.176033;
    Weights[8]  = 0.120985;
    Weights[9]  = 0.064759;
    Weights[10] = 0.026995;
    Weights[11] = 0.008764;
    Weights[12] = 0.002216;

    mediump vec4 Color = vec4(0.0, 0.0, 0.0, 1.0);

    for( lowp int i = 0; i < KernelSize; i++ )
    {    
        Color += texture2D(tex0, v_T2d + PixelKernelH[i].xy / float(size.x)) * Weights[i] * 0.5;
        Color += texture2D(tex0, v_T2d + PixelKernelV[i].xy / float(size.y)) * Weights[i] * 0.5;
    }

    //high pass filtering
    const mediump float fMiddleGray = 0.18;
    const mediump float fWhiteCutoff = 0.8;
    const mediump float fThreshold = 5.0;
    const mediump float fOffset = 10.0;
    Color *= fMiddleGray / (luminance + 0.001);
    Color *= (1.0 + (Color / (fWhiteCutoff * fWhiteCutoff)));
    Color -= fThreshold;
    Color = max(Color, 0.0);
    Color /= (fOffset + Color);
    Color.w = 1.0;
    
    //black & white bloom
    //Color = vec4((Color.x + Color.y + Color.z) / 3.0);

	gl_FragColor = Color;
}
