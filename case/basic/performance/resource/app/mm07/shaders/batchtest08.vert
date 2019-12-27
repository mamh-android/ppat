uniform mediump mat4    fm_view_to_clip_matrix;
uniform mediump float   fm_time;
uniform mediump vec2    current_grid_position;

attribute vec3 fm_position;
attribute vec2 fm_texcoord;

uniform mediump vec4 bt_color0;
uniform mediump vec4 bt_color1;
uniform mediump vec4 bt_color2;
uniform mediump vec4 bt_color3;

varying mediump vec2 v_noise_offset;
varying mediump vec4 v_color;

void main()
{
	gl_Position = fm_view_to_clip_matrix * vec4(fm_position, 1.0);	// vertex_position_in_clip_space
	
    mediump vec2 scaled_texcoord = fm_texcoord;
    scaled_texcoord.x -= current_grid_position.x;
    scaled_texcoord.y -= current_grid_position.y;
    
    v_noise_offset = scaled_texcoord + 0.4 + sin(fm_time) * 0.1;
    v_color     = bt_color0 + bt_color1 + bt_color2 + bt_color3;
}
