----------UtilsLibrary----------
-- Just some useful functions --
--      Made By MgPhenix      --
--------------------------------

local M = {}

--Functions--
function GetPercentage(value, max)
    return (value / max)*100
end

function Clamp(value, max, min)
    return math.max(min, math.min(max, value))
end

function M.round(n)
    if n >= 0 then
        return math.floor(n + 0.5)
    else
        return math.ceil(n - 0.5)
    end
end
--Functions--

return M