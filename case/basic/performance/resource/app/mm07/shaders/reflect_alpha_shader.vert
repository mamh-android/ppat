attribute mediump vec3 fm_position;
attribute mediump vec4 fm_color;
attribute mediump vec2 fm_texcoord0;

uniform mediump mat4 fm_local_to_clip_matrix;

varying mediump vec4 v_color;
varying mediump vec2 v_texcoord;

void main(void)
{
    v_color = fm_color / 255.0;
    v_texcoord = fm_texcoord0;

    gl_Position = fm_local_to_clip_matrix * vec4(fm_position, 1.0);
}
 