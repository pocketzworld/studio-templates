--!SerializeField
local playerLostClip : AudioClip = nil
--!SerializeField
local playerWonClip : AudioClip = nil

local gameAudio = require("GameAudio")
local playerManagerScript = require("PlayerManager")

function self:OnTriggerEnter(collider)
    -- The Character and Player info for the one who enters the collider
    if(collider.transform.parent == nil) then return end -- Make sure whatever entered the player Trigger has a parent
    colliderCharacter = collider.transform.parent.gameObject:GetComponent(Character)
    if(colliderCharacter == nil) then return end -- Make sure the parent is a Character
    colliderPlayer = colliderCharacter.player -- Player Info

    --The Character and Player info for the one who owns the collider
    myCharacter = self.transform.parent.gameObject:GetComponent(Character)
    myPlayer = myCharacter.player

    -- Only Register locally if the owner of the trigger is the local player, Only managing when some steps into your own trigger
    if(myPlayer == client.localPlayer)then
        --Now only register if we have more power than the one who entered our trigger
        if(playerManagerScript.players[myPlayer].Power.value > playerManagerScript.players[colliderPlayer].Power.value)then
            --This is the winners client

            --Which ever client has the player with the most power on a collision registers the collision and can send an event to the server, avoiding contradicting server requests.
            --Making the winner of player collision the authority for the server request

            --Add Energy to the winner
            playerManagerScript.AddEnergy(1) --Since the winner of the collision is authoiritative they call the function and therefore get the Energy

            --Destroy/Reset the loser
            playerManagerScript.DestroyPlayer(colliderPlayer)

            --Player victory sound
            gameAudio.playSound(playerWonClip)
            -- ColliderPlayer - the one who lost
            -- myPlayer - the one who won, and also the local
        elseif(playerManagerScript.players[myPlayer].Power.value < playerManagerScript.players[colliderPlayer].Power.value)then -- a new if rather than just else because we still want to ignore a tie
            -- This is the loosers client

            --Player lost sound
            gameAudio.playSound(playerLostClip)
        end
    end
end