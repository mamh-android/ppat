const int Li = 2;

uniform mat4 ProjectionMatrix;

uniform vec3 LposWA[Li];    // 'Light position in world coordinates (array)'
uniform vec3 VposW;         // 'View position in world coordinates'

attribute vec3 Position;
attribute vec2 TexCoord;

varying mediump vec2 T2d;         // 'Surface texture coordinate'
varying mediump vec3 L0w[Li];     // 'Light direction, before normalization'
varying mediump vec3 V0w;         // 'View direction, before normalization'

void main()
{
    gl_Position = ProjectionMatrix * vec4(Position, 1.0);
    T2d	= TexCoord;
    V0w = VposW;

    for(int i = 0; i < Li; ++i)
    {
        L0w[i] = LposWA[i] - Position;    // light_direction0,  varying
    }
}
