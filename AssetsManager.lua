local AssetsManager = {}

AssetsManager.init = function()
    
  local sprites = {
    ship = love.graphics.newImage("Assets/ship.png"),
    enemy = love.graphics.newImage("Assets/enemy.png"),
    bullet = love.graphics.newImage("Assets/bullet.png"),
    explosion = love.graphics.newImage("Assets/explosion.png"),
    coin = love.graphics.newImage("Assets/coin.png"),
    health = love.graphics.newImage("Assets/health.png"),
    shield = love.graphics.newImage("Assets/shield.png"),
    magnet = love.graphics.newImage("Assets/magnet.png"),
    fireRate = love.graphics.newImage("Assets/fireRate.png"),
    fireAngles = love.graphics.newImage("Assets/fireAngles.png"),
    heart = love.graphics.newImage("Assets/heart.png")
  }

  local fonts = {
    medium = love.graphics.newFont("Assets/ethnocentric rg it.otf", 12),
    large = love.graphics.newFont("Assets/ethnocentric rg it.otf", 18)
  }
  
  AssetsManager.sprites = sprites
  AssetsManager.fonts = fonts
    
end



return AssetsManager