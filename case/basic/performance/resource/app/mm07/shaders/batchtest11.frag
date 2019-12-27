const int Li = 2;

uniform sampler2D	 Rd0;			// 'Surface diffuse reflectance texture'
uniform sampler2D	 Rd1;			// 'Surface diffuse reflectance texture'
uniform sampler2D	 Nm;				// 'Surface normal texture'
uniform mediump vec3 LcolorA[Li];	// 'Light color (array)'
uniform mediump vec3 ambient;

varying mediump vec2 T2d;			// 'Surface texture coordinate'
varying mediump vec3 L0w[Li];		// 'Light direction, before normalization'
varying mediump vec3 V0w;			// 'View direction, before normalization'

void main(void)
{
    mediump vec3 Vw  = normalize(V0w);								// view_direction
    mediump vec2 T2d1 = T2d;
    mediump vec2 T2d2 = T2d;
  
    mediump vec4 FinalColor = vec4(ambient, 1.0);

    // Shift texcoordinates according to height
    mediump float height = texture2D(Rd1, T2d1).r * 0.04 - 0.02;
    T2d1 += (height * Vw.xy);
    T2d2 += (height * Vw.xy);

    mediump vec3 Ns  = texture2D(Nm, T2d1).xyz * 2.0 - 1.0;         // sample_normal
    Ns.y = -Ns.y;

    mediump vec4 Crd  = texture2D(Rd0, T2d2);						// diffuse_surface_factor

    for(int i = 0; i < Li; ++i)
    {
        // Triangle must face the light in order to get light shading
        mediump vec3  Lw  = normalize(L0w[i]);								// light_direction
        mediump float nDotL = dot(Lw, Ns);
        if(nDotL >= 0.0)
        {
            // Diffuse term
            FinalColor += nDotL * Crd * vec4(LcolorA[i], 1.0); // * vec4(0.73, 0.73, 0.73, 1.0);

            mediump vec3  Hw = normalize(Lw + Vw);

            mediump float nDotH = dot( Ns, Hw );
            if(nDotH > 0.0)
            {
                FinalColor += pow(nDotH, 16.0) * vec4(0.73, 0.73, 0.73, 1.0);
            }
        }
    }
    gl_FragColor = FinalColor;
}
