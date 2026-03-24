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

create_mesh_terrain :: proc(mesh: ^Mesh, width, depth: u32) {
    for i: u32 = 0; i < width - 1; i += 1 {
        for j: u32 = 0; j < depth - 1; j += 1 {
            x0 := f32(i)     / f32(width)
            x1 := f32(i + 1) / f32(width)
            z0 := f32(j)     / f32(depth)
            z1 := f32(j + 1) / f32(depth)

            bl := vec3{x0 * f32(width), 0.0, z0 * f32(depth)}
            br := vec3{x1 * f32(width), 0.0, z0 * f32(depth)}
            tl := vec3{x0 * f32(width), 0.0, z1 * f32(depth)}
            tr := vec3{x1 * f32(width), 0.0, z1 * f32(depth)}

            alt := (i + j) % 2 == 0
            if alt {
                append_flat_triangle(mesh, bl, tl, tr)
                append_flat_triangle(mesh, bl, tr, br)
            } else {
                append_flat_triangle(mesh, bl, tl, br)
                append_flat_triangle(mesh, tl, tr, br)
            }
        }
    }

    mesh.use_indices  = false
    mesh.vertex_count = i32(len(mesh.vertices) / 8)
    upload_mesh(mesh)
}

// Old CPU terrain generation
// create_mesh_terrain :: proc(mesh: ^Mesh, width, depth: u32, scale, max_height: f32) {
//     heightmap := make([]f32, width * depth)
//     defer delete(heightmap)

//     for i: u32 = 0; i < width; i += 1 {
//         for j: u32 = 0; j < depth; j += 1 {
//             x := f32(i) / f32(width)
//             z := f32(j) / f32(depth)

//             flat     := (fbm(x * 0.5, z * 0.5) + 1.0) * 0.5 * 0.05
//             mask     := (fbm(x * 0.8, z * 0.8) + 1.0) * 0.5
//             t        := smoothstep(0.65, 0.80, mask)
//             mountain := math.pow((fbm(x, z) + 1.0) * 0.5, f32(2.5))

//             heightmap[i * depth + j] = _lerp(flat * 4.0, mountain * 60.0, t)
//         }
//     }

//     for i: u32 = 0; i < width - 1; i += 1 {
//         for j: u32 = 0; j < depth - 1; j += 1 {

//             // The x/z positions of the 4 corners of this quad
//             x0 := f32(i)     / f32(width)
//             x1 := f32(i + 1) / f32(width)
//             z0 := f32(j)     / f32(depth)
//             z1 := f32(j + 1) / f32(depth)

//             // The heights of the 4 corners, looked up from our heightmap
//             h_bl := heightmap[i       * depth + j    ]  // bottom-left
//             h_br := heightmap[(i + 1) * depth + j    ]  // bottom-right
//             h_tl := heightmap[i       * depth + j + 1]  // top-left
//             h_tr := heightmap[(i + 1) * depth + j + 1]  // top-right

//             // Build vec3s for each corner so we can do math on them
//             bl := vec3{x0 * f32(width), h_bl, z0 * f32(depth)}
//             br := vec3{x1 * f32(width), h_br, z0 * f32(depth)}
//             tl := vec3{x0 * f32(width), h_tl, z1 * f32(depth)}
//             tr := vec3{x1 * f32(width), h_tr, z1 * f32(depth)}

//             // Alternate the diagonal split direction per quad
//             alt := (i + j) % 2 == 0

//             if alt {
//                 append_flat_triangle(mesh, bl, tl, tr)
//                 append_flat_triangle(mesh, bl, tr, br)
//             } else {
//                 append_flat_triangle(mesh, bl, tl, br)
//                 append_flat_triangle(mesh, tl, tr, br)
//             }
//         }
//     }

//     mesh.use_indices  = false
//     mesh.vertex_count = i32(len(mesh.vertices) / 8)
//     upload_mesh(mesh)
// }

append_flat_triangle :: proc(mesh: ^Mesh, v1, v2, v3: vec3) {
    // Calculate the two edge vectors from v1
    edge1 := v2 - v1
    edge2 := v3 - v1

    // Cross product gives a vector perpendicular to the triangle face
    // Normalize it so its length is 1, which is required for lighting math
    normal := linalg.normalize(linalg.cross(edge1, edge2))

    // Append all 3 vertices, each with the same flat normal
    // Format: pos.x, pos.y, pos.z, norm.x, norm.y, norm.z, tex.u, tex.v
    append_vertex(mesh, v1, normal)
    append_vertex(mesh, v2, normal)
    append_vertex(mesh, v3, normal)
}

append_vertex :: proc(mesh: ^Mesh, pos, normal: vec3) {
    append(&mesh.vertices, pos.x)
    append(&mesh.vertices, pos.y)
    append(&mesh.vertices, pos.z)
    append(&mesh.vertices, normal.x)
    append(&mesh.vertices, normal.y)
    append(&mesh.vertices, normal.z)
    append(&mesh.vertices, pos.x)  // use x/z as tex coords
    append(&mesh.vertices, pos.z)
}

cleanup_mesh :: proc(mesh: ^Mesh) {
    GL.DeleteVertexArrays(1, &mesh.VAO)
    GL.DeleteBuffers(1, &mesh.VBO)
    delete(mesh.vertices)
    delete(mesh.indices)
}