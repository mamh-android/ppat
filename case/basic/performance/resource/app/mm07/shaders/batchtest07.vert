uniform mediump mat4 fm_view_to_clip_matrix;

uniform mediump vec4 bt_color0;
uniform mediump vec4 bt_color1;
uniform mediump vec4 bt_color2;
uniform mediump vec4 bt_color3;
uniform mediump vec4 bt_color4;
uniform mediump vec4 bt_color5;
uniform mediump vec4 bt_color6;
uniform mediump vec4 bt_color7;
uniform mediump vec4 bt_color8;
uniform mediump vec4 bt_color9;
uniform mediump vec4 bt_color10;
uniform mediump vec4 bt_color11;
uniform mediump vec4 bt_color12;
uniform mediump vec4 bt_color13;
uniform mediump vec4 bt_color14;
uniform mediump vec4 bt_color15;

uniform mediump vec4 bt_texcoord0;
uniform mediump vec4 bt_texcoord1;
uniform mediump vec4 bt_texcoord2;
uniform mediump vec4 bt_texcoord3;
uniform mediump vec4 bt_texcoord4;
uniform mediump vec4 bt_texcoord5;
uniform mediump vec4 bt_texcoord6;
uniform mediump vec4 bt_texcoord7;

attribute vec3 fm_position;
attribute vec2 fm_texcoord;

varying mediump vec2 v_texcoord;
varying mediump vec4 v_color;

void main()
{
	gl_Position = fm_view_to_clip_matrix * vec4(fm_position, 1.0);	// vertex_position_in_clip_space

	v_color = bt_color0 + bt_color1 - bt_color2 + bt_color3 - bt_color4 + bt_color5 - bt_color6 + bt_color7;
	v_color += bt_color8 + bt_color9 - bt_color10 + bt_color11 - bt_color12 + bt_color13 - bt_color14 + bt_color15;

	v_texcoord	= fm_texcoord;										// attribute 'Vertex texture coordinate'
	v_texcoord  += bt_texcoord0.xy - bt_texcoord1.xy + bt_texcoord2.xy - bt_texcoord3.xy;
	v_texcoord  += bt_texcoord4.xy - bt_texcoord5.xy + bt_texcoord6.xy - bt_texcoord7.xy;
}
