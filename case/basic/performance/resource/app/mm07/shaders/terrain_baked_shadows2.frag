uniform mediump vec4 fm_light_direction;

uniform mediump vec4 fm_delta_diffuse_color;
uniform mediump vec4 fm_delta_specular_color;
uniform mediump vec4 fm_delta_specular_exponent;

uniform mediump vec4 fm_shadow_bias;

uniform mediump vec4 fm_color0;
uniform mediump vec4 fm_color1;

uniform sampler2D fm_texture0;
uniform sampler2D fm_texture1;

varying mediump vec3 v_normal;
varying mediump vec3 v_view_direction;
varying mediump vec3 v_position;
varying mediump vec4 v_color;

mediump vec3 screen(mediump vec3 a, mediump vec3 b)
{
    mediump vec3 white = vec3(1.0, 1.0, 1.0);
    mediump vec3 res = white - (white - a) * (white - b);
    return res;
//    return a +b;
}

void main(void)
{
    mediump vec3 N  = normalize(v_normal);
    mediump vec3 V  = normalize(v_view_direction);
    mediump vec3 L  = fm_light_direction.xyz;
    mediump vec3 H = normalize(L + V);

    mediump float ln  = dot(L, N);
    mediump float hn = dot(H, N);
    mediump float ln_clamped = max(0.0, ln);
    mediump vec3 n2 = N * N;

    mediump vec3 texcoord = v_position.xyz;
    mediump vec4 tex = n2.x * texture2D(fm_texture0, texcoord.yz * vec2(0.5, 1.0));
    tex += n2.y * texture2D(fm_texture1, texcoord.xz * vec2(1.0, 1.0));
    tex += n2.z * texture2D(fm_texture0, texcoord.xy * vec2(1.0, 0.5));
    
    mediump vec3 delta_diffuse = ln_clamped * fm_delta_diffuse_color.rgb;
    mediump vec3 ambient_diffuse = 2.0 * v_color.rgb * tex.rrr;
    mediump vec3 shadow = v_color.aaa;

    // Specular
    mediump vec3 delta_specular = vec3(0.0);
    if(ln > 0.0)
    {
        mediump float hnp = pow(hn, fm_delta_specular_exponent.x);
        delta_specular += (1.0 - n2.y) * hnp * hnp * tex.aaa;
        delta_specular += vec3(0.5 * n2.y) * hnp;
    }

    mediump vec3 fog = max(0.0, (1.0 - gl_FragCoord.w * 100.0)) * fm_color1.rgb;
    mediump vec3 delta = shadow * tex.rgb * (delta_diffuse + delta_specular);
    mediump vec3 shade = screen(delta + ambient_diffuse.rgb, fog); 
    gl_FragColor.rgb  = shade;
    gl_FragColor.a  = 1.0;
}
 