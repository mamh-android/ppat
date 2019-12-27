varying mediump vec2 v_noise_offset;
varying mediump vec4 v_color;

mediump float fmu_noise2d(mediump vec2 offset)
{
    return fract(pow(abs(offset.x + offset.y * 1.7735375), 5.175755757) * 1375.754877);
}

void main(void)
{
    mediump float noise = fmu_noise2d(v_noise_offset);
    gl_FragColor = vec4(v_color.rgb * noise, 1.0);
}
