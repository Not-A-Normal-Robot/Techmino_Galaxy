local correctPositions={
    {x=1, y=1,dir={0},  msg="tutorial_twoRotatingKey_m1"},
    {x=4, y=1,dir={0}},
    {x=7, y=1,dir={0}},
    {x=5, y=2,dir={1,3}},
    {x=1, y=2,dir={0}},
    {x=8, y=1,dir={3}},
    {x=6, y=3,dir={3}},
    {x=8, y=4,dir={0},  msg="tutorial_twoRotatingKey_m2"},
    {x=1, y=3,dir={0}},
    {x=3, y=3,dir={1,3}},
    {x=1, y=5,dir={1}},
    {x=4, y=5,dir={0}},
    {x=7, y=6,dir={0}},
    {x=10,y=1,dir={1,3}},
    {x=5, y=2,dir={0}},
    {x=2, y=2,dir={0},  msg="tutorial_twoRotatingKey_m3"},
    {x=7, y=3,dir={1,3}},
    {x=9, y=3,dir={1,3}},
    {x=2, y=3,dir={1}},
    {x=1, y=4,dir={1}},
    {x=4, y=4,dir={0}},
    {x=4, y=5,dir={3}},
    {x=3, y=5,dir={1,3}},
    {x=6, y=5,dir={2},  msg="tutorial_twoRotatingKey_m4"},
    {x=1, y=7,dir={1}},
    {x=2, y=7,dir={1,3}},
    {x=8, y=7,dir={0}},
    {x=10,y=1,dir={1,3}},
    {x=5, y=3,dir={0}},
    {x=7, y=4,dir={2},  msg=false},
    {x=3, y=4,dir={3}},
    {x=5, y=5,dir={0}},
    {x=2, y=6,dir={0}},
    {x=7, y=6,dir={0}},
    {x=10,y=1,dir={1,3}},
}

return {
    initialize=function()
        GAME.newPlayer(1,'mino')
        GAME.setMain(1)
        playBgm('space','full')
    end,
    settings={mino={
        skin='mino_interior',
        shakeness=0,
        readyDelay=1,
        spawnDelay=62,
        dropDelay=1e99,
        lockDelay=1e99,
        nextSlot=3,
        holdSlot=0,
        seqType='none',
        soundEvent={
            countDown=NULL,
        },
        event={
            playerInit=function(P)
                P.modeData.waitTime=0
                P.modeData.msgTimer=0
                P.modeData.msg=false
            end,
            gameStart=function(P)
                P.spawnTimer=1500
            end,
            always=function(P)
                P.modeData.waitTime=P.modeData.waitTime+1
                P.modeData.msgTimer=P.modeData.msgTimer+1
            end,
            afterPress=function(P,act)
                if not P.hand then return end
                if act=='rotateCW' or act=='rotateCCW' or act=='rotate180' then
                    if not P.modeData.rotDir then
                        P.modeData.rotDir=act
                    end
                    if act==P.modeData.rotDir then
                        P.modeData.rotCount=P.modeData.rotCount+(act=='rotate180' and 2 or 1)
                    else
                        P.modeData.rotCount=1e99
                    end
                    if P.hand.name=='O' or (P.hand.name=='S' or P.hand.name=='Z' or P.hand.name=='I') and P.hand.direction==2 then
                        P.modeData.rotCount=1e99
                    end
                    if P.modeData.rotCount>2 then
                        table.insert(P.nextQueue,1,P:getMino(Minoes[P.hand.name].id))
                        P.hand=false
                        P.spawnTimer=1000
                        P:playSound('b2b_break')
                        P:say{
                            duration='1s',
                            text='@tutorial_twoRotatingKey_unnecessaryRotation',
                            size=40,
                            type='bold',
                            y=-60,
                            i=.0626,o=.126,
                            c={1,.26,.26},
                        }
                    end
                end
            end,
            afterResetPos=function(P)
                P.modeData.rotDir=false
                P.modeData.rotCount=0
                local ans=correctPositions[#P.dropHistory+1]
                local shape=TABLE.shift(P.hand.matrix,1)
                if ans then
                    if ans.dir[1]~=0 then
                        shape=TABLE.rotate(shape,ans.dir[1]==1 and 'R' or ans.dir[1]==2 and ans.dir[1] and 'F' or 'L')
                    end
                    P.modeData.x,P.modeData.y=ans.x,ans.y
                    P.modeData.dir=ans.dir
                    P.modeData.shape=shape
                    P.modeData.waitTime=0
                    if ans.msg~=nil and P.modeData.msg~=ans.msg then
                        P.modeData.msg=ans.msg
                        P.modeData.msgTimer=0
                    end
                end
            end,
            afterDrop=function(P)
                if P.modeData.shape and not (P.handX==P.modeData.x and P.handY==P.modeData.y and TABLE.find(P.modeData.dir,P.hand.direction)) then
                    table.insert(P.nextQueue,1,P:getMino(Minoes[P.hand.name].id))
                    P.hand=false
                else
                    P.modeData.shape=false
                end
            end,
            afterLock=function(P)
                if #P.nextQueue==0 then
                    P.modeData.signal=
                        P:checkLineFull(1) and
                        P:checkLineFull(2) and
                        P:checkLineFull(3) and
                        P:checkLineFull(4) or false
                end
            end,
            drawBelowMarks=function(P)
                local m=P.modeData.shape
                if m then
                    GC.setColor(1,1,1,.42*(math.min(P.modeData.waitTime/126,1)+.42*math.sin(P.modeData.waitTime*.01)))
                    GC.setLineWidth(6)
                    for y=1,#m do for x=1,#m[1] do
                        local C=m[y][x]
                        if C then
                            GC.rectangle('line',(P.modeData.x+x-2)*40+7,-(P.modeData.y+y-1)*40+7,26,26)
                        end
                    end end
                end
            end,
            drawOnPlayer=function(P)
                if P.modeData.msg then
                    FONT.set(35)
                    GC.setColor(1,.75,.7,math.min(P.modeData.msgTimer/260,1))
                    GC.mStr(Text[P.modeData.msg],0,-30)
                end
            end,
        },
        script={
            {cmd='say',arg={duration='1.5s',text="@tutorial_twoRotatingKey_1",y=-60}},

            "pushNext IZOSJLT",
            "pushNext OZSLJTI",
            "pushNext OSZITJL",
            "pushNext JZTLSOI",
            "pushNext ZLTOSJI",
            "wait signal",

            "sfx win",
            {cmd='say',arg={duration='6.26s',text="@tutorial_pass",size=120,type='bold',style='beat',c=COLOR.lG,y=-30}},
            {cmd=function(P) if P.isMain then PROGRESS.setTutorialPassed(4) end end},
            "finish AC",
        },
    }},
}
