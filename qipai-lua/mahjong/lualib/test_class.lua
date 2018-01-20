local class = require "class"
--父类  
local Base = class()  
function Base:ctor(val)  
    print("Base ctor")  
    self._cnt = val or 2
end  
function Base:show()  
    print("in Base.show _cnt=", self._cnt)  
end

--子类1  
local Child1 = class(Base)  
function Child1:ctor()
    print("Child1 ctor")
end

function Child1:init()
    print("Child1 init")
end

function Child1:show()  
    -- self:super("show")
    print("in Child1 show _cnt=", self._cnt)  
end

--子类2  
local Child2 = class(Child1)
function Child2:init()
    self:super("init")
    print("Child2 init")
end

function Child2:show()  
    print("in Child2 show _cnt=", self._cnt)  
    self:super("show")
    self:init()
end

function Child2:ctor()
    print("Child2 ctor")
    -- self:init()
end

-- local child = Child2.new(3)
local child = Child2(3)
child:show()

require "utils"

local tbl = {
	["eye"] = { [1] = true, [2] = true, [3] = true, ["4"] = "true"},
	["tbl"] = { [1] = true, [2] = true, [3] = true, [4] = true},
}
print(table.tostring(tbl))