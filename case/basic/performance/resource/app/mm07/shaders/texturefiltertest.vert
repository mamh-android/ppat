uniform mediump mat4 fm_world_to_clip_matrix;

attribute vec3 fm_position;
attribute vec2 fm_texcoord0;

varying mediump vec2 v_T2d;

void main()
{
    gl_Position = fm_world_to_clip_matrix * vec4(fm_position, 1.0);  // vertex_position_in_clip_space
    v_T2d.xy      = fm_texcoord0;                                      // attribute 'Vertex texture coordinate'
}
