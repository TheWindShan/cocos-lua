local AopContainer = class("AopContainer")

local AopType = aop.AopType

AopContainer._maptype2funcs = nil

local function _executeMethod(self,type,...)
	local funcs = self._maptype2funcs[type]
	if not funcs or #funcs <1 then
		return false
	end
	for _,func in ipairs(funcs or {}) do
		local ret,msg = pcall(func,...)
		if not ret then
			print(msg)
		end
	end
	return true
end



local function _insertAspect(self,target,field)
	local origin = target[field]
	local proxy = {}
	local proxymeta = {}
	proxymeta.__call = function(...)
        _executeMethod(self,AopType.Before,...)
        if not _executeMethod(self,AopType.Repleace,...) then
			origin(...)
		end
        _executeMethod(self,AopType.After,...)
	end
	setmetatable(proxy,proxymeta)
	target[field] = proxy
end

function AopContainer:ctor(target,field)
	_insertAspect(self,target,field)
	self._maptype2funcs = {}
end

local function _tryGetOrCreateMethods(self,type)
	local methods = self._maptype2funcs[type]
	if not methods then
		methods = {}
		self._maptype2funcs[type] = methods
	end
	return methods
end

function AopContainer:insertMethod(type,func)
	local typeMethods = _tryGetOrCreateMethods(self,type)
	table.insert(typeMethods,func)
end

function AopContainer:removeMethod(type,func)
	local typeMethods = _tryGetOrCreateMethods(self,type)
	for _index,_func in ipairs(typeMethods) do
		if _func == func then
			table.remove(typeMethods,_index)
		end
	end
end

function AopContainer:clear(target,field)
	self._maptype2funcs = {}
end

return AopContainer