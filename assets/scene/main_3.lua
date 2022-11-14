local scene={}

local versionText=GC.newText(FONT.get(35,'bold'))
local terminalName=GC.newText(FONT.get(35,'thin'))

function scene.enter()
    BG.set('none')
    PROGRESS.playBGM_main_3()
    versionText:set(VERSION.appVer)
    terminalName:set(("TERM[%s]"):format(SYSTEM:sub(1,3):upper()))
end

function scene.keyDown(key,isRep)
    if isRep then return end
    if key=='return' then
        SCN.go('game_simp',nil,'mino/sprint')
    elseif key=='c' then
        SCN.go('_console')
    elseif key=='escape' then
        if sureCheck('quit') then SCN.back() end
    end
end

function scene.draw()
    GC.setColor(1,1,1)
    GC.draw(IMG.title.techmino,100,180,nil,.55)
    GC.setColor(.1,.1,.1)
    for a=0,MATH.tau,MATH.tau/20 do
        GC.draw(IMG.title.galaxy,550+10*math.cos(a),310+10*math.sin(a),nil,.7)
    end
    GC.setColor(1,1,1)
    GC.draw(IMG.title.galaxy,550,310,nil,.7)
    GC.draw(versionText,140,370)
    GC.draw(terminalName,160+versionText:getWidth(),370)
end

scene.widgetList={
    WIDGET.new{type='button',   x=325,  y=520,w=530,h=100,text=function() return CHAR.icon.person    ..' '..Text.main_3_single       end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn''},
    WIDGET.new{type='button',   x=895,  y=520,w=530,h=100,text=function() return CHAR.icon.people    ..' '..Text.main_3_multi        end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn''},

    WIDGET.new{type='button',   x=230,  y=660,w=340,h=100,text=function() return CHAR.icon.settings  ..' '..Text.main_3_setting_3    end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn'setting_3'},
    WIDGET.new{type='button',   x=610,  y=660,w=340,h=100,text=function() return CHAR.icon.statistics..' '..Text.main_3_stat         end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn'stat'},
    WIDGET.new{type='button',   x=990,  y=660,w=340,h=100,text=function() return CHAR.icon.bookmark  ..' '..Text.main_3_dict         end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn'dict'},
    WIDGET.new{type='button',   x=230,  y=800,w=340,h=100,text=function() return CHAR.icon.language  ..' '..Text.main_3_setting_lang end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn'setting_lang'},
    WIDGET.new{type='button',   x=610,  y=800,w=340,h=100,text=function() return CHAR.icon.music     ..' '..Text.main_3_musicroom    end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn'musicroom'},
    WIDGET.new{type='button',   x=990,  y=800,w=340,h=100,text=function() return CHAR.icon.info_circ ..' '..Text.main_3_about        end, fontSize=40,lineWidth=2,cornerR=26,code=WIDGET.c_goScn'about'},
}
return scene
