uniform sampler2D tex0;
uniform mediump vec4 fm_viewport_x_y_width_height;
uniform mediump float offset_factor;
uniform mediump vec2 stripe_dir;
uniform mediump float attenuation_factor;

varying mediump vec2 v_T2d;

const mediump float factor = 0.75;
const lowp int num_samples = 5;
mediump vec2 samples[num_samples];


void main(void)
{
    mediump vec2 size;
    size.x = fm_viewport_x_y_width_height.z;
    size.y = fm_viewport_x_y_width_height.w;

    lowp int i;
    for( i = 0; i < num_samples; ++i )
    {
        samples[i]  = stripe_dir * float(i);
    }

    mediump vec4 Color = vec4(0.0, 0.0, 0.0, 1.0);
    for( i = 0; i < num_samples; ++i )
    {
        mediump vec4 col =  pow(attenuation_factor, offset_factor*float(i)) * 
                            texture2D(tex0, v_T2d + (offset_factor * vec2(samples[i].x / size.x, samples[i].y / size.y)));
        Color += col;
    }

	gl_FragColor = Color * factor;
}
