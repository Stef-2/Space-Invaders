local Model = require("Model")
local Level = require("Level")
local UI = {}

UI.draw = function(ship, level)
  
  local currentTime = os.clock()
  
  -- define common colors
  local white = {1, 1, 1}
  local red = {1, 0, 0}
  local grey = {0.2, 0.2, 0.2}
  
  -- default color
  love.graphics.setColor(white)
  
  -- default font size
  love.graphics.setFont(Model.mediumFont)
    
  -- draw hearts, representing lives <3
  local heart = Model.UIparams.livesAsset
  
  local scale = 0.5
  local x = Model.UIparams.livesPosX
  local y = Model.UIparams.livesPosY
  local w = heart:getWidth() * scale
  local h = heart:getHeight() * scale
  
  local maxLives = Model.shipParams.lives
  local currentLives = ship.lives
  
  -- horizontal offset between hearts
  local offsetX = 5
  
  -- draw the hearts, switch color to grey for lost hearts
  for i = 1, maxLives do
    if currentLives < i then
      love.graphics.setColor(grey)
    end
    love.graphics.draw(heart, x + (i - 1) * (w + offsetX), y, 0, scale, scale)
  end
  
  -- draw a health bar
  -- we actually draw two health bars (lines)
  -- one grey underneath to represent lost health
  -- and a red one on top to represent current health
  love.graphics.setLineWidth(Model.UIparams.healthBarH)
  
  local maxHealth = Model.shipParams.health
  local currentHealth = ship.health
  -- scale the health bar as a percentage of the current / maximum health
  local HPbarLength = Model.UIparams.healthBarW * (currentHealth / maxHealth)
  
  local x1 = Model.UIparams.healthBarX
  local y1 = Model.UIparams.healthBarY
  local x2 = x1 + HPbarLength
  local y2 = y1
  
  love.graphics.setColor(grey)
  love.graphics.line(x1, y1, Model.UIparams.healthBarW, y2)
  love.graphics.setColor(red)
  love.graphics.line(x1, y1, x2, y2)
  
  -- draw score text
  love.graphics.setColor(white)
  
  local scoreX = Model.UIparams.scorePosX
  local scoreY = Model.UIparams.scorePosY
  local shiftX = Model.largeFont:getWidth("0") / 2
  
  -- figure out how many digits the current score has
  -- we might need to shift the string to the left so the number doesnt get rendered outside of the window
  -- every time the score grows in digits, we nudge the whole thing slightly to the left
  local numScoreDigits = string.len(tostring(Model.score))
  
  love.graphics.printf(Model.UIparams.scoreText .. Model.score, scoreX - numScoreDigits * shiftX, scoreY, math.huge, "left")
  
  love.graphics.setFont(Model.largeFont)
  
  -- draw level number at the start of each level
  local newLevelTextDuration = 2.2
  
  -- red text color for the following printfs
  local textColor = {1.0, 0.0, 0.0, 1.0}
  
  -- draw the new level text from the moment the new level is made / entered
  -- until that time + [newLevelTextDuration]
  if currentTime >= level.startTime and currentTime <= level.startTime + newLevelTextDuration then
    love.graphics.printf({textColor, Model.UIparams.newLevelText .. level.levelCounter + 1}, Model.UIparams.newLevelPosX - 40, Model.UIparams.newLevelPosY, 100, "center")
  end

  -- draw end screen on game over
  if Model.gameOver then
    -- hack current level start time so the new level text doesn't show
    level.startTime = math.huge

    love.graphics.printf({textColor, Model.UIparams.endScreenText1 .. Model.score .. Model.UIparams.endScreenText2},
    Model.UIparams.endScreenPosX - 200, Model.UIparams.endScreenPosY, 400, "center")
  end
end

return UI