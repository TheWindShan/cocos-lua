module("Extend",package.seeall)


--Lua类sub是否继承Lua类super
function Extend.checkSubClassOf(sub,super)

    if sub == super then return true end
    for _ ,_super in ipairs(sub.__supers or {}) do
        local ret = checkSubClassOf(_super,super)
        if ret then return true end
    end
    return false

end




--userdata对象----------->C++类
local function _checkIsInstanceOfCClass(instance,clazz)
    if type(instance)~= "userdata" or clazz[".isclass"] == nil then return false end
    local temp = getmetatable(instance)
    local clz = getmetatable(clazz)
    if clz == nil then return false end
    while temp~= nil do
        if temp == clz then return true end
        temp = getmetatable(temp)
    end
    return false
end

--table对象/Userdata对象----------->Lua类
local function _checkIsInstanceOfLuaClass(instance,clazz)
    local instanceClz = instance.class
    if instanceClz == clazz then return true end
    return Extend.checkSubClassOf(instanceClz,clazz)
end

--是否是clazz的一个实例
function Extend.checkIsInstanceOf(instance,clazz)
    if type(instance) ~= "table" and type(instance) ~="userdata" then return false end
    if type(clazz) ~="table" then return false end
    
    if clazz[".isclass"] then
        return _checkIsInstanceOfCClass(instance,clazz)
    else
        return _checkIsInstanceOfLuaClass(instance,clazz)
    end
end


return nil