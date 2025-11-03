--!SerializeField
local viewCamera : GameObject = nil
--!SerializeField
local mainCam : GameObject = nil
local focused = false


function self:Start()
    mainCam = GameObject.FindGameObjectWithTag("MainCamera")
end

self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    focused = true
    mainCam.gameObject:SetActive(false)
    viewCamera:SetActive(true)
end)

Input.PinchOrDragBegan:Connect(function(evt)
    if(focused)then
        viewCamera:SetActive(false)
        mainCam.gameObject:SetActive(true)
        focused = false
    end
end)