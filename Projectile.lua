local Model = require("Model")
local classes = require("classes")
local Projectile = classes.class()

-- projectiles vector
Projectile.projectiles = {}

Projectile.UpdateProjectiles = function(dt)
  
  for i = 1, #Projectile.projectiles do
    Projectile.projectiles[i]:update(dt)
  end
  
  for k, v in pairs(Projectile.projectiles) do
    if not v.alive then
      table.remove(Projectile.projectiles, k)
    end
  end
  
end

function Projectile:init(params)
    self.speed = params.speed
    self.asset = params.asset
    self.x = params.x
    self.y = params.y
    self.dirX = params.dirX
    self.dirY = params.dirY
    self.alive = true
    self.w = self.asset:getWidth()
    self.h = self.asset:getHeight()
    self.radius = self.asset:getWidth() / 2
    self.damage = params.damage
end

function Projectile:update(dt)
  
    self.x = self.x + self.speed * self.dirX * dt
    self.y = self.y + self.speed * self.dirY * dt
  
    if self.y < 0 - self.h / 2 then
      self.alive = false
    end
end

function Projectile:draw()
  
    love.graphics.setColor(1, 1, 1)
    
  for i = 1, #Projectile.projectiles do
    local newX = Projectile.projectiles[i].x - (Projectile.projectiles[i].w/2)
    local newY = Projectile.projectiles[i].y - (Projectile.projectiles[i].h/2)
    
    love.graphics.draw(Projectile.projectiles[i].asset, newX, newY, math.sin(Projectile.projectiles[i].dirX))
  end
    
end

return Projectile