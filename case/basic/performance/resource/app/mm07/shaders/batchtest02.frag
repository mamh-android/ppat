uniform sampler2D fm_diffuse_reflectance;

varying mediump vec4 v_color;

void main(void)
{
	gl_FragColor = v_color;
}