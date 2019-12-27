attribute mediump vec3 fm_position;
attribute mediump vec3 fm_normal;

uniform mediump vec4 fm_view_position;
uniform mediump mat4 fm_local_to_clip_matrix;
uniform mediump mat4 fm_local_to_world_matrix;

varying mediump vec3 v_normal;

void main(void)
{
    gl_Position = fm_local_to_clip_matrix * vec4(fm_position, 1.0);
    v_normal = vec3(fm_local_to_world_matrix * vec4(fm_normal, 0.0));
}
 