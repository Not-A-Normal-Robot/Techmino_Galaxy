local gc=love.graphics

return {
    initialize=function()
        GAME.newPlayer(1,'mino')
        GAME.setMain(1)
        playBgm('sakura','','-noloop')
        BGM.set('all','seek',0)
    end,
    settings={mino={
        dropDelay=1000,
        lockDelay=1000,
        event={
            always=function(P)
                if P.gameTime>=120000 then
                    P:finish('AC')
                end
            end,
            drawOnPlayer=function(P)
                gc.push('transform')
                gc.translate(-300,0)
                gc.setLineWidth(2)
                gc.setColor(.98,.98,.98,.8)
                gc.rectangle('line',-75,-50,150,100,4)
                gc.setColor(.98,.98,.98,.4)
                gc.rectangle('fill',-75+2,-50+2,150-4,100-4,2)
                FONT.set(50)
                local t=P.gameTime/1000
                local T=("%.1f"):format(120-t)
                gc.setColor(COLOR.lD)
                GC.mStr(T,2,-33)
                t=t/120
                gc.setColor(1.7*t,2.3-2*t,.3)
                GC.mStr(T,0,-35)
                gc.pop()
            end,
        },
    }},
    checkFinish=function()
        for i=1,#GAME.playerList do
            if not GAME.playerList[i].finished then
                return false
            end
        end
        return true
    end,
}
