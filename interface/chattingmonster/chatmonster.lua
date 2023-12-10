require "/monsters/monster.lua"

function init()
    self.parentEntity = config.getParameter("parentEntity")
    message.setHandler("dreadwingDeath", function()end)
    message.setHandler("despawn", function()end)
    message.setHandler("dieplz", function()
        monster.setDropPool(nil)
        monster.setDeathParticleBurst(nil)
        monster.setDeathSound(nil)
        self.deathBehavior = nil
        self.shouldDie = true
        status.addEphemeralEffect("monsterdespawn")
      end)
      sb.logInfo("Chat monster spawn")
      

end

function update(dt)
    status.setPersistentEffects("invincibilityTech", {
        {stat = "breathProtection", amount = 1},
        {stat = "biomeheatImmunity", amount = 1},
        {stat = "biomecoldImmunity", amount = 1},
        {stat = "biomeradiationImmunity", amount = 1},
        {stat = "lavaImmunity", amount = 1},
        {stat = "poisonImmunity", amount = 1},
        {stat = "tarImmunity", amount = 1},
        {stat = "invulnerable", amount = 1}
       
      })
    mcontroller.controlFace(1)
    self.dotpos = world.entityMouthPosition(self.parentEntity)
    mcontroller.setPosition({self.dotpos[1] - 0.125, self.dotpos[2] + 2.5})
end

function die()
    monster.setDropPool(nil)
    monster.setDeathParticleBurst(nil)
    monster.setDeathSound(nil)
    self.deathBehavior = nil
    self.shouldDie = true
    status.addEphemeralEffect("monsterdespawn")   
end
