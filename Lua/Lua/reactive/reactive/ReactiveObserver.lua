local ReactiveObserver = class("ReactiveObserver")

ReactiveObserver._observers = nil

local function _insertAspect(self,target)
	local oldMeta = getmetatable(target)
	local newMeta = {}
	local temp = {}
	newMeta.__proxy = {}
	for key,value in pairs(target) do
		if type(value) ~="function" then
			newMeta.__proxy[key] = value
			table.insert(temp,key)
		end
	end
    for _,key in ipairs(temp) do
		target[key] =nil
	end

	newMeta.__index = newMeta.__proxy

	newMeta.__newindex = function(tt,k,v)
		newMeta.__proxy[k] = v
		for _,observers in pairs(self._observers[k] or {}) do
			for key,_observer in ipairs(observers) do
				local ret,msg = pcall(_observer,target,k,v)
				if not ret then
					print("############observer执行失败  "..msg)
				end
			end
		end
	end
	setmetatable(newMeta.__proxy,oldMeta)
	setmetatable(target,newMeta)
end

function ReactiveObserver:ctor(target)
	_insertAspect(self,target)
	self._observers = {}
end

local function _tryGetOrCreateObserver(self,field,key)
	local fieldObservers = self._observers[field]
	if not fieldObservers then 
		fieldObservers = {}
		self._observers[field] = fieldObservers
	end
	local keyObservers = fieldObservers[key]
	if not keyObservers then
		keyObservers = {}
		fieldObservers[key] = keyObservers
	end
	return keyObservers
end

function ReactiveObserver:addObServer(field,key,func)
	local funcs = _tryGetOrCreateObserver(self,field,key)
	table.insert(funcs,func)
end

function ReactiveObserver:removeObServer(field,key,func)
	local funcs = _tryGetOrCreateObserver(self,field,key)
	for i,vFunc in ipairs(funcs) do
		if vFunc == func then
			table.remove(funcs,i)
			return
		end
	end
end


function ReactiveObserver:removeForField(field)
	self._observers[field] = nil
end

function ReactiveObserver:removeForKey(key)
	for field,observers in ipairs(self._observers) do
		observers[key] = nil
	end
end

function ReactiveObserver:removeForKeyAndField(field,key)
	local observers = self._observers[field]
	if observers then
		observers[key] = nil
	end
end

function ReactiveObserver:clear(target)
	local newMeta = getmetatable(target)
	local oldMeta = getmetatable(newMeta.__proxy)
	setmetatable(target,nil)
	for k,v in pairs(newMeta.__proxy) do
		if type(v) ~= "function" then
			target[k] = v
		end
	end
	setmetatable(target,oldMeta)
	self._observers = {}
end

return ReactiveObserver