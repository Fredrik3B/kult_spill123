function init()
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    points = 0
    block_x, block_y, block_w, block_h = getBlock()
    shady_block_x, shady_block_y, shady_block_w, shady_block_h = getBlock()

    -- Spiller og blokker
    objects = {}
    player = {}

    player.img = player_img
    player_width = player.img:getWidth()
    player_height = player.img:getHeight()
    player_window_width = window_width - player_width
    player_x, player_y = (window_width-player_width)/2, window_height - player_height - 50
    player.body = love.physics.newBody(world, player_x, player_y, "dynamic")
    -- player.shape = love.physics.newRectangleShape(player_x, player_y)
    -- player_points = {player_x, window_height-200, player_x+player_width, window_height-200, window_width/2, 0}
    player_points = {0, player_height, 0+player_width, player_height, (0+player_width)/2+1, 0, (0+player_width)/2-1, 0}
    player.shape = love.physics.newPolygonShape(player_points)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setUserData("Player")

    objects.shady_block = {}
    objects.shady_block.attr = "shady"
    objects.shady_block.notSpawn = false
    objects.shady_block.body = love.physics.newBody(world, shady_block_x, shady_block_y, "kinematic") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    objects.shady_block.shape = love.physics.newRectangleShape(shady_block_w, shady_block_h) --make a rectangle with a width of 650 and a height of 50
    objects.shady_block.fixture = love.physics.newFixture(objects.shady_block.body, objects.shady_block.shape) --attach shape to body


    objects.block = {}
    objects.block.attr = "normal"
    objects.block.body = love.physics.newBody(world, block_x, block_y, "kinematic") --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    objects.block.shape = love.physics.newRectangleShape(block_w, block_h) --make a rectangle with a width of 650 and a height of 50
    objects.block.fixture = love.physics.newFixture(objects.block.body, objects.block.shape) --attach shape to body

    speed = 100
end
-- Load some default values for our rectangle.
function love.load()
    -- Verden uten gravity

    font = love.graphics.newFont("font.ttf", 32)
    smallFont = love.graphics.newFont("font.ttf", 22)
    largeFont = love.graphics.newFont("font.ttf", 50)

    -- sfx
    local sfx = "sound/fx/"
    sel_up = love.audio.newSource(sfx .. "select-up.mp3", "static")
    sel_down = love.audio.newSource(sfx .. "select-down.mp3", "static")
    menu_sfx = love.audio.newSource(sfx .. "menu.mp3", "static")
    ad_sfx = love.audio.newSource(sfx .. "access-denied.mp3", "static")
    krasj_sfx = love.audio.newSource(sfx .. "krasj.mp3", "static")

    gamestate = "start"
    sens = 10
    window_height = love.graphics.getHeight()
    window_width = love.graphics.getWidth()

    local m = "sound/music/"
    music = {
        love.audio.newSource(m .. "jazz.mp3", "stream"),
        love.audio.newSource(m .. "jazz2.mp3", "stream"),
        love.audio.newSource(m .. "techno.mp3", "stream"),
        love.audio.newSource(m .. "future.mp3", "stream")
    }


    math.randomseed(os.time())
    math.random(); math.random(); math.random()


    left_key, right_key = "left", "right"
    player_img = love.graphics.newImage("images/rakett.png")
    -- explo_video = love.graphics.newVideo("images/explo.mkv")

    init()
end

function getBlock()
    return math.random(120, window_width-120), -50, 120+(100*points), 50
end

function gameover()
    love.graphics.clear(1, 1, 0, 0.8)
end

function keypresses()
    if love.keyboard.isDown(left_key) then
        x = player.body:getX() - sens
        if x < 0 then
            x = 0
        end
        player.body:setX(x)
    end
    if love.keyboard.isDown(right_key) then
        x = player.body:getX() + sens
        if x > player_window_width then
            x = player_window_width
        end
        player.body:setX(x)
    end

end

function chechIfBlockHitBottom(object)
    local y = object.body:getY()
    if y > window_height then
        x, y, w, h = getBlock()
        print("Block", x, y, w, h)
        object.body:setX(x)
        object.body:setY(y)
        -- object.shape:destroy()
        ----  object.shape = love.physics.newRectangleShape(w, h)
        points = points + 1
    end
    if y == -50 then
        if object.attr == "shady" then
            if math.random(1, 300) ~= 1 then
                object.notSpawn = true
            else
                object.notSpawn = false
            end
        end

    end
    --[[ if shady_block_y > window_height then
        shady_block_y = 0 - shady_block_h
        points = points + 1
        if math.random(1, 300) == 1 then
            shady_block_x, shady_block_y, shady_block_w, shady_block_h = getBlock()
        end
    end --]]

end

