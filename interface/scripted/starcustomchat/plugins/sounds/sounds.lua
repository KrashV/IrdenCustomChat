require "/interface/scripted/starcustomchat/plugin.lua"

local shared = getmetatable('').shared
if type(shared) ~= "table" then
  shared = {}
  getmetatable('').shared = shared
end

sounds = PluginClass:new(
  { name = "sounds" }
)

function sounds:init()
  self:_loadConfig()

  self.allRaceSounds = root.assetJson("/npcs/base.npctype")["scriptConfig"]["chatSounds"]
  local currentRaceSounds = self.allRaceSounds[player.species()] or self.allRaceSounds["human"]

  self.soundsPool = currentRaceSounds[player.gender()] 
  self.soundsEnabled = root.getConfiguration("scc_sounds_enabled") or false
  self.soundPitch = player.getProperty("scc_sound_pitch") or 1
  status.addPersistentEffect("scctalking", "scctalking")
end

function sounds:onSendMessage()
  if self.soundsEnabled then
    local soundTable = {
      pool = self.soundsPool,
      pitch = self.soundPitch,
      volume = 1.3
    }
    if not shared.sccTalkingSound then
      status.addPersistentEffect("scctalking", "scctalking")
    end
    shared.sccTalkingSound(soundTable)
  end
end

function sounds:onSettingsUpdate()
  self.soundsEnabled = root.getConfiguration("scc_sounds_enabled") or false
  self.soundPitch = player.getProperty("scc_sound_pitch") or 1
  self.soundsPool = self.allRaceSounds[player.getProperty("scc_sound_species") or player.species()][player.gender()]
end

function sounds:uninit()
  status.clearPersistentEffects("scctalking")
end