--!SerializeField
local myShopIndicator: GameObject = nil
--!SerializeField
local Cam : GameObject = nil
--!SerializeField
local MainMaskVis : LayerMask = nil
--!SerializeField
local MainMaskClick : LayerMask = nil
--!SerializeField
local MyMask : LayerMask = nil
--!SerializeField
local myLayerName : string = "Default"

local AvatarController = require("PlayerCharacterController")
function self:Start()
    AvatarController.options.tapMask = MainMaskClick
end

function SetAvatarMask(other, layerName)
    other.transform.parent.gameObject:GetComponent(Character).renderLayer = LayerMask.NameToLayer(layerName)
end

function self:OnTriggerEnter(other : Collider)
    if (other.gameObject.tag == "localPlayer") then
        Cam:GetComponent(Camera).cullingMask = MyMask
        AvatarController.options.tapMask = MyMask
        myShopIndicator:SetActive(true)
    end
    SetAvatarMask(other, myLayerName)
end

function self:OnTriggerExit(other : Collider)
    if (other.gameObject.tag == "localPlayer") then
        Cam:GetComponent(Camera).cullingMask = MainMaskVis
        AvatarController.options.tapMask = MainMaskClick
        myShopIndicator:SetActive(false)
    end
    SetAvatarMask(other, "Default")
end