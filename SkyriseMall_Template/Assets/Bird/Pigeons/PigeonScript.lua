--!SerializeField
local Poop : GameObject = nil
--!SerializeField
local FlyDirTransform : GameObject = nil
--!SerializeField
local RandomizeRot : boolean = true

local Speed = 8

local spooked = false

local lifeTime = 8
local currentLifeTime = lifeTime

local myTransform = self.transform
local spawnPos = Vector3.new(0,0,0)

bannerbird = false

function SetStartPos(newPos)
    spawnPos = newPos
end 

function RandomRot(randRot)
    if(randRot)then self.transform.localEulerAngles = Vector3.new(0,math.random(-135,-45),0) end
end

RandomRot(RandomizeRot)

function self:OnTriggerEnter(other : Collider)
    if(self.transform.localPosition.y > 1) then
        Poop.transform.parent = self.transform.parent
        Poop.transform.localScale = Vector3.new(1,1,1)
        Poop:GetComponent(ParticleSystem):Play()
        Poop:GetComponent(AudioSource):PlayDelayed(0.75)
        bannerbird = true
    end
    spooked = true
    self.gameObject:GetComponent(AudioSource):Play()
end

function self:Update()
    if(spooked) then 
        self.gameObject:GetComponent(Animator):SetTrigger("Spooked")
        myTransform.position = myTransform.position + FlyDirTransform.transform.forward * Speed * Time.deltaTime
        currentLifeTime = currentLifeTime - Time.deltaTime 

        if(currentLifeTime < 0) then 
            spooked = false
            if(bannerbird)then
                self.transform.parent:GetComponent("PigeonSpawner").UpdateBirdCount(-1)
            else
                self.transform.parent:GetComponent("PigeonSpawner").UpdateBannerBirdCount(-1)
            end
            Object.Destroy(self.gameObject)
        end
    end
end