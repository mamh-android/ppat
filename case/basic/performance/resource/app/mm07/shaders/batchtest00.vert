uniform mediump mat4 fm_view_to_clip_matrix;

attribute vec3 fm_position;
attribute vec2 fm_texcoord;

varying mediump vec2 v_texcoord;

void main()
{
	gl_Position	= fm_view_to_clip_matrix * vec4(fm_position, 1.0);	// vertex_position_in_clip_space
	v_texcoord	= fm_texcoord;										// attribute 'Vertex texture coordinate'
}
