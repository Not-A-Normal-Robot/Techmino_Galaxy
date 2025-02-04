local gc=love.graphics

return {
    initialize=function()
        GAME.newPlayer(1,'mino')
        GAME.setMain(1)
        playBgm('race','base')
    end,
    settings={mino={
        dropDelay=1000,
        lockDelay=1000,
        event={
            playerInit=function(P)
                P.modeData.line=0
            end,
            afterClear=function(P)
                P.modeData.line=math.min(P.modeData.line+P.clearHistory[#P.clearHistory].line,40)
                if P.modeData.line>=40 then
                    P:finish('AC')
                end
                if PROGRESS.getMain()>=2 and P.modeData.line>10 and P.isMain then
                    BGM.set(bgmList['race'].add,'volume',math.min((P.modeData.line-10)/20,1),2.6)
                end
            end,
            drawInField=function(P)
                gc.setColor(1,1,1,.26)
                gc.rectangle('fill',0,(P.modeData.line-40)*40-2,P.settings.fieldW*40,4)
            end,
            drawOnPlayer=function(P)
                gc.setColor(COLOR.L)
                FONT.set(80)
                GC.mStr(40-P.modeData.line,-300,-55)
            end,
        },
    }},
}
