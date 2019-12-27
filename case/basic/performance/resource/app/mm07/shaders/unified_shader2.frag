uniform sampler2D tex0;
//uniform sampler2D tex1;
uniform mediump float offset;

uniform mediump vec2 c_ps;
uniform mediump int palette_size;
uniform mediump float frag_vert_blend;

varying mediump vec2 v_texcoord0;
varying mediump vec2 v_texcoord1;

const int num = (SAMPLE_COUNT_FS - 1) / 2;

void main() 
{
    mediump vec2 z;
    z.x = 3.0 * (v_texcoord0.x - 0.5);
    z.y = 2.0 * (v_texcoord0.y - 0.5);

    lowp int i;
    for(i=0; i<ITERATIONS_FS; i++) 
    {
        mediump float x = (z.x * z.x - z.y * z.y) + c_ps.x;
        mediump float y = (z.y * z.x + z.x * z.y) + c_ps.y;

        if((x * x + y * y) > 4.0) 
            break;
        
        z.x = x;
        z.y = y;
    }
    mediump float fractalX = float((i == ITERATIONS_FS ? 0.0 : float(i)) / 100.0) + offset;
    
    
    mediump vec4 totalColor0 = vec4(0.0, 0.0, 0.0, 1.0);
    mediump vec4 totalColor1 = vec4(0.0, 0.0, 0.0, 1.0); 

    mediump float pixelStep = 1.0 / float(palette_size);
    for( int x = -num; x <= +num; x++ )
    {
        mediump vec4 color0 = texture2D(tex0, vec2(fractalX+(float(x)*pixelStep), 0.0));
        mediump vec4 color1 = texture2D(tex0, vec2(v_texcoord1.x+float(x)*pixelStep, 0.0));
        if( x == 0 )
        {
            totalColor0 += color0 * color0 * float(num+1);
            totalColor1 += color1 * color1 * float(num+1);
        }
        else
        {
            totalColor0 += color0;
            totalColor1 += color1;
        }
    }   
    totalColor0 /= float((num*2)+1);
    totalColor1 /= float((num*2)+1);
    
    gl_FragColor = mix(totalColor1, totalColor0, frag_vert_blend);
}