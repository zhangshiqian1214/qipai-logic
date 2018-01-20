-- local table_mgr = require "table_mgr"
package.path = "../lualib/?.lua;".. package.path
require "utils"

local table_mgr = {
    tbl = {},
    eye_tbl = {},
    feng_tbl = {},
    feng_eye_tbl = {}
}

function table_mgr:init()
    for i=0,8 do
        self.tbl[i] = {}
        self.eye_tbl[i] = {}
        self.feng_tbl[i] = {}
        self.feng_eye_tbl[i] = {}
    end
end

function table_mgr:add(key, gui_num, eye, chi)
    if not chi then
        if eye then
            self.feng_eye_tbl[gui_num][key] = true
        else
            self.feng_tbl[gui_num][key] = true
        end
    else
        if eye then
            self.eye_tbl[gui_num][key] = true
        else
            self.tbl[gui_num][key] = true
        end
    end
end

function table_mgr:dump()
    local config = {
        tbl = self.tbl,
        eye_tbl = self.eye_tbl,
        feng_tbl = self.feng_tbl,
        feng_eye_tbl = self.feng_eye_tbl,
    }
    table.dump2file("mahjong_gui_table.lua", config)
end

local function gen_base_table()
    local gui_tested = {}
    local gui_eye_tested = {}
    for i=0,8 do
        gui_tested[i] = {}
        gui_eye_tested[i] = {}
    end

    local function check_add(cards, gui_num, eye)
        local key = 0

        for i=1,9 do
            key = key * 10 + cards[i]
        end

        if key == 0 then
            return false
        end

        local m
        if not eye then
            m = gui_tested[gui_num]
        else
            m = gui_eye_tested[gui_num]
        end

        if m[key] then
            return false
        end

        m[key] = true

        for i=1,9 do
            if cards[i] > 4 then
                return true
            end
        end
        table_mgr:add(key, gui_num, eye, true)
        return true
    end

    local function parse_table_sub(cards, num, eye)
        for i=1,9 do
            repeat
                if cards[i] == 0 then
                    break
                end

                cards[i] = cards[i] - 1

                if not check_add(cards, num, eye) then
                    cards[i] = cards[i] + 1
                    break
                end
                if num < 8 then
                    parse_table_sub(cards, num + 1, eye)
                end
                cards[i] = cards[i] + 1
            until(true)
        end
    end

    local function parse_table(cards, eye)
        if not check_add(cards, 0, eye) then
            return
        end
        parse_table_sub(cards, 1, eye)
    end

    local function gen_table_sub(t, level, eye)
        for j=1,16 do
            repeat
                if j <= 9 then
                    if t[j] > 3 then
                        break
                    end
                    t[j] = t[j] + 3
                elseif j<= 16 then
                    local index = j - 9
                    if t[index] >= 4 or t[index+1] >= 4 or t[index+2] >= 4 then
                        break
                    end
                    t[index] = t[index] + 1
                    t[index + 1] = t[index + 1] + 1
                    t[index + 2] = t[index + 2] + 1
                end
                parse_table(t, eye)
                if level < 4 then
                    gen_table_sub(t, level + 1, eye)
                end

                if j<= 9 then
                    t[j] = t[j] - 3
                else
                    local index = j - 9
                    t[index] = t[index] - 1
                    t[index + 1] = t[index + 1] - 1
                    t[index + 2] = t[index + 2] - 1
                end
            until(true)
        end
    end

    local function gen_table()
        local t = {0,0,0,0,0,0,0,0,0}
        gen_table_sub(t, 1, false)
    end

    local function gen_eye_table()
        local t = {0,0,0,0,0,0,0,0,0}

        for i=1,9 do
            t[i] = 2
            parse_table(t, true)
            gen_table_sub(t, 1, true)
            t[i] = 0
        end
    end

    gen_table()
    gen_eye_table()

end

local function gen_feng_table()
    local gui_tested = {}
    local gui_eye_tested = {}
    for i=0,8 do
        gui_tested[i] = {}
        gui_eye_tested[i] = {}
    end

    local function check_add(cards, gui_num, eye)
        local key = 0

        for i=1,7 do
            key = key * 10 + cards[i]
        end

        if key == 0 then
            return false
        end

        local m
        if not eye then
            m = gui_tested[gui_num]
        else
            m = gui_eye_tested[gui_num]
        end

        if m[key] then
            return false
        end

        m[key] = true

        for i=1,7 do
            if cards[i] > 4 then
                return true
            end
        end
        table_mgr:add(key, gui_num, eye, false)
        return true
    end

    local function parse_table_sub(cards, num, eye)
        for i=1,7 do
            repeat
                if cards[i] == 0 then
                    break
                end

                cards[i] = cards[i] - 1

                if not check_add(cards, num, eye) then
                    cards[i] = cards[i] + 1
                    break
                end
                if num < 8 then
                    parse_table_sub(cards, num + 1, eye)
                end
                cards[i] = cards[i] + 1
            until(true)
        end
    end

    local function parse_table(cards, eye)
        if not check_add(cards, 0, eye) then
            return
        end
        parse_table_sub(cards, 1, eye)
    end

    local function gen_table_sub(cards, level, eye)
        for i=1,7 do
            repeat
                if cards[i] > 3 then
                    break
                end
                cards[i] = cards[i] + 3
                parse_table(cards, eye)
                if level < 4 then
                    gen_table_sub(cards, level + 1, eye)
                end
                cards[i] = cards[i] - 3
            until(true)
        end
    end

    local function gen_table()
        local t = {0,0,0,0,0,0,0}
        gen_table_sub(t, 1, false)
    end

    local function gen_eye_table()
        local t = {0,0,0,0,0,0,0}

        for i=1,7 do
            t[i] = 2
            parse_table(t, true)
            gen_table_sub(t, 1, true)
            t[i] = 0
        end
    end

    gen_table()
    gen_eye_table()
end

local function main()
    table_mgr:init()
    gen_base_table()
    gen_feng_table()
    -- gen_table()
    -- gen_eye_table()
    table_mgr:dump()
end

main()
