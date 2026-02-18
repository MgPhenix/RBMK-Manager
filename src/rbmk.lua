--RBMK Manager--


--Include--
--local utils = require("utils")
--local crane = require("craneManager")
--local state = require("rbmkState")
local config  = require("rbmkConfig")
--Include--


--Components--
local component = require("component")
local rbmk = component.rbmk_console
local gpu = component.gpu
--Components--


--Global Variables--
--CURRENT_STATE = state.OFFLINE
local w, h = gpu.getResolution()


local FUEL_RODS = {
    { x = 4, y =  10 },
    { x =  7, y =  10 },
    { x =  10, y =  10 },

    { x = 4, y =  7 },
    { x =  7, y =  7 },
    { x =  10, y =  7 },

    { x = 4, y = 4 },
    { x =  7, y = 4 },
    { x =  10, y = 4 }
}

local STEAM_COLUMNS = {
    { x = 5, y =  9 },
    { x = 9, y =  9 },

    { x = 6, y =  8 },
    { x = 8, y =  8 },

    { x = 6, y = 6 },
    { x = 8, y = 6 },

    { x = 5, y = 5 },
    { x = 9, y = 5 }
}


--Global Variables--


--Random Functions--
local function ClearScreen()
    gpu.fill(1, 1, w, h, " ")
end

local function GetColumn(x, y)
    local data = rbmk.getColumnData(x, y)
    if not data then return nil end
    return data
end
--Random Functions--



--Start/Stop--
local function Start()
    ClearScreen()
    rbmk.setLevel(1)
end

local function Stop()
    rbmk.setLevel(0)
end

local function UrgentShutdown()
    rbmk.pressAZ5()
end
--Start/Stop--


--Loop--
local function RBMK_Run()


    while true do

        local i = 0

        for _, rod in ipairs(FUEL_RODS) do
            local data = rbmk.getColumnData(rod.x,rod.y)
            if data then

                if data.coreTemp >= config.MAX_CORE_TEMP or data.coreSkinTemp >= config.MAX_SKIN_TEMP then
                    UrgentShutdown()
                    break

                elseif data.coreTemp >= config.MAX_CORE_TEMP - 50 or data.coreSkinTemp >= config.MAX_SKIN_TEMP - 200 then
                    rbmk.setLevel(0.95)
                end
                
                gpu.set(2,2+2*i,string.format("Fuel Rod :  Temp : %.3f/%.3f", data.coreTemp, config.MAX_CORE_TEMP))
            else
                gpu.set(2,2*i,"Error reading data")
            end

            i = i + 1
        end

        for _, steam in ipairs(STEAM_COLUMNS) do
            local data = rbmk.getColumnData(steam.x,steam.y)

            if data.water < 1500 or data.steam >= config.MAX_STEAM - 1000 then
                UrgentShutdown()
                break
            end
        end
    end
end
--Loop--


--Main--
local function Main()
    Start()
    RBMK_Run()
    Stop()
end


Main()