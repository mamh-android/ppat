uniform sampler2D fm_diffuse_reflectance_texture;
uniform mediump vec4 fm_delta_diffuse_color;
uniform mediump vec4 fm_light_diffuse_color;

varying mediump vec4 v_color;
varying mediump vec2 v_texcoord;

void main(void)
{
    mediump vec4 tex = texture2D(fm_diffuse_reflectance_texture, v_texcoord);
    if(tex.a == 0.0) discard;

    mediump vec3 ambient = tex.rgb * fm_light_diffuse_color.rgb;

    gl_FragColor.rgb  = v_color.rgb * tex.rgb * fm_delta_diffuse_color.rgb + ambient;
    gl_FragColor.a  = tex.a;
}
 