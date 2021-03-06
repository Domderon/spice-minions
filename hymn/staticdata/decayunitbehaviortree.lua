local Class = require "smee.libs.middleclass"
local BehaviorTree = require "smee.logic.behaviortree"
local Behaviors = require "hymn.staticdata.behaviors"

local function createDecayUnitBT()
-- Absolutely valid BT
    -- local findTarget = BehaviorTree.Selector:new()
    -- findTarget:addChild(Behaviors.SearchEnemy:new())
    -- findTarget:addChild(Behaviors.FindWaypoint:new())
    -- findTarget:addChild(Behaviors.FindConstruction:new())

    -- local root = BehaviorTree.Sequence:new()
    -- root:addChild(findTarget)
    -- root:addChild(Behaviors.MoveTo:new())
    -- root:addChild(Behaviors.AttackEnemy:new())
    -- root:addChild(Behaviors.WorkConstruction:new())

    local root = BehaviorTree.Selector:new()
    local engageCombat = BehaviorTree.Sequence:new()
    local goToPath = BehaviorTree.Sequence:new()
    local constructionJob = BehaviorTree.Sequence:new()
    local claimDeposit = BehaviorTree.Sequence:new()

	root:addChild(goToPath)
		goToPath:addChild(Behaviors.FindWaypoint:new())
		goToPath:addChild(Behaviors.MoveTo:new())
    root:addChild(engageCombat)
    	engageCombat:addChild(Behaviors.SearchEnemy:new())
    	engageCombat:addChild(Behaviors.MoveTo:new())
    	engageCombat:addChild(Behaviors.AttackEnemy:new())
	root:addChild(constructionJob)
	 	constructionJob:addChild(Behaviors.FindConstruction:new())
	 	constructionJob:addChild(Behaviors.MoveTo:new())
	 	constructionJob:addChild(Behaviors.WorkConstruction:new())
    -- root:addChild(claimDeposit)
    --     claimDeposit:addChild(Behaviors.FindDeposit:new())
    --     claimDeposit:addChild(Behaviors.MoveTo:new())
    --     claimDeposit:addChild(Behaviors.ClaimDeposit:new())

	return root
end

local function depositDebuggingBT()
    local root = BehaviorTree.Sequence:new()
    root:addChild(Behaviors.FindDeposit:new())
    root:addChild(Behaviors.MoveTo:new())
    root:addChild(Behaviors.ClaimDeposit:new())

    return root
end

-- return depositDebuggingBT
return createDecayUnitBT