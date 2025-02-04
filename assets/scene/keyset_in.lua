local gc=love.graphics

local scene={}

local keyButtons={}

function scene.enter()
    BG.set('none')

    TABLE.cut(keyButtons)
    for i=1,#scene.widgetList do
        table.insert(keyButtons,scene.widgetList[i])
    end
    table.remove(keyButtons)
end
function scene.leave()
    saveKey()
end

function scene.draw()
    FONT.set(25)
    gc.setColor(COLOR.L)
    for i=1,#keyButtons do
        local l=KEYMAP.mino[i].keys
        for j=1,#l do
            GC.mStr(l[j],
                keyButtons[i].x+79+80*j,
                keyButtons[i].y-20
            )
        end
    end
end

local function _selAct(mode,act)
    SCN.go('keyset_press','none',mode,act)
end
local function selAct(mode,act)
    return function() _selAct(mode,act) end
end

scene.widgetList={
    WIDGET.new{type='button', x=600,y=80, w=200,h=70,cornerR=0,text=LANG"keyset_mino_moveLeft",  fontSize=20,color='lG',code=selAct('mino','moveLeft'  )},
    WIDGET.new{type='button', x=600,y=160,w=200,h=70,cornerR=0,text=LANG"keyset_mino_moveRight", fontSize=20,color='lG',code=selAct('mino','moveRight' )},
    WIDGET.new{type='button', x=600,y=240,w=200,h=70,cornerR=0,text=LANG"keyset_mino_rotateCW",  fontSize=20,color='lG',code=selAct('mino','rotateCW'  )},
    WIDGET.new{type='button', x=600,y=320,w=200,h=70,cornerR=0,text=LANG"keyset_mino_rotateCCW", fontSize=20,color='lG',code=selAct('mino','rotateCCW' )},
    WIDGET.new{type='button', x=600,y=400,w=200,h=70,cornerR=0,text=LANG"keyset_mino_rotate180", fontSize=20,color='lG',code=selAct('mino','rotate180' )},
    WIDGET.new{type='button', x=600,y=480,w=200,h=70,cornerR=0,text=LANG"keyset_mino_softDrop",  fontSize=20,color='lG',code=selAct('mino','softDrop'  )},
    WIDGET.new{type='button', x=600,y=560,w=200,h=70,cornerR=0,text=LANG"keyset_mino_hardDrop",  fontSize=20,color='lG',code=selAct('mino','hardDrop'  )},
    WIDGET.new{type='button', x=600,y=640,w=200,h=70,cornerR=0,text=LANG"keyset_mino_holdPiece", fontSize=20,color='lG',code=selAct('mino','holdPiece' )},
    WIDGET.new{type='button', x=600,y=720,w=200,h=70,cornerR=0,text=LANG"keyset_mino_sonicDrop", fontSize=20,color='lG',code=selAct('mino','sonicDrop' )},
    WIDGET.new{type='button', x=600,y=800,w=200,h=70,cornerR=0,text=LANG"keyset_mino_sonicLeft", fontSize=20,color='lG',code=selAct('mino','sonicLeft' )},
    WIDGET.new{type='button', x=600,y=880,w=200,h=70,cornerR=0,text=LANG"keyset_mino_sonicRight",fontSize=20,color='lG',code=selAct('mino','sonicRight')},

    WIDGET.new{type='button',pos={1,1},x=-120,y=-80,w=160,h=80,sound='back',fontSize=60,text=CHAR.icon.back,code=WIDGET.c_backScn('none')},
}
return scene
