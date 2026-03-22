package fenrir

import "core:log"
import SDL "vendor:sdl3"
import GL "vendor:OpenGL"

init_window :: proc(engine: ^Engine) -> bool {
    if !SDL.Init({.VIDEO}) {
        log.error("Failed to init SDL:\n", SDL.GetError())
        return false
    }

    SDL.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
    SDL.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 3)
    SDL.GL_SetAttribute(.CONTEXT_PROFILE_MASK, transmute(i32)SDL.GL_CONTEXT_PROFILE_CORE)

    SDL.GL_SetAttribute(SDL.GL_RED_SIZE, 8);
    SDL.GL_SetAttribute(SDL.GL_GREEN_SIZE, 8);
    SDL.GL_SetAttribute(SDL.GL_BLUE_SIZE, 8);
    SDL.GL_SetAttribute(SDL.GL_ALPHA_SIZE, 8);
    SDL.GL_SetAttribute(SDL.GL_BUFFER_SIZE, 32);
    SDL.GL_SetAttribute(SDL.GL_DEPTH_SIZE, 24);
    SDL.GL_SetAttribute(SDL.GL_DOUBLEBUFFER, 1);
    
    engine.window = SDL.CreateWindow("Fenrir Game Engine", SCREEN_WIDTH, SCREEN_HEIGHT, {.OPENGL})
    if engine.window == nil {
        log.error("Failed to create window:\n", SDL.GetError())
        return false
    }
    
    engine.gl_context = SDL.GL_CreateContext(engine.window)
    if engine.gl_context == nil {
        log.error("Failed to create context:\n", SDL.GetError())
        return false
    }
    
    // Allows function from opengl to be used
    GL.load_up_to(3, 3, SDL.gl_set_proc_address)
    GL.Enable(GL.DEPTH_TEST)
    // Enables Vsync - synchronizes games frame rate with monitors refresh rate
    SDL.GL_SetSwapInterval(1)

    // Keep mouse inside of the window, dont need for testing currently
    if !SDL.SetWindowRelativeMouseMode(engine.window, true) {
        log.error("Failed to set relative mouse mode:\n", SDL.GetError())
    }

    return true
}

framebuffer_size_callback :: proc(engine: ^Engine, width, height: i32) {
    GL.Viewport(0, 0, width, height)
}

cleanup :: proc(engine: ^Engine) {
    SDL.GL_DestroyContext(engine.gl_context)
    SDL.DestroyWindow(engine.window)
    SDL.Quit()
}