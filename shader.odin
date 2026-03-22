package fenrir

import "core:os"
import "core:log"
import "core:strings"
import GL "vendor:OpenGL"

Shader :: struct {
    id: u32
}

use :: proc(shader: ^Shader) {
    using shader
    GL.UseProgram(id)
}

set_bool :: proc(shader: ^Shader, name: cstring, value: bool) {
    using shader
    GL.Uniform1i(GL.GetUniformLocation(id, name), i32(value))
}

set_int :: proc(shader: ^Shader, name: cstring, value: int) {
    using shader
    GL.Uniform1i(GL.GetUniformLocation(id, name), i32(value))
}

set_float :: proc(shader: ^Shader, name: cstring, value: f32) {
    using shader
    GL.Uniform1f(GL.GetUniformLocation(id, name), value)
}

set_vec2_v :: proc(shader: ^Shader, name: cstring, value: ^vec2) {
    using shader
    GL.Uniform2fv(GL.GetUniformLocation(id, name), 1, &value[0]);
}

set_vec2_f :: proc(shader: ^Shader, name: cstring, x, y: f32) {
    using shader
    GL.Uniform2f(GL.GetUniformLocation(id, name), x, y);
}

set_vec2 :: proc { set_vec2_v, set_vec2_f }

set_vec3_v :: proc(shader: ^Shader, name: cstring, value: ^vec3) {
    using shader
    GL.Uniform3fv(GL.GetUniformLocation(id, name), 1, &value[0]);
}

set_vec3_f :: proc(shader: ^Shader, name: cstring, x, y, z: f32) {
    using shader
    GL.Uniform3f(GL.GetUniformLocation(id, name), x, y, z);
}

set_vec3 :: proc { set_vec3_v, set_vec3_f }

set_vec4_v :: proc(shader: ^Shader, name: cstring, value: ^vec4) {
    using shader
    GL.Uniform4fv(GL.GetUniformLocation(id, name), 1, &value[0]);
}

set_vec4_f :: proc(shader: ^Shader, name: cstring, x, y, z, w: f32) {
    using shader
    GL.Uniform4f(GL.GetUniformLocation(id, name), x, y, z, w);
}

set_vec4 :: proc { set_vec4_v, set_vec4_f }

set_mat2 :: proc(shader: ^Shader, name: cstring, mat: ^mat2) {
    using shader
    GL.UniformMatrix2fv(GL.GetUniformLocation(id, name), 1, GL.FALSE, &mat[0][0]);
}

set_mat3 :: proc(shader: ^Shader, name: cstring, mat: ^mat3) {
    using shader
    GL.UniformMatrix3fv(GL.GetUniformLocation(id, name), 1, GL.FALSE, &mat[0][0]);
}

set_mat4 :: proc(shader: ^Shader, name: cstring, mat: ^mat4) {
    using shader
    GL.UniformMatrix4fv(GL.GetUniformLocation(id, name), 1, GL.FALSE, &mat[0][0]);
}

check_compile_errors :: proc(shader: u32, type: string) {
    success: i32
    info_log: [1024]u8 // char equivalent

    if type != "PROGRAM" {
        GL.GetShaderiv(shader, GL.COMPILE_STATUS, &success)
        if success == 0 {
            GL.GetShaderInfoLog(shader, 1024, nil, &info_log[0])
            log.error("SHADER ERROR:", type, string(info_log[:]))
        }
    } else {
        GL.GetProgramiv(shader, GL.LINK_STATUS, &success)
        if success == 0 {
            GL.GetProgramInfoLog(shader, 1024, nil, &info_log[0])
            log.error("PROGRAM LINKING ERROR:", type, string(info_log[:]))
        }
    }
}

init_shader :: proc(shader: ^Shader, vertex_path: string, fragment_path: string) -> bool {    
    vertex_data, vertex_ok := os.read_entire_file(vertex_path)
    fragment_data, fragment_ok := os.read_entire_file(fragment_path)

    if !vertex_ok {
        log.error("Failed to read vertex shader file")
        return false
    }
    if !fragment_ok {
        log.error("Failed to read fragment shader file")
        return false
    }

    vertex_shader_code: cstring = strings.clone_to_cstring(string(vertex_data))
    fragment_shader_code: cstring = strings.clone_to_cstring(string(fragment_data))

    vertex, fragment: u32

    vertex =  GL.CreateShader(GL.VERTEX_SHADER)
    GL.ShaderSource(vertex, 1, &vertex_shader_code, nil)
    GL.CompileShader(vertex)
    check_compile_errors(vertex, "VERTEX");

    fragment = GL.CreateShader(GL.FRAGMENT_SHADER)
    GL.ShaderSource(fragment, 1, &fragment_shader_code, nil)
    GL.CompileShader(fragment)
    check_compile_errors(fragment, "FRAGMENT");
    
    shader.id = GL.CreateProgram()
    GL.AttachShader(shader.id, vertex)
    GL.AttachShader(shader.id, fragment)
    GL.LinkProgram(shader.id)
    check_compile_errors(shader.id, "PROGRAM");

    GL.DeleteShader(vertex)
    GL.DeleteShader(fragment)

    return true
}