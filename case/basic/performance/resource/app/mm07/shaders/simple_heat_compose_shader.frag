uniform sampler2D fm_texture0;
uniform sampler2D fm_texture1;
uniform mediump vec4 fm_filter_intensity;

varying mediump vec2 v_texcoord;

void main(void)
{
   mediump vec2 power = vec2(fm_filter_intensity.x);

   mediump vec2 distort = vec2(-1.0, -1.0) + texture2D(fm_texture1, v_texcoord).rg * 2.0;
   
   gl_FragColor = texture2D(fm_texture0, v_texcoord + distort * power);
} 