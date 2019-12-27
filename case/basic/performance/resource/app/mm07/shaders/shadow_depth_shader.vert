attribute mediump vec3 fm_position;

uniform mediump mat4 fm_local_to_clip_matrix;

varying mediump vec4 v_position;

void main()
{
   mediump vec4 position = fm_local_to_clip_matrix * vec4(fm_position, 1.0);

   v_position = vec4(position.zzz, 1.0) * 0.5 + 0.5;
   gl_Position = position;
} 