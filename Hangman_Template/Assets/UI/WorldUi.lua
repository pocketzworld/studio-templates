--!Type(UI)

--!Bind
local anagramTextWorld : UILabel = nil
--!Bind
local usedLettersWorld : UILabel = nil

function setText(text)
    anagramTextWorld:SetPrelocalizedText(text)
end

function SetLetters(text)
    usedLettersWorld:SetPrelocalizedText(text)
end