uniform sampler2D fm_diffuse_reflectance_texture;

varying mediump vec2 v_texcoord;

void main(void)
{
	gl_FragColor = texture2D(fm_diffuse_reflectance_texture, v_texcoord);
}
