uniform mediump mat4 ProjectionMatrix;

attribute vec3 Position;
attribute vec2 TexCoord;

// output
varying mediump vec2 v_texcoord0;
varying mediump vec2 v_texcoord1;

// parameters in
uniform mediump float offset;
uniform mediump vec2 c_vs;
uniform mediump vec2 center;
uniform mediump float scale;

void main()
{
    mediump vec2 z;
    mediump vec2 c;

    c.x = 1.3333 * (TexCoord.x - 0.5) * scale - center.x;
    c.y = (TexCoord.y - 0.5) * scale - center.y;

    lowp int i;
    z = c;
    for(i=0; i<ITERATIONS_VS; i++) 
    {
        mediump float x = (z.x * z.x - z.y * z.y) + c.x + c_vs.x;
        mediump float y = (z.y * z.x + z.x * z.y) + c.y + c_vs.y;

        if((x * x + y * y) > 4.0) 
            break;

        z.x = x;
        z.y = y;
    }

    gl_Position = ProjectionMatrix * vec4(Position, 1.0);		// vertex_position_in_clip_space	
    v_texcoord0 = TexCoord;
    v_texcoord1 = vec2(float((i == ITERATIONS_VS ? 0.0 : float(i)) / 100.0) + offset, 0.0);
}
