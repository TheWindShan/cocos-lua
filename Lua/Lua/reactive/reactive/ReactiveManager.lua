local ReactiveManager = class("ReactiveManager")

local ReactiveObject = require("lib.reactive.ReactiveObject")
local ReactiveObserver = require("lib.reactive.ReactiveObserver")

local singleton = nil

ReactiveManager._reactiveObjects = nil

ReactiveManager._reactiveObservers = nil

function ReactiveManager:ctor()
	self._reactiveObjects = {}
	self._reactiveObservers = {}
end

function ReactiveManager:getInstance()
	if not singleton then singleton = ReactiveManager.new() end
	return singleton
end

function ReactiveManager:addSetterFunc(target,field,func)
	local reactiveObject = self._reactiveObjects[target]
	if not reactiveObject then 
		reactiveObject = ReactiveObject.new(target) 
		self._reactiveObjects[target] = reactiveObject
	end
	reactiveObject:addSetterFunc(field,func)
end

function ReactiveManager:addGetterFunc(target,field,func)
	local reactiveObject = self._reactiveObjects[target]
	if not reactiveObject then 
		reactiveObject = ReactiveObject.new(target) 
		self._reactiveObjects[target] = reactiveObject
	end
	reactiveObject:addGetterFunc(field,func)
end

function ReactiveManager:removeTarget(target)
	local reactiveObject = self._reactiveObjects[target]
	if reactiveObject then
		reactiveObject:clear(target)
	end
end

local function tryGetOrCreateObserver(self,target)
	local observer = self._reactiveObservers[target] 
	if not observer then
		observer = ReactiveObserver.new(target)
		self._reactiveObservers[target] = observer
	end
	return observer
end

function ReactiveManager:addObserver(target,field,key,func)
	local observer = tryGetOrCreateObserver(self,target)
	observer:addObServer(field,key,func)
end

function ReactiveManager:removeObserver(target,field,key,func)
	local observer = tryGetOrCreateObserver(self,target)
	observer:removeObServer(field,key,func)
end

function ReactiveManager:removeAllObserver(target)
	local observer = tryGetOrCreateObserver(self,target)
    observer:clear(target)
end

return ReactiveManager