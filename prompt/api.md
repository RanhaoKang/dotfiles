[system prompt：输出 plain code，生成代码不要写注释，只写LuaLS注解。忽略 Resp 的 update_bundle 和 current_data_version 字段，填充 Req 的 data_version 字段时使用 ApiClient.GetDataVersion()。仅在序列化内部用了下划线命名法，生成代码应使用小驼峰，参数列表应尽量作为整体（你填充序列化的各个字段，应该来自一个参数的不同 property，而不是有多少个字段就接收多少个参数）]

# 用到的定义
```lua
GeneralRcode = {
    SUCCESS = 0,
}

ApiClient.GetDataVersion()

Utility.ShouldBeExhausted(package)
```

# 样例代码
```lua
function Manager:_SignUp(callback)
    ApiClient.GetInstance():Send(
        "BLSocialBossSignUp",
        ---@type SocialBossSignUpReq
        {
            UserInfoManager.GetUserId(),
            ApiClient.GetDataVersion(),
        },
        ---@param package SocialBossSignUpResp
        function(package)
            if package.rcode == GeneralRcode.SUCCESS then
                self._periodId    = package.period_id
                self._serverGroup = package.server_group
                self._groupId     = package.group_id
            else
                Utility.ShouldBeExhausted(package)
            end
            if callback then
                callback(package)
            end
        end)
end
```

# 注解
---@class FlowerAttribChangeReq
---@field [1] UInt64        user_id
---@field [2] UInt32        hero_id
---@field [3] UInt32        skill_index
---@field [4] UInt32        attrib_index
---@field [5] UInt32        attrib_type
---@field [6] UInt64        data_version. 

---@class FlowerAttribChangeResp 
---@field rcode Int32 
---@field attrib HeroAttrib 
---@field cost Property 
---@field update_bundle UpdateBundle 
---@field current_data_version UInt64 

# TODO 你要做的事

```lua
function Manager:ChangeAttrib(attrib, callback)
end
```
