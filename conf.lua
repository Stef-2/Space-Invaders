assetFolder = "Assets"

function love.conf(game)
    game.title = "Space Invaders !"                
    game.version = "11.3"                    
    game.console = false                     
    game.window.width =  420                
    game.window.height = 798
    game.window.msaa = 0
    game.window.vsync = 0
    game.window.icon = assetFolder .. "/enemy.png"
end