-- Player
player = { x = 200, y = 600, speed = 450, img = nil }
isAlive = true
score = 0

-- Player shooting timers
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

-- Player bullets
bulletImg = nil
bullets = {}

-- Enemies
-- Enemy spawn timers
createEnemeyTimerMax = 0.4
createEnemeyTimer = createEnemeyTimerMax

enemyImg = nil

enemies = {}


-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end


function love.load(arg)
  -- Load player assets
	player.img = love.graphics.newImage('assets/Aircraft_04.png')
	bulletImg = love.graphics.newImage('assets/bullet_2_orange.png')
  -- Enemy assets
	enemyImg = love.graphics.newImage('assets/Aircraft_06.png')
end


function love.update(dt)
  -- Esc quits the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

  -- Player controls
  -- Movement
	if love.keyboard.isDown('left', 'a') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
		end
	elseif love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed * dt)
		end
	end

  -- Shooting
	canShootTimer = canShootTimer - (1 * dt)

	if canShootTimer < 0 then
		canShoot = true
	end

	if love.keyboard.isDown('space', 'rctrl', 'lctrl', 'ctrl') and canShoot then
    -- Spawn new bullet
		newBullet = {
			x = player.x + (player.img:getWidth() / 2),
			y = player.y,
			img = bulletImg
		}
		-- Add to bullets array
		table.insert(bullets, newBullet)
    -- Reset timer vars
		canShoot = false
		canShootTimer = canShootTimerMax
	end

  -- Update bullets postion
	for i,bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

    -- Remove bullets from the array when the pass off the screen
		if bullet.y < 0 then
			table.remove(bullets, i)
		end
	end

  -- Spawn enemies
	createEnemeyTimer = createEnemeyTimer - (1 * dt)
	if createEnemeyTimer < 0 and isAlive then
    -- Rest enemy spawn timer
		createEnemeyTimer = createEnemeyTimerMax

    -- Spaw new enemy at random location
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = {
			x = randomNumber,
			y = -50,
			img = enemyImg
		}
		table.insert(enemies, newEnemy)
	end

  -- Move spawned enemies
	for i,enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

    -- Remove enemies when they leave the screen
		if enemy.y > 800 then
			table.remove(enemies, i)
		end
	end

  -- Check collisions for enemy & bullet
	for i,enemy in ipairs(enemies) do
		for j,bullet in ipairs(bullets) do
			if CheckCollision(
				enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
				bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()
			) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 10
			end
		end

		-- Check collisions for enemy & player
		if CheckCollision(
			enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
			player.x, player.y, player.img:getWidth(), player.img:getHeight()
		) and isAlive then
			table.remove(enemies, i)
			isAlive = false
		end
	end

  -- Restarting the game
	if not isAlive and love.keyboard.isDown('r') then
    -- Remove all bullets & enemies
		bullets = {}
		enemies = {}

    -- Reset spawn timers
		canShootTimer = canShootTimerMax
		createEnemeyTimer = createEnemeyTimerMax

    -- Reset player position
		player.x = 200
		player.y = 600

    -- Reset game state
		score = 0
		isAlive = true
	end
end -- love.update()


function love.draw(dt)
  -- Render player assets
	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print(
			'Press "R" to restart',
			love.graphics:getWidth() / 2 - 50,
			love.graphics:getHeight() / 2 - 10
		)
	end

  -- Render bullets in the bullets array
	for i,bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

  -- Render spawned enemies
	for i,enemy in ipairs(enemies) do
		love.graphics.draw(
			enemy.img,
			enemy.x, enemy.y, -- Position
			math.pi, -- Rotate enemies so they face the player
			1, 1, -- Scale
			enemy.img:getWidth() / 2,
			enemy.img:getHeight() / 2 -- Origin offset (rotate around centre)
		 )
	end
end
