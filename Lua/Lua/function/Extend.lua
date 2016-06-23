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

 --解析表达式 Version1
local kDefaultFormulaEnv = {
    round = math.round,
    floor = math.floor,
    max = math.max,
    min = math.min,
    pow = math.pow,
}

local function _createFormulaEnv(env)
    if not env then return kDefaultFormulaEnv end
    local temp = env
    while true do
        local meta = getmetatable(temp)
        if not meta then
            setmetatable(temp,kDefaultFormulaEnv)
            break
        elseif meta == kDefaultFormulaEnv then
            break
        end
        temp = meta
    end
    return env
end

local kCacheFormulaFunction = nil

function Extend.createFormula(params,content,env)
    if kCacheFormulaFunction and kCacheFormulaFunction[content] then return kCacheFormulaFunction[content] end
    params = table.concat(params,",");
    local str = "return function("..params..") return "..content.." end"
    local retFunc = assert(loadstring(str))()
    if not kCacheFormulaFunction then kCacheFormulaFunction = {} end
    kCacheFormulaFunction[content] = retFunc
    env = _createFormulaEnv(env)
    setfenv(retFunc,env)
    
    return retFunc
end


function string.repleace(source,pattern,repl)
    return string.gsub(source,pattern,repl)
end

--解析表达式 Version2


local kDefaultFormulaVersion2 = {
    ["round"] ="math.round",
    ["floor"]="math.floor",
    ["max"]="math.max",
    ["min"]="math.min",
    ["pow"]="math.pow",
}

function Extend.createFormulaVersion2(params,content)
    params = table.concat(params,",")

    for key,value in pairs(kDefaultFormulaVersion2) do
        content = string.gsub(content,key,value)
    end
    local str = "return function( "..params.." ) return ".. content .." end"
    return assert(loadstring(str))()
end

function Extend.performSequenceFunctions(funcs,callback,index)
    index = index and index or 1
    local func = funcs[index]
    if func == nil then callback(true) end
    index = index + 1
    local innercallback = function(result)
        if result == true then
            if index >= #funcs then
                callback(true)
            else
                Extend.performSequenceFunctions(funcs,callback,index)
            end
        else
            callback(false)  
        end
    end
    return func(innercallback)
end


function Extend.tableToString(source,step)
    local ret = {}
    local tempStep = step and step or 1
    if type(source) == "number" or type(source) == "function" or type(source) == "string" or type(source) == "userdata" then
        table.insert(ret,tostring(source))
    elseif type(source) == "table" then
        table.insert(ret,"\n{")
        for key, value in pairs(source) do
            table.insert(ret,"\n")
            table.insert(ret,string.format("[%s]=",key))
            table.insert(ret,Extend.tableToString(value,tempStep + 1))
        end
        table.insert(ret,"\n")
        table.insert(ret,"}")
    end
    return table.concat(ret)
end

return nil