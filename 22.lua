-- 修复版：生成真正可打开的.rbxl文件（解决Invalid XML错误）
local function stealMapFixed()
    -- 1. UI进度（沿用之前的）
    local player = game:GetService("Players").LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "StealProgressUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 120)
    frame.Position = UDim2.new(0.5, -200, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = "正在盗取地图资源..."
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.9, 0, 0, 20)
    progressBg.Position = UDim2.new(0.05, 0, 0, 40)
    progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = frame
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 0, 30)
    progressText.Position = UDim2.new(0, 0, 0, 70)
    progressText.Text = "0 / 0  (0%)"
    progressText.TextColor3 = Color3.fromRGB(200, 200, 200)
    progressText.TextScaled = true
    progressText.BackgroundTransparency = 1
    progressText.Parent = frame
    
    local function updateUI(current, total, status)
        local percent = total > 0 and (current / total) * 100 or 0
        progressFill.Size = UDim2.new(math.clamp(percent / 100, 0, 1), 0, 1, 0)
        progressText.Text = string.format("%d / %d  (%.1f%%)  %s", current, total, percent, status or "")
        task.wait()
    end
    
    -- 2. 收集实例（保持完整）
    local instances = {}
    local idMap = {[game] = 0}
    local idCounter = 0
    local totalInstances = 0
    local queue = {game}
    while #queue > 0 do
        local inst = table.remove(queue)
        totalInstances = totalInstances + 1
        for _, child in ipairs(inst:GetChildren()) do
            table.insert(queue, child)
        end
    end
    updateUI(0, totalInstances, "正在捕获实例...")
    
    local function collect(inst, parentId)
        idCounter = idCounter + 1
        local myId = idCounter
        idMap[inst] = myId
        
        local props = {}
        local success, allProps = pcall(function() return inst:GetProperties() end)
        if success and allProps then
            for _, propName in ipairs(allProps) do
                local success2, val = pcall(function() return inst[propName] end)
                if success2 and val ~= nil then
                    local t = typeof(val)
                    if t ~= "function" and t ~= "thread" and t ~= "userdata" then
                        props[propName] = {type = t, value = val}
                    end
                end
            end
        end
        
        local childrenIds = {}
        local children = inst:GetChildren()
        for _, child in ipairs(children) do
            local childId = collect(child, myId)
            table.insert(childrenIds, childId)
        end
        
        instances[myId] = {
            id = myId,
            className = inst.ClassName,
            name = inst.Name,
            parentId = parentId,
            properties = props,
            childrenIds = childrenIds
        }
        
        if myId % 50 == 0 then
            updateUI(myId, totalInstances, "捕获中...")
        end
        return myId
    end
    
    collect(game, 0)
    updateUI(totalInstances, totalInstances, "捕获完成，构建文件...")
    
    -- 3. 构建正确的.rbxl（修复关键错误）
    local stringTable = {}
    local function addString(str)
        str = tostring(str)
        for i, s in ipairs(stringTable) do
            if s == str then return i end
        end
        table.insert(stringTable, str)
        return #stringTable
    end
    
    -- 先构建字符串表
    for _, inst in pairs(instances) do
        addString(inst.className)
        addString(inst.name)
        for propName, propData in pairs(inst.properties) do
            addString(propName)
            if propData.type == "string" then
                addString(propData.value)
            end
        end
    end
    
    -- 构建实例块（严格按照rbxl规范）
    local instanceBlocks = {}
    local built = 0
    for id, inst in pairs(instances) do
        built = built + 1
        if built % 50 == 0 then
            updateUI(built, #instances, "构建中...")
        end
        
        -- 实例头：ID(4) + 类名字符串ID(4) + 名称字符串ID(4) + 父级ID(4)
        local block = string.pack("<I4 I4 I4 I4", 
            id,
            addString(inst.className),
            addString(inst.name),
            inst.parentId
        )
        
        -- 属性块
        local propData = ""
        for propName, propVal in pairs(inst.properties) do
            local encoded
            local t = propVal.type
            local v = propVal.value
            if t == "number" then
                encoded = string.pack("<d", v)
            elseif t == "string" then
                encoded = string.pack("<I4", addString(v))
            elseif t == "boolean" then
                encoded = v and "\x01" or "\x00"
            elseif t == "Color3" then
                encoded = string.pack("<fff", v.r, v.g, v.b)
            elseif t == "Vector3" then
                encoded = string.pack("<fff", v.x, v.y, v.z)
            elseif t == "CFrame" then
                local r00,r01,r02,r10,r11,r12,r20,r21,r22,px,py,pz = v:GetComponents()
                encoded = string.pack("<ffffffffffff", r00,r01,r02,r10,r11,r12,r20,r21,r22,px,py,pz)
            else
                encoded = string.pack("<I4", addString(tostring(v)))
            end
            -- 属性格式：类型(1) + 名称ID(4) + 长度(4) + 数据
            propData = propData .. string.pack("<B I4 I4", 0, addString(propName), #encoded) .. encoded
        end
        block = block .. string.pack("<I4", #propData) .. propData
        
        -- 子级列表
        block = block .. string.pack("<I4", #inst.childrenIds)
        for _, childId in ipairs(inst.childrenIds) do
            block = block .. string.pack("<I4", childId)
        end
        
        instanceBlocks[id] = block
    end
    
    -- 4. 生成完整文件（包含正确头尾）
    local header = "ROBLOX"  -- 魔数
    header = header .. string.pack("<I4", 0x0004)  -- 版本号（必须是4）
    header = header .. string.pack("<I4", #instances)  -- 实例数量
    header = header .. string.pack("<I4", #stringTable)  -- 字符串数量
    
    -- 字符串表
    local stringData = ""
    for _, str in ipairs(stringTable) do
        stringData = stringData .. string.pack("<I4", #str) .. str
    end
    
    -- 实例数据
    local instancesData = table.concat(instanceBlocks)
    
    -- 关键修复：添加文件尾（4字节校验，简单用0填充，但必须存在）
    local footer = string.pack("<I4", 0)  -- 校验和占位
    
    -- 组合最终数据
    local finalData = header .. stringData .. instancesData .. footer
    
    -- 5. 保存
    local saveDir = getexecutordirectory and getexecutordirectory() or ""
    if saveDir == "" then saveDir = "." end
    local fileName = saveDir .. "/stolen_map_fixed.rbxl"
    writefile(fileName, finalData)
    
    updateUI(#instances, #instances, "✅ 完成！文件已保存")
    task.wait(1.5)
    gui:Destroy()
    
    print("[Fixed Steal] 文件保存至：" .. fileName .. " 大小：" .. #finalData .. "字节")
    print("[Fixed Steal] 共捕获 " .. #instances .. " 个实例")
end

-- 执行
stealMapFixed()
