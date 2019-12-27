uniform sampler2D fm_texture0;
uniform mediump vec4 fm_filter_kernel_size;

varying mediump vec2 v_texcoord;

mediump vec4 get_sample(mediump vec2 texcoord)
{
    mediump vec4 sample = texture2D(fm_texture0, texcoord);
    return sample;
}

void main()
{
   mediump vec4 sample = vec4(0.0, 0.0, 0.0 ,0.0);

   // using triangle of sample points + center with gaussian weighting; 
   // triangle is inverted from previous pass, thus we get a pseudo-hexagonal kernel
   sample += 0.4 * get_sample(v_texcoord);
   sample += 0.2 * get_sample(v_texcoord + vec2(1.0, 0.0) * fm_filter_kernel_size.xx);
   sample += 0.2 * get_sample(v_texcoord + vec2(-0.707, 0.707) * fm_filter_kernel_size.xx);
   sample += 0.2 * get_sample(v_texcoord + vec2( -0.707, -0.707) * fm_filter_kernel_size.xx); 

   gl_FragColor = sample;
}
 