#version 330 core
out vec4 FragColor;

in vec3 gFragPos;
in vec3 gNormal;
in vec2 gTexCoords;

uniform vec3 lightPos;
uniform vec3 lightColor;
uniform vec3 viewPos;

void main()
{
    // --- Height based colour ---
    // FragPos.y is the world height of this fragment, divided by max_height
    // to get a 0..1 range. Adjust the divisor to match your max_height * scale.
    float height = clamp(gFragPos.y / 60.0, 0.0, 1.0);

    vec3 grassColor  = vec3(0.2,  0.55, 0.15);
    vec3 rockColor   = vec3(0.4,  0.35, 0.3);
    vec3 snowColor   = vec3(0.9,  0.92, 0.95);

    // Blend between grass -> rock -> snow based on height
    vec3 terrainColor;
    if (height < 0.25) {
        // Low ground: grass to rock
        float t = height / 0.25;
        terrainColor = mix(grassColor, rockColor, t);
    } else {
        // High ground: rock to snow
        float t = (height - 0.25) / 0.75;
        terrainColor = mix(rockColor, snowColor, t);
    }

    // --- Lighting ---
    float ambientStrength = 0.3;
    vec3 ambient = ambientStrength * lightColor;

    vec3 norm     = normalize(gNormal);
    vec3 lightDir = normalize(lightPos - gFragPos);
    float diff    = max(dot(norm, lightDir), 0.0);
    vec3 diffuse  = diff * lightColor;

    vec3 result = (ambient + diffuse) * terrainColor;

    // --- Fog ---
    float fogStart = 60.0;   // distance where fog begins
    float fogEnd   = 150.0;  // distance where fog is fully opaque
    vec3  fogColor = vec3(0.2, 0.3, 0.3);  // match your GL.ClearColor

    float dist      = length(viewPos - gFragPos);
    float fogFactor = clamp((fogEnd - dist) / (fogEnd - fogStart), 0.0, 1.0);

    vec3 finalColor = mix(fogColor, result, fogFactor);
    FragColor = vec4(finalColor, 1.0);
}