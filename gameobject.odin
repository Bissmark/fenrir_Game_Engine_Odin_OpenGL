package fenrir

import "core:math/linalg"
import GL "vendor:OpenGL"

GameObject :: struct {
    position: vec3,
    rotation_axis: vec3,
    rotation_angle: f32,
    orientation: quaternion128,
    scale: vec3,

    mesh: ^Mesh,
    shader: ^Shader,
}

draw_object :: proc(engine: ^Engine, gameobject: ^GameObject) {
    use(gameobject.shader)

    translate  := linalg.matrix4_translate_f32(gameobject.position)
    rotate     := linalg.matrix4_from_quaternion_f32(gameobject.orientation)
    scale      := linalg.matrix4_scale_f32(gameobject.scale)
    model      := translate * rotate * scale
    flat_model := linalg.matrix_flatten(model)
    GL.UniformMatrix4fv(gameobject.shader.loc_model, 1, GL.FALSE, &flat_model[0])

    GL.BindVertexArray(gameobject.mesh.VAO)
    if gameobject.mesh.use_indices {
        GL.DrawElements(GL.TRIANGLES, gameobject.mesh.vertex_count, GL.UNSIGNED_INT, nil)
    } else {
        GL.DrawArrays(GL.TRIANGLES, 0, gameobject.mesh.vertex_count)
    }
}

move_sun :: proc(engine: ^Engine, gameobject: ^GameObject) {
    gameobject.position.x += 5.0 * engine.delta_time
}