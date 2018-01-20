--[[
    基本胡牌类型麻将查表算法(mjlib)
    Mahjong Algorithm By Query Table
  ]]

package.path = "../lualib/?.lua;".. package.path

local class = require "class"

local M = class()

function M:ctor()
	self.mahjong_tbl = nil
end

function M:check_mahjong_tbl(key)
	if key % 3 == 0 then
        return self.mahjong_tbl.tbl[key]
    else
        return self.mahjong_tbl.eye_tbl[key]
    end
end

function M:load(filename)
	local ok,msg = xpcall(function()
		local configDb = require "config_db"
		if configDb then
			self.mahjong_tbl = configDb[filename]
		end
	end, debug.traceback)
	if not ok then
		self.mahjong_tbl = require(filename)
	end
	assert(type(self.mahjong_tbl) == "table")
end

--[[
	手牌
	@param hand_cards => { [1] = 2, [2] = 3, ... }
	@param cur_card => (1-27, )
]]
function M:get_hu_info(hand_cards, cur_card)
	local cards = {}
	for i, v in ipairs(hand_cards) do
		cards[i] = v
	end

	if cur_card then
		cards[cur_card] = cards[cur_card] + 1
	end
	local first_info = {
		eye = false
	}
	-- 字牌（东西南北中发白)
    if not self:check_color(cards, first_info) then
        return false
    -- 万
    elseif not self:check_color_chi(cards, 1, 9, first_info) then
        return false
    -- 筒
    elseif not self:check_color_chi(cards, 10, 18, first_info) then
        return false
    -- 条
    elseif not self:check_color_chi(cards, 19, 27, first_info) then
        return false
    end
    return true
end

--效验字牌
function M:check_color(cards, min, max, info)
    for i = 28, 34 do
        local count = cards[i]

        if count == 1 or count == 4 then
            return false
        end

        if count == 2 then
            if info.eye then
                return false
            end

            info.eye = true
        end
    end

    return true
end

--效验万筒条
function M:check_color_chi(cards, min, max, info)
    local key = 0
    for i = min, max do
        local c = cards[i]
        if c > 0 then
            key = key * 10 + c
		end

        if key > 0 and (c == 0 or i == max) then
            local eye = (key%3 == 2)
            if info.eye and eye then
                return false
            end

            if not self:check_mahjong_tbl(key) then
                return false
            end
            key = 0
        end
    end

    return true
end

-- local mj = M()
-- mj:load("mahjong_base_table")

-- local function test_one()
--     local t = {
--         0,0,3,   3,2,3,   0,0,0,
--         0,0,0,   1,1,1,   0,0,0,
--         0,0,0,   0,0,0,   0,0,0,
--         0,0,0,0, 0,0,0}
--     if mj:get_hu_info(t) then
--         print("胡")
--     else
--         print("不能胡")
--     end
-- end

-- test_one()

-- print("mj.tbl=", mj.tbl)
-- print("mj.eye_tbl=", mj.eye_tbl)

return M