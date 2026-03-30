#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoords;

out vec3 FragPos;
out vec2 TexCoords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform sampler2D heightmap;

void main()
{
    vec3 pos = aPos;

    // Convert local position to 0..1 UV for heightmap lookup
    // aPos.x and aPos.z are in 0..100 range
    vec2 uv  = vec2(aPos.x / 100.0, aPos.z / 100.0);
    pos.y    = texture(heightmap, uv).r;

    FragPos     = vec3(model * vec4(pos, 1.0));
    TexCoords   = aTexCoords;

    gl_Position = projection * view * vec4(FragPos, 1.0);
}