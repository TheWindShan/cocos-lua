local LuaObjectUserdataTest = class("LuaObjectUserdataTest")

function LuaObjectUserdataTest:test()
    local Test = class("Test",cc.Node)
    Test.a = function() print("####come in Test function a#########") end
    local test = Test.new()
    
    print("##########type(test):  "..type(test))  --"userdata" 虽然继承Test 的LuaTable，但是还是userdata
    print("##########type(Test)  "..type(Test))  --"table"
    
    print("##########   "..tostring(getmetatable(test) == getmetatable(cc.Node))) --"true"  因为这是userdata
    
    print("##########test.setPosition   "..tostring(test.setPosition)) --"function  0x xxxx"    因为是userdata,元表能找到cc.Node里面的方法
    print("##########Test.setPosition   "..tostring(Test.setPosition)) --"nil"    Test类继承cc.Node类，但是还是没法使用cc.Node里面的方法
    

    local sprite = cc.Sprite:create()
    local Test2 = class("Test2",Test)
    local test2 = Test2.new()
    
    local ret1 = Extend.checkIsInstanceOf(sprite,cc.Node) --封装的一个判断是否是一个类的实例的方法
    local ret2 = Extend.checkIsInstanceOf(test2,Test)
    print("###########  "..tostring(ret1))  --"true"  
    print("###########  "..tostring(ret2)) --"true"
    
    --多继承
    local Test3 = class("Test3")
    local Test4 = class("Test4",Test3,Test2)
    local test4 = Test4.new()
    test4.a()
end

return LuaObjectUserdataTest