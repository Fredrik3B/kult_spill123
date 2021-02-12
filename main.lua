HC = require 'HC'

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
	player = love.graphics.newImage("bilder/rakett.png")
	
	-- Spiller og blokker 
	objects = {}
	player = {}

	objects.block = {}
	objects.block.body = love.physics.newBody(world, block_x/2, block_x-block_y/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
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

-- Increase the size of the rectangle every frame.
function love.update(dt)
	if block_y > window_height then
		block_x, block_y, block_w, block_h = getBlock()
		points = points + 1
	end
	if shady_block_y > window_height then
		shady_block_y = 0 - shady_block_h
		points = points + 1
		if math.random(1, 300) == 1 then
			shady_block_x, shady_block_y, shady_block_w, shady_block_h = getBlock()
		end
	end
		
    block_y = block_y + speed * dt
	
	if shady_block_y > 100 then 
		shady_block_y = shady_block_y * (math.ceil(shady_block_y/500) + 0.1)
	else 
		shady_block_y = shady_block_y + 2
	end
	speed = speed + 4 * dt
	
	keypresses()
	print(points)
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
    -- love.graphics.rectangle("fill", shady_block_x, shady_block_y, shady_block_w, shady_block_h)
	-- love.graphics.draw(player, player_x, player_y)
	
	
end