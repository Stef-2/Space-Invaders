local Model = require("Model")
local classes = require("classes")
local Collectible = classes.class()

-- collectibles vector
Collectible.collectibles = {}

Collectible.UpdateCollectibles = function(dt)
  
  for i = 1, #Collectible.collectibles do
    Collectible.collectibles[i]:update(dt)
  end
  
  for k, v in pairs(Collectible.collectibles) do
    if not v.alive then
      table.remove(Collectible.collectibles, k)
    end
  end
end

function Collectible:init(params)
    self.speed = params.speed
    self.collectible = params.collectible
    self.x = params.x
    self.y = params.y
    self.alive = true
    self.w = self.collectible.asset:getWidth()
    self.h = self.collectible.asset:getHeight()
    self.radius = self.w / 2
    self.type = params.collectible.type
end

function Collectible:update(dt)
  
  -- collectibles move down at a constant rate
  self.y = self.y + self.speed * dt

  -- once they reach the bottom of the stage, destroy them
  if self.y + self.h / 2 >= Model.stageBoundaries.maxY then
    self.alive = false
  end
end

function Collectible:draw()
  
    local cornerRadius = self.w / 4
    local frameOffset = 2
    love.graphics.setColor(1, 1, 1)
    

    local newX = self.x - self.w/2
    local newY = self.y - self.h/2
    
    love.graphics.setColor(0.75, 0.75, 0.75, 0.5)
    love.graphics.rectangle("fill", newX - frameOffset, newY - frameOffset, self.w + frameOffset * 2, self.h + frameOffset * 2, cornerRadius, cornerRadius)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.collectible.asset, newX, newY )

    
end

return Collectible