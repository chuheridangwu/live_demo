varying highp vec2 textureCoordinate;

uniform sampler2D texture;

void main()
{
    highp vec4 color=texture2D(texture, textureCoordinate);
    //gl_FragColor = texture2D(texture, textureCoordinate);
    gl_FragColor = vec4(color.rgb, color.a);

    
	//gl_FragColor = texture2D(texture, textureCoordinate);
//	gl_FragColor = vec4(textureCoordinate, 1.0, 1.0);
}
