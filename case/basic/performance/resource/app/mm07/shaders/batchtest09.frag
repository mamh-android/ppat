const int Li = 2;
uniform mediump vec3 LcolorA[Li];
uniform sampler2D   Rd0;      // 'Surface diffuse reflectance texture'
uniform sampler2D   Rd1;      // 'Surface diffuse reflectance texture'
uniform mediump vec3		ambient;
varying mediump vec2        T2d;     // 'Surface texture coordinate'
varying mediump vec3 L0w[Li];

void main(void)
{
	mediump float value = 1.0 / 128.0;
	
/*	mediump float sample = texture2D(Rd1, T2d).g;
	gl_FragColor = sample;*/
	
	mediump vec2 samplex0 = texture2D(Rd1, vec2(T2d.x - value, T2d.y)).rg;
	mediump vec2 samplex1 = texture2D(Rd1, vec2(T2d.x + value, T2d.y)).rg;
	
	mediump vec2 sampley0 = texture2D(Rd1, vec2(T2d.x, T2d.y - value)).rg;
	mediump vec2 sampley1 = texture2D(Rd1, vec2(T2d.x, T2d.y + value)).rg;
	
	mediump float x0 = (samplex0.r * 255.0 + samplex0.g * 65280.0) / 65535.0;
	mediump float x1 = (samplex1.r * 255.0 + samplex1.g * 65280.0) / 65535.0;
	mediump float y0 = (sampley0.r * 255.0 + sampley0.g * 65280.0) / 65535.0;
	mediump float y1 = (sampley1.r * 255.0 + sampley1.g * 65280.0) / 65535.0;
	
	mediump vec2 offset = vec2(x0 - x1, y0 - y1) * value * 15.0;
	mediump float shading = offset.x;
	
    mediump vec4 t = texture2D(Rd0, T2d + offset);
    mediump vec4 FinalColor = t + shading;

	gl_FragColor = FinalColor;
}
