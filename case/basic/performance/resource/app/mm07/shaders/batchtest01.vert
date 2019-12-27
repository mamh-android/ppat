uniform mediump mat4 fm_view_to_clip_matrix;

uniform mediump vec4 bt_color0;
uniform mediump vec4 bt_color1;
uniform mediump vec4 bt_color2;
uniform mediump vec4 bt_color3;

attribute vec3 fm_position;
attribute vec2 fm_texcoord;

varying mediump vec2 v_texcoord;
varying mediump vec4 v_color;

void main()
{
	gl_Position = fm_view_to_clip_matrix * vec4(fm_position, 1.0);	// vertex_position_in_clip_space
	v_color     = (bt_color0 + bt_color1 + bt_color2 + bt_color3) * 0.25;
	v_texcoord  = fm_texcoord;                                      // attribute 'Vertex texture coordinate'
}
