package fenrir

import "core:fmt"
import "core:math/linalg"
import SDL "vendor:sdl3"
import GL "vendor:OpenGL"

Engine :: struct {
    window: ^SDL.Window,
    event: SDL.Event,

    gl_context: SDL.GLContext,

    shader: Shader,
    light_shader: Shader,
    mesh: Mesh,
    texture: Texture,
    camera: Camera,
    light: Light,

    wireframe: bool
}

cube_positions := [10]vec3 {
    vec3{0.0, 0.0, 0.0},
    vec3{ 2.0,  5.0, -15.0},
    vec3{-1.5, -2.2, -2.5},
    vec3{-3.8, -2.0, -12.3},
    vec3{2.4, -0.4, -3.5},
    vec3{-1.7,  3.0, -7.5},
    vec3{ 1.3, -2.0, -2.5},
    vec3{ 1.5,  2.0, -2.5},
    vec3{ 1.5,  0.2, -1.5},
    vec3{-1.3,  1.0, -1.5}
}

main_loop :: proc(engine: ^Engine) {
    for {
        for SDL.PollEvent(&engine.event) {
            #partial switch engine.event.type {
                case .QUIT:
                    return
                case .MOUSE_MOTION:
                    update_mouse_input(&engine.camera, f64(engine.event.motion.xrel), f64(engine.event.motion.yrel))
                case .MOUSE_WHEEL:
                    zoom_input(&engine.camera, f64(engine.event.wheel.x), f64(engine.event.wheel.y))
            }
        }

        //SDL.Delay(16)
        GL.ClearColor(0.2, 0.3, 0.3, 1.0)
        GL.Clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)

        // GL.ActiveTexture(GL.TEXTURE0);
        // GL.BindTexture(GL.TEXTURE_2D, engine.texture.texture1);
        // GL.ActiveTexture(GL.TEXTURE1);
        // GL.BindTexture(GL.TEXTURE_2D, engine.texture.texture2);
        
        // create transformations
        // glm::mat4 transform = glm::mat4(1.0f); // make sure to initialize matrix to identity matrix first
        // transform = glm::translate(transform, glm::vec3(0.5f, -0.5f, 0.0f)); // translate
        // transform = glm::rotate(transform, (float)glfwGetTime(), glm::vec3(0.0f, 0.0f, 1.0f)); // rotate
        
        // render container
        use(&engine.shader)
        set_int(&engine.shader, "material.diffuse", 0)
        set_int(&engine.shader, "material.specular", 1)
        view_loc := GL.GetUniformLocation(engine.shader.id, "view")
        flat_view := linalg.matrix_flatten(engine.camera.view)
        GL.UniformMatrix4fv(view_loc, 1, GL.FALSE, &flat_view[0])
        // set_int(&engine.shader, "texture1", 0)
        // set_int(&engine.shader, "texture2", 1)
        
        // set_vec3(&engine.shader, "objectColor", 1.0, 0.5, 0.31)
        // set_vec3(&engine.shader, "lightColor", 1.0, 1.0, 1.0)
        set_vec3(&engine.shader, "light.position", &engine.light.position)
        set_vec3(&engine.shader, "viewPos", &engine.camera.position)
        //set_vec3(&engine.shader, "material.ambient", 1.0, 0.5, 0.31)
        
        // Light Properties
        set_vec3(&engine.shader, "light.ambient", &engine.light.ambient_color)
        set_vec3(&engine.shader, "light.diffuse", &engine.light.diffuse_color)
        set_vec3(&engine.shader, "light.specular", &engine.light.specular_color)
        
        // Material Properties
        set_float(&engine.shader, "material.shininess", 64.0)
        
        // View and Projection transformations
        projection := linalg.matrix4_perspective_f32(f32(linalg.to_radians(engine.camera.fov)), f32(SCREEN_WIDTH) / f32(SCREEN_HEIGHT), 0.1, 100.0)
        set_mat4(&engine.shader, "projection", &projection)
        transform_loc: i32 = GL.GetUniformLocation(engine.shader.id, "transform")
        transform := linalg.matrix4_translate_f32(linalg.Vector3f32{0.0, 0.0, 0.0})
        flat := linalg.matrix_flatten(transform)
        GL.UniformMatrix4fv(transform_loc, 1, GL.FALSE, &flat[0])

        // Bind diffuse Map
        GL.ActiveTexture(GL.TEXTURE0);
        GL.BindTexture(GL.TEXTURE_2D, engine.texture.diffuse_map);
        
        // Bind Specular Map
        GL.ActiveTexture(GL.TEXTURE1);
        GL.BindTexture(GL.TEXTURE_2D, engine.texture.specular_map);
        
        // Render the cubes around the scene
        GL.BindVertexArray(engine.mesh.VAO);
        for i: u32 = 0; i < 10; i += 1 {
            translate := linalg.matrix4_translate_f32(cube_positions[i])
            angle: f32 = 20.0 * f32(i)
            rotate := linalg.matrix4_rotate_f32(linalg.to_radians(angle), vec3{1.0, 0.3, 0.5})
            model := translate * rotate
            model_loc := GL.GetUniformLocation(engine.shader.id, "model")
            flat_model := linalg.matrix_flatten(model)
            GL.UniformMatrix4fv(model_loc, 1, GL.FALSE, &flat_model[0])
            
            GL.DrawArrays(GL.TRIANGLES, 0, engine.mesh.vertex_count)
        }
        
        use(&engine.light_shader)
        
        // upload view and projection to light shader
        light_view_loc := GL.GetUniformLocation(engine.light_shader.id, "view")
        GL.UniformMatrix4fv(light_view_loc, 1, GL.FALSE, &flat_view[0])
        set_mat4(&engine.light_shader, "projection", &projection)

        // build light cube model matrix - translate to light position and scale it down
        light_translate := linalg.matrix4_translate_f32(engine.light.position)
        light_scale := linalg.matrix4_scale_f32(vec3{0.2, 0.2, 0.2})
        light_model := light_translate * light_scale
        light_model_loc := GL.GetUniformLocation(engine.light_shader.id, "model")
        flat_light_model := linalg.matrix_flatten(light_model)
        GL.UniformMatrix4fv(light_model_loc, 1, GL.FALSE, &flat_light_model[0])

        GL.BindVertexArray(engine.light.VAO)
        GL.DrawArrays(GL.TRIANGLES, 0, 36)
        
        update_camera(&engine.camera)
        update_keyboard_input(engine, &engine.camera)
        //update_light(&engine.light)

        //GL.DrawElements(GL.TRIANGLES, 6, GL.UNSIGNED_INT, nil);
        SDL.GL_SwapWindow(engine.window)
    }

    GL.DeleteVertexArrays(1, &engine.mesh.VAO)
    GL.DeleteBuffers(1, &engine.mesh.VBO)
    // GL.DeleteBuffers(1, &engine.mesh.EBO)
}

run :: proc(engine: ^Engine) {
    
    if !init_window(engine) do return
    fmt.println("window ok")
    if !init_shader(&engine.shader, "shaders/transform.vs", "shaders/shader.fs") do return
    fmt.println("shader ok") 
    if !init_shader(&engine.light_shader, "shaders/light.vs", "shaders/light.fs") do return
    fmt.println("light shader ok")
    create_mesh_cube(&engine.mesh)
    fmt.println("mesh ok")
    if !init_light(&engine.light, engine.mesh.VBO) do return
    fmt.printfln("light ok")
    if !init_texture(&engine.texture) do return
    fmt.println("texture ok")
    if !init_camera(&engine.camera) do return
    fmt.printfln("Camera ok")


    main_loop(engine)
    cleanup(engine)
    cleanup_mesh(&engine.mesh)
}