return {
    initialize=function()
        GAME.newPlayer(1,'mino')
        GAME.newPlayer(2,'mino')
        GAME.newPlayer(3,'puyo')
        GAME.setMain(1)
        playBgm('battle','base')
    end,
    settings={
        mino={
            dropDelay=1000,
            lockDelay=1000,
            atkSys='modern',
        },
        puyo={
            dropDelay=1500,
            lockDelay=1500,
        }
    },
    checkFinish=function()
        return #GAME.playerList==1
    end,
}
