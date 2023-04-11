local AssetsManager = require("AssetsManager")

local Model = {
    movement = {
        up = false,
        down = false,
        left = false,
        right = false,
        space = false
    },
    
    fire = false,
    quit = false
}

Model.windowTitle = "Space Invaders !"

Model.shipParams = {
    assetName = "ship",
    speed = 500,
    fireRate = 0.2,
    radius = 80,
    health = 1000,
    lives = 3
}

Model.starsParams = {
    radius = {
      min = 0.5,
      default = 1.0,
      max = 2.0,
      
      -- % chance that a generated star's attribute will deviate from the default
      deviancyChance = 0.2
    },
    
    speed = {
      min = 50,
      default = 100,
      max = 200,
      
      -- % chance that a generated star's attribute will deviate from the default
      deviancyChance = 0.4
    },
    
    color = {
      min = 0.66,
      default = {1.0, 1.0, 1.0},
      max = 1.0,
      
      -- % chance that a generated star's attribute will deviate from the default
      deviancyChance = 0.25
    },
    
    numStars = 300
}

Model.projectileParams = {
  alive = false,
  assetName = "bullet",
  speed = 500,
  damage = 25
}

Model.enemyParams = {
  alive = false,
  assetName = "enemy",
  speed = 100,
  health = 100,
  dmgOnContact = 60,
  scoreBounty = 80,
  
  color = {
    min = 0.5,
    default = 1.0,
    max = 1.0,
    
    -- chance that an enemy will have a different color
    deviancyChance = 0.3
  },
  
  coinChance = 0.3,
  healthChance = 0.1
}

Model.levelParams = {
  numEnemies = 5,
  enemySpeed = Model.enemyParams.speed,
  enemyHealth = Model.enemyParams.health,
  enemyFrequency = 1,
  enemyOffsetX = 60,
  enemyOffsetY = 0,
  enemyDamage = Model.enemyParams.dmgOnContact,
  
  cleared = false,
  levelCounter = 0,
  scoreBounty = 100,
  
  -- chance on game tick to spawn a collectible
  collectibleChance = {
    fireAngle = 0.05,
    fireRate = 0.083,
    shield = 0.02,
    magnet = 0.02
  },
  
  -- value offsets for subsequent levels
  -- used to make them more difficult
  newLevelOffsets = {
    numEnemyOffset = 5,
    speedOffset = 25,
    healthOffset = 100,
    damageOffset = 20,
    scoreOffset = 50
  }
}

Model.explosionParams = {
  assetName = "explosion",
  duration = 1.0,
  -- % size for the explosion animation
  minSize = 0.1,
  maxSize = 1.0
}

Model.coinParams = {
  assetName = "coin",
  -- score to add
  bounty = 500,
  type = 1
}

Model.healthParams = {
  assetName = "health",
  -- lives to add, max is still defined in shipParams
  heal = 1,
  type = 2
}

Model.fireAngleParams = {
  assetName = "fireAngles",
  -- spread angle, in degrees
  angle = 20,
  type = 3,
  duration = 30
}

Model.fireRateParams = {
  assetName = "fireRate",
  rateMultiplier = 3,
  type = 4,
  duration = 30
}

Model.shieldParams = {
  assetName = "shield",
  damageBlock = 500,
  type = 5,
  duration = 25
}

Model.magnetParams = {
  assetName = "magnet",
  -- radius in which the shield has an effect
  effectRadius = 250,
  type = 6,
  duration = 30
}

Model.collectibleParams = {
  type = 0,
  speed = 100,
  duration = 30,
  collectible = {},
}

Model.keys = {
  LEFT_KEY = "left",
  RIGHT_KEY = "right",
  UP_KEY = "up",
  DOWN_KEY = "down",
  
  A_KEY = "a",
  D_KEY = "d",
  W_KEY = "w",
  S_KEY = "s",

  FIRE_KEY = "space",
  QUIT_KEY = "escape"
}

Model.init = function()
    Model.stage = {
        stageHeight = love.graphics.getHeight(),
        stageWidth = love.graphics.getWidth()
    }
    
    Model.lives = Model.shipParams.lives
    Model.score = 0
    Model.gameOver = false
    
    -- precompute stage boundaries
    -- so we don't waste cpu time doing it every update cycle
    Model.stageBoundaries = {
      minX = 0.0,
      maxX = Model.stage.stageWidth,
      minY = 0.0,
      maxY = Model.stage.stageHeight
    }
    
    -- setup UI so it uses stage boundaries as parameters
    -- making it scalable to different stage sizes
    Model.UIparams = {
      livesPosX = Model.stageBoundaries.minX + 10,
      livesPosY = Model.stageBoundaries.minY + 10,
      
      healthBarX = Model.stageBoundaries.minX + 10,
      healthBarY = Model.stageBoundaries.minY + 50,
      healthBarW = 75,
      healthBarH = 20,
      
      scorePosX = Model.stageBoundaries.maxX - 80,
      scorePosY = Model.stageBoundaries.minY + 10,
      scoreText = "Score: ",
      
      newLevelPosX = Model.stageBoundaries.maxX / 2,
      newLevelPosY = Model.stageBoundaries.maxY / 2,
      newLevelText = "Level: ",
      
      endScreenPosX = Model.stageBoundaries.maxX / 2,
      endScreenPosY = Model.stageBoundaries.maxY / 2,
      endScreenText1 = "Game Over !\n Final score:",
      endScreenText2 = "\nPress Esc key to exit",
      
      livesAssetName = "heart"
    }
    
    Model.shipParams.x = Model.stageBoundaries.maxX / 2
    Model.shipParams.y = Model.stageBoundaries.maxY - 40
    
    -- init assets dynamically
    Model.shipParams.asset = AssetsManager.sprites[Model.shipParams.assetName]
    Model.projectileParams.asset = AssetsManager.sprites[Model.projectileParams.assetName]
    Model.enemyParams.asset = AssetsManager.sprites[Model.enemyParams.assetName]
    Model.explosionParams.asset = AssetsManager.sprites[Model.explosionParams.assetName]
    Model.UIparams.livesAsset = AssetsManager.sprites[Model.UIparams.livesAssetName]

    Model.coinParams.asset = AssetsManager.sprites[Model.coinParams.assetName]
    Model.healthParams.asset = AssetsManager.sprites[Model.healthParams.assetName]
    
    Model.fireAngleParams.asset = AssetsManager.sprites[Model.fireAngleParams.assetName]
    Model.fireRateParams.asset = AssetsManager.sprites[Model.fireRateParams.assetName]
    Model.shieldParams.asset = AssetsManager.sprites[Model.shieldParams.assetName]
    Model.magnetParams.asset = AssetsManager.sprites[Model.magnetParams.assetName]
    
    Model.mediumFont = AssetsManager.fonts.medium
    Model.largeFont = AssetsManager.fonts.large
    
    -- random seed based on OS time to make sure every game has different RNG
    math.randomseed(os.time())
    
end




return Model