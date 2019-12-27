attribute mediump vec3 fm_position;

uniform mediump mat4 fm_local_to_clip_matrix;

varying mediump vec2 v_offset;

void main()
{
   mediump vec4 position = fm_local_to_clip_matrix * vec4(fm_position, 1.0);
   v_offset = position.xy / position.w;
   gl_Position = position;
} 