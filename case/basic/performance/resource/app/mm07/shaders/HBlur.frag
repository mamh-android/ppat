uniform sampler2D tex0;
uniform mediump vec4 fm_viewport_x_y_width_height;
uniform mediump float luminance;

varying mediump vec2 v_T2d;

const lowp int KernelSize = 13;

mediump vec2 PixelKernel[KernelSize];
/*const mediump vec2 PixelKernel[KernelSize] =
{
    {0.0, -6.0},
    {0.0, -5.0},
    {0.0, -4.0},
    {0.0, -3.0},
    {0.0, -2.0},
    {0.0, -1.0},
    {0.0,  0.0},
    {0.0,  1.0},
    {0.0,  2.0},
    {0.0,  3.0},
    {0.0,  4.0},
    {0.0,  5.0},
    {0.0,  6.0}
};*/

mediump float Weights[KernelSize];
/*const mediump float Weights[KernelSize] = 
{
    0.002216,
    0.008764,
    0.026995,
    0.064759,
    0.120985,
    0.176033,
    0.199471,
    0.176033,
    0.120985,
    0.064759,
    0.026995,
    0.008764,
    0.002216
};*/

void main(void)
{
    mediump vec2 size;
    size.x = fm_viewport_x_y_width_height.z;
    size.y = fm_viewport_x_y_width_height.w;

    PixelKernel[0]  = vec2(-6.0, 0.0);
    PixelKernel[1]  = vec2(-5.0, 0.0);
    PixelKernel[2]  = vec2(-4.0, 0.0);
    PixelKernel[3]  = vec2(-3.0, 0.0);
    PixelKernel[4]  = vec2(-2.0, 0.0);
    PixelKernel[5]  = vec2(-1.0, 0.0);
    PixelKernel[6]  = vec2( 0.0, 0.0);
    PixelKernel[7]  = vec2( 1.0, 0.0);
    PixelKernel[8]  = vec2( 2.0, 0.0);
    PixelKernel[9]  = vec2( 3.0, 0.0);
    PixelKernel[10] = vec2( 4.0, 0.0);
    PixelKernel[11] = vec2( 5.0, 0.0);
    PixelKernel[12] = vec2( 6.0, 0.0);

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
        Color += texture2D(tex0, v_T2d + PixelKernel[i].xy / float(size.x)) * Weights[i];
    }

    //bright pass filtering
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
