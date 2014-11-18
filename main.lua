require "smee.dbginit"

local games = {
    "hymn",
    "minionmaster",
}

function love.load(arg)
    math.randomseed(os.time())

    local game = type(arg[3]) == "string" and arg[3] or games[math.random(#games)]
    -- game = "minionmaster"
    require(game .. ".main")()
end
