uniform mediump mat4 ProjectionMatrix;

attribute vec3 Position;
attribute vec2 TexCoord;

varying mediump vec2 v_T2d;

void main()
{
	gl_Position	= ProjectionMatrix * vec4(Position, 1.0);
	v_T2d	    = vec2(TexCoord.x, 1.0 - TexCoord.y);
}
