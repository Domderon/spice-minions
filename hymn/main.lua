local InputHandler = require "hymn.InputHandler"

local baseWidth, baseHeight = 1920, 1080
local Entity = require "shared.entity"
local EntityManager = require "shared.entitymanager"
local Unit = require "shared.unit"

local myUnit
local inputHandler

local entityManager

local function load()
    -- mouseCursor = love.graphics.newImage("images/ui/mouseCursor.png")
    love.window.setMode(baseWidth/2, baseHeight/2, { centered = true, resizable = true })
	entityManager = EntityManager:new()
    myUnit = Unit:new(3)
    inputHandler = InputHandler:new(myUnit)
    entityManager:add(myUnit)
end

function love.update(dt)
	entityManager:update(dt)
end

function love.draw(dt)
    entityManager:draw(dt)
end

function love.keypressed(key, unicode)
	if key == "escape" then
        -- sends quit event
        love.event.quit()
    end
    inputHandler:keyPressed(key, unicode)
end

function love.mousepressed(x, y, button)
    inputHandler:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
    inputHandler:mouseReleased(x, y, button)
end

function love.focus(focussed)
end

function love.textinput(text)
end

function love.resize(w, h)
end

return load
