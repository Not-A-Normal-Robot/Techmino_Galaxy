local gc=love.graphics

local max,min=math.max,math.min
local floor,ceil=math.floor,math.ceil
local abs,rnd=math.abs,math.random
local ins,rem=table.insert,table.remove

local sign,expApproach=MATH.sign,MATH.expApproach
local inst=SFX.playSample

local defaultSoundFunc={
    countDown=function(num)
        if num==0 then-- 6, 3+6+6
            inst('bass',.8,'A3')
            inst('lead',.9,'A4','E5','A5')
        elseif num==1 then-- 5, 3+7
            inst('bass',.9,'G3')
            inst('lead',.9,'B4','E5')
        elseif num==2 then-- 4, 6+2
            inst('bass','F3')
            inst('lead',.8,'A4','D5')
        elseif num==3 then-- 6+6
            inst('bass',.9,'A3','E4')
            inst('lead',.8,'A4')
        elseif num==4 then-- 5+7, 5
            inst('bass',.9,'G3','B3')
            inst('lead',.6,'G4')
        elseif num==5 then-- 4+6, 4
            inst('bass',.8,'F3','A3')
            inst('lead',.3,'F4')
        elseif num<=10 then
            inst('bass',2.2-num/5,'A2','E3')
        end
    end,
    move=           function() SFX.play('move')          end,
    move_failed=    function() SFX.play('move_failed')   end,
    swap=           function() SFX.play('rotate')        end,
    swap_failed=    function() SFX.play('tuck')          end,
    twist=          function() SFX.play('rotate')        end,
    twist_failed=   function() SFX.play('tuck')          end,
    move_back=      function() SFX.play('rotate_failed') end,
    touch=          function() SFX.play('lock')          end,
    clear=function(lines)
        SFX.play(
            lines==1 and 'clear_1' or
            lines==2 and 'clear_2' or
            lines==3 and 'clear_3' or
            lines==4 and 'clear_4' or
            'clear_5'
        )
        if lines>=3 then
            BGM.set('all','highgain',.26+1/lines,0)
            BGM.set('all','highgain',1,min((lines)^1.5/5,2.6))
        end
    end,
    combo=       function() end,
    chain=       function() end,
    win=         function() SFX.play('win')         end,
    fail=        function() SFX.play('fail')        end,
}

--[[ Gem tags:
    int id (1~7)
    boolean movable

    int clearTimer
    int clearDelay

    int moveTimer
    int moveDelay
    float dx
    float dy
    boolean fall

    int lrCnt
    int udCnt
    int riseCnt
    int dropCnt
]]

local GP={}

--------------------------------------------------------------
-- Actions
local actions={}

