--!Type(UI)

--!Bind
local anagramText : UILabel = nil
--!Bind
local usedLetters : UILabel = nil
--!Bind
local cooldown : UILabel = nil

--!Bind
local rapidFireButton : UIButton = nil
--!Bind
local rapidSlider : UISlider = nil

local Tracker = require("PlayerTracker")
local HangmanController = require("HangManController")

function setText(text)
    anagramText:SetPrelocalizedText(text)
end

function SetLetters(text)
    usedLetters:SetPrelocalizedText(text)
end

function setCooldown(text)
    cooldown:SetPrelocalizedText(text)
end


----------------- SLIDER CONTROLS ---------------------

rapidSlider.lowValue, rapidSlider.highValue = 0, 100

function UpdateMeter(arg)
    rapidSlider:SetValueWithoutNotify(arg)
end

-- Variables for meter control
local runDuration = 10
local elapsedTime = 0
local value = 0
local running = false

-- Function to start the meter with specified durations
function StartMeter(duration)
    runDuration = duration
    elapsedTime = 0
    value = 0
    running = true
    rapidSlider:EnableInClassList("hidden", false)
end

-- Function to cancel the meter
function CancelMeter()
    elapsedTime = 0
    value = 0
    running = false
    UpdateMeter(0)
    rapidSlider:EnableInClassList("hidden", true)
end

rapidFireButton:RegisterPressCallback(function()
    --ENABLE RAPID FIRE
    HangmanController.ActivateRapid()
end, true, true, true)

-- Function called when the script starts
function self:Start()
    UpdateMeter(0)
    rapidSlider:EnableInClassList("hidden", true)
end

-- Function called every frame
function self:Update()
    -- Update the meter if it's running
    if running then
        elapsedTime = elapsedTime + Time.deltaTime

        local t = Mathf.Clamp01(elapsedTime / runDuration)
        value = Mathf.Lerp(1.0, 0.0, t)

        UpdateMeter(value * 100)

        if t >= 1 then
            t = 1
            running = false
            elapsedTime = 0
            rapidSlider:EnableInClassList("hidden", true)
        end
    end
end
