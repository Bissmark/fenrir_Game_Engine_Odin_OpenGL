package fenrir

import "core:math/linalg"
import SDL "vendor:sdl3"
import GL "vendor:OpenGL"

update_keyboard_input :: proc(engine: ^Engine, camera: ^Camera) {
    using camera
    key_states := SDL.GetKeyboardState(nil)

    if key_states[SDL.Scancode.W] {
        position += speed * engine.delta_time * front
    }
    if key_states[SDL.Scancode.S] {
        position -= speed * engine.delta_time * front
    }
    if key_states[SDL.Scancode.A] {
        position -= linalg.normalize(linalg.cross(front, up)) * engine.delta_time * speed
    }
    if key_states[SDL.Scancode.D] {
        position += linalg.normalize(linalg.cross(front, up)) * engine.delta_time * speed
    }

    if key_states[SDL.Scancode.F] {
        engine.wireframe = !engine.wireframe
        if engine.wireframe {
            GL.PolygonMode(GL.FRONT_AND_BACK, GL.LINE)
        } else {
            GL.PolygonMode(GL.FRONT_AND_BACK, GL.FILL)
        }
    }
}

update_mouse_input :: proc(camera: ^Camera, x_offset_in, y_offset_in: f64) {
    x_offset: f32 = f32(x_offset_in) * 0.1
    y_offset: f32 = f32(y_offset_in) * 0.1

    camera.yaw += x_offset
    camera.pitch -= y_offset

    if camera.pitch > 89.0 {
        camera.pitch = 89.0
    }
    if camera.pitch < -89.0 {
        camera.pitch = -89.0
    }

    front: vec3
    front.x = linalg.cos(linalg.to_radians(camera.yaw)) * linalg.cos(linalg.to_radians(camera.pitch))
    front.y = linalg.sin(linalg.to_radians(camera.pitch))
    front.z = linalg.sin(linalg.to_radians(camera.yaw)) * linalg.cos(linalg.to_radians(camera.pitch))
    camera.front = linalg.normalize(front)
}

zoom_input :: proc(camera: ^Camera, x_offset, y_offset: f64) {
    camera.fov -= f32(y_offset)

    if camera.fov < 1.0 {
        camera.fov = 1.0
    }
    if camera.fov > 45.0 {
        camera.fov = 45.0
    }
}