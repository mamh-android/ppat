uniform sampler2D tex0;
varying mediump vec2 v_T2d;

void main(void)
{
    gl_FragColor = texture2D(tex0, v_T2d);
}
