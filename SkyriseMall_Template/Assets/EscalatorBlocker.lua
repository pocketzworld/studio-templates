--!SerializeField
local Top : Transform = nil
--!SerializeField
local Bottom : Transform = nil

local moveRequest = Event.new("MoveRequest")
local moveEvent = Event.new("MoveEvent")


self.ClientAwake = function()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        if(client.localPlayer.character.transform.position.y < self.transform.position.y)then
            moveRequest:FireServer(Top.position)
        else
            moveRequest:FireServer(Bottom.position)
        end
    end)

    moveEvent:Connect(function(player, point)
		local character = player.character
		player.character:MoveTo(point, -1)
	end)
end

self.ServerAwake = function()
    moveRequest:Connect(function(player, point)
	    if not player.character then
			return
		end
		player.character.transform.position = point
		moveEvent:FireAllClients(player, point)
	end)
end