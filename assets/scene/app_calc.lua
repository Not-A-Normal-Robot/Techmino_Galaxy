local gc=love.graphics
local kb=love.keyboard

local scene={}

local reg-- register
local val-- result value
local sym-- symbol

local function _autoReturn()
    if reg and sym then
        scene.keyDown('calculate')
    else
        reg=false
    end
end

function scene.enter()
    BG.set('none')
    BGM.stop()
    reg,val,sym=false,"0",false
end
function scene.leave()
    BGM.play()
end

scene.mouseDown=NULL
function scene.keyDown(key)
    if kb.isDown('lshift','rshift') then
        if key=='=' then
            scene.keyDown('+')
            return
        elseif kb.isDown('lshift','rshift') and key=='8' then
            scene.keyDown('*')
            return
        end
    elseif key:sub(1,2)=='kp' then
        scene.keyDown(key:sub(3))
        return
    end
    if key=='.' then
        if sym=="=" then
            sym,reg=false,false
            val="0."
        elseif not (val:find(".",nil,true) or val:find("e")) then
            if sym and not reg then
                reg=val
                val="0."
            else
                val=val.."."
            end
        end
    elseif key=='e' then
        if sym=="=" then
            sym,reg=false
            val="0e"
        elseif not val:find("e") then
            val=val.."e"
        end
    elseif key=='backspace' then
        if sym=="=" then
            val=""
        elseif sym then
            sym=false
        else
            val=val:sub(1,-2)
        end
        if val=="" then
            val="0"
        end
    elseif key=='+' then
        _autoReturn()
        sym="+"
    elseif key=='*' then
        _autoReturn()
        sym="*"
    elseif key=='-' then
        _autoReturn()
        sym="-"
    elseif key=='/' then
        _autoReturn()
        sym="/"
    elseif key:byte()>=48 and key:byte()<=57 then
        if sym=="=" then
            val=key
            sym=false
        elseif sym and not reg then
            reg=val
            val=key
        else
            if #val<14 then
                if val=="0" then
                    val=""
                end
                val=val..key
            end
        end
    elseif key=='return' then
        scene.keyDown('calculate')
    elseif key=='calculate' then
        val=val:gsub("e$","")
        if sym and reg then
            reg=reg:gsub("e$","")
            val=
                sym=="+" and tostring((tonumber(reg) or 0)+tonumber(val)) or
                sym=="-" and tostring((tonumber(reg) or 0)-tonumber(val)) or
                sym=="*" and tostring((tonumber(reg) or 0)*tonumber(val)) or
                sym=="/" and tostring((tonumber(reg) or 0)/tonumber(val)) or
                "-1"
        end
        sym="="
        reg=false
    elseif key=='escape' then
        if val~="0" then
            reg,sym=false,false
            val="0"
        else
            SCN.back()
        end
    elseif key=='delete' then
        val="0"
    end
end

function scene.draw()
    gc.setColor(COLOR.dX)
    gc.rectangle('fill',100,80,650,150,5)
    gc.setColor(COLOR.L)
    gc.setLineWidth(2)
    gc.rectangle('line',100,80,650,150,5)
    FONT.set(45)
    if reg then gc.printf(reg,0,100,720,'right') end
    if val then gc.printf(val,0,150,720,'right') end
    if sym then FONT.set(50)gc.print(sym,126,150) end
end

scene.widgetList={
    WIDGET.new{type='button',x=145,y=300,w=90,sound=false,text="1",fontSize=50,code=WIDGET.c_pressKey'1'},
    WIDGET.new{type='button',x=245,y=300,w=90,sound=false,text="2",fontSize=50,code=WIDGET.c_pressKey'2'},
    WIDGET.new{type='button',x=345,y=300,w=90,sound=false,text="3",fontSize=50,code=WIDGET.c_pressKey'3'},
    WIDGET.new{type='button',x=145,y=400,w=90,sound=false,text="4",fontSize=50,code=WIDGET.c_pressKey'4'},
    WIDGET.new{type='button',x=245,y=400,w=90,sound=false,text="5",fontSize=50,code=WIDGET.c_pressKey'5'},
    WIDGET.new{type='button',x=345,y=400,w=90,sound=false,text="6",fontSize=50,code=WIDGET.c_pressKey'6'},
    WIDGET.new{type='button',x=145,y=500,w=90,sound=false,text="7",fontSize=50,code=WIDGET.c_pressKey'7'},
    WIDGET.new{type='button',x=245,y=500,w=90,sound=false,text="8",fontSize=50,code=WIDGET.c_pressKey'8'},
    WIDGET.new{type='button',x=345,y=500,w=90,sound=false,text="9",fontSize=50,code=WIDGET.c_pressKey'9'},
    WIDGET.new{type='button',x=145,y=600,w=90,sound=false,text="0",fontSize=50,code=WIDGET.c_pressKey'0'},
    WIDGET.new{type='button',x=245,y=600,w=90,sound=false,text=".",color='lM',fontSize=50,code=WIDGET.c_pressKey'.'},
    WIDGET.new{type='button',x=345,y=600,w=90,sound=false,text="e",color='lM',fontSize=50,code=WIDGET.c_pressKey'e'},
    WIDGET.new{type='button',x=445,y=300,w=90,sound=false,text="+",color='lB',fontSize=50,code=WIDGET.c_pressKey'+'},
    WIDGET.new{type='button',x=445,y=400,w=90,sound=false,text="-",color='lB',fontSize=50,code=WIDGET.c_pressKey'-'},
    WIDGET.new{type='button',x=445,y=500,w=90,sound=false,text="*",color='lB',fontSize=50,code=WIDGET.c_pressKey'*'},
    WIDGET.new{type='button',x=445,y=600,w=90,sound=false,text="/",color='lB',fontSize=50,code=WIDGET.c_pressKey'/'},
    WIDGET.new{type='button',x=545,y=300,w=90,sound=false,text=CHAR.key.backspace,color='lR',fontSize=50,code=WIDGET.c_pressKey'backspace'},
    WIDGET.new{type='button',x=545,y=400,w=90,sound=false,text="=",color='lY',fontSize=50,code=WIDGET.c_pressKey'return'},
    WIDGET.new{type='button',x=1135,y=640,w=170,h=80,sound='back',fontSize=60,text=CHAR.icon.back,code=WIDGET.c_backScn()},
}

return scene
