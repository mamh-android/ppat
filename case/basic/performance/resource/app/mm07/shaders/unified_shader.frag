uniform sampler2D tex;
uniform mediump vec2 center;
uniform mediump float scale;

varying mediump vec2 v_texcoord;

void main() 
{
    mediump vec2 z, c;

    c.x = 1.3333 * (v_texcoord.x - 0.5) * scale - center.x;
    c.y = (v_texcoord.y - 0.5) * scale - center.y;

    lowp int i;
    z = c;
    for(i=0; i<ITERATIONS_FS; i++) 
    {
        mediump vec2 float x = (z.x * z.x - z.y * z.y) + c.x;
        mediump vec2 float y = (z.y * z.x + z.x * z.y) + c.y;

        if((x * x + y * y) > 4.0) 
            break;

        z.x = x;
        z.y = y;
    }

    gl_FragColor = texture2D(tex, vec2(float((i == ITERATIONS_FS ? 0.0 : float(i)) / 100.0), 0.0));
//    gl_FragColor = (i == ITERATIONS_FS) ? vec4(0.0, 0.0, 0.0, 1.0) : vec4(1.0, 1.0, 1.0, 1.0);
}
	