local Keypad : GameObject = nil
local On_Mesh : GameObject = nil

Keypad = self.transform.parent.gameObject
On_Mesh = self.gameObject.transform:GetChild(0).gameObject

function ResetKey()  
    On_Mesh:SetActive(false)
end

function self:Start()
    ResetKey()

    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        On_Mesh:SetActive(true)
        Keypad:GetComponent("KeyPadMixer").CheckOrder(self.gameObject)
    end)
end