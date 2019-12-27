uniform mediump mat4 fm_view_to_clip_matrix;
uniform mediump mat4 fm_texture_matrix;
uniform mediump vec2 origin;

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
	gl_Position = fm_view_to_clip_matrix * vec4(fm_position, 1.0);
	
	mat4 matrix_to_origin = mat4(1.0, 0.0, 0.0, 0.0,
					             0.0, 1.0, 0.0, 0.0,
					             0.0, 0.0, 1.0, 0.0,
					             origin.x, origin.y, 0.0, 1.0);

	mat4 matrix_from_origin = mat4(1.0, 0.0, 0.0, 0.0,
					               0.0, 1.0, 0.0, 0.0,
					               0.0, 0.0, 1.0, 0.0,
					               -origin.x, -origin.y, 0.0, 1.0);


	v_texcoord = (matrix_to_origin * fm_texture_matrix * matrix_from_origin * vec4(fm_texcoord, 1, 1)).xy;
	v_color = (bt_color0 + bt_color1 + bt_color2 + bt_color3) * 0.25;
}
