local Model = require("Model")
local Explosion = classes.class()

Explosion.explosions = {}

function Explosion:init(params)
  self.x = params.x
  self.y = params.y
  self.w = params.asset:getWidth()
  self.h = params.asset:getHeight()
  self.spawnTime = os.clock()
  self.duration = params.duration
  self.minSize = params.minSize
  self.maxSize = params.maxSize
  self.asset = params.asset
  self.rotation = math.random(-1, 1)
  table.insert(Explosion.explosions, self)
  
end

function Explosion.UpdateExplosions(dt)
  
  -- keep track of how long the explosions last, destroy them once they expire
  for i, explosion in pairs(Explosion.explosions) do
    
    if os.clock() >= explosion.spawnTime + explosion.duration then
      table.remove(Explosion.explosions, i)
    end
    
    explosion:update(dt)
    
  end
end

function Explosion:update(dt)
  -- give explosions a slight Y push to make them look more interesting
  self.y = self.y + 100 * dt
end

function Explosion.DrawExplosions()

  for i, explosion in pairs(Explosion.explosions) do
    explosion:draw()
  end
end

function Explosion:draw()
  
  local currentTime = os.clock()

  -- the explosions start off small and grow as time goes on
  -- explosions should be as small as minSize in the start and as large as maxSize by the end
  -- calculate the [0,1] scale with current time between spawnTime and endTime(spawnTime + duration)
  -- use this scale in hand made linear interpolation since lua doesn't have one in its math library
  -- use the same result for rotation to add a bit more visual detail
  
  -- of the game is over, set the currentTime to end time so that the animation stops
  if Model.gameOver then currentTime = self.spawnTime + self.duration end
  
	local middle = currentTime - self.spawnTime;
	local delta = self.duration;
	local scale = middle / delta;
  
  local lerp = self.minSize * (1 - scale) + self.maxSize * scale
  
  -- use the lerp output to fade the color out and add a slight rotation
  love.graphics.setColor(1, 1, 1, 1 - lerp)
  love.graphics.draw(self.asset, self.x, self.y , lerp * self.rotation, lerp, lerp, self.w / 2, self.h /2)

end

return Explosion