--!SerializeField
local Pigeon : GameObject = nil

--!SerializeField
local birdCount : Vector2 = Vector2.new(0,0)
--!SerializeField
local birdBannerCount : Vector2 = Vector2.new(0,0)

--!SerializeField
local spawnRadius : number = 1.35

--!SerializeField
local BannerEP1 : GameObject = nil
--!SerializeField
local BannerEP2 : GameObject = nil

--!SerializeField
local BannerEP3 : GameObject = nil
--!SerializeField
local BannerEP4 : GameObject = nil

birdtotal = 0
bannerBirdtotal = 0

function self:Start()
    SpawnBirds()
    SpawnOnBanner()
end

function SpawnBirds()
    local spawnNum = math.random(birdCount.x,birdCount.y)
    for i=1,spawnNum do
        local newBird = Object.Instantiate(Pigeon)
        local newBirdTrans = newBird.transform
        newBirdTrans.parent = self.transform
        local newPos = Vector3.new(math.random(-spawnRadius,spawnRadius) + math.random(),0,math.random(-spawnRadius,spawnRadius) + math.random())
        newBirdTrans.localPosition = newPos
        --newBird:GetComponent("PigeonScript").RandomRot(true)
        --newBird:GetComponent("PigeonScript").SetStartPos(newPos)
        birdtotal = birdtotal + 1
    end
end

function SpawnOnBanner()
    local spawnNum = math.random(birdBannerCount.x,birdBannerCount.y)
    for i=1,spawnNum do
        local newBird = Object.Instantiate(Pigeon)
        local newBirdTrans = newBird.transform
        newBirdTrans.parent = self.transform
        local newPos = Vector3.new(math.random(BannerEP1.transform.localPosition.x,BannerEP2.transform.localPosition.x) + math.random(),BannerEP1.transform.localPosition.y,BannerEP1.transform.localPosition.z)
        newBirdTrans.localPosition = newPos
        --newBird:GetComponent("PigeonScript").RandomRot(true)
        --newBird:GetComponent("PigeonScript").SetStartPos(newPos)
        bannerBirdtotal = bannerBirdtotal + 1
    end

    local spawnNum2 = math.random(birdBannerCount.x,birdBannerCount.y)
    for i=1,spawnNum2 do
        local newBird = Object.Instantiate(Pigeon)
        local newBirdTrans = newBird.transform
        newBirdTrans.parent = self.transform
        local newPos = Vector3.new(math.random(BannerEP3.transform.localPosition.x + math.random(),BannerEP4.transform.localPosition.x),BannerEP3.transform.localPosition.y,BannerEP3.transform.localPosition.z)
        newBirdTrans.localPosition = newPos
        --newBird:GetComponent("PigeonScript").RandomRot(true)
        --newBird:GetComponent("PigeonScript").SetStartPos(newPos)
        bannerBirdtotal = bannerBirdtotal + 1
    end
end

function UpdateBirdCount(num)
    birdtotal = birdtotal + num
    if(birdtotal < 1)then
        --Birds Empty
        SpawnBirds()
    end
end

function UpdateBannerBirdCount(num)
    bannerBirdtotal = bannerBirdtotal + num
    if(bannerBirdtotal < 1)then
        --Banners Empty
        SpawnOnBanner()
    end
end