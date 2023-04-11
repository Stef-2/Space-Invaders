local Model = require("Model")
local Stars = classes.class()

function Stars:init(params)
    print("Stars init!")
    self.speed = params.speed.default
    self.radius = params.radius.default
    self.color = params.color.default
    
    local numStars = params.numStars
    local stageWidth = Model.stage.stageWidth
    local stageHeight = Model.stage.stageHeight

    local starsArr = {}
    
    for i = 1, numStars do
        local x = math.random(0.0, stageWidth)
        local y = math.random(0.0, stageHeight)
        
        local radius = self.radius
        local speed = self.speed
        local color = self.color
        
        -- stars can have random radius, speed and color to give some interesting visual detail
        local diceRoll = math.random()
        
        if diceRoll <= params.radius.deviancyChance then
          radius = math.random(params.radius.min, params.radius.max)
        end
        
        if diceRoll <= params.speed.deviancyChance then
          speed = math.random(params.speed.min, params.speed.max)
        end
        
        if diceRoll <= params.color.deviancyChance then
          color = {math.random(params.color.min, params.color.max), math.random(params.color.min, params.color.max), math.random(params.color.min, params.color.max)}
        end
        
        local star = {x = x, y = y, radius = radius, speed = speed, color = color}
        table.insert(starsArr, star)
    end
    
    self.numStars = numStars
    self.starsArr = starsArr
    
end


function Stars:update(dt)
  
    -- stars continuosly "fall" down, giving the effect of player moving forward
    -- fake an endless star scrolling effect:
    -- once a star reaches the bottom of the stage, roll it back to the top
    for i=1, self.numStars do
      
      local star = self.starsArr[i]
      
        if star.y >= Model.stageBoundaries["maxY"] then
          star.y = Model.stageBoundaries["minY"]
        end
      
        star.y = star.y + star.speed * dt
    end
end

function Stars:draw()
  
    local radius = self.radius
    local starsArr = self.starsArr
    local numStars = self.numStars
    
    for i = 1, numStars do
      
        local star = starsArr[i]
        love.graphics.setColor(star.color)
        love.graphics.circle("fill", star.x, star.y, star.radius)
    end
end





return Stars