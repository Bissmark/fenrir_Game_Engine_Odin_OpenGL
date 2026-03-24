#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

// Inputs from vertex shader - arrays of 3 because we receive a full triangle
in vec3 FragPos[];
in vec2 TexCoords[];

// Outputs to fragment shader
out vec3 gFragPos;
out vec3 gNormal;
out vec2 gTexCoords;

void main()
{
    // Get the world positions of all 3 vertices
    vec3 p0 = FragPos[0];
    vec3 p1 = FragPos[1];
    vec3 p2 = FragPos[2];

    // Calculate flat normal from cross product of the two edges
    // This is the same calculation that was done on the CPU before
    vec3 edge1  = p1 - p0;
    vec3 edge2  = p2 - p0;
    vec3 normal = normalize(cross(edge1, edge2));

    // Emit all 3 vertices with the same flat normal
    gFragPos   = FragPos[0];
    gNormal    = normal;
    gTexCoords = TexCoords[0];
    gl_Position = gl_in[0].gl_Position;
    EmitVertex();

    gFragPos   = FragPos[1];
    gNormal    = normal;
    gTexCoords = TexCoords[1];
    gl_Position = gl_in[1].gl_Position;
    EmitVertex();

    gFragPos   = FragPos[2];
    gNormal    = normal;
    gTexCoords = TexCoords[2];
    gl_Position = gl_in[2].gl_Position;
    EmitVertex();

    EndPrimitive();
}