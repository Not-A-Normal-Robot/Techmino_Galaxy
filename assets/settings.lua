local settings={
    _system={-- We just save values here, do not change them directly.
        -- Audio
        autoMute=false,
        mainVol=1,
        bgmVol=.8,
        sfxVol=1,
        vocVol=0,
        vibVol=1,

        -- Video
        hitWavePower=.6,
        fullscreen=true,
        maxFPS=300,
        updRate=100,
        drawRate=30,

        -- Gameplay
        touchControl=false,

        -- Other
        powerInfo=true,
        sysCursor=false,
        showTouch=true,
        clean=false,
        locale='en',
    },
    game_mino={
        -- Handling
        das=120,
        arr=20,
        sdarr=20,
        dascut=26,

        -- Video
        shakeness=.6,
    },
    game_puyo={
        -- Handling
        das=120,
        arr=20,
        sdarr=20,
        dascut=26,

        -- Video
        shakeness=.6,
    },
    game_gem={
        -- Handling
        das=150,
        arr=40,

        -- Video
        shakeness=.6,
    },
}
local settingTriggers={-- Changing values in SETTINGS.system will trigger these functions (if exist).
    -- Audio
    mainVol=        function(v) love.audio.setVolume(v) end,
    bgmVol=         function(v) BGM.setVol(v) end,
    sfxVol=         function(v) SFX.setVol(v) end,
    vocVol=         function(v) VOC.setVol(v) end,

    -- Video
    fullscreen=     function(v) love.window.setFullscreen(v); love.resize(love.graphics.getWidth(),love.graphics.getHeight()) end,
    maxFPS=         function(v) Zenitha.setMaxFPS(v) end,
    updRate=        function(v) Zenitha.setUpdateFreq(v) end,
    drawRate=       function(v) Zenitha.setDrawFreq(v) end,
    sysCursor=      function(v) love.mouse.setVisible(v) end,
    clean=          function(v) Zenitha.setCleanCanvas(v) end,

    -- Other
    locale=         function(v) Text=LANG.get(v) LANG.setTextFuncSrc(Text) end,
}
settings.system=setmetatable({},{
    __index=settings._system,
    __newindex=function(_,k,v)
        if settings._system[k]~=v then
            settings._system[k]=v
            if settingTriggers[k] then
                settingTriggers[k](v)
            end
        end
    end,
    __metatable=true,
})
return settings
