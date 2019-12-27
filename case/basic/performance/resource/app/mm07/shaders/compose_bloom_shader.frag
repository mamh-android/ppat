uniform sampler2D fm_texture0;
uniform sampler2D fm_texture1;

uniform mediump vec4 fm_defog_color;
uniform mediump vec4 fm_gamma;

varying mediump vec2 v_texcoord;
varying mediump float v_exposure;

void main(void)
{
   mediump vec4 scene_color = texture2D(fm_texture0, v_texcoord);
   mediump vec4 bloom_color = texture2D(fm_texture1, v_texcoord);

   mediump vec3 defog = fm_defog_color.rgb;
   mediump vec3 color = max(vec3(0.0), (scene_color.rgb + bloom_color.rgb) - defog) * v_exposure;

   // gamma correction - could use texture lookups for this
   mediump vec3 gamma = fm_gamma.xxx;
   gl_FragColor.rgb = pow(color.rgb, gamma.rgb);
   gl_FragColor.a = 1.0;
} 