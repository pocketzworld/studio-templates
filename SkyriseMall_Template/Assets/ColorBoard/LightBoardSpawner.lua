--!SerializeField
local prefabToSpawn : GameObject = nil

local BoardState = StringValue.new("BoardState")
local changeColorEvent = Event.new("ChangeColorEvent")
local clearBoardEvent = Event.new("ClearBoardEvent")

local gridSize = {16,16}

self.ClientAwake = function()

    local activeColor = "y"
    local spacing = .2
    local rowOffset = 0
    local Pixels = {}
    PixelCount = 0

    function SpawnGrid()
        for i = 1, gridSize[2] do
            local currentRowOffset = ((i % 2 == 0) and rowOffset or 0)
            for j = 1, gridSize[1] do
                local spawnPosition = Vector3.new(((j - 1) * spacing) + currentRowOffset, (-i + 1) * spacing, 0)
                local newObject = Object.Instantiate(prefabToSpawn)
                local newObjectTran = newObject.transform
                newObjectTran.parent = self.transform
                newObjectTran.localPosition = spawnPosition
                newObjectTran.localEulerAngles = Vector3.new(-180,0,0)
                newObjectTran.localScale = Vector3.new(1,1,1)
                table.insert(Pixels, newObject)
                PixelCount = PixelCount + 1
                newObject:GetComponent("ColorPeg").myIndex = PixelCount
                newObject:GetComponent("ColorPeg").Manager = self.transform
            end
        end
    end

    function UpdateBoard(renderString)
        for i = 1, #Pixels do
            
            local newID = 0
            if(renderString:sub(i,i) == "o") then newID = 0 end
            if(renderString:sub(i,i) == "b") then newID = 1 end
            if(renderString:sub(i,i) == "g") then newID = 2 end
            if(renderString:sub(i,i) == "n") then newID = 3 end
            if(renderString:sub(i,i) == "p") then newID = 4 end
            if(renderString:sub(i,i) == "r") then newID = 5 end
            if(renderString:sub(i,i) == "v") then newID = 6 end
            if(renderString:sub(i,i) == "w") then newID = 7 end
            if(renderString:sub(i,i) == "y") then newID = 8 end
            if(newID ~= 0) then 
                Pixels[i]:GetComponent("ColorPeg").SetPeg(newID) 
            else 
                Pixels[i]:GetComponent("ColorPeg").ClearPeg(newID) 
            end
        end
    end

    function selectColor(color)
        activeColor = color
    end

    function ChangeColor(pegIndex)
        changeColorEvent:FireServer(pegIndex, activeColor)
    end
    function ClearBoard()
        clearBoardEvent:FireServer()
    end

    SpawnGrid()
    BoardState.Changed:Connect(function(newVal, oldVal)
        UpdateBoard(newVal)
    end)
end

self.ServerAwake = function()
    
    function replaceCharAtIndex(str, index, newChar)
        if index == 1 then
            return newChar .. str:sub(2)
        else
            return str:sub(1, index - 1) .. newChar .. str:sub(index + 1, #str)
        end
    end

    local newBoardString = ""
    for i = 1, gridSize[2] do
        for j = 1, gridSize[1] do
            newBoardString = newBoardString .. "o"
        end
    end
    BoardState.value = newBoardString

    changeColorEvent:Connect(function(player, pegIndex, color)
        if(BoardState.value[pegIndex] == color)then
            return
        else
            modifiedString = replaceCharAtIndex(BoardState.value, pegIndex, color)
            BoardState.value = modifiedString
        end
    end)
    clearBoardEvent:Connect(function()
        newBoardString = ""
        for i = 1, gridSize[2] do
            for j = 1, gridSize[1] do
                newBoardString = newBoardString .. "o"
            end
        end
        BoardState.value = newBoardString
    end)
end