function speedOnBlocks(object, dt)
    local current_y = object.body:getY()
    local attr = object.attr
    if attr == "normal" then
        y = current_y + (speed * 100 * dt)
        -- bør ha et table
        if points > 50 then
            speed = 220
        elseif points > 35 then
            speed = 190
        elseif points > 25 then
            speed = 170
        elseif points > 20 then
            speed = 150
        elseif points > 15 then
            speed = 125
        elseif points > 10 then
            speed = 100
        end
    elseif attr == "shady" then
        -- bare spawn shady speedblokker av og til
        if object.notSpawn == false then
            y = current_y
            if y > 100 then
                y = y * (math.ceil(y/500) + 0.1)
            else
                y = y + 2
            end
        else
            y = current_y
        end
    else
        print("object has no attr")
        print(object.attr)
    end
    object.body:setY(y)
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
    if gamestate == "start" then
        init()
    elseif gamestate == "play" then
        speed = (2 + speed * dt) + (points/70)

        for i, block in pairs(objects) do
            speedOnBlocks(block, dt)
            chechIfBlockHitBottom(block)
        end

        keypresses()
        world:update(dt)
    end
end



function love.keypressed(key)
    if key == 'escape' then
        love.event.quit() -- Quit the game.
    end
end
function love.mousepressed(x, y, button)
    if gamestate == "start" then
        if button == 1 then
            local mouse_x = love.mouse.getX()
            local mouse_y = love.mouse.getY()
            if mouse_x >= 100 and mouse_x <= 290 then
                if mouse_y >= 100 and mouse_y <= 150 then
                    sel_up:play()
                    love.timer.sleep(0.2)
                    music_song = music[math.random(1,4)]
                    music_song:play()
                    gamestate = "play"
                elseif mouse_y >= 165 and mouse_y <= 215 then
                    sens = math.min(sens + 2, 50)
                    sel_up:play()
                elseif mouse_y >= 230 and mouse_y <= 280 then
                    sens = math.max(sens - 2, 1)
                    sel_down:play()
                elseif mouse_y >= 295 and mouse_y <= 345 then
                    ad_sfx:play()
                elseif mouse_y >= 360 and mouse_y <= 410 then
                    menu_sfx:play()
                    love.timer.sleep(0.3)
                    love.event.quit()
                end
            end
        end
    elseif gamestate == "gameover" then
        if button == 1 then
            local mouse_x = love.mouse.getX()
            local mouse_y = love.mouse.getY()
            if mouse_x >= window_width/2-80 and mouse_x <= window_width/2+80 then
                if mouse_y >= window_height/2-30 and mouse_y <= window_height/2+60 then
                    menu_sfx:play()
                    gamestate = "start"
                end
            end
        end

    end
end

local function menu()
    love.graphics.setColor(0, 0.8, 0.4)
    love.graphics.rectangle("fill", 100, 100, 190, 50)
    love.graphics.setColor(0, 0.4, 0.7)
    love.graphics.rectangle("fill", 100, 165, 190, 50)
    love.graphics.rectangle("fill", 100, 230, 190, 50)
    love.graphics.rectangle("fill", 100, 295, 190, 50)
    love.graphics.setColor(1, 0.0, 0.1)
    love.graphics.rectangle("fill", 100, 360, 190, 50)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.print("Spill!", 109, 107)
    love.graphics.print("Mer sens", 109, 172)
    love.graphics.print("Mindre sens", 109, 237)
    love.graphics.print("Leaderboard", 109, 302)
    love.graphics.print("Quit", 109, 367)

    love.graphics.setFont(smallFont)
    love.graphics.print("Sens " .. sens, 100, 8)
    if sens == 50 then
        love.graphics.print("Feite Ku! Det holder", 180, 8)
    end

    love.graphics.draw(player.img, 380, 150, 0, 2)
end


-- Draw a coloured rectangle.
function love.draw()
    love.graphics.setBackgroundColor(0.05, 0.18, 0.21, 0.8)

    if gamestate == "play" then
        love.graphics.setColor(0.6, 0.8, 0.9)

        for _, body in pairs(world:getBodies()) do
            for _, fixture in pairs(body:getFixtures()) do
                local shape = fixture:getShape()
                local fixtureData = fixture:getUserData()
                if fixtureData ~= "Player" then
                    love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
                elseif fixtureData == "Player" then
                    love.graphics.draw(player.img, player.body:getX()+player_width, player.body:getY()+player_height, player.body:getAngle(),
                        1, 1, player_width,  player_height)
                end

                -- ToDo Draw collision
            end
        end
        --   love.graphics.draw(player.img, player.shape:getPoints())
    elseif gamestate == "start" then
        menu()
    elseif gamestate == "gameover" then
        love.graphics.clear(0.7, 0.1, 0, 0.8)
        love.graphics.setFont(largeFont)
        love.graphics.print(points, window_width/2-10, window_height/3)
        love.graphics.rectangle("fill", window_width/2-80, window_height/2-30, 160, 60)
        love.graphics.setFont(font)
        love.graphics.setColor(0.1, 0.3, 0.8)
        love.graphics.print("Til meny", window_width/2-60, window_height/2-15)
    end
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 0.7, 0.2)
    love.graphics.print("Poeng " .. points, 8, 8)
end

-- Kræsjing
function beginContact(a, b, coll)
    print("kræsj", a, b, coll)
    music_song:pause()
    krasj_sfx:play()
    gamestate = "gameover"
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end
