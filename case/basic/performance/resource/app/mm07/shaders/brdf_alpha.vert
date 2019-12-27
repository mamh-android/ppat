attribute mediump vec3 fm_position;
attribute mediump vec4 fm_color;
attribute mediump vec2 fm_texcoord0;

uniform mediump vec4 fm_shadow_bias;
uniform mediump mat4 fm_local_to_clip_matrix;

varying mediump vec4 v_color;
varying mediump vec2 v_texcoord;

void main(void)
{
    v_texcoord = fm_texcoord0;
    v_color = clamp((fm_color / 256.0) + fm_shadow_bias.xxxx, 0.0, 1.0);
    gl_Position = fm_local_to_clip_matrix * vec4(fm_position, 1.0);
}
 