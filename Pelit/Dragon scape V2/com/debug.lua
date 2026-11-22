local M = {}

local content = {}


function M.add(ref, target)
    if type(ref) ~= "table" or type(target) ~= "string" then
        print("WARNING: Invalid value")
        return
    end

    content[target] = {
        who = ref,
        what = target
    }
end

function M.call()
    local output = {}

    for k, v in pairs(content) do
        table.insert(output, k .. " = " .. tostring(v.who[v.what]))
    end

    print(table.concat(output, " | "))
end

-- Runtime:addEventListener("enterFrame", M.call)


return M