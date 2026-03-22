package fenrir

import "core:math/linalg"
import GL "vendor:OpenGL"
import SDL "vendor:sdl3"

Light :: struct {
    position: vec3,
    color: vec3,
    diffuse_color: vec3,
    ambient_color: vec3,
    specular_color: vec3,

    mesh: Mesh,

}

init_light :: proc(light: ^Light) -> bool {
    light.position = {1.2, 1.0, 2.0}
    light.ambient_color = {0.2, 0.2, 0.2}
    light.diffuse_color = {0.5, 0.5, 0.5}
    light.specular_color = {1.0, 1.0, 1.0}

    create_mesh_cube(&light.mesh)

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