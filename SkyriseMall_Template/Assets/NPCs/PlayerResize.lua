--!Type(Module)

function ResizePlayer(scale)
    game.PlayerConnected:Connect(function(player)
        player.CharacterChanged:Connect(function(player, character)
            character.renderScale = Vector3.new(scale,scale,scale)
        end)
    end)
end

function self:ClientAwake()
    ResizePlayer(0.8)
end

function self:ServerAwake()
end