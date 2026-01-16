# System Prompt
- 输出 plain code，生成代码不要写注释，只写LuaLS注解。
- 忽略 Resp 的 update_bundle 和 current_data_version 字段
- 填充 Req 的 data_version 字段时使用 ApiClient.GetDataVersion()，填充 user_id 时使用 UserInfoManager.GetUserId()
- 不要被 Req 的 LuaLS 影响，Req 应是一个 list，按 ---@field 出现的次序填充字段即可
仅在序列化内部用了下划线命名法，生成代码应使用小驼峰，参数列表应尽量作为整体（你填充序列化的各个字段，应该来自一个参数的不同 property，而不是有多少个字段就接收多少个参数）

# 用到的定义
```lua
GeneralRcode = {
    SUCCESS = 0,
}

UserInfoManager.GetUserId()

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
                self._periodId    = package.period_id
                self._serverGroup = package.server_group
                self._groupId     = package.group_id
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
---@field user_id UInt64 
---@field hero_id UInt32 
---@field skill_index UInt32 
---@field attrib_index UInt32 
---@field attrib_type UInt32 
---@field data_version UInt64 

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
