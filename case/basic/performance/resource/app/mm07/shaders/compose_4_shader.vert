attribute mediump vec2 fm_position;
attribute mediump vec2 fm_texcoord0;

varying mediump vec2 v_texcoord;

void main()
{
   gl_Position = vec4(fm_position, 0.0, 1.0);
   v_texcoord = fm_texcoord0;
} 