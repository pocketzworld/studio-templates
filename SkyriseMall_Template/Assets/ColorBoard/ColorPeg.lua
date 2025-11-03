--!SerializeField
local pegB : GameObject = nil
--!SerializeField
local pegG : GameObject = nil
--!SerializeField
local pegO : GameObject = nil
--!SerializeField
local pegP : GameObject = nil
--!SerializeField
local pegR : GameObject = nil
--!SerializeField
local pegV : GameObject = nil
--!SerializeField
local pegW : GameObject = nil
--!SerializeField
local pegY : GameObject = nil

myIndex = 1

local colorStrings = {"o","b","g","n","p","r","v","w","y"}

local pegs = {pegB,pegG,pegO,pegP,pegR,pegV,pegW,pegY}
local On = false

function SetPeg(pegID)
    if(On)then
        ClearPeg()
        On = false
    end
    local spawnPosition = Vector3.new(0,0,0)
    local newObject = Object.Instantiate(pegs[pegID])
    local newObjectTransform = newObject.transform
    newObjectTransform.parent = self.transform
    newObjectTransform.localPosition = spawnPosition
    newObjectTransform.localEulerAngles = Vector3.new(0,0,0)
    newObjectTransform.localScale = Vector3.new(100,100,23)
    On = true
end

function ClearPeg()
    if(self.transform.childCount > 0) then
        Object.Destroy(self.transform:GetChild(0).gameObject)
    end
end

self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    self.transform.parent.gameObject:GetComponent("LightBoardSpawner").ChangeColor(myIndex)
    local As = self.transform.parent.gameObject:GetComponent(AudioSource)
    As.pitch = .8
    As:Play()
end)