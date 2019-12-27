attribute vec2 fm_position;
attribute vec2 fm_texcoord0;

uniform mediump vec4 fm_exposure;

varying mediump vec2 v_texcoord;
varying mediump float v_exposure;

void main()
{
   v_texcoord = fm_texcoord0;
   v_exposure = pow(2.0, fm_exposure.x);
   gl_Position = vec4(fm_position, 0.0, 1.0);
} 