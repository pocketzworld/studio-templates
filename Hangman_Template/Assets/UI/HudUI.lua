--!Type(UI)

--!Bind
local tutorialImage : Image = nil

tutorialImage:RegisterPressCallback(function()
    tutorialImage:EnableInClassList("hidden", true)
end)