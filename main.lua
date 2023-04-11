--this is how you require files in directories
package.path = package.path .. ";utils/?.lua;"
----------------------

--this is to make prints appear right away in zerobrane
io.stdout:setvbuf("no")

----INSTANTIARING A CLASS
local Ship = require("Ship")--import the class
local ship = nil

local Stars = require("Stars")
local stars = nil

local Projectile = require("Projectile")

local Level = require("Level")
local level = nil

local AssetsManager = require("AssetsManager")
local Model = require("Model")

local Enemy = require("Enemy")
local Explosions = require("Explosion")

local UI = require("UI")

local time = os.clock()
local interval = 1
local switch = true

function love.load()
  print("love.load")
  AssetsManager.init()
  Model.init()
  stars = Stars.new(Model.starsParams)
  ship = Ship.new(Model.shipParams)
  level = Level.new(Model.levelParams)
end

function love.update(dt)
  
  if Model.gameOver then goto gameover end
  
  -- action(s) to perform every [interval] seconds
  -- flash the window title from upper to lower
  if os.clock() >= time + interval then
    if switch then
      love.window.setTitle(string.upper(Model.windowTitle))
    else
      love.window.setTitle(string.lower(Model.windowTitle))
    end
    switch = not switch
    time = os.clock()
  end
  
  ship:update(dt)
  stars:update(dt)
  Projectile.UpdateProjectiles(dt)
  Explosions.UpdateExplosions(dt)
  level:update(dt)
  
  -- a level is cleared once all the enemies in it are dead
  -- reconstruct a new level with more difficult parameters
  if #Enemy.enemies <= 0 then
    
    Model.score = Model.score + level.scoreBounty
    
    local params = Model.levelParams
    params.levelCounter = level.levelCounter + 1
    params.numEnemies = params.numEnemies + params.newLevelOffsets.numEnemyOffset * params.levelCounter
    params.enemySpeed = params.enemySpeed + params.newLevelOffsets.speedOffset * params.levelCounter
    params.enemyHealth = params.numEnemies + params.newLevelOffsets.healthOffset * params.levelCounter
    params.enemyDamage = params.numEnemies + params.newLevelOffsets.damageOffset * params.levelCounter
    params.scoreBounty = params.scoreBounty + params.newLevelOffsets.scoreOffset * params.levelCounter
    
    level = Level.new(params)
  end
  
  ::gameover::
  
end


function love.draw()

  stars:draw()
  ship:draw()
  level:draw()
  Projectile.draw()
  Explosions.DrawExplosions()
  UI.draw(ship, level)
  
end


function love.keypressed(key)
  
  if Model.gameOver then goto gameover end
  
  -- movement
  if key == Model.keys.LEFT_KEY or key == Model.keys.A_KEY then
      Model.movement.left = true
  elseif key == Model.keys.RIGHT_KEY or key == Model.keys.D_KEY then
      Model.movement.right = true
  end
  
  if key == Model.keys.UP_KEY or key == Model.keys.W_KEY then
      Model.movement.up = true
  elseif key == Model.keys.DOWN_KEY or key == Model.keys.S_KEY then
      Model.movement.down = true
  end
  
  -- fire
  if key == Model.keys.FIRE_KEY then
    Model.fire = true
  end
  
  -- gameover
  ::gameover::
  if key == Model.keys.QUIT_KEY then
    love.event.quit()
  end
end

function love.keyreleased(key)
  -- movement
  if key == Model.keys.LEFT_KEY or key == Model.keys.A_KEY then
      Model.movement.left = false
  elseif key == Model.keys.RIGHT_KEY or key == Model.keys.D_KEY then
      Model.movement.right = false
  end
  
  if key == Model.keys.UP_KEY or key == Model.keys.W_KEY then
      Model.movement.up = false
  elseif key == Model.keys.DOWN_KEY or key == Model.keys.S_KEY then
      Model.movement.down = false
  end
  
  -- fire
  if key == Model.keys.FIRE_KEY then
    Model.fire = false
  end
  
end