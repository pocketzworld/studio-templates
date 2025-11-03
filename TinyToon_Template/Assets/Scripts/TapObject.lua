--!Type(Client)

--!SerializeField
local _vibrateTap : AudioShader = nil

--!SerializeField
local _tapSound : AudioShader = nil

local _tapHandler : TapHandler = nil

local function PlayHaptic(haptic: AudioShader)
  if (haptic) then
      Audio:PlayShader(haptic)
  end
end

local function PlayTapFeedback()
  if (_tapSound) then
      Audio:PlaySound(_tapSound, self.gameObject, 1, 1, false, false)
  end

  PlayHaptic(_vibrateTap)

  --play squish animation
  local currentScale = self.transform.localScale
  local targetScale = currentScale * 1.05
  self.transform:TweenLocalScale(currentScale, targetScale)
      :Duration(0.1)
      :PingPong()
      :Play()
end

local function OnTapped()
  PlayTapFeedback()
end

function self:Awake()
  _tapHandler = self.gameObject:GetComponent(TapHandler)
  _tapHandler.Tapped:Connect(OnTapped)
end