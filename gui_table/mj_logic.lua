--[[
    带赖子的基本胡牌类型麻将算法(mjlib)
    Mahjong Algorithm By Query Table
  ]]

package.path = "../lualib/?.lua;".. package.path

local class = require "class"

local M = class()

function M:ctor()
	self.mahjong_tbl = nil
end

function M:check_mahjong_tbl(key, gui_num, eye, chi)
    if not chi then
        if eye then
            return self.mahjong_tbl.feng_eye_tbl[gui_num][key]
        else
            return self.mahjong_tbl.feng_tbl[gui_num][key]
        end
    else
        if eye then
            return self.mahjong_tbl.eye_tbl[gui_num][key]
        else
            return self.mahjong_tbl.tbl[gui_num][key]
        end
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

function M:get_hu_info(cards, gui_index)
    local hand_cards = {}
    for i,v in ipairs(cards) do
        hand_cards[i] = v
    end

    local gui_num = 0
    if gui_index > 0 then
        gui_num = hand_cards[gui_index]
        hand_cards[gui_index] = 0
    end

    return self:check(hand_cards, gui_num)
end

function M:check(cards, gui_num)
	local total_need_gui = 0
	local eye_num = 0
	for i=0,3 do
		local from = i*9 + 1
		local to = from + 8
		if i == 3 then
			to = from + 6
		end
		
		local need_gui, eye = self:get_need_gui(cards, from, to, i<3, gui_num)
		if not need_gui then
		    return false
		end
		total_need_gui = total_need_gui + need_gui
		if eye then
			eye_num = eye_num + 1
		end
	end
	
	if eye_num == 0 then
		return total_need_gui + 2 <= gui_num
	elseif eye_num == 1 then
		return total_need_gui <= gui_num
	else
		return total_need_gui + eye_num - 1 <= gui_num
	end
end

function M:get_need_gui(cards, from, to, chi, gui_num)
	local num = 0
	local key = 0
	for i=from,to do
		key = key * 10 + cards[i]
		num = num + cards[i]
	end
	
	if num == 0 then
	    return 0, false
	end

    for i=0, gui_num do
        local yu = (num + i)%3
        if yu ~= 1 then
            local eye = (yu == 2)
            if self:check_mahjong_tbl(key, i, eye, chi) then
                return i, eye
            end
        end
    end
end

-- local mj = M()
-- mj:load("mahjong_gui_table")

-- local function test_one()
--     -- 6万6万6万4筒4筒4筒4条4条5条5条6条6条发发
--     local t = {
--         0,0,0,   0,0,3,   0,0,0,
--         0,0,0,   3,0,0,   0,0,0,
--         0,0,0,   2,2,2,   0,0,0,
--         0,0,0,0, 0,2,0}
--     if not mj:get_hu_info(t, 0) then
--         print("测试失败")
--     end
-- end

-- test_one()

return M