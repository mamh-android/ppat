
uniform sampler2D    fm_diffuse_reflectance_texture;  // 'Surface diffuse reflectance texture'
varying mediump vec2 v_T2d;                             // 'Surface texture coordinate'

void main(void)
{
    mediump vec4 Crd  = texture2D(fm_diffuse_reflectance_texture, v_T2d); // diffuse_surface_factor
    gl_FragColor = Crd;
    //gl_FragColor.r = v_T2d.x * 0.4;
    //gl_FragColor.g = v_T2d.y * 0.4;
    //gl_FragColor = vec4(1,1,1,1);
    gl_FragColor.a = 1.0;
}
