#+feature dynamic-literals
package fenrir

import GL "vendor:OpenGL"
import "core:math"
import "core:math/linalg"

Mesh :: struct {
    VBO, VAO, EBO: u32,
    vertices: [dynamic]f32,
    indices: [dynamic]u32,
    vertex_count: i32,
    use_indices: bool,
}

upload_mesh :: proc(mesh: ^Mesh) -> bool {
    GL.GenVertexArrays(1, &mesh.VAO)
    GL.GenBuffers(1, &mesh.VBO)
    GL.GenBuffers(1, &mesh.EBO)

    GL.BindVertexArray(mesh.VAO);
    GL.BindBuffer(GL.ARRAY_BUFFER, mesh.VBO)
    GL.BufferData(GL.ARRAY_BUFFER, len(mesh.vertices) * size_of(f32), &mesh.vertices[0], GL.STATIC_DRAW)

    GL.BindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.EBO)
    if len(mesh.indices) > 0 {
        GL.BufferData(GL.ELEMENT_ARRAY_BUFFER, len(mesh.indices) * size_of(u32), &mesh.indices[0], GL.STATIC_DRAW)
    }

    // position
    GL.VertexAttribPointer(0, 3, GL.FLOAT, GL.FALSE, 8 * size_of(f32), 0)
    GL.EnableVertexAttribArray(0)
    // normal
    GL.VertexAttribPointer(1, 3, GL.FLOAT, GL.FALSE, 8 * size_of(f32), uintptr(3 * size_of(f32)))
    GL.EnableVertexAttribArray(1)
    // texcoords
    GL.VertexAttribPointer(2, 2, GL.FLOAT, GL.FALSE, 8 * size_of(f32), uintptr(6 * size_of(f32)))
    GL.EnableVertexAttribArray(2)

    delete(mesh.vertices)

    return true
}

fractal_brownian_motion :: proc() {

}

create_mesh_cube :: proc(mesh: ^Mesh) {
    mesh.vertices = {
        // positions          // texture coords
        -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0,  0.0,
        0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  1.0,  0.0,
        0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0,  1.0,
        0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0,  1.0,
        -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  0.0,  1.0,
        -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0,  0.0,

        -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,  0.0,  0.0,
        0.5, -0.5,  0.5,  0.0,  0.0,  1.0,  1.0,  0.0,
        0.5,  0.5,  0.5,  0.0,  0.0,  1.0,  1.0,  1.0,
        0.5,  0.5,  0.5,  0.0,  0.0,  1.0,  1.0,  1.0,
        -0.5,  0.5,  0.5,  0.0,  0.0,  1.0,  0.0,  1.0,
        -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,  0.0,  0.0,

        -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0,  0.0,
        -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,  1.0,  1.0,
        -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0,  1.0,
        -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0,  1.0,
        -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,  0.0,  0.0,
        -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0,  0.0,

        0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0,  0.0,
        0.5,  0.5, -0.5,  1.0,  0.0,  0.0,  1.0,  1.0,
        0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0,  1.0,
        0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0,  1.0,
        0.5, -0.5,  0.5,  1.0,  0.0,  0.0,  0.0,  0.0,
        0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0,  0.0,

        -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0,  1.0,
        0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  1.0,  1.0,
        0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0,  0.0,
        0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0,  0.0,
        -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  0.0,  0.0,
        -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0,  1.0,

        -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0,  1.0,
        0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  1.0,  1.0,
        0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0,  0.0,
        0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0,  0.0,
        -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  0.0,  0.0,
        -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0,  1.0
    }

    mesh.vertex_count = i32(len(mesh.vertices) / 8)
    upload_mesh(mesh)
}

create_mesh_terrain :: proc(mesh: ^Mesh, width, depth: u32, scale, max_height: f32) {
    // Vertex Loop
    for i: u32 = 0; i < width; i += 1 {
        for j: u32 = 0; j < depth; j+= 1 {
            x := f32(i) / f32(width)
            z := f32(j) / f32(depth)
            // Flat land noise - high frequency, low amplitude (what you have now)
            flat := (fbm(x * 0.5, z * 0.5) + 1.0) * 0.5 * 0.05

            // Mountain mask - very low frequency so mountains are large and spread out
            mask := (fbm(x * 0.8, z * 0.8) + 1.0) * 0.5

            // Sharpen the mask so transition is smoother - smoothstep between 0.4 and 0.7
            t := smoothstep(0.55, 0.75, mask)

            // Mountain noise - medium frequency, will be raised to a power for sharp peaks
            mountain := math.pow((fbm(x * 3.0, z * 3.0) + 1.0) * 0.5, 2.5)

            // Blend flat and mountain based on mask
            height := _lerp(flat, mountain * 0.6, t)

            // Positions
            append(&mesh.vertices, x)
            append(&mesh.vertices, height * max_height)
            append(&mesh.vertices, z)

            // Normals and TexCoords
            append(&mesh.vertices, f32(0.0))
            append(&mesh.vertices, f32(1.0))
            append(&mesh.vertices, f32(0.0))

            append(&mesh.vertices, x)
            append(&mesh.vertices, z)
        }
    }

    // Index Loop
    for i: u32 = 0; i < width - 1; i += 1 {
        for j: u32 = 0; j < depth - 1; j+= 1 {
            row_1 := j * width 
            row_2 := (j + 1) * width

            append(&mesh.indices, u32(row_1 + i))
            append(&mesh.indices, u32(row_1 + i + 1))
            append(&mesh.indices, u32(row_2 + i + 1))
            append(&mesh.indices, u32(row_1 + i))
            append(&mesh.indices, u32(row_2 + i + 1))
            append(&mesh.indices, u32(row_2 + i))
        }
    }

    mesh.use_indices = true
    mesh.vertex_count = i32(len(mesh.indices))
    upload_mesh(mesh)
}

cleanup_mesh :: proc(mesh: ^Mesh) {
    GL.DeleteVertexArrays(1, &mesh.VAO)
    GL.DeleteBuffers(1, &mesh.VBO)
    delete(mesh.vertices)
    delete(mesh.indices)
}