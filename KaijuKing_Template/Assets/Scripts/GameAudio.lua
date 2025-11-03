local audioSrc = nil
function playSound(clip)
    if(audioSrc == nil) then
        audioSrc = self.gameObject:AddComponent(AudioSource)
        audioSrc:PlayOneShot(clip)
    else
        audioSrc:PlayOneShot(clip)
    end
end