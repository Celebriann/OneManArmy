function love.load()
	love.window.setMode(1280, 720, {vsync=1}) --parametres de la fenêtre

	sti = require 'libraries/sti' --pour importer la map faites sur tiledmap
	anim8 = require 'libraries/anim8' --pour les mouvements
	camera = require 'libraries/camera' --pour la camera
	wf = require 'libraries/windfield' -- collisions
	world = wf.newWorld(0, 0)

	cam = camera()
	love.graphics.setDefaultFilter("nearest", "nearest") --pour eviter que le joueur soit flou lorsqu'on le redimenssione 

	gameMap = sti('assets/map/tiledmap/map1.lua')
	lifeTime = 0
	delay = 0
	Timer = 0
	direction = 'right'

	player = {} --on définis le joueur
	player.x = 640
	player.y = 1000
	player.speed = 150
	player.bullet = 5
	player.collider = world:newBSGRectangleCollider(player.x, player.y, 38, 35, 10)
	player.collider:setFixedRotation(true)
	player.spriteSheet = love.graphics.newImage('assets/player/walk.png')
	player.grid = anim8.newGrid(80, 80, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
	player.animations = {}
	player.animations.down = anim8.newAnimation(player.grid('1-8', 2), 0.2)
	player.animations.top = anim8.newAnimation(player.grid('1-8', 3), 0.2)
	player.animations.right = anim8.newAnimation(player.grid('1-8', 1), 0.2)
	player.animations.left = anim8.newAnimation(player.grid('8-1', 4), 0.2)
	player.anim = player.animations.right

	bullet = {}
	bullet.x = 640
	bullet.y = 1000
	bullet.speed = 5
	bullet.lifeTime = 5
	bullet.sprite = love.graphics.newImage('assets/power/bullet.png')

	bulletAmount = {}

	worldhitbox = {}
	if gameMap.layers["hitbox"] then
		for i, obj in pairs(gameMap.layers["hitbox"].objects) do
			local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
			wall:setType("static")
			table.insert(worldhitbox, wall)
		end
	end

	
end	
function love.update(dt)
	local isMoving = false --mouvements

	local vx = 0
	local vy = 0

	

	delay = delay + dt
	Timer = Timer + dt

	if love.keyboard.isDown("right") then
		vx = player.speed
		player.anim = player.animations.right
		isMoving = true
		direction = 'right'
	end
	if love.keyboard.isDown("left") then
		vx = player.speed * -1
		player.anim = player.animations.left
		isMoving = true
		direction = 'left'
	end
	if love.keyboard.isDown("down") then
		vy = player.speed
		player.anim = player.animations.down
		isMoving = true
		direction = 'down'
	end
	if love.keyboard.isDown("up") then
		vy = player.speed * -1
		player.anim = player.animations.top
		isMoving = true
		direction = 'up'
	end

	player.collider:setLinearVelocity(vx, vy)

	if isMoving == false then
		player.anim:gotoFrame(1)	
	end

	--show power
	if love.keyboard.isDown('a') and delay >= 0.2 and player.bullet ~= 0 then
		print(direction)
		table.insert(bulletAmount, {x = player.x, y = player.y, t = math.floor(Timer), d = direction}) -- x = coo x du spawn, y = coo y du spawn, t = moment ou la balle à spawn, d = trajectoire de la balle
		delay = 0
		player.bullet = player.bullet - 1
		
	elseif player.bullet == 0 and delay >= 3 then
		player.bullet = 5
		delay = 0
	end
	if bulletAmount ~= nil then
		for i, currentBullet in ipairs(bulletAmount) do
			if math.floor(Timer) == currentBullet.t + bullet.lifeTime then
				table.remove(bulletAmount, i)
			end
		end
		for i, currentBullet in ipairs(bulletAmount) do
			if currentBullet.d == 'right' then 
				currentBullet.x = currentBullet.x + bullet.speed
			end
			if currentBullet.d == 'left' then 
				currentBullet.x = currentBullet.x - bullet.speed
			end
			if currentBullet.d == 'down' then 
				currentBullet.y = currentBullet.y + bullet.speed
			end
			if currentBullet.d == 'up' then 
				currentBullet.y = currentBullet.y - bullet.speed
			end
		end	
	end


	player.anim:update(dt)

	world:update(dt)
	player.x = player.collider:getX()
	player.y = player.collider:getY()
	cam:lookAt(player.x, player.y)
end
function love.draw(dt)
	cam:zoomTo(2)
	cam:attach()--gère la caméra
		gameMap:drawLayer(gameMap.layers["ground_grass"])
		gameMap:drawLayer(gameMap.layers["ground_stone"])
		gameMap:drawLayer(gameMap.layers["props_under"])
		gameMap:drawLayer(gameMap.layers["wallground"])
		gameMap:drawLayer(gameMap.layers["walls"])
		gameMap:drawLayer(gameMap.layers["props_over"])
		gameMap:drawLayer(gameMap.layers["stairs"])
		player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2.4, nil, 40, 40)
		--world:draw()
		
		showPower()
	cam:detach()
end
function showPower()
	for i, currentBullet in ipairs(bulletAmount) do
		local lastbullet = bulletAmount[#bulletAmount]
		love.graphics.draw(bullet.sprite, currentBullet.x, currentBullet.y, 1, 1)
	end
end