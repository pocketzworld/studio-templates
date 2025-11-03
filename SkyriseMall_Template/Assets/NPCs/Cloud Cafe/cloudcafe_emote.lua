--!Type(Client)

static_emotes = {
    "idle-loop-happy"
}

stillPlaying = true

function self:Awake()
    local character = self.gameObject:GetComponent(Character)

    -- random height between .8 and 1.2
    local newScale = math.random(100, 100) / 100
    character.renderScale = Vector3.new(newScale,newScale,1)

    function playEmote()
        character:PlayEmote(static_emotes[math.random(1, #static_emotes)], true, function()
            if stillPlaying then playEmote() end
        end)
    end
    
    playEmote()

end