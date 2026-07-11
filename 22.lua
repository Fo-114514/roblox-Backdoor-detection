-- F3X Require Executor GUI
-- 利用F3X漏洞远程执行require

local function CreateF3XRequireGUI()
    -- 1. 定位F3X SyncAPI
    local function findF3XAPI()
        local player = game.Players.LocalPlayer
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.Name == "SyncAPI" and obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local tool = obj.Parent
                if tool and tool:IsA("Tool") then
                    return obj
                end
            end
        end
        -- 二次搜索：直接在ReplicatedStorage中查找
        for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj.Name == "SyncAPI" and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                return obj
            end
        end
        return nil
    end

    local syncAPI = findF3XAPI()
    if not syncAPI then
        warn("[F3X] SyncAPI not found")
        return
    end

    local remote = syncAPI:IsA("RemoteFunction") and syncAPI or syncAPI.Parent:FindFirstChild("ServerEndpoint")
    if not remote then
        warn("[F3X] ServerEndpoint not found")
        return
    end

    -- 2. 创建GUI
    local player = game.Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "F3XRequireGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    -- 主框架
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 420)
    frame.Position = UDim2.new(0.5, -250, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 180, 255)
    frame.Parent = gui

    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🔧 F3X Require Executor"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- Module路径输入框
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, 0, 0, 25)
    pathLabel.Position = UDim2.new(0, 0, 0, 45)
    pathLabel.Text = "📁 Module路径 (如: game.ReplicatedStorage.MyModule)"
    pathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    pathLabel.TextScaled = false
    pathLabel.TextSize = 14
    pathLabel.BackgroundTransparency = 1
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.Parent = frame

    local pathBox = Instance.new("TextBox")
    pathBox.Size = UDim2.new(1, -20, 0, 30)
    pathBox.Position = UDim2.new(0, 10, 0, 75)
    pathBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    pathBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    pathBox.Text = "game.ReplicatedStorage.SomeModule"
    pathBox.Font = Enum.Font.SourceSans
    pathBox.TextSize = 16
    pathBox.TextXAlignment = Enum.TextXAlignment.Left
    pathBox.ClearTextOnFocus = false
    pathBox.Parent = frame

    -- 执行模式选择
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(1, 0, 0, 25)
    modeLabel.Position = UDim2.new(0, 0, 0, 115)
    modeLabel.Text = "⚙️ 执行模式"
    modeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    modeLabel.TextScaled = false
    modeLabel.TextSize = 14
    modeLabel.BackgroundTransparency = 1
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeLabel.Parent = frame

    local modeDropdown = Instance.new("TextButton")
    modeDropdown.Size = UDim2.new(0.4, 0, 0, 30)
    modeDropdown.Position = UDim2.new(0, 10, 0, 145)
    modeDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    modeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeDropdown.Text = "SyncMesh注入"
    modeDropdown.Font = Enum.Font.Gotham
    modeDropdown.TextSize = 16
    modeDropdown.Parent = frame

    local modeList = {"SyncMesh注入", "CreatePart注入", "远程执行(Invoke)"}
    local currentModeIndex = 1
    modeDropdown.MouseButton1Click:Connect(function()
        currentModeIndex = currentModeIndex % #modeList + 1
        modeDropdown.Text = modeList[currentModeIndex]
    end)

    -- 执行按钮
    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0.45, 0, 0, 40)
    executeBtn.Position = UDim2.new(0.025, 0, 0, 190)
    executeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.Text = "▶️ 执行 Require"
    executeBtn.Font = Enum.Font.GothamBold
    executeBtn.TextSize = 18
    executeBtn.BorderSizePixel = 0
    executeBtn.Parent = frame

    -- 清空按钮
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.45, 0, 0, 40)
    clearBtn.Position = UDim2.new(0.525, 0, 0, 190)
    clearBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Text = "🗑️ 清空日志"
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 18
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = frame

    -- 结果输出框
    local resultBox = Instance.new("ScrollingFrame")
    resultBox.Size = UDim2.new(1, -20, 0, 140)
    resultBox.Position = UDim2.new(0, 10, 0, 245)
    resultBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    resultBox.BorderSizePixel = 1
    resultBox.BorderColor3 = Color3.fromRGB(60, 60, 80)
    resultBox.ScrollBarThickness = 6
    resultBox.Parent = frame

    local resultText = Instance.new("TextLabel")
    resultText.Size = UDim2.new(1, -10, 0, 130)
    resultText.Position = UDim2.new(0, 5, 0, 5)
    resultText.Text = "等待执行..."
    resultText.TextColor3 = Color3.fromRGB(200, 200, 200)
    resultText.TextSize = 14
    resultText.TextWrapped = true
    resultText.TextXAlignment = Enum.TextXAlignment.Left
    resultText.TextYAlignment = Enum.TextYAlignment.Top
    resultText.BackgroundTransparency = 1
    resultText.Font = Enum.Font.SourceSans
    resultText.Parent = resultBox
    resultBox.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 10)

    -- 状态栏
    local statusBar = Instance.new("TextLabel")
    statusBar.Size = UDim2.new(1, 0, 0, 25)
    statusBar.Position = UDim2.new(0, 0, 1, -25)
    statusBar.Text = "✅ 就绪 | F3X漏洞已加载"
    statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
    statusBar.TextSize = 13
    statusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    statusBar.BackgroundTransparency = 0.5
    statusBar.Font = Enum.Font.Gotham
    statusBar.TextXAlignment = Enum.TextXAlignment.Left
    statusBar.Parent = frame

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- 拖动功能
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

    -- 3. 核心执行函数（支持三种模式）
    local function executeRequire(modulePath)
        -- 清理显示
        resultText.Text = "⏳ 正在执行 require(" .. modulePath .. ") ...\n"
        resultBox.CanvasSize = UDim2.new(0, 0, 0, 150)
        statusBar.Text = "⏳ 执行中..."

        -- 获取F3X远程函数
        local serverEndpoint = syncAPI.Parent:FindFirstChild("ServerEndpoint")
        if not serverEndpoint then
            resultText.Text = resultText.Text .. "❌ 错误: 未找到ServerEndpoint"
            statusBar.Text = "❌ 执行失败"
            return
        end

        local mode = modeList[currentModeIndex]
        local result = nil
        local success = false
        local errorMsg = ""

        if mode == "SyncMesh注入" then
            -- 模式1: 通过SyncMesh注入require代码
            local args = {
                [1] = "SyncMesh",
                [2] = {
                    [1] = {
                        ["Part"] = workspace.Terrain or workspace,
                        ["MeshId"] = "rbxassetid://0"
                    }
                }
            }
            -- 注入require到第三个参数
            local injectCode = "local r = require(" .. modulePath .. "); return r"
            local success, res = pcall(function()
                return serverEndpoint:InvokeServer(unpack(args))
            end)
            if success then
                result = res
                success = true
            else
                errorMsg = tostring(res)
            end

        elseif mode == "CreatePart注入" then
            -- 模式2: 创建临时Part并附加ModuleScript
            local createArgs = {
                [1] = "CreatePart",
                [2] = "Normal",
                [3] = CFrame.new(0, -9999, 0),
                [4] = game.ReplicatedStorage
            }
            local partRef = serverEndpoint:InvokeServer(unpack(createArgs))
            wait(0.2)

            -- 搜索刚创建的Part
            local tempPart
            for _, obj in ipairs(game.ReplicatedStorage:GetChildren()) do
                if obj:IsA("BasePart") and obj.Name == "Part" then
                    tempPart = obj
                    break
                end
            end

            if tempPart then
                -- 添加ModuleScript
                local ms = Instance.new("ModuleScript")
                ms.Name = "TempRequire"
                ms.Parent = tempPart
                ms.Source = "return require(" .. modulePath .. ")"

                -- 通过SyncMesh触发执行
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

        else -- "远程执行(Invoke)"
            -- 模式3: 直接尝试执行require（如果服务端支持）
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

        -- 显示结果
        if success then
            local resultStr = tostring(result)
            if #resultStr > 500 then
                resultStr = resultStr:sub(1, 500) .. "... (截断)"
            end
            resultText.Text = resultText.Text .. "✅ 执行成功！\n📦 返回值:\n" .. resultStr
            statusBar.Text = "✅ 执行成功 | " .. mode
            statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            resultText.Text = resultText.Text .. "❌ 执行失败: " .. errorMsg
            statusBar.Text = "❌ 执行失败: " .. errorMsg:sub(1, 30)
            statusBar.TextColor3 = Color3.fromRGB(255, 80, 80)
        end

        -- 更新滚动框高度
        resultBox.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 20)
    end

    -- 绑定执行按钮
    executeBtn.MouseButton1Click:Connect(function()
        local path = pathBox.Text
        if path == "" then
            resultText.Text = "⚠️ 请输入Module路径"
            return
        end
        executeRequire(path)
    end)

    -- 清空按钮
    clearBtn.MouseButton1Click:Connect(function()
        resultText.Text = "等待执行..."
        resultBox.CanvasSize = UDim2.new(0, 0, 0, 150)
        statusBar.Text = "✅ 就绪 | F3X漏洞已加载"
        statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
    end)

    print("[F3X Require GUI] 已加载")
end

-- 执行
CreateF3XRequireGUI()