function actions.swapLeft(P)
    if (P.settings.multiMove or #P.movingGroups==0) and P.settings.swap then
        P:swap('action',P.swapX,P.swapY,-1,0)
    end
end
function actions.swapRight(P)
    if (P.settings.multiMove or #P.movingGroups==0) and P.settings.swap then
        P:swap('action',P.swapX,P.swapY,1,0)
    end
end
function actions.swapUp(P)
    if (P.settings.multiMove or #P.movingGroups==0) and P.settings.swap then
        P:swap('action',P.swapX,P.swapY,0,1)
    end
end
function actions.swapDown(P)
    if (P.settings.multiMove or #P.movingGroups==0) and P.settings.swap then
        P:swap('action',P.swapX,P.swapY,0,-1)
    end
end
function actions.twistCW(P)
    if (P.settings.multiMove or #P.movingGroups==0) and P.settings.twistR then
        P:twist('action',P.twistX,P.twistY,'R')
    end
end
function actions.twistCCW(P)
    if (P.settings.multiMove or #P.movingGroups==0) and P.settings.twistL then
        P:twist('action',P.twistX,P.twistY,'L')
    end
end
function actions.twist180(P)
    if (P.settings.multiMove or #P.movingGroups==0) and P.settings.twistF then
        P:twist('action',P.twistX,P.twistY,'F')
    end
end
function actions.moveLeft(P)
    P.mouseX,P.mouseY=false,false
    P.moveDirH=-1
    P.moveChargeH=0

    if P.swapX>1 then
        P.swapX=P.swapX-1
        if P.twistX>1 then
            P.twistX=P.twistX-1
        end
        P:playSound('move')
    elseif P.twistX>1 then
        P.twistX=P.twistX-1
        P:playSound('move')
    else
        P:playSound('move_failed')
    end
end
function actions.moveRight(P)
    P.mouseX,P.mouseY=false,false
    P.moveDirH=1
    P.moveChargeH=0

    if P.swapX<P.settings.fieldSize then
        P.swapX=P.swapX+1
        if P.twistX<P.settings.fieldSize-1 then
            P.twistX=P.twistX+1
        end
        P:playSound('move')
    elseif P.twistX<P.settings.fieldSize-1 then
        P.twistX=P.twistX+1
        P:playSound('move')
    else
        P:playSound('move_failed')
    end
end
function actions.moveUp(P)
    P.mouseX,P.mouseY=false,false
    P.moveDirV=1
    P.moveChargeV=0

    if P.swapY<P.settings.fieldSize then
        P.swapY=P.swapY+1
        if P.twistY<P.settings.fieldSize-1 then
            P.twistY=P.twistY+1
        end
        P:playSound('move')
    elseif P.twistY<P.settings.fieldSize-1 then
        P.twistY=P.twistY+1
        P:playSound('move')
    else
        P:playSound('move_failed')
    end
end
function actions.moveDown(P)
    P.mouseX,P.mouseY=false,false
    P.moveDirV=-1
    P.moveChargeV=0

    if P.swapY>1 then
        P.swapY=P.swapY-1
        if P.twistY>1 then
            P.twistY=P.twistY-1
        end
        P:playSound('move')
    elseif P.twistY>1 then
        P.twistY=P.twistY-1
        P:playSound('move')
    else
        P:playSound('move_failed')
    end
end

actions.func1=NULL
actions.func2=NULL
actions.func3=NULL
actions.func4=NULL
actions.func5=NULL
actions.func6=NULL


local function _getActionObj(a)
    if type(a)=='string' then
        return actions[a]
    elseif type(a)=='function' then
        return setmetatable({
            press=a,
            release=NULL,
        },{__call=function(self,P)
            self.press(P)
        end})
    elseif type(a)=='table' then
        assert(type(a.press)=='function' and type(a.release)=='function',"wtf why action do not contain func press() & func release()")
        return setmetatable({
            press=a.press,
            release=a.release,
        },{__call=function(self,P)
            self.press(P)
            self.release(P)
        end})
    else
        error("Invalid action: should be function or table contain 'press' and 'release' fields")
    end
end
for k,v in next,actions do actions[k]=_getActionObj(v) end
--------------------------------------------------------------
-- Effects
function GP:shakeBoard(args,v)
    local shake=self.settings.shakeness
    if args:sArg('-drop') then
        self.pos.vy=self.pos.vy+.2*shake
    elseif args:sArg('-down') then
        self.pos.dy=self.pos.dy+.1*shake
    elseif args:sArg('-up') then
        self.pos.dy=self.pos.dy-.1*shake
    elseif args:sArg('-right') then
        self.pos.dx=self.pos.dx+.1*shake
    elseif args:sArg('-left') then
        self.pos.dx=self.pos.dx-.1*shake
    elseif args:sArg('-cw') then
        self.pos.va=self.pos.va+.002*shake
    elseif args:sArg('-ccw') then
        self.pos.va=self.pos.va-.002*shake
    elseif args:sArg('-180') then
        self.pos.vy=self.pos.vy+.1*shake
    elseif args:sArg('-clear') then
        self.pos.dk=self.pos.dk*(1+shake)
        self.pos.vk=self.pos.vk+.0002*shake*min(v^1.6,26)
    end
end
function GP:playSound(event,...)
    if not self.sound then return end
    if self.time-self.soundTimeHistory[event]>=15 then
        self.soundTimeHistory[event]=self.time
        if self.soundEvent[event] then
            self.soundEvent[event](...)
        else
            MES.new('warn',"Unknown sound event: "..event)
        end
    end
end
function GP:setPosition(x,y,k,a)
    self.pos.x=x or self.pos.x
    self.pos.y=y or self.pos.y
    self.pos.k=k or self.pos.k
    self.pos.a=a or self.pos.a
end
function GP:movePosition(dx,dy,k,da)
    self.pos.x=self.pos.x+(dx or 0)
    self.pos.y=self.pos.y+(dy or 0)
    self.pos.k=self.pos.k*(k or 1)
    self.pos.a=self.pos.a+(da or 0)
end
--------------------------------------------------------------
-- Game methods
function GP:printField()-- For debugging
    local F=self.field
    print('----------')
    for y=self.settings.fieldSize,1,-1 do
        local s="|"
        for x=1,self.settings.fieldSize do
            s=s..(F[y][x] and 'X' or '.')
        end
        print(s.."|")
    end
end
function GP:triggerEvent(name,...)
    local L=self.event[name]
    if L then for i=1,#L do L[i](self,...) end end
end
function GP:isMovable(x,y)
    if x>=1 and x<=self.settings.fieldSize and y>=1 and y<=self.settings.fieldSize then
        local F=self.field
        if F[y][x] then
            return F[y][x].movable
        else
            return true
        end
    else
        return false
    end
end
function GP:setMoveBias(mode,C,dx,dy)
    if not C then return end
    C.checkTimer=false
    C.movable=false
    C.moveTimer=self.settings.moveDelay
    C.moveDelay=self.settings.moveDelay
    C.dx=(C.dx or 0)+dx
    C.dy=(C.dy or 0)+dy
    if mode=='fall' then C.fall=true end
end
function GP:swap(mode,x,y,dx,dy)
    local F=self.field
    if
        self:isMovable(x,y) and self:isMovable(x+dx,y+dy)
    then
        self:setMoveBias('swap',F[y][x],-dx,-dy)
        self:setMoveBias('swap',F[y+dy][x+dx],dx,dy)
        F[y][x],F[y+dy][x+dx]=F[y+dy][x+dx],F[y][x]
        if mode=='action' then
            ins(self.movingGroups,{
                mode='swap',
                force=self.settings.swapForce,
                args={x,y,dx,dy},
                positions={x,y,x+dx,y+dy},
            })
            self:triggerEvent('legalMove','swap')
            self:playSound('swap')
        elseif mode=='auto' then
            self:playSound('move_back')
        end
    else
        self:playSound('swap_failed')
    end
    self:freshSwapCursor()
end
function GP:twist(mode,x,y,dir)
    local F=self.field
    if
        self:isMovable(x,y) and
        self:isMovable(x,y+1) and
        self:isMovable(x+1,y+1) and
        self:isMovable(x+1,y)
    then
        if dir=='R' then
            self:setMoveBias('twist',F[y][x],0,-1)
            self:setMoveBias('twist',F[y][x+1],1,0)
            self:setMoveBias('twist',F[y+1][x+1],0,1)
            self:setMoveBias('twist',F[y+1][x],-1,0)
            F[y][x],F[y][x+1],F[y+1][x+1],F[y+1][x]=F[y][x+1],F[y+1][x+1],F[y+1][x],F[y][x]
        elseif dir=='L' then
            self:setMoveBias('twist',F[y][x],-1,0)
            self:setMoveBias('twist',F[y][x+1],0,-1)
            self:setMoveBias('twist',F[y+1][x+1],1,0)
            self:setMoveBias('twist',F[y+1][x],0,1)
            F[y][x],F[y][x+1],F[y+1][x+1],F[y+1][x]=F[y+1][x],F[y][x],F[y][x+1],F[y+1][x+1]
        elseif dir=='F' then
            self:setMoveBias('twist',F[y][x],-1,-1)
            self:setMoveBias('twist',F[y][x+1],1,-1)
            self:setMoveBias('twist',F[y+1][x+1],1,1)
            self:setMoveBias('twist',F[y+1][x],-1,1)
            F[y][x],F[y][x+1],F[y+1][x+1],F[y+1][x]=F[y+1][x+1],F[y+1][x],F[y][x],F[y][x+1]
        end
        if mode=='action' then
            ins(self.movingGroups,{
                mode='twist',
                force=self.settings.swapForce,
                args={x,y,dir=='R' and 'L' or dir=='L' and 'R' or 'F'},
                positions={x,y,x+1,y,x+1,y+1,x,y+1},
            })
            self:playSound('twist')
            self:triggerEvent('legalMove','twist')
        elseif mode=='auto' then
            self:playSound('move_back')
        end
    else
        self:playSound('twist_failed')
    end
end
local function linkLen(F,id,x,y,dx,dy)
    local cnt=0
    x,y=x+dx,y+dy
    while true do
        local G=F[y] and F[y][x]
        if G and G.id==id and G.movable then
            x,y=x+dx,y+dy
            cnt=cnt+1
        else
            break
        end
    end
    return cnt
end
function GP:psedoCheckPos(x,y)
    local F=self.field
    if not F[y][x] then return end

    local id=F[y][x].id

    if not F[y][x].lrCnt then
        local stepX,stepY=1,0
        if 1+linkLen(F,id,x,y,-stepX,-stepY)+linkLen(F,id,x,y,stepX,stepY)>=self.settings.linkLen then
            return true
        end
    end
    if not F[y][x].udCnt then
        local stepX,stepY=0,1
        if 1+linkLen(F,id,x,y,-stepX,-stepY)+linkLen(F,id,x,y,stepX,stepY)>=self.settings.linkLen then
            return true
        end
    end
    if self.settings.diagonalLinkLen then
        if not F[y][x].riseCnt then
            local stepX,stepY=1,1
            if 1+linkLen(F,id,x,y,-stepX,-stepY)+linkLen(F,id,x,y,stepX,stepY)>=self.settings.diagonalLinkLen then
                return true
            end
        end
        if not F[y][x].dropCnt then
            local stepX,stepY=1,-1
            if 1+linkLen(F,id,x,y,-stepX,-stepY)+linkLen(F,id,x,y,stepX,stepY)>=self.settings.diagonalLinkLen then
                return true
            end
        end
    end
end
function GP:checkPosition(x,y)
    local F=self.field
    if not F[y][x] then return end

    local id=F[y][x].id

    local line=0

    if not F[y][x].lrCnt then
        local stepX,stepY=1,0
        local l=linkLen(F,id,x,y,-stepX,-stepY)
        local r=linkLen(F,id,x,y,stepX,stepY)
        local len=1+l+r
        if len>=self.settings.linkLen then
            for i=-l,r do
                local cx,cy=x+stepX*i,y+stepY*i
                local g=F[cy] and F[cy][cx]
                if g and not g.clearTimer then
                    g.clearTimer=self.settings.clearDelay
                    g.clearDelay=self.settings.clearDelay
                    g.movable=false
                    g.lrCnt=len
                end
            end
            line=line+1
        end
    end
    if not F[y][x].udCnt then
        local stepX,stepY=0,1
        local l=linkLen(F,id,x,y,-stepX,-stepY)
        local r=linkLen(F,id,x,y,stepX,stepY)
        local len=1+l+r
        if len>=self.settings.linkLen then
            for i=-l,r do
                local cx,cy=x+stepX*i,y+stepY*i
                local g=F[cy] and F[cy][cx]
                if g and not g.clearTimer then
                    g.clearTimer=self.settings.clearDelay
                    g.clearDelay=self.settings.clearDelay
                    g.movable=false
                    g.udCnt=len
                end
            end
            line=line+1
        end
    end
    if self.settings.diagonalLinkLen then
        if not F[y][x].riseCnt then
            local stepX,stepY=1,1
            local l=linkLen(F,id,x,y,-stepX,-stepY)
            local r=linkLen(F,id,x,y,stepX,stepY)
            local len=1+l+r
            if len>=self.settings.diagonalLinkLen then
                for i=-l,r do
                    local cx,cy=x+stepX*i,y+stepY*i
                    local g=F[cy] and F[cy][cx]
                    if g and not g.clearTimer then
                        g.clearTimer=self.settings.clearDelay
                        g.clearDelay=self.settings.clearDelay
                        g.movable=false
                        g.riseCnt=len
                    end
                end
                line=line+1
            end
        end
        if not F[y][x].dropCnt then
            local stepX,stepY=1,-1
            local l=linkLen(F,id,x,y,-stepX,-stepY)
            local r=linkLen(F,id,x,y,stepX,stepY)
            local len=1+l+r
            if len>=self.settings.diagonalLinkLen then
                for i=-l,r do
                    local cx,cy=x+stepX*i,y+stepY*i
                    local g=F[cy] and F[cy][cx]
                    if g and not g.clearTimer then
                        g.clearTimer=self.settings.clearDelay
                        g.clearDelay=self.settings.clearDelay
                        g.movable=false
                        g.dropCnt=len
                    end
                end
                line=line+1
            end
        end
    end

    if line>0 then
        self:playSound('clear',line)
    end
end
function GP:freshGems()
    local holes={}
    local F=self.field
    for x=1,self.settings.fieldSize do
        -- Drag gems down
        for y=1,self.settings.fieldSize do
            -- F[y][x] is a hole
            if not F[y][x] then
                -- Find a gem above the hole
                for gY=y+1,self.settings.fieldSize do
                    if F[gY][x] then
                        -- Move it if it's movable
                        if self:isMovable(x,gY) then
                            F[y][x],F[gY][x]=F[gY][x],false
                            self:setMoveBias('fall',F[y][x],0,gY-y)
                        end
                        break
                    end
                end
            end
        end

        -- Fill holes with new gems
        for y=self.settings.fieldSize,1,-1 do
            if not F[y][x] then
                F[y][x]={}
                self:setMoveBias('fall',F[y][x],0,8)
                ins(holes,F[y][x])
            else
                break
            end
        end
    end
    local freshTimes=0
    repeat
        for i=1,#holes do
            holes[i].id=self.seqRND:random(self.settings.colors)
        end
        freshTimes=freshTimes+1
    until freshTimes>=self.settings.refreshCount or self:hasMove()
end
function GP:hasMove()
    return true
end
function GP:changeFieldSize(w,h,origX,origY)
end
function GP:receive(data)
    local B={
        power=data.power,
        mode=data.mode,
        time0=math.floor(data.time*1000+.5),
        time=0,
        fatal=data.fatal,
        speed=data.speed,
    }
    ins(self.garbageBuffer,B)
end
function GP:finish(reason)
    --[[ Reason:
        AC:  Win
        WA:  No Moves
        CE:  /
        MLE: /
        TLE: Time out
        OLE: Invalid move
        ILE: /
        PE:  Mission failed
        RE:  Other reason
    ]]

    if self.finished then return end
    self.timing=false
    self.finished=true

    self:triggerEvent('gameOver',reason)
    GAME.checkFinish()

    -- <Temporarily>
    if self.isMain then
        MES.new(reason=='AC' and 'check' or 'error',reason,6.26)
        self:playSound(reason=='AC' and 'win' or 'fail')
    end
    -- </Temporarily>
end
--------------------------------------------------------------
-- Press & Release & Update & Render
function GP:getMousePos(x,y)
    local pos=self.pos
    x,y=((x-pos.x)/pos.k/360+1)/2,((pos.y-y)/pos.k/360+1)/2
    if x>=0 and x<1 and y>=0 and y<1 then
        return x,y
    else
        return false,false
    end
end
function GP:getSwapPos(x,y)
    local size=self.settings.fieldSize
    x,y=floor(x*size+1),floor(y*size+1)
    if x>=1 and x<=size and y>=1 and y<=size then return x,y end
end
function GP:freshSwapCursor()
    self.swapLock=false
    if self.mouseX then
        local sx,sy=self:getSwapPos(self.mouseX,self.mouseY)
        if sx and (self.swapX~=sx or self.swapY~=sy) then
            self.swapX,self.swapY=sx,sy
        end
    end
end
function GP:getTwistPos(x,y)
    local size=self.settings.fieldSize
    x,y=floor(x*size+.5),floor(y*size+.5)
    if x>=1 and x<=size-1 and y>=1 and y<=size-1 then return x,y end
end
function GP:freshTwistCursor()
    if self.mouseX then
        local tx,ty=self:getTwistPos(self.mouseX,self.mouseY)
        if tx and (self.twistX~=tx or self.twistY~=ty) then
            self.twistX,self.twistY=tx,ty
        end
    end
end
function GP:mouseDown(x,y,id)
    if id==2 then
        if self.swapLock then
            self:freshSwapCursor()
        end
    else
        self:mouseMove(x,y,0,0,id)
        if self.swapLock then
            local mx,my=self:getMousePos(x,y)
            if mx then
                local sx,sy=self:getSwapPos(mx,my)
                if sx==self.swapX and math.abs(sy-self.swapY)==1 or sy==self.swapY and math.abs(sx-self.swapX)==1 then
                    if self.settings.multiMove or #self.movingGroups==0 then
                        self:swap('action',self.swapX,self.swapY,sx-self.swapX,sy-self.swapY)
                    end
                else
                    if sx==self.swapX and sy==self.swapY then
                        self:freshSwapCursor()
                    else
                        self.swapX,self.swapY=sx,sy
                    end
                end
            end
        else
            self.swapLock=true
        end
    end
end
function GP:mouseMove(x,y,_,_,_)
    self.mouseX,self.mouseY=self:getMousePos(x,y)

    if self.mouseX then
        if not self.swapLock then
            self:freshSwapCursor()
        end
        self:freshTwistCursor()
    end
end
function GP:mouseUp(_,_,_)
    -- ?
end
function GP:press(act)
    self:triggerEvent('beforePress',act)

    if not self.actions[act] or self.keyState[act] then return end
    self.keyState[act]=true
    ins(self.actionHistory,{0,self.time,act})
    self.actions[act].press(self)

    self:triggerEvent('afterPress',act)
end
function GP:release(act)
    self:triggerEvent('beforeRelease',act)
    if not self.actions[act] or not self.keyState[act] then return end
    self.keyState[act]=false
    ins(self.actionHistory,{1,self.time,act})
    self.actions[act].release(self)
    self:triggerEvent('afterRelease',act)
end
function GP:update(dt)
    local df=floor((self.realTime+dt)*1000)-floor(self.realTime*1000)
    self.realTime=self.realTime+dt
    local SET=self.settings

    for _=1,df do
        -- Step game time
        if self.timing then self.gameTime=self.gameTime+1 end

        self:triggerEvent('always')

        -- Calculate board animation
        local O=self.pos
        --                     sticky           force          soft
        O.vx=expApproach(O.vx,0,.02)-sign(O.dx)*.0001*abs(O.dx)^1.2
        O.vy=expApproach(O.vy,0,.02)-sign(O.dy)*.0001*abs(O.dy)^1.1
        O.va=expApproach(O.va,0,.02)-sign(O.da)*.0001*abs(O.da)^1.0
        O.vk=expApproach(O.vk,0,.01)-sign(O.dk)*.0001*abs(O.dk)^1.0
        O.dx=O.dx+O.vx
        O.dy=O.dy+O.vy
        O.da=O.da+O.va
        O.dk=O.dk+O.vk

        -- Step main time & Starting counter
        if self.time<SET.readyDelay then
            self.time=self.time+1
            local d=SET.readyDelay-self.time
            if floor((d+1)/1000)~=floor(d/1000) then
                self:playSound('countDown',ceil(d/1000))
            end
            if d==0 then
                self:playSound('countDown',0)
                self:triggerEvent('gameStart')
                self.timing=true
            end
        else
            self.time=self.time+1
        end

        -- Auto shift
        if self.moveDirH and (self.moveDirH==-1 and self.keyState.moveLeft or self.moveDirH==1 and self.keyState.moveRight) then
            if self.swapX~=MATH.clamp(self.swapX+self.moveDirH,1,self.settings.fieldSize) then
                local c0=self.moveChargeH
                local c1=c0+1
                self.moveChargeH=c1
                local dist=0
                if c0>=SET.das then
                    c0=c0-SET.das
                    c1=c1-SET.das
                    if SET.arr==0 then
                        dist=1e99
                    else
                        dist=floor(c1/SET.arr)-floor(c0/SET.arr)
                    end
                elseif c1>=SET.das then
                    if SET.arr==0 then
                        dist=1e99
                    else
                        dist=1
                    end
                end
                if dist>0 then
                    local moved
                    local x0=self.swapX
                    self.swapX=MATH.clamp(self.swapX+self.moveDirH*dist,1,self.settings.fieldSize)
                    if self.swapX~=x0 then moved=true end
                    x0=self.twistX
                    self.twistX=MATH.clamp(self.twistX+self.moveDirH*dist,1,self.settings.fieldSize-1)
                    if self.twistX~=x0 then moved=true end
                    if moved then self:playSound('move') end
                end
            else
                self.moveChargeH=SET.das
                self:shakeBoard(self.moveDirH>0 and '-right' or '-left')
            end
        else
            self.moveDirH=self.keyState.moveLeft and -1 or self.keyState.moveRight and 1 or false
            self.moveChargeH=0
        end
        if self.moveDirV and (self.moveDirV==-1 and self.keyState.moveDown or self.moveDirV==1 and self.keyState.moveUp) then
            if self.swapY~=MATH.clamp(self.swapY+self.moveDirV,1,self.settings.fieldSize) then
                local c0=self.moveChargeV
                local c1=c0+1
                self.moveChargeV=c1
                local dist=0
                if c0>=SET.das then
                    c0=c0-SET.das
                    c1=c1-SET.das
                    if SET.arr==0 then
                        dist=1e99
                    else
                        dist=floor(c1/SET.arr)-floor(c0/SET.arr)
                    end
                elseif c1>=SET.das then
                    if SET.arr==0 then
                        dist=1e99
                    else
                        dist=1
                    end
                end
                if dist>0 then
                    local moved
                    local x0=self.swapY
                    self.swapY=MATH.clamp(self.swapY+self.moveDirV*dist,1,self.settings.fieldSize)
                    if self.swapY~=x0 then moved=true end
                    x0=self.twistY
                    self.twistY=MATH.clamp(self.twistY+self.moveDirV*dist,1,self.settings.fieldSize-1)
                    if self.twistY~=x0 then moved=true end
                    if moved then self:playSound('move') end
                end
            else
                self.moveChargeV=SET.das
                self:shakeBoard(self.moveDirV>0 and '-up' or '-down')
            end
        else
            self.moveDirV=self.keyState.moveDown and -1 or self.keyState.moveUp and 1 or false
            self.moveChargeV=0
        end

        local F=self.field
        local size=self.settings.fieldSize
        local needFresh=false
        local touch

        -- Update moveTimer
        for y=1,size do for x=1,size do local g=F[y][x] if g and g.moveTimer then
            g.moveTimer=g.moveTimer-1
            if g.moveTimer<=0 then
                g.moveTimer,g.moveDelay=nil
                g.dx,g.dy=nil
                g.movable=true
                g.checkTimer=self.settings.checkDelay
                needFresh=true
                if g.fall then
                    g.fall=nil
                    touch=true
                end
            end
        end end end

        if touch then self:playSound('touch') end

        -- Update movingGroups
        for i=#self.movingGroups,1,-1 do
            local group=self.movingGroups[i]
            local fin
            local legal=false
            local posList=group.positions
            for n=1,#posList,2 do
                local g=F[posList[n+1]][posList[n]]
                if not g then
                    fin,legal=true,true
                    break
                elseif g.movable then
                    fin=true
                    if self:psedoCheckPos(posList[n],posList[n+1]) then
                        legal=true
                    end
                end
            end
            if fin then
                if group.force and not legal then
                    self[group.mode](self,'auto',unpack(group.args))
                    self:triggerEvent('illegalMove',group.mode)
                else
                    self:triggerEvent('legalMove',group.mode)
                end
                rem(self.movingGroups,i)
            end
        end

        -- Update checkTimer
        for y=1,size do for x=1,size do local g=F[y][x] if g and g.checkTimer then
            g.checkTimer=g.checkTimer-1
            if g.checkTimer<=0 then
                g.checkTimer=nil
                self:checkPosition(x,y)
            end
        end end end

        -- Update clearTimer
        for y=1,size do for x=1,size do local g=F[y][x] if g and g.clearTimer then
            g.clearTimer=g.clearTimer-1
            if g.clearTimer<=0 then
                F[y][x]=false
                needFresh=true
            end
        end end end

        if needFresh then
            self:freshGems()
        end

        -- Update garbage
        for i=1,#self.garbageBuffer do
            local g=self.garbageBuffer[i]
            if g.mode==0 and g.time<g.time0 then
                g.time=g.time+1
            end
        end
    end
    for _,v in next,self.particles do v:update(dt) end
    self.texts:update(dt)
end
function GP:render()
    local settings=self.settings
    local skin=SKIN.get(settings.skin)
    SKIN.time=self.time

    gc.push('transform')

    -- applyPlayerTransform
    gc.translate(self.pos.x,self.pos.y)
    gc.scale(self.pos.k*(1+self.pos.dk))
    gc.translate(self.pos.dx,self.pos.dy)
    gc.rotate(self.pos.a+self.pos.da)

    -- applyFieldTransform
    gc.push('transform')
    gc.translate(-360,360)

    -- startFieldStencil
    GC.stc_setComp()
    GC.stc_rect(0,0,720,-720)
    gc.scale(16/settings.fieldSize)


        self:triggerEvent('drawBelowField')


        -- Grid & Cells
        skin.drawFieldBackground(settings.fieldSize)
        skin.drawFieldCells(self.field)


        self:triggerEvent('drawInField')


    -- stopFieldStencil
    GC.stc_stop()

    -- Particles
    gc.setColor(1,1,1)
    gc.draw(self.particles.star)
    gc.draw(self.particles.trail)

    -- Cursor(s)
    if self.settings.swap then
        skin.drawSwapCursor(self.swapX,self.swapY,self.swapLock)
    end
    if self.settings.twistR then
        skin.drawTwistCursor(self.twistX,self.twistY)
    end

    -- popFieldTransform
    gc.pop()

    -- Field border
    skin.drawFieldBorder()

    -- Garbage buffer
    skin.drawGarbageBuffer(self.garbageBuffer)

    -- Timer
    skin.drawTime(self.gameTime)

    -- Texts
    self.texts:draw()


    self:triggerEvent('drawOnPlayer')


    -- Starting counter
    if self.time<settings.readyDelay then
        skin.drawStartingCounter(settings.readyDelay)
    end

    gc.pop()
end
--------------------------------------------------------------
-- Builder
local baseEnv={
    fieldSize=8,

    readyDelay=3000,
    moveDelay=200,
    checkDelay=200,
    clearDelay=500,
    fallDelay=200,

    atkSys='None',

    colors=7,
    linkLen=3,
    diagonalLinkLen=false,
    refreshCount=0,

    multiMove=false,
    swap=true,
    swapForce=true,
    twistR=false,twistL=false,twistF=false,
    twistForce=false,

    skin='gem_default',

    shakeness=.26,
}
local modeDataMeta={
    __index=function(self,k) rawset(self,k,0) return 0 end,
    __newindex=function(self,k,v) rawset(self,k,v) end,
    __metatable=true,
}
local soundTimeMeta={
    __index=function(self,k) rawset(self,k,0) return -1e99 end,
    __metatable=true,
}
local soundEventMeta={
    __index=defaultSoundFunc,
    __metatable=true,
}
function GP.new()
    local self=setmetatable({},{__index=GP,__metatable=true})
    self.sound=false
    self.settings=TABLE.copy(baseEnv)
    self.event={
        -- Press & Release
        beforePress={},
        afterPress={},
        beforeRelease={},
        afterRelease={},

        -- Start & End
        playerInit={},
        gameStart={},
        gameOver={},

        -- Drop
        legalMove={},
        illegalMove={},

        -- Update
        always={},

        -- Graphics
        drawBelowField={},
        drawBelowBlock={},
        drawBelowMarks={},
        drawInField={},
        drawOnPlayer={},
    }

    return self
end
function GP:loadSettings(settings)
    -- Load data & events from mode settings
    for k,v in next,settings do
        if k=='event' then
            for name,E in next,v do
                assert(self.event[name],"Wrong event key: '"..tostring(name).."'")
                if type(E)=='table' then
                    for i=1,#E do
                        ins(self.event[name],E[i])
                    end
                elseif type(E)=='function' then
                    ins(self.event[name],E)
                end
            end
        elseif k=='soundEvent' then
            for name,E in next,v do
                if type(E)=='function' then
                    self.soundEvent[name]=E
                else
                    error("soundEvent must be function")
                end
            end
        else
            if type(v)=='table' then
                self.settings[k]=TABLE.copy(v)
            elseif v~=nil then
                self.settings[k]=v
            end
        end
    end
end
function GP:initialize()
    self.soundEvent=setmetatable({},soundEventMeta)
    self.modeData=setmetatable({},modeDataMeta)
    self.soundTimeHistory=setmetatable({},soundTimeMeta)

    self.rcvRND=love.math.newRandomGenerator(GAME.seed+434)
    self.seqRND=love.math.newRandomGenerator(GAME.seed+231)

    self.pos={
        x=0,y=0,k=1,a=0,

        dx=0,dy=0,dk=0,da=0,
        vx=0,vy=0,vk=0,va=0,
    }

    self.finished=false -- Did game finish
    self.realTime=0     -- Real time, [float] s
    self.time=0         -- Inside timer for player, [int] ms
    self.gameTime=0     -- Game time of player, [int] ms
    self.timing=false   -- Is gameTime running?

    self.field={}
    for y=1,self.settings.fieldSize do
        self.field[y]=TABLE.new(false,self.settings.fieldSize)
    end
    self:freshGems()

    self.movingGroups={}

    self.mouseX,self.mouseY=false,false
    self.swapX,self.swapY=1,1
    self.swapLock=false
    self.twistX,self.twistY=1,1

    self.moveDirH=-1
    self.moveChargeH=0
    self.moveDirV=1
    self.moveChargeV=0

    self.garbageBuffer={}

    self.actionHistory={}
    self.texts=TEXT.new()

    -- Generate available actions
    do
        self.actions={}
        for k in next,actions do
            self.actions[k]=_getActionObj(k)
        end

        self.keyState={}
        for k in next,self.actions do
            self.keyState[k]=false
        end
    end

    self.particles={}
    for k,v in next,particleTemplate do
        self.particles[k]=v:clone()
    end
end
--------------------------------------------------------------

return GP
