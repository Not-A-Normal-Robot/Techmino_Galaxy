function love.conf(t)
    t.identity='Techmino_Galaxy'-- Saving folder
    t.version="11.1"
    t.gammacorrect=false
    t.appendidentity=true-- Search files in source then in save directory
    t.accelerometerjoystick=false-- Accelerometer=joystick on ios/android
    if t.audio then
        t.audio.mic=false
        t.audio.mixwithsystem=true
    end

    local W=t.window
    W.title=require"version".appName.."  "..require"version".appVer
    W.width,W.height=1440,900
    W.minwidth,W.minheight=288,180
    W.borderless=false
    W.resizable=true
    W.fullscreen=false
    W.vsync=0-- Unlimited FPS
    W.msaa=2-- Multi-sampled antialiasing
    W.depth=0-- Bits/samp of depth buffer
    W.stencil=true-- Bits/samp of stencil buffer
    W.display=1-- Monitor ID
    W.highdpi=true-- High-dpi mode for the window on a Retina display
    W.x,W.y=nil

    local M=t.modules
    M.window,M.system,M.event,M.thread=true,true,true,true
    M.timer,M.math,M.data=true,true,true
    M.video,M.audio,M.sound=true,true,true
    M.graphics,M.font,M.image=true,true,true
    M.mouse,M.touch,M.keyboard,M.joystick=true,true,true,true
    M.physics=false
end
