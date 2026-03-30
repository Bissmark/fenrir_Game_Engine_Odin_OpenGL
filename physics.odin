package fenrir

import "core:math/linalg"

EPSILON        :: f32(0.5)
CUBE_HALF_HEIGHT :: f32(0.5)

Rigidbody :: struct {
    position, velocity, acceleration: vec3,
    mass:             f32,
    isGrounded:       bool,
    // Rotation state
    angular_velocity: vec3,       // axis * radians_per_second
    orientation:      quaternion128, // current rotation
}

get_terrain_normal :: proc(engine: ^Engine, x, z: f32) -> vec3 {
    hL := get_terrain_height(engine, x - EPSILON, z)
    hR := get_terrain_height(engine, x + EPSILON, z)
    hD := get_terrain_height(engine, x, z - EPSILON)
    hU := get_terrain_height(engine, x, z + EPSILON)

    n := vec3{hL - hR, 2.0 * EPSILON, hD - hU}
    return linalg.normalize(n)
}

update_movement :: proc(engine: ^Engine, rigidbody: ^Rigidbody) {
    using rigidbody

    terrain_y    := get_terrain_height(engine, position.x, position.z)
    ground_level := terrain_y + CUBE_HALF_HEIGHT

    if position.y > ground_level + 0.01 {
        // Airborne
        velocity.y += GRAVITY.y * engine.delta_time
        isGrounded  = false
    } else {
        // Grounded - slope physics
        normal := get_terrain_normal(engine, position.x, position.z)

        dot := linalg.dot(velocity, normal)
        if dot < 0 {
            velocity -= normal * dot
        }

        gravity_along_slope := GRAVITY - normal * linalg.dot(GRAVITY, normal)
        velocity += gravity_along_slope * engine.delta_time

        // Derive angular velocity from linear velocity:
        // a cube rolling without slipping rotates around the axis
        // perpendicular to its movement direction
        speed := linalg.length(velocity)
        if speed > 0.001 {
            move_dir       := linalg.normalize(velocity)
            rotation_axis  := linalg.normalize(linalg.cross(normal, move_dir))
            // radius = CUBE_HALF_HEIGHT, omega = v / r
            angular_velocity = rotation_axis * (speed / CUBE_HALF_HEIGHT)
        } else {
            angular_velocity = {0, 0, 0}
        }

        FRICTION :: f32(0.985)
        velocity *= FRICTION

        position.y = ground_level
        isGrounded  = true
    }

    // Integrate orientation from angular velocity
    angle := linalg.length(angular_velocity) * engine.delta_time
    if angle > 0.0001 {
        axis        := linalg.normalize(angular_velocity)
        delta_rot   := linalg.quaternion_angle_axis_f32(angle, axis)
        orientation  = linalg.quaternion_mul_quaternion(delta_rot, orientation)
        // Keep it normalised to avoid float drift
        orientation  = linalg.quaternion_normalize(orientation)
    }

    position += velocity * engine.delta_time
}