local Class = require "shared.middleclass"
local GameMath = require "shared.gamemath"
local InputHandler = Class "InputHandler"
local SpawnPortal = require "hymn.spawnportal"


function InputHandler:initialize(logicCore)
    self.logicCore = logicCore
    self.translate = GameMath.Vector2:new(0, 0)
end

local borderWidth = 20
local scrollSpeed = 500

function InputHandler:update(dt)
    local width, height = love.graphics.getDimensions()
    local x, y = love.mouse.getPosition()

    if x < borderWidth then
        self.translate.x = self.translate.x + scrollSpeed * dt
    elseif x > width - borderWidth then
        self.translate.x = self.translate.x - scrollSpeed * dt
    end

    if y < borderWidth then
        self.translate.y = self.translate.y + scrollSpeed * dt
    elseif y > height - borderWidth then
        self.translate.y = self.translate.y - scrollSpeed * dt
    end

    local w, h = self.logicCore.map:size()
    self.translate.x = GameMath.clamp(self.translate.x, -w + width, 0)
    self.translate.y = GameMath.clamp(self.translate.y, -h + height, 0)
end

function InputHandler:mousePressed(x, y, button)
    -- print("mousePressed", x, y, button)
end

function InputHandler:mouseReleased(x, y, button)
    local position = GameMath.Vector2:new(x, y) + self.translate

    if button == "l" then
        if self.mode == "build" then
            local building = SpawnPortal:new()
            self.logicCore.entityManager:add(building)
            building:setPosition(position.x, position.y)
            self.mode = false
        else
            -- selection
            local entities = self.logicCore.entityManager.entities 
            local closestDist = 10000000
            local closestEntity
            for id, entity in ipairs(entities) do
                local dist = GameMath.Vector2.distance(entity.position, position)
                if dist < closestDist then
                    closestEntity = entity
                    closestDist = dist
                end
            end
            self:selectEntity(closestEntity.id)
        end
    end
end

function InputHandler:keyPressed(key, unicode)
    if key == "b" then
        self.mode = "build"
    else
        self.mode = false
    end
end

function InputHandler:selectEntity(entityId)
    self.selectedEntityId = entityId
end

-- local SubClass =  Class("Subclass", InputHandler)
-- local InputHandler = Handler:subclass("InputHandler")

return InputHandler