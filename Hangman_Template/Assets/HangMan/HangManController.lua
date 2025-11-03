-- Hangman Game in Lua

--!SerializeField
local hangMan : GameObject = nil
--!SerializeField
local worldUIObj : GameObject = nil
--!SerializeField
local newClip : AudioShader = nil
--!SerializeField
local wrongClip : AudioShader = nil
--!SerializeField
local savedClip : AudioShader = nil
--!SerializeField
local deadClip : AudioShader = nil
--!SerializeField
local weeheeClip : AudioShader = nil
--!SerializeField
local rightClip : AudioShader = nil

local isRapidFire = false

local anim = nil

local secretWord = ""
local guessedLetters = {}
local guessedLettersTotal = {}
local numAttempts = IntValue.new("NumAttempts", 7)
local currentStatus = StringValue.new("CurrentStatus","")
local currentGuesses = StringValue.new("CurrentGuesses","")

alphabet = {"a", "t", "f", "s", "e", "g", "d"}

local words = require("Words")

local guessRequest = Event.new("GuessRequest")
local setWordRequest = Event.new("SetWordRequest")
local announceGame = Event.new("AnnounceGame")
local wrongGuessEvent = Event.new("WrongGuessEvent")

local worldUI = nil
local myUI = nil

local cooldownTimer1 = nil
local cooldownTimer2 = nil
local canGuess = true

local Tracker = require("PlayerTracker")

-- Function to check if the player has won
function checkWin()
    return currentStatus.value == secretWord
end
-- Function to check if the player has lost
function checkLoss()
    return numAttempts.value <= 1
end

function ActivateRapid()
    if Tracker.GetTokens(client.localPlayer) >= 1 and not isRapidFire then
        myUI.StartMeter(10)
        Tracker.IncrementTokens(-1)
        if cooldownTimer1 then
            cooldownTimer1:Stop()
        end
        if cooldownTimer2 then
            cooldownTimer2:Stop()
        end

        canGuess = true

        isRapidFire = true
        myUI.setCooldown("Rapid Fire!")
        Timer.After(10, function()
            isRapidFire = false
            myUI.setCooldown("Ready!")
        end)
    end
end

-- Main function to run the game
function self:ClientAwake()
    myUI = self.gameObject:GetComponent("AnagramText")
    worldUI = worldUIObj:GetComponent("WorldUi")
    anim = hangMan:GetComponent(Animator)

    myUI.setCooldown("Ready!")

    function CoolDownWarning()
        canGuess = false
        local secondsleft = 5
        myUI.setCooldown("guessing cooldown: " .. tostring(secondsleft))
        cooldownTimer1 = Timer.Every(1, 
        function()
            secondsleft = secondsleft - 1
            myUI.setCooldown("guessing cooldown: " .. tostring(secondsleft))
        end)

        cooldownTimer2 = Timer.After(5, function()
            cooldownTimer1:Stop()
            canGuess = true
            myUI.setCooldown("Ready!")
        end)
    end

    info = nil
    Chat.TextMessageReceivedHandler:Connect(function(channelInfo, player, message)
        if(player == client.localPlayer)then
            if(#message == 1 and message:match("%a"))then
                if canGuess or Tracker.activePlayers == 1 then
                    guessRequest:FireServer(string.lower(message))
                end
            end
        end
        Chat:DisplayTextMessage(channelInfo, player, message)
        info = channelInfo
    end)

    currentStatus.Changed:Connect(function(newVal, oldVal)
        myUI.setText(newVal)
        worldUI.setText(newVal)
        Audio:PlayShader(rightClip)
    end)

    numAttempts.Changed:Connect(function(newVal, oldVal)
        anim:SetInteger("State", newVal)
    end)

    currentGuesses.Changed:Connect(function(newVal, oldVal)
        myUI.SetLetters(newVal)
        worldUI.SetLetters(newVal)

        myUI.setText(currentStatus.value)
        worldUI.setText(currentStatus.value)
    end)

    wrongGuessEvent:Connect(function()
        Audio:PlayShader(wrongClip)
        if Tracker.activePlayers > 1 and isRapidFire == false then
            CoolDownWarning()
        end
    end)

    announceGame:Connect(function(game, word)

        local lastWord = "The word was: " .. word
        myUI.SetLetters(lastWord)
        worldUI.SetLetters(lastWord)

        if game == "win" then
            Audio:PlayShader(savedClip)
            if math.random(1,20) >= 15 then Audio:PlayShader(weeheeClip) end
            local message = "Mr.Hangman Survived!"
            myUI.setText(message)
            worldUI.setText(message)
            Timer.After(4, function()
                Audio:PlayShader(newClip)
                message = "New Word!"
                myUI.setText(message)
                worldUI.setText(message)
                myUI.SetLetters(" ")
                worldUI.SetLetters(" ")
            end)
        else
            Audio:PlayShader(deadClip)
            local message = "Mr.Hangman Died!"
            myUI.setText(message)
            worldUI.setText(message)
            Timer.After(4, function()
                Audio:PlayShader(newClip)
                message = "New Word!"
                myUI.setText(message)
                worldUI.setText(message)
                myUI.SetLetters(" ")
                worldUI.SetLetters(" ")
            end)
        end
    end)
end

function self:ServerAwake()
    math.randomseed(os.time())

    function SetWord()
        secretWord = words.Words[math.random(1,#words.Words)]  -- Change this to set a different secret word
        currentStatus.value = "_" .. string.rep("_", #secretWord - 1)

        numAttempts.value = 7
        guessedLetters = {}
        guessedLettersTotal = {}
        currentGuesses.value = " "
    end
    setWordRequest:Connect(function()
        SetWord()
    end)

    function MakeAttempt(attempt, player)
        local guess = attempt

        local alreadyGuessed = false
    
        for i = 1, #guessedLettersTotal do
            if guessedLettersTotal[i] == guess then
                return
            end
        end

        table.insert(guessedLettersTotal, guess)
        
        -- Check if the guessed letter is in the secret word
        local found = false
        local points = 0
        for i = 1, #secretWord do
            if secretWord:sub(i, i) == guess then
                currentStatus.value = currentStatus.value:sub(1, i - 1) .. guess .. currentStatus.value:sub(i + 1)
                points = points + 1
                found = true
            end
        end

        if found then
            Tracker.AddScoreServer(player, points)
        end
    
        -- If the guessed letter is not in the secret word, decrement attempts
        if not found then
            numAttempts.value = numAttempts.value - 1
            table.insert(guessedLetters, guess)
            -- Add the guessed letter to the list of guessed letters
            local guessesToString = table.concat(guessedLetters)
            currentGuesses.value = guessesToString
            wrongGuessEvent:FireClient(player)
        end
    
        -- Check if the player has won or lost and display appropriate message
        if checkWin() then
            --print("Congratulations! You guessed the word: " .. secretWord)
            announceGame:FireAllClients("win", secretWord)
            Timer.After(5, function()
                    SetWord()
            end)
            return
        elseif checkLoss() then
            --print("Sorry, you've run out of attempts. The word was: " .. secretWord)
            announceGame:FireAllClients("lose", secretWord)
            Timer.After(5, function()
                    SetWord()
            end)
            return
        end
    end

    SetWord()

    guessRequest:Connect(function(player, guess)
        --Client made a guess
        MakeAttempt(guess, player)
    end)
end