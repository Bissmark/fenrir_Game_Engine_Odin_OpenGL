package fenrir

import "core:math/linalg"
import GL "vendor:OpenGL"

GameObject :: struct {
    position: vec3,
    rotation_axis: vec3,
    rotation_angle: f32,
    scale: vec3,

    mesh: ^Mesh,
    shader: ^Shader,
}

draw_object :: proc(gameobject: ^GameObject) {
    use(gameobject.shader)

    translate := linalg.matrix4_translate_f32(gameobject.position)
    angle: f32 = gameobject.rotation_angle
    rotate := linalg.matrix4_rotate_f32(linalg.to_radians(angle), gameobject.rotation_axis)
    scale := linalg.matrix4_scale_f32(gameobject.scale)
    model := translate * rotate * scale
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