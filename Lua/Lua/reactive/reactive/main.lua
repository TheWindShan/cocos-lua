
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require "traceback"

local function _initLib()
	require("common.common");
    require("lib.util.util")
    require("game.game")
end

local function testReactiveObject()
    local target = {}
    reactive.ReactiveManager:getInstance():addGetterFunc(target,"a",function(t,v)
        v = v +1
        return v
    end)

    target.a  = 1
    print(target.a)
    reactive.ReactiveManager:getInstance():removeTarget(target)
    print(target.a)
end

local function testReactiveObserver()
    local target = {}
    target.a = 1
    target.b = 2
    local meta = {}
    meta.c = 4
    setmetatable(target,meta)
    local callback =function(t,k,v)
        print("#######发生了赋值操作#####  "..tostring(k).."   "..tostring(v))
    end
    reactive.ReactiveManager:getInstance():addObserver(target,"a","this",callback) --测试添加监听
    target.a = 3
    print(target.a)
  --  reactive.ReactiveManager:getInstance():removeObserver(target,"a","this",callback)  --测试单个移除
    reactive.ReactiveManager:getInstance():removeAllObserver(target) --测试所有移除
    target.a = 4
     print(target.a)


end

local function main()
    _initLib();
    local scene = cc.Scene:create()
    cc.Director:getInstance():pushScene(scene);
    testReactiveObject()
   testReactiveObserver()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
