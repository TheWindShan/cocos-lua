local ReactiveObject = class("ReactiveObject")

ReactiveObject._setterFuncContainer = nil
ReactiveObject._getterFuncContainer = nil

local function _redirectGetField(self,target)
	local oldMeta = getmetatable(target)
	local newMeta = {}
	setmetatable(target,newMeta)
	newMeta.__proxy = {}
	local temp = {}
	for key,value in pairs(target) do
		if type(value) ~= "function" then
			table.insert(temp,key)
			newMeta.__proxy[key] = value
		end
	end

	for _,key in ipairs(temp) do
		target[key] = nil
	end

	newMeta.__index = function(target,field)
		local value = newMeta.__proxy[field]
		local func = self._getterFuncContainer[field]
		if func then value = func(target,value) end
		return value
	end
	setmetatable(newMeta.__proxy,oldMeta)
end

local function _redirectSetField(self,target)
	local newMeta = getmetatable(target)
	newMeta.__newindex = function(target,field,value)
		local func = self._setterFuncContainer[field]
		if func then value = func(target,value) end
		newMeta.__proxy[field] = value
	end
end

function ReactiveObject:ctor(target)
	_redirectGetField(self,target)
	_redirectSetField(self,target)

	self._setterFuncContainer = {}
	self._getterFuncContainer = {}
end

function ReactiveObject:addSetterFunc(field,func)
	self._setterFuncContainer[field] = func
end

function ReactiveObject:addGetterFunc(field,func)
	self._getterFuncContainer[field] = func
end

function ReactiveObject:clear(target)
	local newMeta = getmetatable(target)
	if not newMeta.__proxy then return end
	local oldMeta = getmetatable(newMeta)
	newMeta.__newindex = nil
	for key,value in pairs(newMeta.__proxy) do
		if type(value) ~= "function" then
			target[key] = value
		end
	end
	setmetatable(target,oldMeta)
	self._setterFuncContainer = {}
	self._getterFuncContainer = {}
end

return ReactiveObject