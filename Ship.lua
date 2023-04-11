local classes = require("classes")
local Ship = classes.class()
local Model = require("Model")
local ProjectileCls = require("Projectile")
local collision = require("Collision")
local Level = require("Level")
local Enemy = require("Enemy")
local Explosions = require("Explosion")
local Collectible = require("Collectible")

function Ship:init(params)
    print("Ship init!")
    self.speed = params.speed
    self.asset = params.asset
    self.fireRate = params.fireRate
    self.lastFireTime = os.clock()
    self.x = params.x
    self.y = params.x
    self.w = self.asset:getWidth()
    self.h = self.asset:getHeight()
    self.radius = self.asset:getWidth() / 2
    self.health = params.health
    self.lives = params.lives
    self.shield = 0
    
    -- powerup timers, these will take values of current time + respective powerup duration
    self.powerUps = {
      fireRateTime = 0,
      fireAngleTime = 0,
      shieldTime = 0,
      magnetTime = 0
    }
end

function Ship:update(dt)

    local left = Model.movement.left
    local right = Model.movement.right
    local up = Model.movement.up
    local down = Model.movement.down
    
    local fire = Model.fire

    -- handle movement
    local x = 0
    local y = 0

    if left then
        x = x + -1
    end
    if right then
        x = x + 1
    end

    if up then
        y = y + -1
    end
    if down then
        y = y + 1
    end
    
    self.x = self.x + (x * self.speed * dt)
    self.y = self.y + (y * self.speed * dt)
    
    -- check stage boundries, clamp if necessary
    self.x = math.min(math.max(self.x, Model.stageBoundaries["minX"]), Model.stageBoundaries["maxX"])
    self.y = math.min(math.max(self.y, Model.stageBoundaries["minY"]), Model.stageBoundaries["maxY"])

    -- handle fire
    currentTime = os.clock()

    -- check for fire rate power up, increase rate of fire if its on
    if self.powerUps.fireRateTime > 0 then
      self.fireRate = Model.shipParams.fireRate / Model.fireRateParams.rateMultiplier
    else
      self.fireRate = Model.shipParams.fireRate
    end
    
    -- check if the fire rate allows us to fire at this time
    if fire and currentTime > self.lastFireTime + self.fireRate then
      
      local params = Model.projectileParams
      params.x = self.x
      params.y = self.y - self.w / 2
      params.dirX = 0
      params.dirY = -1
      local projectile = ProjectileCls.new(params)
      table.insert(ProjectileCls.projectiles, projectile)
        
      -- check if we have the fire angle power up
      -- if we do, spawn two additional projectiles at an angle
      if self.powerUps.fireAngleTime > 0 then
        
        params.dirX = -math.sin(math.rad(Model.fireAngleParams.angle))
        projectile = ProjectileCls.new(params)
        table.insert(ProjectileCls.projectiles, projectile)
        
        params.dirX = math.sin(math.rad(Model.fireAngleParams.angle))
        projectile = ProjectileCls.new(params)
        table.insert(ProjectileCls.projectiles, projectile)
      else
        
      end
      -- remember the last fire time for later
      self.lastFireTime = os.clock()
    end
    
    -- handle enemy collision detection
    local shipObj = {self.x - (self.w / 2), self.y - (self.h / 2), self.radius}
    
    for i, enemy in pairs(Enemy.enemies) do
      
      local enemyObj = {enemy.x - (enemy.w / 2), enemy.y - (enemy.h / 2), enemy.radius}
      
      if collision.check(shipObj, enemyObj) then
        local damage = enemy.damage
        
        -- if we have a shield powerUps, let it absorb damage
        if self.shield > 0 then
          self.shield = self.shield - enemy.damage
          
        -- if the shield absorbed all damage, set damage to 0
        -- if the shield could not absorb everything, deal the remaining damage to player health
        if self.shield > 0 then
          damage = 0
        else
          damage = self.shield * -1
          self.shield = 0
          end
        end
        -- collision with enemies does damage to the ship and instantly destroys enemies
        -- mark them for deletion
        self.health = self.health - damage
        enemy.alive = false
      end
    end
    
    -- handle magnet power up
    if self.powerUps.magnetTime > 0 then
      
      for i, c in pairs(Collectible.collectibles) do
        
        -- calculate a normalized vector between the collectible and the ship
        local x = self.x - c.x
        local y = self.y - c.y
        local n = math.sqrt(x * x + y * y)
        
        -- if they're in magnets effect radius, apply it to the collectible
        if n <= Model.magnetParams.effectRadius then
          c.x = c.x + x / n
          c.y = c.y + y / n
        end
      end
    end
    
    -- handle collectible collision detection
    for i, collectible in pairs(Collectible.collectibles) do
      
      local collectibleObj = {collectible.x - (collectible.w / 2), collectible.y - (collectible.h / 2), collectible.radius}
      
      if collision.check(shipObj, collectibleObj) then
        
        -- collected coin bonus
        if collectible.type == Model.coinParams.type then Model.score = Model.score + Model.coinParams.bounty end
        -- collected heal bonus
        if collectible.type == Model.healthParams.type then self.lives = math.min(Model.shipParams.lives, self.lives + Model.healthParams.heal) end
        
        -- collected fire rate bonus
        if collectible.type == Model.fireRateParams.type then
          self.powerUps.fireRateTime = Model.fireRateParams.duration + currentTime
        end
        -- collected fire angle bonus
        if collectible.type == Model.fireAngleParams.type then self.powerUps.fireAngleTime = Model.fireAngleParams.duration + currentTime end
        -- collected shield bonus
        if collectible.type == Model.shieldParams.type then
          self.powerUps.shieldTime = Model.shieldParams.duration + currentTime
          self.shield = Model.shieldParams.damageBlock
        end
        -- collected magnet bonus
        if collectible.type == Model.magnetParams.type then self.powerUps.magnetTime = Model.magnetParams.duration + currentTime end
        
        -- mark collectible for deletion
        collectible.alive = false
      end
    end
    
    
    
    -- handle own health and lives
    -- if our health reaches zero, we lose a life and health is reset to maximum
    if self.health <= 0 then
      self.lives = self.lives - 1
      self.health = Model.shipParams.health
      
      -- if that occurs, display and explosion and reset our position to default
      explosionParams = Model.explosionParams
      explosionParams.x = self.x
      explosionParams.y = self.y
      explosion = Explosions.new(explosionParams)
      table.insert(Explosions.explosions, explosion)
      
      self.x = Model.shipParams.x
      self.y = Model.shipParams.y
    end
  
    -- handle game state in case of losing all lives
    if self.lives <= 0 then
      Model.gameOver = true
    end
    
    -- keep track of power up times
    for k, v in pairs(self.powerUps) do
      if currentTime >= v then self.powerUps[k] = 0 end
    end

    
end

function Ship:draw()
  
  local rotation = 0
  local time = os.clock() * 3
  
  -- if we're currently moving to one of the sides
  -- tilt the ship sprite to make things look more interesting
  if Model.movement.left then rotation = -0.2 end
  if Model.movement.right then rotation = 0.2 end
  
  love.graphics.setColor(1, 1, 1)
  local newX = self.x - (self.w/2)
  local newY = self.y - (self.h/2)
  love.graphics.draw(self.asset, newX, newY, rotation, 1, 1, 0, 0, 0, 0)
  
  -- if we have the shield power up, draw it on top
  if self.shield > 0 then
    
    -- scale for the shield sprit
    local scale = 0.5
    newX = newX + self.w / 2
    newY = newY + self.h / 2
    local shield = Model.shieldParams.asset
    local w = shield:getWidth() / 2 * scale
    local h = shield:getHeight() / 2 * scale
    
    -- use trig functions on time to display a rotating shield around the ship while the power up is active
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(shield, newX - w + self.w * math.sin(time), newY - h + self.h * math.cos(time), 0, 0.5, 0.5)
  end
  
end

return Ship