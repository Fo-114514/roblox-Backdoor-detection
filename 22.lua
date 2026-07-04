-- 获取当前播放音乐ID并显示UI
local function getMusicIDWithUI()
    -- 1. 创建UI界面
    local player = game:GetService("Players").LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "MusicIDDisplay"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- 背景框（半透明，可拖动）
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    frame.Parent = gui
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🎵 当前播放音乐 ID"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- 音乐ID显示
    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, 0, 0, 35)
    idLabel.Position = UDim2.new(0, 0, 0, 30)
    idLabel.Text = "未检测到音乐"
    idLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    idLabel.TextScaled = true
    idLabel.BackgroundTransparency = 1
    idLabel.Font = Enum.Font.Gotham
    idLabel.Parent = frame
    
    -- 复制按钮
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 60, 0, 25)
    copyBtn.Position = UDim2.new(1, -70, 1, -30)
    copyBtn.Text = "复制"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = frame
    copyBtn.MouseButton1Click:Connect(function()
        if idLabel.Text ~= "未检测到音乐" and idLabel.Text ~= "" then
            setclipboard(idLabel.Text)
            copyBtn.Text = "✅ 已复制"
            task.wait(1.5)
            copyBtn.Text = "复制"
        end
    end)
    
    -- 2. 获取音乐ID的函数
    local function getCurrentMusicID()
        -- 方法1：从SoundService中查找正在播放的音频
        local soundService = game:GetService("SoundService")
        local sounds = soundService:GetDescendants()
        for _, obj in ipairs(sounds) do
            if obj:IsA("Sound") or obj:IsA("SoundGroup") then
                -- 检查是否有播放中的音频
                local success, isPlaying = pcall(function()
                    return obj.IsPlaying and obj.IsPlaying == true
                end)
                if success and isPlaying and obj.SoundId and obj.SoundId ~= "" then
                    local id = obj.SoundId
                    -- 提取纯数字ID（格式通常为 rbxlasset://1234567890 或 https://www.roblox.com/asset/?id=1234567890）
                    local numericId = id:match("(%d+)")
                    if numericId then
                        return numericId, id
                    else
                        return id, id
                    end
                end
            end
        end
        
        -- 方法2：从工作区中查找播放中的音频
        local workspaceSounds = workspace:GetDescendants()
        for _, obj in ipairs(workspaceSounds) do
            if obj:IsA("Sound") then
                local success, isPlaying = pcall(function()
                    return obj.IsPlaying and obj.IsPlaying == true
                end)
                if success and isPlaying and obj.SoundId and obj.SoundId ~= "" then
                    local numericId = obj.SoundId:match("(%d+)")
                    if numericId then
                        return numericId, obj.SoundId
                    else
                        return obj.SoundId, obj.SoundId
                    end
                end
            end
        end
        
        -- 方法3：从玩家角色或工具中查找
        local char = player.Character
        if char then
            local charSounds = char:GetDescendants()
            for _, obj in ipairs(charSounds) do
                if obj:IsA("Sound") then
                    local success, isPlaying = pcall(function()
                        return obj.IsPlaying and obj.IsPlaying == true
                    end)
                    if success and isPlaying and obj.SoundId and obj.SoundId ~= "" then
                        local numericId = obj.SoundId:match("(%d+)")
                        if numericId then
                            return numericId, obj.SoundId
                        else
                            return obj.SoundId, obj.SoundId
                        end
                    end
                end
            end
        end
        
        return nil, nil
    end
    
    -- 3. 实时更新UI
    local function updateDisplay()
        local id, fullId = getCurrentMusicID()
        if id then
            idLabel.Text = "🎵 " .. id
            -- 鼠标悬停显示完整链接
            idLabel.ToolTip = fullId or id
        else
            idLabel.Text = "🔇 未检测到音乐"
            idLabel.ToolTip = ""
        end
    end
    
    -- 4. 定时刷新（每0.5秒检查一次）
    updateDisplay()
    local connection = game:GetService("RunService").Heartbeat:Connect(function()
        updateDisplay()
    end)
    
    -- 5. 关闭按钮（右上角）
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        connection:Disconnect()
        gui:Destroy()
        print("[MusicID] UI已关闭")
    end)
    
    -- 6. 拖动功能
    local dragging = false
    local dragStartPos, dragStartMouse
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = frame.Position
            dragStartMouse = input.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartMouse
            frame.Position = UDim2.new(
                dragStartPos.X.Scale + delta.X / 1000,
                dragStartPos.X.Offset + delta.X,
                dragStartPos.Y.Scale + delta.Y / 1000,
                dragStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    print("[MusicID] UI已启动，正在监听音乐播放...")
end

-- 执行
getMusicIDWithUI()
