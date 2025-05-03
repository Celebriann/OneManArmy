function love.load()
	love.window.setMode(1280, 720, {vsync=1}) --parametres de la fenêtre
	--love.mouse.setGrabbed(true)

	sti = require 'libraries/sti' --pour importer la map faites sur tiledmap
	anim8 = require 'libraries/anim8' --pour les mouvements
	camera = require 'libraries/camera' --pour la camera
	wf = require 'libraries/windfield' -- collisions
	world = wf.newWorld(0, 0)

	cam = camera()
	love.graphics.setDefaultFilter("nearest", "nearest") --pour eviter que le joueur soit flou lorsqu'on le redimenssione 

	gameMap = sti('assets/map/tiledmap/map2.lua')
	lifeTime = 0
	delay = 0
	Timer = 0
	direction = 'right'
	mouseClick = {x = 0, y = 0}

	isPaused = false

	player = {} --on définis le joueur
	player.x = 640
	player.y = 1000
	player.speed = 150
	player.bullet = 5
	player.collider = world:newBSGRectangleCollider(player.x, player.y, 38, 35, 10)
	player.collider:setFixedRotation(true)
	world:addCollisionClass('player')
	player.collider:setCollisionClass('player')
	player.spriteSheet = love.graphics.newImage('assets/player/walk.png')
	player.grid = anim8.newGrid(80, 80, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
	player.animations = {}
	player.animations.down = anim8.newAnimation(player.grid('1-8', 2), 0.2)
	player.animations.top = anim8.newAnimation(player.grid('1-8', 3), 0.2)
	player.animations.right = anim8.newAnimation(player.grid('1-8', 1), 0.2)
	player.animations.left = anim8.newAnimation(player.grid('8-1', 4), 0.2)
	player.anim = player.animations.right

	bob = {}
	bob.x = 20
	bob.y = 20
	bob.speed = 100
	bob.collider = world:newBSGRectangleCollider(bob.x, bob.y, 2, 2, 1)
	bob.collider:setFixedRotation(true)
	world:addCollisionClass('bob')
	bob.collider:setCollisionClass('bob')
	bob.spriteSheet = love.graphics.newImage('assets/ennemies/default_enemies.png')
	bob.grid = anim8.newGrid(80, 60, bob.spriteSheet:getWidth(), bob.spriteSheet:getHeight())
	bob.animations = {}
	bob.animations.down = anim8.newAnimation(bob.grid('1-8', 2), 0.2)
	bob.animations.top = anim8.newAnimation(bob.grid('1-8', 3), 0.2)
	bob.animations.right = anim8.newAnimation(bob.grid('1-8', 1), 0.2)
	bob.animations.left = anim8.newAnimation(bob.grid('8-1', 4), 0.2)
	bob.anim = bob.animations.right

	bullet = {}
	bullet.x = player.x
	bullet.y = player.y
	bullet.speed = 100
	bullet.lifeTime = 5
	bullet.sprite = love.graphics.newImage('assets/power/bullet.png')
	--bullet.collider = world:newBSGRectangleCollider(player.x, player.y, 1, 1, 1)
	--bullet.collider:setFixedRotation(true)
	--world:addCollisionClass("bullet")
	--bullet.collider:setCollisionClass("bullet")

	ui = {}
	ui.gameover = {}
	ui.gameover.sprite = love.graphics.newImage('assets/ui/game_over.png')

	bullets = {}

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
	if not isPaused then
		local isMoving = false --mouvements

		local vx = 0
		local vy = 0

		local bvx = 0
		local bvy = 0

		local tempX = {}
		local tempY = {}
		
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
		if love.keyboard.isDown("e") then
			player.speed = 170
		end
		player.collider:setLinearVelocity(vx, vy)

		if isMoving == false then
			player.anim:gotoFrame(1)	
		end

		--show power

		for i, ball in ipairs(bullets) do
			ball.x = ball.x + ball.vx * dt
			ball.y = ball.y + ball.vy * dt
			
			
		end

		------------
		
		if bob.x <= player.x then --mouvements des ennemies (ils suivent la position du joueur)
			bvx = bob.speed
		end
		if bob.y <= player.y then
			bvy = bob.speed
		end
		if bob.x >= player.x then
			bvx = bob.speed * -1
		end
		if bob.y >= player.y then
			bvy = bob.speed * -1
		end
		--bob.collider:setLinearVelocity(bvx, bvy)

		if player.collider:enter('bob') then
			print("killed")
			isPaused = true
			love.mouse.setGrabbed(false)
		end

		for i, currentBullet in ipairs(bullets) do
			if currentBullet.x >= bob.x - 40 and currentBullet.x <= bob.x + 40 and currentBullet.y >= bob.y - 40 and currentBullet.y <= bob.y + 40 then
				print("test")
			end
		end

		player.anim:update(dt)
		bob.anim:update(dt)

		world:update(dt)
		player.x = player.collider:getX()
		player.y = player.collider:getY()
		bob.x = bob.collider:getX()
		bob.y = bob.collider:getY()
		cam:lookAt(player.x, player.y)
	else --ce qui doit pouvoir être fait quand le jeu est en pause mais uniquement là
		if love.keyboard.isDown('e') then
			isPaused = false
		end
	end
end
function love.draw(dt)
	cam:zoomTo(1.5)
	cam:attach()--gère la caméra
		gameMap:drawLayer(gameMap.layers["ground"])
		--gameMap:drawLayer(gameMap.layers["ground_stone"])
		--gameMap:drawLayer(gameMap.layers["props_under"])
		--gameMap:drawLayer(gameMap.layers["wallground"])
		--gameMap:drawLayer(gameMap.layers["walls"])
		--gameMap:drawLayer(gameMap.layers["props_over"])
		--gameMap:drawLayer(gameMap.layers["stairs"])
		player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2.4, nil, 40, 40)
		bob.anim:draw(bob.spriteSheet, bob.x, bob.y, nil, 2.4, nil, 40, 40)
		--world:draw()
		if isPaused then
			love.graphics.draw(ui.gameover.sprite, player.x - 320, player.y - 64, nil, 5)
			
		end
		for i, ball in ipairs(bullets) do
			love.graphics.draw(bullet.sprite, ball.x, ball.y, 1, 1)
		end
	cam:detach()
end
function togglePause()
	isPaused = not isPaused
end
function love.mousepressed(x, y, button, isTouch, presses)
	if button == 1 then

		local worldX, worldY = cam:worldCoords(x, y)

		local dx = worldX - player.x
		local dy = worldY - player.y
		local distance = math.sqrt(dx^2 + dy^2)

		if distance > 0 then
			dx = dx / distance
			dy = dy / distance
		end

		vx = dx * bullet.speed
		vy = dy * bullet.speed

		

		--[[if player.x <= x and player.y <= y then -- quadrant supérieur gauche
			vx = vx
			vy = vy
		end
		if player.x >= x and player.y <= y then -- quadrant supérieur droit
			vx = vx * -1
			vy = vy
		end
		if player.x <= x and player.y >= y then -- quadrant inférieur gauche
			vx = vx
			vy = vy * -1
		end
		if player.x >= x and player.y >= y then -- quadrant inférieur droit
			vx = vx * -1
			vy = vy * -1
		end]]--
		print("dx: "..dx..", dy: "..dy..", magnitude: "..distance..", vx: "..vx..", vy: "..vy)
		--bullet.x = player.x
		--bullet.y = player.y
		local newBullet = {x = player.x, y = player.y, vx = vx, vy = vy, dx = x, dy = y}
	
		table.insert(bullets, newBullet)
	end
end