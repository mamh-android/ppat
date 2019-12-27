
attribute mediump vec3 fm_position;
attribute mediump vec3 fm_normal;
attribute mediump vec3 fm_tangent;

uniform mediump vec4 fm_time;

uniform mediump vec4 fm_particle_size;
uniform mediump vec4 fm_particle_force;

uniform mediump mat4 fm_local_to_world_matrix;

uniform mediump mat4 fm_world_to_view_matrix;

uniform mediump mat4 fm_world_to_clip_matrix;

uniform mediump mat4 fm_projection_matrix;

varying mediump float v_time;

void main(void)
{
    mediump float particle_time = mod(fm_time.x + fm_tangent.y, fm_tangent.x);

    mediump vec3 local_position = fm_position + particle_time * fm_normal;
    mediump vec4 world_position =  fm_local_to_world_matrix * vec4(local_position, 1.0);

    mediump vec4 force  =  fm_local_to_world_matrix * vec4(fm_particle_force.xyz, 0)  ;
    world_position += particle_time * particle_time * force ;
   
    mediump vec4 view_position = fm_world_to_view_matrix * world_position;
    mediump vec4 particle_radius_vector = vec4(fm_particle_size.x, 0.0, 0.0, 1.0);
    mediump vec4 position_right = fm_projection_matrix * (view_position + particle_radius_vector);
    mediump vec4 position_center = fm_projection_matrix * view_position;

    gl_PointSize = 2.0 * distance(position_right / position_right.w, position_center / position_center.w);
    gl_Position = position_center;

    v_time = particle_time;
}
 