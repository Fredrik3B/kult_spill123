-- Load some default values for our rectangle.
function love.load()
    -- Verden uten gravity
    world = love.physics.newWorld(0, 0, true)

    sens = 10
    window_height = love.graphics.getHeight()
    window_width = love.graphics.getWidth()


    math.randomseed(os.time())
    block_x, block_y, block_w, block_h = getBlock()
    shady_block_x, shady_block_y, shady_block_w, shady_block_h = 0, -50, 120, 50
    window_height = love.graphics.getHeight()
    speed = 50

    left_key, right_key = "left", "right"
    points = 0

    player_x, player_y = window_height - 200, window_width/2

    -- Spiller og blokker
    objects = {}
    player = {}

    player.img = love.graphics.newImage("images/rakett.png")
    player.body = love.physics.newBody(world, player_x, player_y)
    player.shape = love.physics.newRectangleShape(player_x, player_y)
    player.fixture = love.physics.newFixture(player.body, player.shape)

    objects.shady_block = {}
    objects.shady_block.attr = "shady"
    objects.shady_block.notSpawn = false
    objects.shady_block.body = love.physics.newBody(world, shady_block_x, shady_block_y) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    objects.shady_block.shape = love.physics.newRectangleShape(shady_block_x, shady_block_y) --make a rectangle with a width of 650 and a height of 50
    objects.shady_block.fixture = love.physics.newFixture(objects.shady_block.body, objects.shady_block.shape) --attach shape to body


    objects.block = {}
    objects.block.attr = "normal"
    objects.block.body = love.physics.newBody(world, block_x, block_y) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    objects.block.shape = love.physics.newRectangleShape(block_x, block_y) --make a rectangle with a width of 650 and a height of 50
    objects.block.fixture = love.physics.newFixture(objects.block.body, objects.block.shape) --attach shape to body

end

function getBlock()
    return math.random(0, window_width-120), -50, 120, 50
end

function keypresses()
    if love.keyboard.isDown(left_key) then
        player_x = player_x - sens
        print(player_x)
    end
    if love.keyboard.isDown(right_key) then
        player_x = player_x + sens
        print(player_x)
    end
end

function chechIfBlockHitBottom(object)
    local y = object.body:getY()
    print("y", y, window_height)
    if y > window_height then
        x, y, w, h = getBlock()
        object.body:setX(x)
        object.body:setY(y)
        points = points + 1
        print(points)
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

function speedOnBlocks(object)
    local current_y = object.body:getY()
    local attr = object.attr
    print(current_y, speed, attr)
    if attr == "normal" then
        y = current_y + speed --* dt
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
    speed = (2 + speed * dt) + (points/70)
    print("speed", speed)

    for i, block in pairs(objects) do
        print("iter")
        speedOnBlocks(block)
        chechIfBlockHitBottom(block)
    end

    keypresses()
    -- print(points)
    world:update(dt)
end



function love.keypressed(key)
    if key == 'escape' then
        love.event.quit() -- Quit the game.
    end
end


-- Draw a coloured rectangle.
function love.draw()
    -- In versions prior to 11.0, color component values are (0, 102, 102)
    love.graphics.setColor(0.6, 0.8, 0.9)
    love.graphics.rectangle("fill", objects.block.body:getX(), objects.block.body:getY(), block_w, block_h)
    love.graphics.rectangle("fill", objects.shady_block.body:getX(), objects.shady_block.body:getY(), block_w, block_h)
    love.graphics.draw(player, player_x, player_y)


end
