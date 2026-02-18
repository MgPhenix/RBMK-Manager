----------------RBMK Manager----------------
--Library for interact with a RBMK Console--
--            Made By MgPhenix            --
--------------------------------------------

local M = {}


--Include--
local utils = require("utils")
--Include--

--Optional Include--
local hasCrane, crane = pcall(require, "craneManager")
--Optional Include--


--Components--
local component = require("component")
local rbmk = component.rbmk_console
--Components--

--Optional Components--
local hasGPU = false
if component.isAvailable("gpu") then
    gpu = component.gpu
    hasGPU = true
end
--Optional Components--

--Variables--
M.IS_INIT = false
M.CORE = {
    BLANK     = {},
    FUEL      = {},
    CONTROL   = {},
    BOILER    = {},
    MODERATOR = {},
    ABSORBER  = {},
    REFLECTOR = {},
    STORAGE   = {},
    UNKNOW    = {}
}

M.TYPE_COLORS = {
    BLANK     = 0xFFFFFF,
    FUEL      = 0x03FC03,
    CONTROL   = 0xFC9003,
    BOILER    = 0x0362FC,
    MODERATOR = 0x474747,
    ABSORBER  = 0xABB3FF,
    REFLECTOR = 0xB0B0B0,
    STORAGE   = 0x1F1F1F,
    UNKNOW    = 0x000000
}
--Variables--


--GPU Function--
if hasGPU then

    function M.DrawReactor(x,y, sizeW, sizeH)
        local startX = utils.clamp(x,100,1)
        local startY = utils.clamp(y,100,1)

        for typename, table in pairs(M.CORE) do

            local color = M.TYPE_COLORS[typename] or 0xFFFFFF
            gpu.setBackground(color)

            for i, pos in ipairs(table) do
                
                local cx, cy = utils.ToConsoleCoords(pos.x, pos.y)

                local drawX = startX + (cx * sizeW)
                local drawY = startY + (cy * sizeH)

                gpu.fill(drawX,drawY,sizeW,sizeH," ")

            end
        end

        gpu.setBackground(0x000000)

    end
end
--GPU Function--


--Crane Function--
if hasCrane then
    print("HasCrane")
end

function M.Test()
    crane.move(1,"up")
end
--Crane Function--


--Utilitary Function--
function M.SetMasterControl(percentage)
    percentage = utils.clamp(percentage,100,0)
    rbmk.setLevel(percentage/100)
end


function M.SetControl(x,y,percentage)
    percentage = utils.clamp(percentage,100,0)
    rbmk.setColumnLevel(x,y,percentage/100)
end

--/ true if you use coord when 0,0 is the center, false if 7,7 is the center /--
function M.GetColumn(x,y,center)

    if center == nil then center = false end

    if center then
        x, y = M.ToConsoleCoords(x, y)
    end

    return rbmk.getColumnData(x,y)
end

--/ Return All data from a table /--
function M.GetData(table)

    local result = {}
    
    if not table then return result end

    for i, pos in ipairs(table) do
    
        local data = M.GetColumn(pos.x,pos.y)

        if data then

            local PosAndData = {
                x = pos.x,
                y = pos.y,
                data = data
            }

            table.insert(result,PosAndData)
        end
    end

    return result
end

--/ Take multiple string to get data /--
function M.PrintData(x,y,...)
    
    x,y = utils.ToConsoleCoords(x,y)

    local data = M.GetColumn(x,y)
    if not data then
        print("No Data found at : ",x,",",y)
        return
    end

    local keys = {...}

    for i, key in ipairs(keys) do
       print(key, " : ", data[key] or nil) 
    end
end


function M.GetAvgFuelTemp()

    local size = #M.CORE.FUEL
    if size == 0 or not M.IS_INIT then return 0 end

    local sumCoreTemp = 0
    local sumSkinTemp = 0

    for i, rodPos in ipairs(M.CORE.FUEL) do
        data = M.GetColumn(rodPos.x, rodPos.y)

        if data and data.coreTemp and data.coreSkinTemp then
            sumCoreTemp = sumCoreTemp + data.coreTemp
            sumSkinTemp = sumSkinTemp + data.coreSkinTemp
        end
    end

    return { 
        coreAvg = sumCoreTemp / size,
        skinAvg = sumSkinTemp / size
    }
end
--Utilitary Function--


--Init--
function M.InitReactor()

    for x = 0,14 do
        for y = 0,14 do
        
            data = rbmk.getColumnData(x,y)

            if data then

                local pos = {
                    x = x,
                    y = y
                }
                
                if data.type == "BLANK" then
                    table.insert(M.CORE.BLANK,pos)

                elseif data.type == "FUEL" or data.type == "FUEL_SIM" then
                    table.insert(M.CORE.FUEL,pos)

                elseif data.type == "CONTROL" or data.type == "CONTROL_AUTO" then
                    table.insert(M.CORE.CONTROL,pos)

                elseif data.type == "BOILER" then
                    table.insert(M.CORE.BOILER,pos)
                
                elseif data.type == "MODERATOR" then
                    table.insert(M.CORE.MODERATOR,pos)
                
                elseif data.type == "ABSORBER" then
                    table.insert(M.CORE.ABSORBER,pos)
                
                elseif data.type == "REFLECTOR" then
                    table.insert(M.CORE.REFLECTOR,pos)
                
                elseif data.type == "STORAGE" then 
                    table.insert(M.CORE.STORAGE,pos)
                else
                    table.insert(M.CORE.UNKNOW,pos)
                end
            end
        end
    end

    M.IS_INIT = true

end
--Init--


return M


--temp info--
-- BLANK(0), FUEL(10), FUEL_SIM(90), CONTROL(20), CONTROL_AUTO(30), BOILER(40),
--         MODERATOR(50), ABSORBER(60), REFLECTOR(70), OUTGASSER(80), BREEDER(100),
--         STORAGE(110), COOLER(120), HEATEX(130);
--