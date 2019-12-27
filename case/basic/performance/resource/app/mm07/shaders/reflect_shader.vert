attribute mediump vec3 fm_position;
attribute mediump vec4 fm_color;
attribute mediump vec2 fm_texcoord0;

uniform mediump vec4 fm_view_position;

uniform mediump mat4 fm_local_to_clip_matrix;
uniform mediump mat4 fm_local_to_world_matrix;

varying mediump vec4 v_color;
varying mediump vec2 v_texcoord;
varying mediump float v_calm_height;

void main(void)
{
    mediump float water_surface_y = -5.0;//-8.5847;
    mediump float calm_scale = 8.0;

    mediump vec4 vertex_position_world = fm_local_to_world_matrix * vec4(fm_position, 1.0);

    v_color = fm_color / 255.0;
    v_texcoord = fm_texcoord0;
    v_calm_height = clamp(calm_scale * (water_surface_y - vertex_position_world.y), 0.0, 1.0);

    gl_Position = fm_local_to_clip_matrix * vec4(fm_position, 1.0);
}
 