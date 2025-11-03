function self:ClientStart()
	Chat.PlayerJoinedChannel:Connect(function(channelInfo, player)
		if player == client.localPlayer then
			general = channelInfo
			Chat:SetDefaultChannel(general)
		end
	end)

	
	Chat.TextMessageReceivedHandler:Connect(function(channelInfo, player, message)
        Chat:DisplayTextMessage(channelInfo, player, message)
	end)
end