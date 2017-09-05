precision mediump float;

POSITION attribute vec4 position;

varying vec2 v_texCoord;

void main()
{
    gl_Position = position;
    v_texCoord = (position.xy + 1.0) * 0.5;
}
