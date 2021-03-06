local flux     = require "smee.libs.flux"
local blocking = require "smee.logic.blocking"
local GameMath = require "smee.logic.gamemath"
local Entity   = require "smee.game_core.entity"

local Vector2 = GameMath.Vector2

local Unit = Entity:subclass("Unit")

-- speed: pixels/second
-- orientation: radians
function Unit:initialize(entityStatic, player)
    Entity.initialize(self, entityStatic, player)

    self.speed = self.speed or 300
    -- self.orientation = orientation
    self.targetPosition = Vector2:new(self.position.x, self.position.y)
    self.targetEntity = nil
    self.targetDirection = GameMath.Vector2:new(0,0)
    self.stopRange = 30
    self.waypoints = false
    self.dead = false
end

function Unit:moveToPosition(targetPos, stopRange)
    -- RESET OLD TARGET / SET NEW
    self.targetEntity = nil
    self.targetPosition.x = targetPos.x
    self.targetPosition.y = targetPos.y
    self.stopRange = stopRange or self.stopRange
    dbgprint(self.position.x, self.position.y, "--", targetPos.x, targetPos.y)
    -- CAN RETURN NIL! Careful, in one behavior we expected to get always something
    self.waypoints = {}
    local rawWPs = blocking.findPath(self.position.x, self.position.y,
                                       targetPos.x, targetPos.y)
    for i = 1, #rawWPs do
        table.insert(self.waypoints, Vector2:new(rawWPs[i].x, rawWPs[i].y))
    end
    return self.waypoints
end

function Unit:moveToTarget(targetEntity)
    -- SET NEW TARGET
    local targetPos = targetEntity:closestPosition(self.position)
    self.targetEntity = targetEntity
    self.targetPosition.x = targetPos.x
    self.targetPosition.y = targetPos.y
    self.nextPathUpdate = 0.25 + math.random()
    -- CAN RETURN NIL! Careful, in one behavior we expected to get always something
    self.waypoints = {}
    local rawWPs = blocking.findPath(self.position.x, self.position.y,
                                       targetPos.x, targetPos.y)
    for i = 1, #rawWPs do
        table.insert(self.waypoints, Vector2:new(rawWPs[i].x, rawWPs[i].y))
    end
    return self.waypoints
end


function Unit:reachedTarget(target, step)
    local direction = (target - self.position)
    local length = direction:length()

    -- RETURN REACHED, direction vector, direction length
    return length <= step, direction, length
end

function Unit:updatePath(dt)
    self.nextPathUpdate = self.nextPathUpdate - dt
    if self.nextPathUpdate > 0 then
        -- lets check later 
        return
    end 
    if self.targetEntity then
        local newTargetPos = self.targetEntity:closestPosition(self.position)
        local dist = self.targetPosition - newTargetPos
        if dist:sqLength() > 4 then
            self:moveToTarget(self.targetEntity)
        end
    end
end

function Unit:updateMove(dt)
    self:updatePath(dt)
    if self.waypoints and #self.waypoints > 0 then
        local waypoints = self.waypoints

        local target = waypoints[1]
        local step = dt * self.speed

        local reached, direction, length = self:reachedTarget(target, step)

        -- Update orientation
        if length > 0 then
            local newOrientation = math.atan2(direction.y, direction.x)
            -- self.orientation = newOrientation
            flux.to(self, 0.04, { orientation = newOrientation }):ease("quadinout")
        end

        if #waypoints > 1 or length > self.stopRange then
            if reached then
                self:setPosition(target.x, target.y)
                table.remove(waypoints, 1)
            else
                direction:normalize()
                local newPosition = self.position + direction * step
                self:setPosition(newPosition.x, newPosition.y)
            end
            return false
        else
            self.waypoints = nil
            return true
        end
    end

    return true
end

function Unit:drawPath()
    if self.waypoints and #self.waypoints > 0 then
        local waypoints = self.waypoints

        -- Draw the path to the destination
        love.graphics.setColor(255,0,0,64)
        love.graphics.setPointSize(5)
        local px, py = self.position.x, self.position.y
        for i, waypoint in ipairs(waypoints) do
            local x, y = waypoint.x, waypoint.y
            if px then
                love.graphics.line(px, py, x, y)
            else
                love.graphics.point(x, y)
            end
            px, py = x, y
        end
        love.graphics.point(px, py)
    end
end

function Unit:setPosition(x, y)
    self.targetPosition.x = x
    self.targetPosition.y = y
    Entity.setPosition(self, x, y)
end

function Unit:getTargetPosition()
    return self.targetPosition.x, self.targetPosition.y
end

return Unit
