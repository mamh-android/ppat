uniform sampler2D fm_diffuse_reflectance_texture;

varying mediump vec2 v_texcoord;

void main(void)
{
    mediump float alpha = texture2D(fm_diffuse_reflectance_texture, v_texcoord).a;
    gl_FragColor = vec4(alpha, alpha, alpha, 1.0);
}
