uniform sampler2D fm_diffuse_reflectance_texture;      // 'Surface diffuse reflectance texture'

varying mediump vec2 v_texcoord;
varying mediump vec4 v_color;

void main(void)
{
    mediump float alpha = texture2D(fm_diffuse_reflectance_texture, v_texcoord).a;
	gl_FragColor = vec4(v_color.rgb * alpha, 1.0);
}
