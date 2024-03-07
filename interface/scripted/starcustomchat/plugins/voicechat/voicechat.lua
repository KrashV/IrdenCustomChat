require "/interface/scripted/starcustomchat/plugin.lua"

voicechat = PluginClass:new(
  { name = "voicechat" }
)

function voicechat:init()
  self:_loadConfig()
  voice.setEnabled(widget.getChecked("btnCkVoice"))
end

function voicechat:onModeToggle(button, isChecked)
  if button == "btnCkVoice" then
    voice.setEnabled(isChecked)
  end
end