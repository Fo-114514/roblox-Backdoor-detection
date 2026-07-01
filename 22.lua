-- 方案一：生成.rbxmx（XML格式，Studio完美支持）
local function stealAsXML()
    -- UI进度（沿用之前）
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
    title.Text = "正在导出XML地图..."
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
    
    -- 构建XML字符串
    local xmlParts = {}
    xmlParts[#xmlParts+1] = [[<?xml version="1.0" encoding="UTF-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
    <External>null</External>
    <External>nil</External>
    <Item class="DataModel" referent="0">
        <Properties>
            <string name="Name">Roblox</string>
        </Properties>]]
    
    -- 递归生成XML节点（简化版）
    local function generateXML(inst, depth)
        local indent = string.rep("    ", depth)
        local lines = {}
        lines[#lines+1] = string.format('%s<Item class="%s" referent="%d">', indent, inst.ClassName, inst.id)
        
        -- 属性
        for propName, propData in pairs(inst.properties) do
            local val = propData.value
            local t = propData.type
            local tag
            if t == "string" then
                tag = "string"
                val = tostring(val):gsub("&", "&amp;"):gsub("<", "&lt;")
            elseif t == "number" then
                tag = "float"
            elseif t == "boolean" then
                tag = "bool"
                val = val and "true" or "false"
            elseif t == "Color3" then
                tag = "Color3"
                val = string.format("%f,%f,%f", val.r, val.g, val.b)
            elseif t == "Vector3" then
                tag = "Vector3"
                val = string.format("%f,%f,%f", val.x, val.y, val.z)
            elseif t == "CFrame" then
                tag = "CFrame"
                local r00,r01,r02,r10,r11,r12,r20,r21,r22,px,py,pz = val:GetComponents()
                val = string.format("%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f", 
                    r00,r01,r02,r10,r11,r12,r20,r21,r22,px,py,pz)
            else
                tag = "string"
                val = tostring(val):gsub("&", "&amp;"):gsub("<", "&lt;")
            end
            lines[#lines+1] = string.format('%s    <%s name="%s">%s</%s>', indent, tag, propName, val, tag)
        end
        
        -- 子级
        for _, childId in ipairs(inst.childrenIds) do
            local child = instances[childId]
            if child then
                local childLines = generateXML(child, depth + 1)
                for _, line in ipairs(childLines) do
                    lines[#lines+1] = line
                end
            end
        end
        
        lines[#lines+1] = string.format('%s</Item>', indent)
        return lines
    end
    
    -- 先收集所有实例（同之前）
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
    updateUI(0, totalInstances, "正在捕获...")
    
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
    updateUI(totalInstances, totalInstances, "捕获完成，生成XML...")
    
    -- 生成根节点（DataModel）
    local rootLines = generateXML(instances[1], 1)
    for _, line in ipairs(rootLines) do
        xmlParts[#xmlParts+1] = line
    end
    
    xmlParts[#xmlParts+1] = [[    </Item>
</roblox>]]
    
    local xmlContent = table.concat(xmlParts, "\n")
    
    -- 保存为.rbxmx（XML格式）
    local saveDir = getexecutordirectory and getexecutordirectory() or ""
    if saveDir == "" then saveDir = "." end
    local fileName = saveDir .. "/stolen_map.rbxmx"
    writefile(fileName, xmlContent)
    
    updateUI(#instances, #instances, "✅ 完成！文件已保存为.rbxmx")
    task.wait(1.5)
    gui:Destroy()
    
    print("[XML Steal] 文件保存至：" .. fileName)
    print("[XML Steal] 请直接用Roblox Studio打开此文件（.rbxmx）")
end

stealAsXML()
