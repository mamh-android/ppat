attribute vec3 fm_position;
attribute vec2 fm_texcoord0;
attribute vec3 fm_normal;

const lowp int       Li = 2;                // constant 'Light count'

uniform mediump mat4 fm_projection_matrix;
uniform mediump vec3 fm_light_position[Li]; // 'Light position in world coordinates (array)'
uniform mediump vec3 fm_view_position;      // 'View position in world coordinates'

varying mediump vec2 v_T2d;     // 'Surface texture coordinate'
varying mediump vec3 v_N0w;     // 'Normal direction, before normalization and bump'
varying mediump vec3 v_Tw;      // 'Tangent direction'
varying mediump vec3 v_L0w[Li]; // 'Light direction, before normalization'
varying mediump vec3 v_V0w;     // 'View direction, before normalization'

void main()
{
    gl_Position = fm_projection_matrix * vec4(fm_position, 1.0); // vertex_position_in_clip_space

    v_N0w = vec3(0.0, 0.0, 1.0); // fm_normal;
    v_Tw  = vec3(1.0, 0.0, 0.0);

    v_T2d = fm_texcoord0;      // attribute 'Vertex texture coordinate'
    v_V0w = fm_view_position;  // ( fm_view_position.xyz / fm_view_position.w );

    for(lowp int i = 0; i < Li; ++i)
    {
        v_L0w[i] = fm_light_position[i] - fm_position;  // light_direction0,  varying
    }
}
