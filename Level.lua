local Model = require("Model")
local Level = classes.class()
local Enemy = require("Enemy")
local Collectible = require("Collectible")

function Level:init(params)
    print("Level init!")
    
    self.cleared = params.cleared
    self.levelCounter = params.levelCounter
    self.scoreBounty = params.scoreBounty
    self.startTime = os.clock()
    
    local minX = Model.stageBoundaries.minX
    local minY = Model.stageBoundaries.minY
    
    local maxX = Model.stageBoundaries.maxX
    local maxY = Model.stageBoundaries.maxY
    local thresholdY = maxY * 2/3

    -- if the number of enemies that is requested to be spawned by the level
    -- can not reasonably fit into a single row, spawn subsequent enemies in rows below
    local x = 1
    local y = 0
    local offsetY = Model.enemyParams.asset:getWidth()
    
    -- spawn enemies
    for i = 1, params.numEnemies do
      
      local enemyParam = Model.enemyParams
      
      local newX = minX + params.enemyOffsetX * x
      local newY = minY + params.enemyOffsetY * y
      
      -- if the new enemy placement puts it beyond the Y threshold
      -- we can no longer reasonably create new enemies
      -- skip the rest of the loop

      if newY >= thresholdY then goto continue end
      
      if newX >= maxX then
        x = 1
        y = y + 1
      end
      
      enemyParam.x = minX + params.enemyOffsetX * x
      enemyParam.y = minY + params.enemyOffsetY * y + offsetY * y
      enemyParam.health = params.enemyHealth
      enemyParam.speed = params.enemySpeed
      enemyParam.dmgOnContact = params.enemyDamage
      
      -- roll a random dice to decide which one of the 3 movement AIs the enemy will use
      local randomAI = math.random(1, 3)
      
      if randomAI == 1 then 
        enemyParam.ai = Enemy.StaticAI
      elseif randomAI == 2 then
        enemyParam.ai = Enemy.ZigZagAI
      elseif randomAI == 3 then
        enemyParam.ai = Enemy.SpiralAI
      end
      
      
      local enemy = Enemy.new(enemyParam)
      table.insert(Enemy.enemies, enemy)
      
      x = x + 1
    end
    
    ::continue::
end


function Level:update(dt)
  
    Enemy.UpdateEnemies(dt)
    
    -- handle collectible spawning
    -- roll a random dice and check if we should spawn any collectibles
    local diceRoll = math.random()
    local chances = Model.levelParams.collectibleChance
    
    -- fire angle drop
    if diceRoll <= chances.fireAngle * dt then
      
      local params = Model.collectibleParams
      params.collectible = Model.fireAngleParams
      params.x = math.random(Model.stageBoundaries.minX, Model.stageBoundaries.maxX)
      params.y = Model.stageBoundaries.minY
      params.type = Model.fireAngleParams.type
      
      local collectible = Collectible.new(params)
      
      table.insert(Collectible.collectibles, collectible)
    end
    
    -- fire rate drop
    if diceRoll <= chances.fireRate * dt then
      
      local params = Model.collectibleParams
      params.collectible = Model.fireRateParams
      params.x = math.random(Model.stageBoundaries.minX, Model.stageBoundaries.maxX)
      params.y = Model.stageBoundaries.minY
      params.type = Model.fireRateParams.type
      
      local collectible = Collectible.new(params)
      
      table.insert(Collectible.collectibles, collectible)
    end
    
    -- shield drop
    if diceRoll <= chances.shield * dt then
      
      local params = Model.collectibleParams
      params.collectible = Model.shieldParams
      params.x = math.random(Model.stageBoundaries.minX, Model.stageBoundaries.maxX)
      params.y = Model.stageBoundaries.minY
      params.type = Model.shieldParams.type
      
      local collectible = Collectible.new(params)
      
      table.insert(Collectible.collectibles, collectible)
    end
    
    -- magnet drop
    if diceRoll <= chances.magnet * dt then
      
      local params = Model.collectibleParams
      params.collectible = Model.magnetParams
      params.x = math.random(Model.stageBoundaries.minX, Model.stageBoundaries.maxX)
      params.y = Model.stageBoundaries.minY
      params.type = Model.magnetParams.type
      
      local collectible = Collectible.new(params)
      
      table.insert(Collectible.collectibles, collectible)
    end
      
    Collectible.UpdateCollectibles(dt)
end

function Level:draw()
  
    -- draw enemies and collectables
    for i = 1, #Enemy.enemies do
      Enemy.enemies[i]:draw()
    end
    
    for i = 1, #Collectible.collectibles do
      Collectible.collectibles[i]:draw()
    end
end

return Level