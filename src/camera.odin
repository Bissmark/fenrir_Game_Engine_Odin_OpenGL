package fenrir

import "core:math/linalg"
import SDL "vendor:sdl3"

Camera :: struct {
    position: vec3,
    target: vec3,
    direction: vec3,
    up: vec3,
    front: vec3,
    camera_right: vec3,
    camera_up: vec3,
    view: linalg.Matrix4f32,

    speed: f32,
    yaw: f32,
    pitch: f32,
    fov: f32
}

init_camera :: proc(camera: ^Camera) -> bool {
    camera.position = {0.0, 0.0, 3.0}
    camera.target = {0.0, 0.0, 0.0}
    camera.direction = linalg.normalize(camera.position - camera.target)
    camera.up = {0.0, 1.0, 0.0}
    camera.front = {0.0, 0.0, -1.0}
    camera.camera_right = linalg.normalize(linalg.cross(camera.up, camera.direction))
    camera.camera_up = linalg.cross(camera.direction, camera.camera_right)
    camera.speed = 0.05
    camera.yaw = -90.0
    camera.pitch = 0.0
    camera.fov = 45.0

    // camera.view = linalg.matrix4_look_at_f32(vec3{0.0, 0.0, 3.0}, vec3{0.0, 0.0, 0.0}, vec3{0.0, 1.0, 0.0})

    return true
}

update_camera :: proc(camera: ^Camera) {
    radius: f32 = 10.0
    time := f32(SDL.GetTicks()) / 1000.0
    camX := linalg.sin(time) * radius
    camZ := linalg.cos(time) * radius
    camera.view = linalg.matrix4_look_at_f32(camera.position, camera.position + camera.front, camera.up)
}