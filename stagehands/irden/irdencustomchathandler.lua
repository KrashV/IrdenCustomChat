require "/scripts/messageutil.lua"
require "/scripts/irden/chat/stagehand_class.lua"

function iccstagehand_init()
  self.stagehand = IrdenChatStagehand:create("irdencustomchat", 300)
  
  message.setHandler( "icc_sendMessage", simpleHandler(handleMessage) )
  message.setHandler( "icc_requestPortrait", simpleHandler(requestPortrait) )
  message.setHandler( "icc_getAllPlayers", simpleHandler(getAllPlayers) )
  message.setHandler( "icc_savePortrait", simpleHandler(savePortrait) )
end

function handleMessage(data)
  local author = data.connection * -65536
  if data.mode == "Proximity" then
    local authorPos = world.entityPosition(author)
    for _, pId in ipairs(world.players()) do 
      local distance = world.magnitude(authorPos, world.entityPosition(pId))
      if distance <= self.stagehand.proximityRadius then
        self.stagehand:sendDataToPlayer(pId, data)
      end
    end
  elseif data.mode == "Fight" and data.fight then
    promises:add(world.sendEntityMessage("irdenfighthandler_" .. data.fight, "getFight"), function(fight) 
      if fight and not fight.done then
        for uuid, player in pairs(fight.players) do
          self.stagehand:sendDataToPlayer(uuid, data)
        end
      end
    end)
  end
end

function getAllPlayers()
  local players = {}
  for _, player in ipairs(world.players()) do 
    table.insert(players, {
      id = player,
      name = world.entityName(player),
      portrait = requestPortrait(player)
    })
  end
  return players
end

function requestPortrait(entityId)
  local uuid = world.entityUniqueId(entityId)

  if uuid then
    if self.stagehand.portraits[uuid] then
      return self.stagehand.portraits[uuid]
    elseif world.entityExists(entityId) and world.entityPortrait(entityId, "bust") then 
      self.stagehand.portraits[uuid] = {
        portrait = world.entityPortrait(entityId, "bust"),
        cropArea = cropArea
      }
      return self.stagehand.portraits[uuid]
    else
      return nil
    end
  end
end

function savePortrait(request)
  if world.entityExists(request.entityId) and world.entityPortrait(request.entityId, "bust") then 
    local uuid = world.entityUniqueId(request.entityId)
    self.stagehand.portraits[uuid] = {
      portrait = request.portrait or world.entityPortrait(request.entityId, "bust"),
      cropArea = request.cropArea
    }
    return true
  else
    return nil
  end
end

function iccstagehand_update(dt)
  promises:update()
end

function uninit()

end