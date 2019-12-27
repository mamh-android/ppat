uniform mediump vec4 fm_light_diffuse_color;
uniform mediump vec4 fm_light_direction;
uniform mediump vec4 fm_object_shadow;

uniform mediump vec4 fm_delta_diffuse_color;
uniform mediump vec4 fm_delta_specular_color;
uniform mediump vec4 fm_delta_specular_exponent;
uniform mediump vec4 fm_color_posy;
uniform mediump vec4 fm_color_posx;
uniform mediump vec4 fm_color_negy;

uniform mediump vec4 fm_shadow_bias;

uniform sampler2D fm_texture0;

varying mediump vec3 v_normal;
varying mediump vec3 v_view_direction;
varying mediump vec2 v_texcoord0;
varying mediump vec4 v_color;
varying mediump vec3 v_half;

mediump vec3 screen(mediump vec3 a, mediump vec3 b)
{
    mediump vec3 white = vec3(1.0);
    mediump vec3 res;
    res = white - (white - a) * (white - b);
    return res;
}

void main(void)
{
    mediump vec3 N  = normalize(v_normal);
    mediump vec3 V  = v_view_direction;
    mediump vec3 L  = fm_light_direction.xyz;
    mediump vec3 H =v_half;

    mediump float hn_clamped = max(0.0, dot(H, N));
    mediump float ln_clamped  = max(0.0, dot(L, N));
    
    mediump vec3 delta_diffuse0 = ln_clamped * fm_delta_diffuse_color.rgb; 
    mediump float shadow = clamp( fm_shadow_bias.x + fm_object_shadow.a, 0.0, 1.0);
    mediump vec3 ambient_diffuse0;
    ambient_diffuse0 += max(0.0, 1.0 - abs(N.y)) * fm_color_posx.rgb;
    ambient_diffuse0 += max(0.0, N.y) * fm_color_posy.rgb;
    ambient_diffuse0 += max(0.0, -N.y) * fm_color_negy.rgb;

    mediump vec3 delta_specular0 = pow(hn_clamped, fm_delta_specular_exponent.x) * fm_delta_specular_color.rgb * sqrt(ln_clamped);

    mediump vec4 tex = texture2D(fm_texture0, v_texcoord0);

    mediump vec3 ambient_diffuse = tex.rgb * v_color.rgb * fm_object_shadow.rgb * ambient_diffuse0;
    mediump vec3 delta_diffuse = tex.rgb * shadow * delta_diffuse0;
    mediump vec3 delta_specular = tex.a * shadow * delta_specular0;
    gl_FragColor.rgb  = screen(delta_diffuse + delta_specular, ambient_diffuse);
    gl_FragColor.rgb  = ambient_diffuse;
    gl_FragColor.rgb  = delta_diffuse + delta_specular + ambient_diffuse;
    gl_FragColor.rgb  = screen(delta_diffuse + delta_specular, ambient_diffuse);
//    gl_FragColor.rgb  = fm_object_shadow.aaa;
    gl_FragColor.a  = 1.0;
}
 