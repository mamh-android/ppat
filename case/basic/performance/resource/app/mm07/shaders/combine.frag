uniform sampler2D tex0;
uniform sampler2D tex1;
uniform mediump float weight0;
uniform mediump float weight1;
varying mediump vec2 v_T2d;

void main(void)
{
	mediump vec4 color0 = texture2D(tex0, v_T2d);
	mediump vec4 color1 = texture2D(tex1, v_T2d);
	
	gl_FragColor = (color0*weight0) + (color1*weight1);
	//gl_FragColor = min(vec4(1.0), (color0*weight0) + (color1*weight1));
}
