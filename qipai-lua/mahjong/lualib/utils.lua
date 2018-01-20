

function table.tostring(root)
    if root == nil then
        return "nil"
    elseif type(root) == "number" then
        return tostring(root)
    elseif type(root) == "string" then
        return root
    elseif type(root) == "function" then
        return "function"
    end
    local spaceLen = 2
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        if t == root then
            table.insert(temp, "local t = {")
        else 
            table.insert(temp, " = {")
        end
        
        for k,v in pairs(t) do
            local key
            local tmpKey = tostring(k)
            if type(k) == "string" then
                key = "[\""..k.."\"]"
            elseif type(k) == "number" then
                key = "["..tostring(k).."]"
            end
            if cache[v] then
                -- table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. tmpKey
                cache[v] = new_key
                table.insert(temp, space .. key .. _dump(v, space .. string.rep(" ", spaceLen), new_key))
            else
                if type(v) == "string" then
                    table.insert(temp, space .. key .. " = \"" .. tostring(v).."\",")
                else
                    table.insert(temp, space .. key .. " = " .. tostring(v)..",")
                end
            end
        end
        if t == root then
            table.insert(temp, "}\nreturn t")
        else 
            table.insert(temp, string.rep(" ", string.len(space)-spaceLen) .. "},")
        end
        
        return table.concat(temp,"\n")
    end
    return (_dump(root, string.rep(" ", spaceLen), ""))
end

function table.dump2file(filename, tbl)
    local f = io.open(filename, "w+")
    local content = table.tostring(tbl)
    f:write(content)
    f:close()
end

-- local t = {
--     ["tmp1"] = { ["abc"] = {1, 2, 3}, [2] = true, [3] = "hello"},
-- }

-- print(table.tostring(t))

-- print(table.tostring(string.split(".tmp1", ".")))
