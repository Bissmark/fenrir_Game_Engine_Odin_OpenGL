package fenrir

import "core:math/linalg"
import GL "vendor:OpenGL"
import SDL "vendor:sdl3"

Light :: struct {
    VAO: u32,
    position: vec3,
    color: vec3,
    diffuse_color: vec3,
    ambient_color: vec3,
    specular_color: vec3,
}

init_light :: proc(light: ^Light, mesh_vbo: u32) -> bool {
    light.position = {1.2, 1.0, 2.0}
    light.ambient_color = {0.2, 0.2, 0.2}
    light.diffuse_color = {0.5, 0.5, 0.5}
    light.specular_color = {1.0, 1.0, 1.0}

    GL.GenVertexArrays(1, &light.VAO)
    GL.BindVertexArray(light.VAO)
    GL.BindBuffer(GL.ARRAY_BUFFER, mesh_vbo)
    GL.VertexAttribPointer(0, 3, GL.FLOAT, GL.FALSE, 8 * size_of(f32), 0)
    GL.EnableVertexAttribArray(0)

    return true
}

update_light :: proc(light: ^Light) {
    time := f32(SDL.GetTicks()) / 1000.0
    light.color.x = linalg.sin(time * 2.0)
    light.color.y = linalg.sin(time * 0.7)
    light.color.z = linalg.sin(time * 1.3)
    light.diffuse_color = light.color * vec3{0.5, 0.5, 0.5}
    light.ambient_color = light.diffuse_color * vec3{0.2, 0.2, 0.2}
}