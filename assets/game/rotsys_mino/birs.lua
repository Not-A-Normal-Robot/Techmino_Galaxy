local BiRS={}
BiRS.centerPreset='common'
BiRS.centerTex=GC.load{10,10,
    {'setCL',1,1,1,.6},
    {'fRect',0,3,10,4},
    {'fRect',3,0,4,10},
    {'setCL',1,1,1},
    {'fRect',1,4,8,2},
    {'fRect',4,1,2,8},
    {'fRect',3,3,4,4},
}

local R={'+0+0','-1+0','-1-1','+0-1','-1+1','+1-1','+1+0','+0+1','+1+1','+0+2','-1+2','+1+2','-2+0','+2+0'}
local L={'+0+0','+1+0','+1-1','+0-1','+1+1','-1-1','-1+0','+0+1','-1+1','+0+2','+1+2','-1+2','+2+0','-2+0'}
local F={'+0+0','+0-1','+0+1','+0+2'}
for i=1,#R do R[i]=minoRotSys._strToVec(R[i]) end
for i=1,#L do L[i]=minoRotSys._strToVec(L[i]) end
for i=1,#F do F[i]=minoRotSys._strToVec(F[i]) end
local list={
    {[02]=L,[20]=R,[13]=R,[31]=L},-- Z
    {[02]=R,[20]=L,[13]=L,[31]=R},-- S
    {[02]=L,[20]=R,[13]=L,[31]=R},-- J
    {[02]=R,[20]=L,[13]=L,[31]=R},-- L
    {[02]=F,[20]=F,[13]=L,[31]=R},-- T
    {[02]=F,[20]=F,[13]=F,[31]=F},-- O
    {[02]=F,[20]=F,[13]=R,[31]=L},-- I

    {[02]=L,[20]=L,[13]=R,[31]=R},-- Z5
    {[02]=R,[20]=R,[13]=L,[31]=L},-- S5
    {[02]=L,[20]=R,[13]=L,[31]=R},-- P
    {[02]=R,[20]=L,[13]=R,[31]=L},-- Q
    {[02]=R,[20]=L,[13]=L,[31]=R},-- F
    {[02]=L,[20]=R,[13]=R,[31]=L},-- E
    {[02]=F,[20]=F,[13]=L,[31]=R},-- T5
    {[02]=F,[20]=F,[13]=L,[31]=R},-- U
    {[02]=R,[20]=L,[13]=L,[31]=R},-- V
    {[02]=R,[20]=L,[13]=L,[31]=R},-- W
    {[02]=F,[20]=F,[13]=F,[31]=F},-- X
    {[02]=L,[20]=R,[13]=R,[31]=L},-- J5
    {[02]=R,[20]=L,[13]=L,[31]=R},-- L5
    {[02]=L,[20]=R,[13]=R,[31]=L},-- R
    {[02]=R,[20]=L,[13]=L,[31]=R},-- Y
    {[02]=L,[20]=R,[13]=R,[31]=L},-- N
    {[02]=R,[20]=L,[13]=L,[31]=R},-- H
    {[02]=F,[20]=F,[13]=F,[31]=F},-- I5

    {[02]=F,[20]=F,[13]=F,[31]=F},-- I3
    {[02]=R,[20]=L,[13]=L,[31]=R},-- C
    {[02]=F,[20]=F,[13]=R,[31]=L},-- I2
    {[02]=F,[20]=F,[13]=F,[31]=F},-- O1
}
for i=1,29 do
    local a,b=R,L
    if i==6 or i==18 then a,b=b,a end
    list[i][01]=a; list[i][10]=b; list[i][03]=b; list[i][30]=a
    list[i][12]=a; list[i][21]=b; list[i][32]=b; list[i][23]=a
end
local function r(self,dir)
    local C=self.hand

    local icb=TABLE.rotate(C.matrix,dir)
    local idir=(C.direction+(dir=='R' and 1 or dir=='L' and 3 or 2))%4

    local kickList=list[C.shape][C.direction*10+idir]

    local nx,ny do
        local oldSC=minoRotSys.BiRS[C.shape][C.direction].center
        local newSC=minoRotSys.BiRS[C.shape][idir].center
        nx,ny=self.handX+oldSC[1]-newSC[1],self.handY+oldSC[2]-newSC[2]
    end
    local dx,dy=0,0 do
        if self.keyState.moveLeft  and self:ifoverlap(C.matrix,self.handX-1,self.handY) then dx=dx-1 end
        if self.keyState.moveRight and self:ifoverlap(C.matrix,self.handX+1,self.handY) then dx=dx+1 end
        if self.keyState.softDrop  and self:ifoverlap(C.matrix,self.handX,self.handY-1) then dy=  -1 end
    end

    while true do
        for test=1,#kickList do
            local fdx,fdy=kickList[test][1]+dx,kickList[test][2]+dy
            if
                (dx==0 or dx*fdx>0) and
                (dy+.5)*fdy>=0 and
                fdx^2+fdy^2<=5
            then
                local ix,iy=nx+fdx,ny+fdy
                if not self:ifoverlap(icb,ix,iy) then
                    C.matrix=icb
                    C.direction=idir
                    self:moveHand('rotate',ix,iy,dir)
                    self:freshGhost()
                    return
                end
            end
        end

        -- Try release left/right, then release softdrop, then give up
        if dx~=0 then
            dx=0
        elseif dy~=0 then
            dy=0
        else
            break
        end
    end

    -- Failed to rotate
    self:freshDelay('rotate')
    self:playSound('rotate_failed')
end

local t={[0]={},[1]={},[2]={},[3]={},rotate=r}
for i=1,29 do BiRS[i]=t end

return BiRS
