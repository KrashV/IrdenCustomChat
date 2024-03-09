require "/interface/scripted/starcustomchatsettings/settingsplugin.lua"

mainchat = SettingsPluginClass:new(
  { name = "mainchat" }
)

function mainchat:init()
  self:_loadConfig()

  self.backImage = self.chatConfig.icons.empty
  self.frameImage = self.chatConfig.icons.frame
  self.proximityRadius = self.chatConfig.proximityRadius
  self.defaultPortraitSettings = {
    offset = self.chatConfig.defaultPortraitOffset,
    scale = self.chatConfig.defaultPortraitScale
  }
  self.chatMode = root.getConfiguration("iccMode") or "modern"
  self.currentLanguage = root.getConfiguration("iccLocale") or "en"
  self.portraitSettings = player.getProperty("icc_portrait_settings") or self.defaultPortraitSettings

  self.fontSize = root.getConfiguration("icc_font_size") or self.chatConfig.fontSize
  self.maxCharactersAllowed = root.getConfiguration("icc_max_allowed_characters") or 0

  self.portraitCanvas = widget.bindCanvas(self.layoutWidget .. ".portraitCanvas")

  self:drawCharacter()
  self.availableLocales = root.assetJson("/interface/scripted/starcustomchat/languages/locales.json")
  self.availableModes = {"compact", "modern"}

  
  widget.setSliderRange(self.layoutWidget .. ".sldFontSize", 0, 4, 1)
  widget.setSliderValue(self.layoutWidget .. ".sldFontSize", self.fontSize - 6)

  self.maxCharactersStep = 300
  widget.setSliderRange(self.layoutWidget .. ".sldMessageLength", 0, 10, 1)
  widget.setSliderValue(self.layoutWidget .. ".sldMessageLength", self.maxCharactersAllowed // self.maxCharactersStep)

  widget.setText(self.layoutWidget .. ".lblFontSizeValue", self.fontSize)
  widget.setText(self.layoutWidget .. ".lblMessageLengthValue", self.maxCharactersAllowed)

  self.portraitAnchor = false
end

function mainchat:cursorOverride(screenPosition)
  if widget.active(self.layoutWidget) then
    if self.portraitAnchor then
      local currentPos = self.portraitCanvas:mousePosition()
      local diff = vec2.sub(currentPos, self.portraitAnchor)

      -- We believe that both the canvas and the crop area are squares

      self.portraitSettings.offset = {
        util.clamp(math.floor(diff[1]), -120, 120),
        util.clamp(math.floor(diff[2]), -120, 120)
      }
      self:drawCharacter()
    end
    
    for _, event in ipairs(input.events()) do
      if event.type == "MouseWheel" and widget.inMember(self.layoutWidget .. ".portraitCanvas", screenPosition) then
        self.portraitSettings.scale = util.clamp(self.portraitSettings.scale + event.data.mouseWheel / 2, 2, 4)
        save()
        self:drawCharacter()
      end
    end
  end
end

function mainchat:save()
  player.setProperty("icc_portrait_settings", {
    offset = self.portraitSettings.offset,
    scale = self.portraitSettings.scale
  })
end

function mainchat:onLocaleChange(localeConfig)
  widget.setText(self.layoutWidget .. ".btnLanguage", starcustomchat.utils.getTranslation("name"))
  widget.setText(self.layoutWidget .. ".btnMode", starcustomchat.utils.getTranslation("settings.modes." .. self.chatMode))
  widget.setText(self.layoutWidget .. ".lblFontSizeHint", starcustomchat.utils.getTranslation("settings.font_size"))
  widget.setText(self.layoutWidget .. ".lblMessageLengthHint", starcustomchat.utils.getTranslation("settings.chat_collapse"))
  widget.setText(self.layoutWidget .. ".btnDeleteChat", starcustomchat.utils.getTranslation("settings.clear_chat_history"))
  widget.setText(self.layoutWidget .. ".btnResetAvatar", starcustomchat.utils.getTranslation("settings.reset_avatar"))
end

-- Utility function: return the index of a value in the given array
function index(tab, value)
  for k, v in ipairs(tab) do
    if v == value then return k end
  end
  return 0
end

function mainchat:resetAvatar()
  
  self.portraitSettings.offset = self.defaultPortraitSettings.offset
  self.portraitSettings.scale = self.defaultPortraitSettings.scale
  self:drawCharacter()
  save()
end

function mainchat:drawCharacter()
  self.portraitCanvas:clear()
  local canvasPosition = widget.getPosition(self.layoutWidget .. ".portraitCanvas")
  local canvasSize =  self.portraitCanvas:size()
  local backImageSize = root.imageSize(self.backImage)
  self.portraitCanvas:drawImageRect(self.backImage, {0, 0, backImageSize[1], backImageSize[2]}, 
    {0, 0, canvasSize[1], canvasSize[2]})

  local portrait = starcustomchat.utils.clearPortraitFromInvisibleLayers(world.entityPortrait(player.id(), "full"))

  for _, layer in ipairs(portrait) do
    self.portraitCanvas:drawImage(layer.image, self.portraitSettings.offset, self.portraitSettings.scale)
  end
  self.portraitCanvas:drawImageRect(self.frameImage, {0, 0, backImageSize[1], backImageSize[2]}, 
    {0, 0, canvasSize[1], canvasSize[2]})
end

function mainchat:changeLanguage()
  local i = index(self.availableLocales, self.currentLanguage)
  self.currentLanguage = self.availableLocales[(i % #self.availableLocales) + 1]
  root.setConfiguration("iccLocale", self.currentLanguage)
  localeSettings()
  save()
end


function mainchat:changeMode()
  local i = index(self.availableModes, self.chatMode)
  self.chatMode = self.availableModes[(i % #self.availableModes) + 1]
  root.setConfiguration("iccMode", self.chatMode)
  widget.setText(self.layoutWidget .. ".btnMode", starcustomchat.utils.getTranslation("settings.modes." .. self.chatMode))
  save()
end

function mainchat:updateFontSize(widgetName)
  self.fontSize = widget.getSliderValue(self.layoutWidget .. "." .. widgetName) + 6
  widget.setText(self.layoutWidget .. ".lblFontSizeValue", self.fontSize)
  root.setConfiguration("icc_font_size", self.fontSize)
  save()
end

function mainchat:updateMessageLength(widgetName)
  self.maxCharactersAllowed = widget.getSliderValue(self.layoutWidget .. "." .. widgetName) * self.maxCharactersStep
  widget.setText(self.layoutWidget .. ".lblMessageLengthValue", self.maxCharactersAllowed)
  root.setConfiguration("icc_max_allowed_characters", self.maxCharactersAllowed)
  save()
end

function mainchat:clearHistory()
  world.sendEntityMessage(player.id(), "icc_clear_history")
end

function mainchat:clickCanvasCallback(position, button, isDown)
  if button == 0 then
    self.portraitAnchor = isDown and vec2.sub(position, self.portraitSettings.offset) or nil
    save()
  end
end