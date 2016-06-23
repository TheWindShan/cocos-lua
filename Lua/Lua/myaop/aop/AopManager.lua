local AopManager = class("AopManager")


local AopContainer = require "aop.AopContainer"

local singeton = nil

AopManager._aopContainers = nil

function AopManager:ctor()
	self._aopContainers = {}
end

function AopManager:getInstance()
	if not singeton then singeton = AopManager.new() end
	return singeton
end

local function _tryGetOrCreateTargetContainer(self,target)
    local container = self._aopContainers[target]
    if not container then
        container = {}
        self._aopContainers[target] = container
    end
    return container
end


local function _tryGetOrCreateFieldContainer(self,target,field)
	local container = _tryGetOrCreateTargetContainer(self,target)
	local fieldContainer = container[field]
	if not fieldContainer then
		fieldContainer = AopContainer.new(target,field)
		container[field] = fieldContainer
	end
	return fieldContainer
end

function AopManager:insert(target,funcname,type,func)
	local container = _tryGetOrCreateFieldContainer(self,target,funcname)
	container:insertMethod(type,func)
end

function AopManager:remove(target,funcname,type,func)
	local container = _tryGetOrCreateFieldContainer(self,target,funcname)
	container:removeMethod(type,func)
end

function AopManager:remove(target,funcname)
	local container = _tryGetOrCreateFieldContainer(self,target,funcname)
	container:clear(target,funcname)
end

function AopManager:remove(target)
    local targetContainer = _tryGetOrCreateTargetContainer(self,target)
    for key,fieldContainer in pairs(targetContainer or {}) do
        fieldContainer:clear(target,key)
    end
end

return AopManager