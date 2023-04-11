local Model = require("Model")
local classes = require("classes")
local Enemy = classes.class()
local Projectile = require("Projectile")
local collision = require("Collision")
local Explosion = require("Explosion")
local Collectible = require("Collectible")

Enemy.enemies = {}

Enemy.UpdateEnemies = function(dt)
  
  for i = 1, #Enemy.enemies do
    Enemy.enemies[i]:update(dt)
  end
  
  for k, enemy in pairs(Enemy.enemies) do
    if not enemy.alive then
      
      -- handle nemy death:
      -- give a bounty for each enemy killed
      -- spawn an explosion
      -- roll a dice to see if it drops anything
      Model.score = Model.score + enemy.scoreBounty
      
      local explosionParams = Model.explosionParams
      explosionParams.x = enemy.x
      explosionParams.y = enemy.y
      explosion = Explosion.new(explosionParams)
      table.insert(Explosion.explosions, explosion)
      
      local diceRoll = math.random()
      
      -- see if we drop a coin
      if diceRoll <= Model.enemyParams.coinChance then
      
        local params = Model.collectibleParams
        params.collectible = Model.coinParams
        params.x = enemy.x
        params.y = enemy.y
        params.type = Model.coinParams.type

        local collectible = Collectible.new(params)
        
        table.insert(Collectible.collectibles, collectible)
      end
      
      -- or a health pick up
      if diceRoll <= Model.enemyParams.healthChance then
      
        local params = Model.collectibleParams
        params.collectible = Model.healthParams
        params.x = enemy.x
        params.y = enemy.y
        params.type = Model.healthParams.type

        local collectible = Collectible.new(params)
        
        table.insert(Collectible.collectibles, collectible)
    end

      table.remove(Enemy.enemies, k)
    end
  end
  
end

function Enemy:init(params)
    self.speed = params.speed
    self.asset = params.asset
    self.x = params.x
    self.y = params.y
    self.alive = true
    self.health = params.health
    self.directionX = 1
    self.directionY = 1
    self.w = self.asset:getWidth()
    self.h = self.asset:getHeight()
    self.radius = self.asset:getWidth() / 2
    self.damage = params.dmgOnContact
    self.scoreBounty = params.scoreBounty
    self.color = {params.color.default, params.color.default, params.color.default}
    
    -- enemies have 3 predefined movement AIs defined below
    -- static (simply fall down)
    -- zig zag (fall down while moving from one side of the screen to the other)
    -- spiral (fall down while spiraling in a clockwise direction)
    self.ai = params.ai

    local diceRoll = math.random()

    -- add some visual variety to enemies in the form of colors, has no gameplay effect
    if diceRoll <= params.color.deviancyChance then
      self.color = {math.random(params.color.min, params.color.max), math.random(params.color.min, params.color.max), math.random(params.color.min, params.color.max)}
    end
end

function Enemy:update(dt)
  
  -- call the movement AI
  self:ai(dt)

  -- handle player projectile collision
    local enemyObj = {self.x - (self.w / 2), self.y - (self.h / 2), self.radius}
    
    for j, projectile in pairs(Projectile.projectiles) do
      local projObj = {projectile.x - (projectile.w / 2), projectile.y - (projectile.h / 2), projectile.radius}
      
      if collision.check(enemyObj, projObj) then
        table.remove(Projectile.projectiles, j)
        self.health = self.health - projectile.damage
      end
    end
  
  if self.health <= 0 then
    self.alive = false
  end
end

function Enemy:StaticAI(dt)
  
  -- just move down
  self.y = self.y + self.speed * dt
  
    -- if an enemy reaches the bottom of the screen, flip it back to the top
  if self.y > Model.stageBoundaries.maxY + self.h / 2 then
    
    self.y = Model.stageBoundaries.minY - self.h
  end
end

function Enemy:ZigZagAI(dt)
  
  -- move in a zig zag pattern from one side to the other
  self.y = self.y + self.speed * dt
  self.x = self.x + (self.directionX * self.speed * dt)

  -- if an enemy reaches the side of the screen, flip its X direction
  if self.x <= Model.stageBoundaries.minX or self.x >= Model.stageBoundaries.maxX then
    self.directionX = self.directionX * -1
  end

  -- if an enemy reaches the bottom of the screen, flip it back to the top
  if self.y > Model.stageBoundaries.maxY + self.h / 2 then
    
    self.y = Model.stageBoundaries.minY - self.h
  end
end

function Enemy:SpiralAI(dt)
  
  local time = os.clock()
  
  -- move in a spiral pattern and ignore X sides of the screen
  self.y = self.y + (self.directionY * self.speed * dt)
  self.y = self.y + self.speed * dt
  self.x = self.x + (self.directionX * self.speed * dt)

  self.directionX = -math.sin(time * 3)
  self.directionY = math.cos(time * 3)
  -- if an enemy reaches the bottom of the screen, flip it back to the top
  if self.y > Model.stageBoundaries.maxY + self.h / 2 then

    self.y = Model.stageBoundaries.minY - self.h
  end
end

function Enemy:draw()

    local newX = self.x - (self.w/2)
    local newY = self.y - (self.h/2)
    
    love.graphics.setColor(self.color)
    love.graphics.draw(self.asset, newX, newY )
end

return Enemy