uniform sampler2D fm_texture0;
uniform mediump vec4 fm_filter_kernel_size;
uniform mediump vec4 fm_filter_threshold;
uniform mediump vec4 fm_filter_intensity;

varying mediump vec2 v_texcoord;

mediump vec4 get_sample(mediump vec2 texcoord)
{
    mediump vec4 sample = texture2D(fm_texture0, texcoord);
    return max(sample - fm_filter_threshold.xxxx, vec4(0.0));
}

void main()
{
   mediump vec2 offset = fm_filter_kernel_size.xx;
   mediump vec2 offset2 = vec2(offset.y, -offset.x);
   mediump vec4 sample = vec4(0.0, 0.0, 0.0 ,1.0);

   // get four samples
   sample += 0.15 * get_sample(v_texcoord + offset);
   sample += 0.15 * get_sample(v_texcoord - offset);
   sample += 0.15 * get_sample(v_texcoord + offset2);
   sample += 0.15 * get_sample(v_texcoord - offset2);
   sample +=   0.4 * get_sample(v_texcoord); 

   //sample = (1.8 * sample) - (0.9 * sample * sample * sample);
 
   sample = sample * fm_filter_intensity.x;

   gl_FragColor = sample;
}

 