-------------------CraneConsoleManager-----------------
--  Library for interact with the rbmk crane console --
--                 Made By MgPhenix                  --
-------------------------------------------------------

local M = {}

--Include--
local utils = require("utils")
--Include


--Components--
component = require("component")
crane = component.rbmk_crane
--Components--


--Movement--
function M.move(value, direction)

    if value < 1 or value > 100 then return false end


    local moveFunc = {
        up = crane.moveUp,
        down = crane.moveDown,
        right = crane.moveRight,
        left = crane.moveLeft
    }

    local action = moveFunc[direction]
    if not action then return false end
    
    action()
    
    return true

end

function M.GoToPosition(x, y)

    while true do

        local posX, posY = crane.getPos()
        posX = utils.round(posX)
        posY = utils.round(posY)

        if posX == x and posY == y then
            break
        end

        if posX < x then
            M.move(1, "right")
        elseif posX > x then
            M.move(1, "left")

        elseif posY < y then
            M.move(1, "up")
        elseif posY > y then
            M.move(1, "down")
        end
    end
end
--Movement--


--Load/Unload--
function M.load()
    crane.loadUnload()
end

function M.unload()
    crane.loadUnload()
end
--Load/Unload--


return M