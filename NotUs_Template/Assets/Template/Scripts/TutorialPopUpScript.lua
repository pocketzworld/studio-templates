--!SerializeField
local nextButton : GameObject = nil
--!SerializeField
local skipButton : GameObject = nil
--!SerializeField
local page1 : GameObject = nil
--!SerializeField
local page2 : GameObject = nil
--!SerializeField
local page3: GameObject = nil
--!SerializeField
local page4 : GameObject = nil
--!SerializeField
local page5 : GameObject = nil

local Pages = {page1, page2, page3, page4, page5}

local currentPage = 1
local totalPages = 5

function self:Start()

    function CloseAll()
        Object.Destroy(self.gameObject)
    end

    function PressAnim(obj)
        obj:GetComponent(Animator):SetTrigger('press')
    end

    nextButton:GetComponent(TapHandler).Tapped:Connect(function()
        --NEXT PAGE
        currentPage = currentPage + 1
        for key, value in pairs(Pages) do
            value:SetActive(false)
        end
        if currentPage > totalPages then
            --CLOSE
            CloseAll()
            return
        else
            Pages[currentPage]:SetActive(true)
        end

        PressAnim(nextButton)
    end)

    skipButton:GetComponent(TapHandler).Tapped:Connect(function()
        --CLOSE
        PressAnim(skipButton)
        CloseAll()
    end)
end