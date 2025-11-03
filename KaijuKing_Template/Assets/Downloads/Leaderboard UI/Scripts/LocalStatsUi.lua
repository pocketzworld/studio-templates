--!Type(UI)

--!Bind
local powerCount : UILabel = nil
----!Bind
--local cashCount : UILabel = nil

function SetPowerCount(count: number)
    powerCount:SetPrelocalizedText(tostring(count))
end

--function SetCashCount(count: number)
--    cashCount:SetPrelocalizedText(tostring(count))
--end

SetPowerCount(0)
--SetCashCount(0)