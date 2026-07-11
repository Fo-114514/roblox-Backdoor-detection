-- 修复版：F3X Require Executor GUI（确保显示）
-- 针对注入器环境优化

local function CreateF3XRequireGUI()
    -- 检查是否为本地玩家环境
    local player = game:GetService("Players").LocalPlayer
    if not player then
        warn("[F3X] 未找到LocalPlayer")
        return
    end

    -- 等待玩家加载完成
    repeat wait() until player:IsA("Player") and player:FindFirstChild("PlayerGui")
    
    -- 1. 定位F3X SyncAPI（增加更多搜索方式）
    local function findF3XAPI()
        -- 方式1：全局搜索
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.Name == "SyncAPI" and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                return obj
            end
        end
        
        -- 方式2：搜索工具
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            local api = tool:FindFirstChild("SyncAPI")
            if api then return api end
        end
        
        -- 方式3：搜索角色
        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if obj.Name == "SyncAPI" then return obj end
            end
        end
        
        -- 方式4：搜索ReplicatedStorage
        for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj.Name == "SyncAPI" then return obj end
        end
        
        return nil
    end

    local syncAPI = findF3XAPI()
    if not syncAPI then
        -- 如果没有SyncAPI，依然显示GUI，但提示错误
        warn("[F3X] SyncAPI not found - GUI will still show")
    end

    local remote = syncAPI and (syncAPI:IsA("RemoteFunction") and syncAPI or syncAPI.Parent:FindFirstChild("ServerEndpoint")) or nil

    -- 2. 创建GUI（使用多种父级尝试）
    local gui = Instance.new("ScreenGui")
    gui.Name = "F3XRequireGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999999999
    
    -- 尝试多个父级
    local parentSuccess = false
    local parentOptions = {
        player.PlayerGui,
        player:WaitForChild("PlayerGui"),
        game:GetService("CoreGui"),
        game:GetService("StarterGui")
    }
    
    for _, parent in ipairs(parentOptions) do
        if parent then
            pcall(function()
                gui.Parent = parent
                parentSuccess = true
            end)
            if parentSuccess then break end
        end
    end
    
    if not parentSuccess then
        -- 最后的备用方案：直接放到workspace（但可能不会显示）
        pcall(function()
            gui.Parent = workspace
            parentSuccess = true
        end)
    end
    
    if not parentSuccess then
        warn("[F3X] 无法将GUI添加到任何父级")
        return
    end

    -- 3. 创建UI元素（使用绝对大小确保显示）
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 520, 0, 440)
    frame.Position = UDim2.new(0.5, -260, 0.5, -220)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 180, 255)
    frame.ClipsDescendants = false
    frame.Parent = gui

    -- 标题栏（带颜色强调）
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "🔧 F3X Require Executor"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Module路径输入框
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -20, 0, 25)
    pathLabel.Position = UDim2.new(0, 10, 0, 55)
    pathLabel.Text = "📁 Module路径"
    pathLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    pathLabel.TextSize = 14
    pathLabel.BackgroundTransparency = 1
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.Parent = frame

    local pathBox = Instance.new("TextBox")
    pathBox.Size = UDim2.new(1, -20, 0, 32)
    pathBox.Position = UDim2.new(0, 10, 0, 85)
    pathBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    pathBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    pathBox.Text = "game.ReplicatedStorage.SomeModule"
    pathBox.Font = Enum.Font.SourceSans
    pathBox.TextSize = 16
    pathBox.TextXAlignment = Enum.TextXAlignment.Left
    pathBox.ClearTextOnFocus = false
    pathBox.BorderSizePixel = 1
    pathBox.BorderColor3 = Color3.fromRGB(80, 80, 120)
    pathBox.Parent = frame

    -- 模式选择
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(0.5, 0, 0, 25)
    modeLabel.Position = UDim2.new(0, 10, 0, 125)
    modeLabel.Text = "⚙️ 执行模式"
    modeLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    modeLabel.TextSize = 14
    modeLabel.BackgroundTransparency = 1
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeLabel.Parent = frame

    local modeDropdown = Instance.new("TextButton")
    modeDropdown.Size = UDim2.new(0.45, 0, 0, 30)
    modeDropdown.Position = UDim2.new(0, 10, 0, 155)
    modeDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    modeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeDropdown.Text = "SyncMesh注入"
    modeDropdown.Font = Enum.Font.Gotham
    modeDropdown.TextSize = 15
    modeDropdown.BorderSizePixel = 1
    modeDropdown.BorderColor3 = Color3.fromRGB(80, 80, 120)
    modeDropdown.Parent = frame

    local modeList = {"SyncMesh注入", "CreatePart注入", "远程执行(Invoke)"}
    local currentModeIndex = 1
    modeDropdown.MouseButton1Click:Connect(function()
        currentModeIndex = currentModeIndex % #modeList + 1
        modeDropdown.Text = modeList[currentModeIndex]
    end)

    -- 按钮行
    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, -20, 0, 42)
    btnRow.Position = UDim2.new(0, 10, 0, 195)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = frame

    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0.48, -5, 1, 0)
    executeBtn.Position = UDim2.new(0, 0, 0, 0)
    executeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.Text = "▶️ 执行"
    executeBtn.Font = Enum.Font.GothamBold
    executeBtn.TextSize = 18
    executeBtn.BorderSizePixel = 0
    executeBtn.Parent = btnRow

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.48, -5, 1, 0)
    clearBtn.Position = UDim2.new(0.52, 0, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Text = "🗑️ 清空"
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 18
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = btnRow

    -- 状态栏
    local statusBar = Instance.new("TextLabel")
    statusBar.Size = UDim2.new(1, -20, 0, 28)
    statusBar.Position = UDim2.new(0, 10, 1, -34)
    statusBar.Text = "✅ 就绪 | " .. (syncAPI and "F3X已连接" or "F3X未连接(部分功能不可用)")
    statusBar.TextColor3 = syncAPI and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 200, 0)
    statusBar.TextSize = 13
    statusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    statusBar.BackgroundTransparency = 0.3
    statusBar.Font = Enum.Font.Gotham
    statusBar.TextXAlignment = Enum.TextXAlignment.Left
    statusBar.Parent = frame

    -- 输出框（带滚动）
    local resultFrame = Instance.new("Frame")
    resultFrame.Size = UDim2.new(1, -20, 0, 145)
    resultFrame.Position = UDim2.new(0, 10, 0, 247)
    resultFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    resultFrame.BorderSizePixel = 1
    resultFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    resultFrame.ClipsDescendants = true
    resultFrame.Parent = frame

    local resultBox = Instance.new("ScrollingFrame")
    resultBox.Size = UDim2.new(1, 0, 1, 0)
    resultBox.Position = UDim2.new(0, 0, 0, 0)
    resultBox.BackgroundTransparency = 1
    resultBox.BorderSizePixel = 0
    resultBox.ScrollBarThickness = 6
    resultBox.Parent = resultFrame

    local resultText = Instance.new("TextLabel")
    resultText.Size = UDim2.new(1, -10, 0, 140)
    resultText.Position = UDim2.new(0, 5, 0, 5)
    resultText.Text = "等待执行..."
    resultText.TextColor3 = Color3.fromRGB(200, 200, 210)
    resultText.TextSize = 14
    resultText.TextWrapped = true
    resultText.TextXAlignment = Enum.TextXAlignment.Left
    resultText.TextYAlignment = Enum.TextYAlignment.Top
    resultText.BackgroundTransparency = 1
    resultText.Font = Enum.Font.SourceSans
    resultText.Parent = resultBox
    resultBox.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 20)

    -- 4. 拖动功能
    local dragging, dragStartPos, dragStartMouse
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

    -- 5. 核心执行函数
    local function executeRequire(modulePath)
        resultText.Text = "⏳ 正在执行 require(" .. modulePath .. ") ...\n"
        resultBox.CanvasSize = UDim2.new(0, 0, 0, 150)
        statusBar.Text = "⏳ 执行中..."
        statusBar.TextColor3 = Color3.fromRGB(255, 200, 50)

        if not syncAPI then
            resultText.Text = resultText.Text .. "❌ 错误: 未找到F3X SyncAPI"
            statusBar.Text = "❌ F3X未连接"
            statusBar.TextColor3 = Color3.fromRGB(255, 80, 80)
            resultBox.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 20)
            return
        end

        local serverEndpoint = syncAPI.Parent:FindFirstChild("ServerEndpoint")
        if not serverEndpoint then
            resultText.Text = resultText.Text .. "❌ 错误: 未找到ServerEndpoint"
            statusBar.Text = "❌ 无ServerEndpoint"
            statusBar.TextColor3 = Color3.fromRGB(255, 80, 80)
            resultBox.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 20)
            return
        end

        local mode = modeList[currentModeIndex]
        local result = nil
        local success = false
        local errorMsg = ""

        if mode == "SyncMesh注入" then
            local args = {
                [1] = "SyncMesh",
                [2] = {
                    [1] = {
                        ["Part"] = workspace.Terrain or workspace,
                        ["MeshId"] = "rbxassetid://0"
                    }
                }
            }
            local success2, res2 = pcall(function()
                return serverEndpoint:InvokeServer(unpack(args))
            end)
            if success2 then
                result = res2
                success = true
            else
                errorMsg = tostring(res2)
            end

        elseif mode == "CreatePart注入" then
            local createArgs = {
                [1] = "CreatePart",
                [2] = "Normal",
                [3] = CFrame.new(0, -9999, 0),
                [4] = game.ReplicatedStorage
            }
            pcall(function() serverEndpoint:InvokeServer(unpack(createArgs)) end)
            wait(0.3)

            local tempPart
            for _, obj in ipairs(game.ReplicatedStorage:GetChildren()) do
                if obj:IsA("BasePart") and obj.Name == "Part" then
                    tempPart = obj
                    break
                end
            end

            if tempPart then
                local ms = Instance.new("ModuleScript")
                ms.Name = "TempRequire"
                ms.Parent = tempPart
                ms.Source = "return require(" .. modulePath .. ")"

                local execArgs = {
                    [1] = "SyncMesh",
                    [2] = {
                        [1] = {
                            ["Part"] = tempPart,
                            ["MeshId"] = "rbxassetid://0"
                        }
                    }
                }
                local success2, res2 = pcall(function()
                    return serverEndpoint:InvokeServer(unpack(execArgs))
                end)
                if success2 then
                    result = res2
                    success = true
                else
                    errorMsg = tostring(res2)
                end
                tempPart:Destroy()
            else
                errorMsg = "无法创建临时Part"
            end

        else
            local execArgs = {
                [1] = "ExecuteScript",
                [2] = modulePath,
                [3] = "require"
            }
            local success2, res2 = pcall(function()
                return serverEndpoint:InvokeServer(unpack(execArgs))
            end)
            if success2 then
                result = res2
                success = true
            else
                errorMsg = tostring(res2)
            end
        end

        if success then
            local resultStr = tostring(result)
            if #resultStr > 800 then
                resultStr = resultStr:sub(1, 800) .. "... (截断)"
            end
            resultText.Text = resultText.Text .. "✅ 执行成功！\n📦 返回值:\n" .. resultStr
            statusBar.Text = "✅ 成功 | " .. mode
            statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            resultText.Text = resultText.Text .. "❌ 执行失败: " .. errorMsg
            statusBar.Text = "❌ 失败: " .. errorMsg:sub(1, 25)
            statusBar.TextColor3 = Color3.fromRGB(255, 80, 80)
        end

        resultBox.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 30)
    end

    executeBtn.MouseButton1Click:Connect(function()
        local path = pathBox.Text
        if path == "" then
            resultText.Text = "⚠️ 请输入Module路径"
            resultBox.CanvasSize = UDim2.new(0, 0, 0, 150)
            return
        end
        executeRequire(path)
    end)

    clearBtn.MouseButton1Click:Connect(function()
        resultText.Text = "等待执行..."
        resultBox.CanvasSize = UDim2.new(0, 0, 0, 150)
        statusBar.Text = "✅ 就绪 | " .. (syncAPI and "F3X已连接" or "F3X未连接")
        statusBar.TextColor3 = syncAPI and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 200, 0)
    end)

    print("[F3X Require GUI] 已加载")
    return gui
end

-- 执行
CreateF3XRequireGUI()
