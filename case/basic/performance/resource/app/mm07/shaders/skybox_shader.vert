attribute vec3 fm_position;
attribute vec2 fm_texcoord0;

uniform mediump mat4 fm_local_to_clip_matrix;
uniform mediump vec4 fm_filter_intensity;

varying mediump vec2 v_texcoord;
varying mediump float v_intensity;

void main(void)
{
    precision mediump float;

    v_intensity = pow(1.0, fm_filter_intensity.x);
    gl_Position = fm_local_to_clip_matrix * vec4(fm_position, 1.0);
    v_texcoord = fm_texcoord0;
}
 