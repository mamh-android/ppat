const int Li = 2;
uniform sampler2D Rd;
uniform mediump float radius;
uniform mediump float slope;
uniform mediump vec2 texSize;
uniform mediump vec3 mask;
uniform mediump float distortion;

uniform mediump vec3 ambient;
varying mediump vec2 T2d;
varying mediump vec3 L0w[Li];
varying mediump vec3   pos;

mediump vec3 distort(in mediump vec3 I, in mediump vec3 N, in mediump float eta)
{
    mediump float IdotN = dot(I, N);
    mediump float k = 1.0 - eta * eta * (1.0 - IdotN * IdotN);
    return eta * I - (eta * IdotN + sqrt(k)) * N;
}

void main(void)
{
    mediump vec4  Crd  = texture2D(Rd, T2d);
    mediump vec4 FinalColor = vec4(ambient, 1.0);
    mediump vec4 totalDistortion = vec4(0.0);
    mediump float blend = 1.0;
    int numL = 0;

    for( int i = 0; i < Li; ++i )
    {
        mediump float distance = length(L0w[i]);

        if( distance < radius && distance > 0.0 )
        {
            mediump vec3 I = vec3(0.0, 0.0, 1.0);
            mediump vec3 N;
            N.xy  = L0w[i].xy;
            N.z = (radius - distance);
            N = normalize(N);

            //vec3 R = distort(I, N, 1.0/distortion);
            mediump vec3 R = distort(I, N, distortion);
            //vec3 R = refract(I, N, 1.0/distortion);
            //vec3 R = refract(I, N, distortion);
            
            //FinalColor.xyz = R;

            //R.xy = 20.0*R.xy / texSize * R.z;
            R.xy = R.xy / texSize * R.z;

            //FinalColor.xyz = R;

            mediump float x0 = floor(T2d.x);
            mediump float y0 = floor(T2d.y);
            R.x = clamp(T2d.x + R.x, x0, x0+1.0);
            R.y = clamp(T2d.y + R.y, y0, y0+1.0);
            totalDistortion += texture2D(Rd, R.xy);
            blend *= clamp(pow(distance / radius, slope), 0.0, 1.0);
        
            numL++;
        }
    }

    if( numL == 0 )
    {
        FinalColor += Crd;
    }
    else
    {
        //FinalColor += totalDistortion/float(numL);
        FinalColor += mix(totalDistortion/float(numL), vec4(mask, 1.0), blend);
        //FinalColor += mix(totalDistortion/float(numL), Crd, blend);
    }

    gl_FragColor = FinalColor;
}
