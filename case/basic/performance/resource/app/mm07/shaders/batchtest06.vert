uniform mediump mat4 fm_view_to_clip_matrix;

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

varying mediump vec2   v_texcoord;

void main()
{
	gl_Position	= fm_view_to_clip_matrix * vec4(fm_position, 1.0);	// vertex_position_in_clip_space
	
	v_texcoord	= fm_texcoord;										// attribute 'Vertex texture coordinate'
	v_texcoord  += bt_texcoord0.xy - bt_texcoord1.xy + bt_texcoord2.xy - bt_texcoord3.xy;
	v_texcoord  += bt_texcoord4.xy - bt_texcoord5.xy + bt_texcoord6.xy - bt_texcoord7.xy;
}
