const int Li = 2;
uniform vec3 LposWA[Li];

uniform mat4 ProjectionMatrix;

attribute vec3 Position;
attribute vec2 TexCoord;

varying mediump vec2 T2d;
varying mediump vec3 L0w[Li];

void main()
{
    gl_Position = ProjectionMatrix * vec4(Position, 1.0);		// vertex_position_in_clip_space
    T2d = TexCoord;										// attribute 'Vertex texture coordinate'

    for(int i = 0; i < Li; ++i)
    {
        L0w[i] = LposWA[i] - Position;   // light_direction0,  varying
    }
}
