--!SerializeField
local ScanButton : GameObject = nil
--!SerializeField
local TaskManager : GameObject = nil
--!SerializeField
local playrManager : GameObject = nil

--!SerializeField
local Indicator : GameObject = nil

--!SerializeField
local completeSound : AudioClip = nil
--!SerializeField
local scanSound : AudioClip = nil
--!SerializeField
local errorSound : AudioClip = nil

local taskCompleteRequest = Event.new("TaskCompleteRequest")
local taskCompleteEvent = Event.new("TaskCompleteEvent")

local ScanTime : number = 3
local Scanning : boolean = false
local hasPlayer = false

local enabled = true

function self:ClientStart()

    local playerManagerScript = playrManager:GetComponent("PlayerManager")
    local audioPlayer = self:GetComponent(AudioSource)

    function self:OnTriggerEnter(other : Collider)
        if(other.gameObject == client.localPlayer.character.gameObject) then
            --Local Player Triggered
            hasPlayer = true
        end
    end
    function self:OnTriggerExit(other : Collider)
        if(other.gameObject == client.localPlayer.character.gameObject) then
            --Local Player Triggered
            hasPlayer = false
        end
    end

    ScanButton.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        if(enabled)then
            if(hasPlayer)then
                self.gameObject:GetComponent(Animator):SetTrigger("Scan")
                Scanning = true
                audioPlayer:PlayOneShot(scanSound)
            else
                audioPlayer:PlayOneShot(errorSound)
            end
        end
    end)

    function Cancel()
        print("Scan Task Canceled!!")
        ScanTime = 3
        Scanning = false
        audioPlayer:PlayOneShot(errorSound, 0.5)
    end
    function Complete(player)
        if((client.localPlayer.name == player.name))then
            print("Scan TASK Completed by " .. player.name)
            ScanTime = 3
            Scanning = false
            TaskManager:GetComponent("TaskMaster").UpdateTaskCount()
            Indicator:SetActive(false)
            enabled = false
            audioPlayer:PlayOneShot(completeSound)
        end
    end

    taskCompleteEvent:Connect(function(player)
        Complete(player)
    end)

    playerManagerScript.gameState.Changed:Connect(function(newVal, oldVal)
        if(newVal == 0) then
            enabled = true
            Indicator:SetActive(true)
        end
    end)

end

function self:ClientUpdate()
    if(Scanning == true) then
        if (ScanTime > 0) then
            if(hasPlayer)then
                ScanTime = ScanTime - Time.deltaTime
            else
                Cancel()
            end
        else
            taskCompleteRequest:FireServer(player)
            Scanning = false
        end
    end
end

function self:ServerAwake()
    taskCompleteRequest:Connect(function(player)
        taskCompleteEvent:FireAllClients(player)
    end)
end