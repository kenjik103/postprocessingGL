#version 330 core
out vec4 FragColor;

in vec2 TexCoords;

uniform sampler2D screenTexture;

vec4 invert(){
     return vec4(vec3(1.0 - texture(screenTexture, TexCoords)), 1.0);
}

vec4 greyscale(){
    vec4 fragcolor = texture(screenTexture, TexCoords);
    float average = 0.2126 * fragcolor.r + 0.7152 * fragcolor.g + 0.0722 * fragcolor.b;
    return vec4(average, average, average, 1.0);
}

vec4 apply_kernal(float kernal[9]){
     float xoffset = 1.0 / textureSize(screenTexture, 0).x;
     float yoffset = 1.0 / textureSize(screenTexture, 0).y;

     vec2 offsets[9] = vec2[](
     	  vec2(-xoffset,  yoffset), // top-left
     	  vec2( 0.0f,     yoffset), // top-center
     	  vec2( xoffset,  yoffset), // top-right
     	  vec2(-xoffset,  0.0f),   // center-left
     	  vec2( 0.0f,     0.0f),   // center-center
     	  vec2( xoffset,  0.0f),   // center-right
     	  vec2(-xoffset, -yoffset), // bottom-left
     	  vec2( 0.0f,    -yoffset), // bottom-center
     	  vec2( xoffset, -yoffset)
     );  // bottom-right

     vec3 samples[9];
     for (int i = 0; i < 9; i++){
     	 samples[i] = vec3(texture(screenTexture, TexCoords.st + offsets[i]));
     }

     vec3 color = vec3(0.0);
     for (int i = 0; i < 9; i++){
     	 color += samples[i] * kernal[i];
     }
     return vec4(color, 1.0);

}

vec4 sharpen() {
     float kernal[9] = float[](
     	   -2, -2, -2,
	   -2,  18, -2,
	   -2, -2, -2
     );

     return apply_kernal(kernal);
}

vec4 blur() {
     float kernal[9] = float[](
     	   1.0 / 16, 2.0 / 16, 1.0 / 16,
	   2.0 / 16, 4.0 / 16, 2.0 / 16,
	   1.0 / 16, 2.0 / 16, 1.0 / 16
     );

     return apply_kernal(kernal);
}

vec4 highlight_edges() {
     float kernal[9] = float[] (
     	   1,  1,  1,
	   1, -8,  1,
	   1,  1,  1
     );
     return apply_kernal(kernal);
}

void main()
{    
     FragColor = highlight_edges();
}