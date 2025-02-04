minoRotSys={}

minoRotSys._defaultCenterTex=GC.load{1,1}-- No texture
minoRotSys._defaultCenterPos={
    common={-- For SRS-like RSs
        -- Tetromino
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- Z
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- S
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- J
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- L
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- T
        {[0]={1,1},     [1]={1,1},     [2]={1,1},     [3]={1,1}     },-- O
        {[0]={2,0},     [1]={0,2},     [2]={2,1},     [3]={1,2}     },-- I

        -- Pentomino
        {[0]={1.5,1.5}, [1]={1.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- Z5
        {[0]={1.5,1.5}, [1]={1.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- S5
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- P
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- Q
        {[0]={1.5,1.5}, [1]={1.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- F
        {[0]={1.5,1.5}, [1]={1.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- E
        {[0]={1.5,1.5}, [1]={1.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- T5
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- U
        {[0]={2,1},     [1]={1,1},     [2]={1,2},     [3]={2,2}     },-- V
        {[0]={1.5,1.5}, [1]={1.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- W
        {[0]={1.5,1.5}, [1]={1.5,1.5}, [2]={1.5,1.5}, [3]={1.5,1.5} },-- X

        {[0]={2,1},     [1]={1,2},     [2]={2,1},     [3]={1,2}     },-- J5
        {[0]={2,1},     [1]={1,2},     [2]={2,1},     [3]={1,2}     },-- L5
        {[0]={2,1},     [1]={1,2},     [2]={2,1},     [3]={1,2}     },-- R
        {[0]={2,1},     [1]={1,2},     [2]={2,1},     [3]={1,2}     },-- Y
        {[0]={2,1},     [1]={1,2},     [2]={2,1},     [3]={1,2}     },-- N
        {[0]={2,1},     [1]={1,2},     [2]={2,1},     [3]={1,2}     },-- H
        {[0]={2.5,0.5}, [1]={0.5,2.5}, [2]={2.5,0.5}, [3]={0.5,2.5} },-- I5

        -- Trimino
        {[0]={1.5,0.5}, [1]={0.5,1.5}, [2]={1.5,0.5}, [3]={0.5,1.5} },-- I3
        {[0]={1,1},     [1]={1,1},     [2]={1,1},     [3]={1,1}     },-- C

        -- Domino
        {[0]={1,0},     [1]={0,1},     [2]={1,1},     [3]={1,1}     },-- I2

        -- Dot
        {[0]={0.5,0.5}, [1]={0.5,0.5}, [2]={0.5,0.5}, [3]={0.5,0.5} },-- O1
    },
}

function minoRotSys._strToVec(vecStr)
    return {tonumber(vecStr:sub(1,2)),tonumber(vecStr:sub(3,4))}
end

function minoRotSys._normalizeKick(data,dir,fdir)
    local kick=data[dir][fdir]
    if kick then
        assert(type(kick)=='table',"KICK must be a table")

        if kick.base then kick.base=minoRotSys._strToVec(kick.base) end
        if not kick.test then kick.test={'+0+0'} end
        if not kick.target then
            kick.target=(dir+(
                fdir=='R' and 1 or
                fdir=='L' and 3 or
                fdir=='F' and 2
            ))%4
        end

        assert(data[kick.target],"Target state ["..kick.target.."] not exist")
        assert(type(kick.test)=='table','[KICK].test must be a table')

        for i=1,#kick.test do
            if type(kick.test[i])~='table' then
                assert(type(kick.test[i])=='string','test[n] must be vecStr')
                kick.test[i]=minoRotSys._strToVec(kick.test[i])
            end
        end
    end
end

-- Use this to copy a symmetry set
function minoRotSys._flipList(O)
    if not O then return end
    local L={}
    for i,s in next,O do
        L[i]=(s:sub(1,1)=='+' and '-' or '+')..s:sub(2)
    end
    return L
end

function minoRotSys._reflect(m)-- Only available for 4/2/1 state minoes
    local m2=TABLE.copy(m)
    if m2[0] and m2[1] and m2[2] and m2[3] then
        m2[0].R.test,m2[0].L.test,m2[0].F.test,
        m2[1].R.test,m2[1].L.test,m2[1].F.test,
        m2[2].R.test,m2[2].L.test,m2[2].F.test,
        m2[3].R.test,m2[3].L.test,m2[3].F.test=
        minoRotSys._flipList(m2[0].L.test),minoRotSys._flipList(m2[0].R.test),minoRotSys._flipList(m2[0].F.test),
        minoRotSys._flipList(m2[3].L.test),minoRotSys._flipList(m2[3].R.test),minoRotSys._flipList(m2[3].F.test),
        minoRotSys._flipList(m2[2].L.test),minoRotSys._flipList(m2[2].R.test),minoRotSys._flipList(m2[2].F.test),
        minoRotSys._flipList(m2[1].L.test),minoRotSys._flipList(m2[1].R.test),minoRotSys._flipList(m2[1].F.test);
    elseif m2[0] and m2[1] then
        m2[0].R.test,m2[0].L.test,m2[0].F.test,
        m2[1].R.test,m2[1].L.test,m2[1].F.test=
        minoRotSys._flipList(m2[0].L.test),minoRotSys._flipList(m2[0].R.test),minoRotSys._flipList(m2[0].F.test),
        minoRotSys._flipList(m2[1].L.test),minoRotSys._flipList(m2[1].R.test),minoRotSys._flipList(m2[1].F.test);
    elseif m2[0] then
        m2[0].R.test,m2[0].L.test,m2[0].F.test=minoRotSys._flipList(m2[0].L.test),minoRotSys._flipList(m2[0].R.test),minoRotSys._flipList(m2[0].F.test)
    else
        error("wtf no minoData[0] to reflect")
    end
    return m2
end

love.graphics.setDefaultFilter('nearest','nearest')
minoRotSys.None=     require'assets.game.rotsys_mino.none'
minoRotSys.TRS=      require'assets.game.rotsys_mino.trs'
minoRotSys.SRS=      require'assets.game.rotsys_mino.srs'
minoRotSys.SRS_plus= require'assets.game.rotsys_mino.srs_plus'
minoRotSys.BiRS=     require'assets.game.rotsys_mino.birs'
minoRotSys.C2_plus=  require'assets.game.rotsys_mino.c2_plus'
minoRotSys.Classic=  require'assets.game.rotsys_mino.classic'
minoRotSys.ASC_plus= require'assets.game.rotsys_mino.asc_plus'
minoRotSys.ARS_plus= require'assets.game.rotsys_mino.ars_plus'
minoRotSys.DRS_weak= require'assets.game.rotsys_mino.drs_weak'
love.graphics.setDefaultFilter('linear','linear')

for name,rs in next,minoRotSys do
    if type(name)=='string' and name:sub(1,1)~='_' and type(rs)=='table' then
        for i=1,29 do
            if not rs[i] then
                rs[i]=minoRotSys.None[i]
            end
        end

        rs=TABLE.copy(rs)

        if not rs.centerTex then rs.centerTex=minoRotSys._defaultCenterTex end
        if rs.centerPreset then
            local set=minoRotSys._defaultCenterPos[rs.centerPreset]
            for i=1,29 do
                if type(rs[i])=='table' then
                    local minoData=rs[i]
                    for dir,state in next,minoData do
                        if type(state)=='table' and state.center==nil then
                            if not set[i][dir] then
                                error("Preset '"..rs.centerPreset.."' has no center for RS '"..name.."', mino "..i..", dir "..dir)
                            end
                            state.center=TABLE.copy(set[i][dir])
                        end
                    end
                end
            end
        end

        -- Make all string vec to the same table vec
        for shapeID,minoData in next,rs do
            if type(shapeID)=='number' then
                assert(type(minoData)=='table','minoData must be table')
                if minoData.rotate then
                    assert(type(minoData.rotate)=='function',"minoData.rotate must be function if exist")
                    assert(minoData.center==nil or type(minoData.center)=='function',"minoData.center must be function if exist")
                end
                for dir in next,minoData do
                    if type(dir)=='number' then
                        minoRotSys._normalizeKick(minoData,dir,'R')
                        minoRotSys._normalizeKick(minoData,dir,'L')
                        minoRotSys._normalizeKick(minoData,dir,'F')
                    end
                end
            end
        end

    end
    minoRotSys[name]=rs
end
