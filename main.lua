function love.load()	
	love.graphics.setFont(love.graphics.newFont(11)) -- load font for text

	lobby = true

	log = {}
	message = ""
	table.insert(log,message)

	AI = {}
	newAI = {Angle = 0, Pos = {x=550, y=250, width=20, height=20}, img = love.graphics.newImage("t.png"), health = 1000}
	table.insert(AI,newAI)

	NPC = {}
	newNPC = {Pos = {x=400, y=550, width=20, height=20}, img = love.graphics.newImage("c.png")}
	table.insert(NPC,newNPC)

	SPEED = 500
	StartPos = {x=250, y=250, width=20, height=20}	--The starting point that the bullets are fired from, acts like the shooter.
	bullets={}
	hero = love.graphics.newImage("c.png")
	damage = -100

	items = {'a','b','c','d','e'}

	invo = {}

	-- Load the "cursor" as crosshair
	curs = love.graphics.newImage("x.png")
    -- Hide the default mouse.
    love.mouse.setVisible(false)
    -- movement limits
    xMax, yMax = love.graphics.getDimensions()
    xMax = xMax - 40
    yMax = yMax - 40

	-- shooting delay    
    delay = false
    delta = 0
    shoottime = 0.15
    ammo = 15
    getammo = false
    killcount = 0
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Ammo = " .. ammo, 20, 20)
	love.graphics.print("Kill Count = " .. killcount, 700, 20)
	for i,v in ipairs(log) do
		if i < 6 then
			love.graphics.print(log[i], 50, 500+12*i)
		else
			table.remove(log,i-5)
			love.graphics.print(log[i-5], 50, 500+12*(i-5))
		end
	end
	--Sets the color to white
	love.graphics.setColor(255, 255, 255)
	-- draws the mouse cursor
	love.graphics.draw(curs, love.mouse.getX(), love.mouse.getY())
	-- draws the player from assigned image
	love.graphics.draw(hero, StartPos.x, StartPos.y)

	if lobby then
		for i,v in pairs(NPC) do
			-- draws npc from assigned image
			love.graphics.draw(v.img, v.Pos.x, v.Pos.y)

			if checkCollision(StartPos.x,StartPos.y,v.Pos.x,v.Pos.y,10,10) and love.keyboard.isDown("e") then
				table.insert(log,"NPC: Have some ammo")
				getammo = true
			end
		end

		-- area change
		if StartPos.y < 50 then
			table.insert(log,"You enter the battlefield")
			StartPos.y = 550
			lobby = false
		end
	end
	
	if not lobby then
		love.graphics.setColor(255, 255, 255)
		--This loops the whole table to get every bullet. Consider v being the bullet.
		for i,v in pairs(bullets) do
			love.graphics.circle("fill", v.x, v.y, 2,4)
			-- loops through all AI to check collisions, manage health etc
			for j,w in pairs(AI) do
				if checkCollision(v.x,v.y,w.Pos.x+10,w.Pos.y+10,4,12) then
				
					w.health = w.health + damage --reduce health on collision
					love.graphics.print(damage,w.Pos.x-30, w.Pos.y+5)

					table.remove(bullets,i)
					if w.health <= 0 then
						table.remove(AI,j)
						killcount = killcount + 1
						table.insert(log,"You killed an enemy!")
						loot = love.math.random(1,5)
						table.insert(invo,items[loot])
						table.insert(log,items[loot] .. " added to your inventory")
					end
				end
			end
		end

		--Sets the color to red and draws the "ai".
		love.graphics.setColor(255, 0, 0)
	
		for i,v in pairs(AI) do
			love.graphics.print(v.health, v.Pos.x-5, v.Pos.y-15)
			-- draw ai from assigned image
			if v.health > 0 then
				love.graphics.draw(v.img, v.Pos.x, v.Pos.y)
			end
		end

		-- area change
		if StartPos.y > 550 then
			table.insert(log,"You enter the lobby")
			StartPos.y = 50
			lobby = true
		end
	end
end

function love.update(dt)
	if delay then
		delta = delta + dt
		if delta > shoottime then
			delay = false
			delta = 0
		end
	end

	if getammo then
		ammo = ammo + 10
		getammo = false
	end

	-- 'Esc' to quit
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	-- wasd movement handling
	if love.keyboard.isDown("a") then
		if StartPos.x > 20 then
			StartPos.x = StartPos.x - 250 * dt
		else
			StartPos.x = StartPos.x
		end
    end
    if love.keyboard.isDown("d") then
    	if StartPos.x < xMax then
			StartPos.x = StartPos.x + 250 * dt
		else
			StartPos.x = StartPos.x
		end
    end
    if love.keyboard.isDown("w") then
    	if StartPos.y > 20 then
			StartPos.y = StartPos.y - 250 * dt
		else
			StartPos.y = StartPos.y
		end
    end
    if love.keyboard.isDown("s") then
    	if StartPos.y < yMax then
			StartPos.y = StartPos.y + 250 * dt
		else
			StartPos.y = StartPos.y
		end
    end
    if love.keyboard.isDown("q") then
    	xloc = love.math.random(0, 800)
    	yloc = love.math.random(0, 600)
    	newAI = {Angle = 0, Pos = {x=xloc, y=yloc, width=20, height=20}, img = love.graphics.newImage("t.png"), health = 1000}
		table.insert(AI,newAI)
    end

    for i,v in pairs(AI) do
    	-- ai movement test
   	 	v.Angle = v.Angle + dt;
    	v.Pos.x = v.Pos.x + math.cos(v.Angle)*1
    	v.Pos.y = v.Pos.y + math.sin(v.Angle)*1
    end

	if love.mouse.isDown(1) and not delay and ammo > 0 then
		--Sets the starting position of the bullet, this code makes the bullets start in the middle of the player.
		local startX = StartPos.x + StartPos.width / 2
		local startY = StartPos.y + StartPos.height / 2
		
		local targetX, targetY = love.mouse.getPosition()
	  
		--Basic maths and physics, calculates the angle so the code can calculate deltaX and deltaY later.
		local angle = math.atan2((targetY - startY), (targetX - startX))
		
		--Creates a new bullet and appends it to the table we created earlier.
		newbullet={x=startX,y=startY,angle=angle}
		table.insert(bullets,newbullet)
		ammo = ammo - 1
		delay = true
	end
	
	for i,v in pairs(bullets) do
		local Dx = SPEED * math.cos(v.angle)		--Physics: deltaX is the change in the x direction.
		local Dy = SPEED * math.sin(v.angle)
		v.x = v.x + (Dx * dt)
		v.y = v.y + (Dy * dt)

		--Cleanup code, removes bullets that exceeded the boundries:
		if v.x > love.graphics.getWidth() or
		   v.y > love.graphics.getHeight() or
		   v.x < 0 or
		   v.y < 0 then
			table.remove(bullets,i)
		end
	end
end

function checkCollision(ax, ay, bx, by, ar, br)
	-- returns true if the circles are touching, false if not
	local dx = bx - ax
	local dy = by - ay
	local dist = math.sqrt(dx * dx + dy * dy)
	return dist < ar + br
end