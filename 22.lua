-- 带UI进度条的完整偷取脚本（缓慢但可视化）
-- 使用ScreenGui显示实时进度，适合大型地图

local function stealMapWithUI()
    -- 1. 创建UI界面（进度条 + 文字）
    local player = game:GetService("Players").LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "StealProgressUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- 背景框
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 120)
    frame.Position = UDim2.new(0.5, -200, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = "正在盗取地图资源..."
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    -- 进度条背景
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.9, 0, 0, 20)
    progressBg.Position = UDim2.new(0.05, 0, 0, 40)
    progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = frame
    
    -- 进度条填充
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    
    -- 进度文字
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 0, 30)
    progressText.Position = UDim2.new(0, 0, 0, 70)
    progressText.Text = "0 / 0  (0%)"
    progressText.TextColor3 = Color3.fromRGB(200, 200, 200)
    progressText.TextScaled = true
    progressText.BackgroundTransparency = 1
    progressText.Parent = frame
    
    -- 更新UI函数
    local function updateUI(current, total, status)
        local percent = total > 0 and (current / total) * 100 or 0
        progressFill.Size = UDim2.new(math.clamp(percent / 100, 0, 1), 0, 1, 0)
        progressText.Text = string.format("%d / %d  (%.1f%%)  %s", current, total, percent, status or "")
        task.wait() -- 强制刷新UI
    end
    
    -- 2. 统计总实例数（先快速遍历一次，仅计数）
    local totalInstances = 0
    local queue = {game}
    while #queue > 0 do
        local inst = table.remove(queue)
        totalInstances = totalInstances + 1
        for _, child in ipairs(inst:GetChildren()) do
            table.insert(queue, child)
        end
    end
    
    updateUI(0, totalInstances, "正在读取实例...")
    
    -- 3. 正式捕获（带进度更新）
    local instances = {}
    local idMap = {[game] = 0}
    local idCounter = 0
    local processed = 0
    
    -- 使用递归但加入进度更新
    local function collect(inst, parentId)
        processed = processed + 1
        if processed % 10 == 0 then  -- 每10个更新一次UI，减少刷新开销
            updateUI(processed, totalInstances, "正在捕获...")
        end
        
        idCounter = idCounter + 1
        local myId = idCounter
        idMap[inst] = myId
        
        -- 获取属性（缓慢但完整）
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
        
        return myId
    end
    
    collect(game, 0)
    updateUI(totalInstances, totalInstances, "捕获完成，正在生成文件...")
    
    -- 4. 构建rbxl（带进度）
    local stringTable = {}
    local function addString(str)
        str = tostring(str)
        for i, s in ipairs(stringTable) do
            if s == str then return i end
        end
        table.insert(stringTable, str)
        return #stringTable
    end
    
    -- 先构建字符串表（显示进度）
    local totalProps = 0
    for _, inst in pairs(instances) do
        totalProps = totalProps + 1
        addString(inst.className)
        addString(inst.name)
        for propName, propData in pairs(inst.properties) do
            addString(propName)
            if propData.type == "string" then
                addString(propData.value)
            elseif propData.type == "Enum" then
                addString(tostring(propData.value))
            end
        end
    end
    
    local instanceBlocks = {}
    local built = 0
    for id, inst in pairs(instances) do
        built = built + 1
        if built % 50 == 0 then
            updateUI(built, #instances, "正在构建文件 (" .. built .. "/" .. #instances .. ")...")
        end
        
        -- 构建实例块（与之前类似）
        local block = string.pack("<I4 I4 I4 I4", 
            id,
            addString(inst.className),
            addString(inst.name),
            inst.parentId
        )
        
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
            propData = propData .. string.pack("<B I4 I4", 0, addString(propName), #encoded) .. encoded
        end
        block = block .. string.pack("<I4", #propData) .. propData
        block = block .. string.pack("<I4", #inst.childrenIds)
        for _, childId in ipairs(inst.childrenIds) do
            block = block .. string.pack("<I4", childId)
        end
        instanceBlocks[id] = block
    end
    
    -- 5. 组装并保存
    updateUI(#instances, #instances, "正在写入磁盘...")
    
    local header = "ROBLOX" .. string.pack("<I4 I4 I4", 0x0004, #instances, #stringTable)
    local stringData = ""
    for _, str in ipairs(stringTable) do
        stringData = stringData .. string.pack("<I4", #str) .. str
    end
    local instancesData = table.concat(instanceBlocks)
    local finalData = header .. stringData .. instancesData
    
    local saveDir = getexecutordirectory and getexecutordirectory() or ""
    if saveDir == "" then saveDir = "." end
    local fileName = saveDir .. "/stolen_map_with_progress.rbxl"
    writefile(fileName, finalData)
    
    -- 6. 完成UI
    updateUI(#instances, #instances, "✅ 完成！文件已保存")
    task.wait(1.5)
    gui:Destroy()
    
    print("[UI Steal] 完成！文件保存至：" .. fileName .. " 大小：" .. #finalData .. "字节")
    print("[UI Steal] 共捕获 " .. #instances .. " 个实例")
end

-- 执行
stealMapWithUI()
