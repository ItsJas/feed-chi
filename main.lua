
cat = {}
food = {}
bomb = {}

platform = {}

function love.load()

--background and window
  background = love.graphics.newImage("images/nature.jpg")
  love.window.setTitle("Feed Chi!")
  music = love.audio.newSource("sounds/Autumn-day-easy-listening-music.mp3", "stream")
  music:setLooping(true)
  music:play()

--cat related variables
  cat.x = love.graphics.getWidth()/2
  cat.y = 2 * love.graphics.getHeight()/3
  cat.speed = 200
  -- right, right jump, right meowing, left ..., dead
  cat.sprites = {"images/r.png","images/ru.png","images/er.png","images/l.png","images/lu.png","images/el.png","images/dc.png"}
  cat.look = 3 
  cat.img = love.graphics.newImage(cat.sprites[cat.look])
  cat.y_velocity = 0
  cat.jump_height = -300
  cat.gravity = -500
  cat.ground = cat.y
  cat.sound = love.audio.newSource("sounds/Cat-sound-effect.mp3", "static")

--food variables
  for i = 1, 10 do
    love.math.random()
  end
  food.sprites = {"images/fu.png","images/fd.png","images/candy.png","images/lollipop.png"}
  food.look = 2
  food.img = love.graphics.newImage(food.sprites[food.look])
  food.x = love.math.random(food.img:getWidth()/2, love.graphics.getWidth()-food.img:getWidth()/2)
  food.y = 0
  food.gravity = -300
  food.draw = true
  food.next = false

--bomb variables
  bomb.sprites = {"images/bomb.png","images/bombexp.png"}
  bomb.img = love.graphics.newImage(bomb.sprites[1])
  bomb.x = love.math.random(food.img:getWidth()/2, love.graphics.getWidth()-food.img:getWidth()/2)
  bomb.y = 0
  bomb.gravity = -400
  bomb.draw = false
  bomb.next = true
  bomb.sound = love.audio.newSource("sounds/Bomb-sound-effect.mp3", "static")

end

function collision(a, b)
aw, ah = a.img:getDimensions()
bw, bh = b.img:getDimensions()
aw = aw/2 
ah = ah/2 
bw = bw/2
bh = bh/2

return a.x < (b.x + bw) and b.x < (a.x + aw) and a.y < (b.y + bh) and b.y < (a.y + ah)
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end


local foodDelay = 0
local bombDelay = 0
local score = 0
is_dead = false
function love.update(dt)

  is_eating = false

  if is_dead == false then
    if cat.look < 4 then
      cat.look = 3
    else
      cat.look = 6
    end

    if love.keyboard.isDown("right") then
      if cat.x < (love.graphics.getWidth() - cat.img:getWidth()/2) then
        cat.look = 1
        cat.x = cat.x + (cat.speed * dt)
      end
    elseif love.keyboard.isDown("left") then
      if cat.x > 0 then
        cat.look = 4
        cat.x = cat.x - (cat.speed * dt)
      end
    end

    if love.keyboard.isDown('up') then
      if cat.y_velocity == 0 then
        cat.y_velocity = cat.jump_height
      end
      if cat.look < 4 then
        cat.look = 2
      else
        cat.look = 5
      end
    end

    if cat.y_velocity ~= 0 then
      cat.y = cat.y + cat.y_velocity * dt  
      cat.y_velocity = cat.y_velocity - cat.gravity * dt
    end

    if cat.y > cat.ground then
      cat.y_velocity = 0
      cat.y = cat.ground
      if cat.look > 1 then
        cat.look = cat.look - 1
      end
    end


    if food.y < (3 * love.graphics.getWidth()/4 - food.img:getWidth()) and food.draw then
      food.y = food.y - food.gravity * dt
    else
      hey = true
      food.draw = false
      food.y = 0
      food.next = true
    end

    if bomb.y < (3 * love.graphics.getWidth()/4 - food.img:getWidth()) and bomb.draw then
      bomb.y = bomb.y - bomb.gravity * dt
    else
      --hey = true
      bomb.draw = false
      bomb.y = 0
      bomb.next = true
    end

    foodDelay = foodDelay + dt

    if (food.next and foodDelay > 3) then
      food.x = love.math.random(food.img:getWidth()/2, love.graphics.getWidth()-food.img:getWidth()/2)
      food.y = 0
      food.look = love.math.random(1,4)
      food.draw = true
      food.next = false
      foodDelay = 0
    end

    bombDelay = bombDelay + dt
    if (bomb.next and bombDelay > 5) then
      bomb.x = love.math.random(bomb.img:getWidth()/2, love.graphics.getWidth()-bomb.img:getWidth()/2)
      bomb.y = 0
      bomb.draw = true
      bomb.next = false
      bombDelay = 0
    end

    food.img = love.graphics.newImage(food.sprites[food.look])
    bomb.img = love.graphics.newImage(bomb.sprites[1])
    is_eating = collision(cat, food)
    is_dead = collision(cat, bomb)

    if is_eating == true then
      print ("cat is eating!")
      cat.sound:play()
      food.y = 0
      food.draw = false
      food.next = true
      score = score + 50
      print (score)
    end
    if is_dead == true then
      print ("cat is dead!")
      bomb.sound:play()
      bomb.img = love.graphics.newImage(bomb.sprites[2])
      cat.look = 7
      love.audio.stop(music)
      sound = love.audio.newSource("sounds/Sad-trombone-sound.mp3", "static")
      sound:play()
    end
    cat.img = love.graphics.newImage(cat.sprites[cat.look])

  else
    sleep(0.3)
    bomb.draw = false
    if love.keyboard.isDown('space') then
      print("spacebar pressed")
      is_dead = false
      cat.look = 1
      score = 0
      love.audio.stop(sound)
      music:play()
    end

  end

end

function love.draw()
  love.graphics.setBackgroundColor({255, 255, 255})
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(background,0,0,0,love.graphics.getWidth()/background:getWidth(),love.graphics.getHeight()/background:getHeight())

  love.graphics.setColor(255, 0, 0)
  love.graphics.setColor(25,125,0) --Red
  love.graphics.setColor(1, 1, 1)
  if food.draw then
    love.graphics.draw(food.img, food.x, food.y, 0, 0.5, 0.5)
  end
  love.graphics.draw(cat.img, cat.x, cat.y, 0, 0.5, 0.5)

  if bomb.draw then
    love.graphics.draw(bomb.img, bomb.x, bomb.y, 0, 0.5, 0.5)
  end


  love.graphics.setColor(0, 0, 0)
  font = love.graphics.newFont(30)
  love.graphics.setFont(font)
  love.graphics.print(score, 720, 20, 0)
  if is_dead == true then
    font = love.graphics.newFont(20)
    love.graphics.setFont(font)
    love.graphics.printf("Press Spacebar to retry!", 0, love.graphics.getHeight()/2, 800, 'center')
    love.graphics.setColor(0, 0, 0)
    font = love.graphics.newFont(40)
    love.graphics.setFont(font)
    love.graphics.printf("Game Over", 0, love.graphics.getHeight()/2-50, 800, 'center')
  end

end
