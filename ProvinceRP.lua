-- Province RP Menu by Tulen Hack
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Конфигурация
local MENU_KEY = Enum.KeyCode.LeftAlt
local ESPElements = {}
local ESPEnabled = false
local FullBrightEnabled = false
local FlingEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalGlobalShadows = Lighting.GlobalShadows

-- Создание основного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ProvinceRP_Menu"

-- Основной фрейм с блюром
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIBlur = Instance.new("BlurEffect")

MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 550, 0, 550)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 8)

UIBlur.Parent = game.Lighting
UIBlur.Size = 10
UIBlur.Enabled = false

-- Верхняя панель
local TopFrame = Instance.new("Frame")
local TopCorner = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local SubTitleLabel = Instance.new("TextLabel")

TopFrame.Parent = MainFrame
TopFrame.Size = UDim2.new(1, 0, 0, 70)
TopFrame.Position = UDim2.new(0, 0, 0, 0)
TopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopFrame.BorderSizePixel = 0

TopCorner.Parent = TopFrame
TopCorner.CornerRadius = UDim.new(0, 8)

TitleLabel.Parent = TopFrame
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Position = UDim2.new(0, 0, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "PROVINCE RP"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 24
TitleLabel.TextStrokeTransparency = 0.8

SubTitleLabel.Parent = TopFrame
SubTitleLabel.Size = UDim2.new(1, 0, 0, 20)
SubTitleLabel.Position = UDim2.new(0, 0, 0, 45)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitleLabel.Text = "by Tulen Hack"
SubTitleLabel.Font = Enum.Font.Gotham
SubTitleLabel.TextSize = 12

-- Табы
local TabsFrame = Instance.new("Frame")
local MainTab = Instance.new("TextButton")
local TeleportTab = Instance.new("TextButton")
local MiscTab = Instance.new("TextButton")

TabsFrame.Parent = MainFrame
TabsFrame.Size = UDim2.new(1, -40, 0, 35)
TabsFrame.Position = UDim2.new(0, 20, 0, 80)
TabsFrame.BackgroundTransparency = 1

-- Функция создания таба с закруглением
local function createTab(name, position)
    local tab = Instance.new("TextButton")
    local tabCorner = Instance.new("UICorner")
    
    tab.Parent = TabsFrame
    tab.Size = UDim2.new(0.3, 0, 1, 0)
    tab.Position = position
    tab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.Text = name
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 12
    tab.BorderSizePixel = 0
    
    tabCorner.Parent = tab
    tabCorner.CornerRadius = UDim.new(0, 6)
    
    return tab
end

MainTab = createTab("Main", UDim2.new(0, 0, 0, 0))
TeleportTab = createTab("Teleport", UDim2.new(0.35, 0, 0, 0))
MiscTab = createTab("Misc", UDim2.new(0.7, 0, 0, 0))

MainTab.BackgroundColor3 = Color3.fromRGB(0, 100, 200)

-- Контейнеры для контента
local MainContainer = Instance.new("ScrollingFrame")
local TeleportContainer = Instance.new("ScrollingFrame")
local MiscContainer = Instance.new("ScrollingFrame")

local function createContainer(name, visible)
    local container = Instance.new("ScrollingFrame")
    container.Parent = MainFrame
    container.Size = UDim2.new(1, -40, 1, -130)
    container.Position = UDim2.new(0, 20, 0, 125)
    container.BackgroundTransparency = 1
    container.Visible = visible
    container.Name = name .. "Container"
    container.ScrollBarThickness = 6
    container.ScrollingDirection = Enum.ScrollingDirection.Y
    container.CanvasSize = UDim2.new(0, 0, 2, 0)
    
    return container
end

MainContainer = createContainer("Main", true)
TeleportContainer = createContainer("Teleport", false)
MiscContainer = createContainer("Misc", false)

-- Функции для ESP
local function getTeamName(targetPlayer)
    if targetPlayer.Team then
        return targetPlayer.Team.Name
    end
    return "Без команды"
end

local function getTeamColor(targetPlayer)
    if targetPlayer.Team then
        return targetPlayer.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function createESP(targetPlayer)
    if targetPlayer == player then return end
    
    local character = targetPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Удаляем старый ESP если есть
    if ESPElements[targetPlayer] then
        if ESPElements[targetPlayer].Billboard then
            ESPElements[targetPlayer].Billboard:Destroy()
        end
    end
    
    local billboard = Instance.new("BillboardGui")
    local nameLabel = Instance.new("TextLabel")
    local teamLabel = Instance.new("TextLabel")
    
    billboard.Name = targetPlayer.Name .. "_ESP"
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = game.CoreGui
    
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Text = targetPlayer.Name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    
    teamLabel.Parent = billboard
    teamLabel.Size = UDim2.new(1, 0, 0.5, 0)
    teamLabel.Position = UDim2.new(0, 0, 0.5, 0)
    teamLabel.BackgroundTransparency = 1
    teamLabel.TextColor3 = getTeamColor(targetPlayer)
    teamLabel.Text = getTeamName(targetPlayer)
    teamLabel.Font = Enum.Font.Gotham
    teamLabel.TextSize = 12
    teamLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    teamLabel.TextStrokeTransparency = 0
    
    ESPElements[targetPlayer] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        TeamLabel = teamLabel
    }
end

local function removeESP(targetPlayer)
    if ESPElements[targetPlayer] then
        if ESPElements[targetPlayer].Billboard then
            ESPElements[targetPlayer].Billboard:Destroy()
        end
        ESPElements[targetPlayer] = nil
    end
end

local function updateESP()
    if not ESPEnabled then return end
    
    for targetPlayer, espData in pairs(ESPElements) do
        if targetPlayer and targetPlayer.Character and espData.NameLabel then
            local character = targetPlayer.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local localRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and localRootPart then
                local distance = (humanoidRootPart.Position - localRootPart.Position).Magnitude
                espData.NameLabel.Text = targetPlayer.Name .. " [" .. math.floor(distance) .. "]"
                
                local teamColor = getTeamColor(targetPlayer)
                espData.TeamLabel.TextColor3 = teamColor
            end
        end
    end
end

local function toggleESP()
    ESPEnabled = not ESPEnabled
    
    if ESPEnabled then
        -- Включаем ESP для всех игроков
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                createESP(otherPlayer)
            end
        end
    else
        -- Выключаем ESP для всех игроков
        for targetPlayer, _ in pairs(ESPElements) do
            removeESP(targetPlayer)
        end
    end
    
    return ESPEnabled
end

-- Функция телепортации к игроку
local function teleportToPlayer(targetPlayer)
    local character = player.Character
    local targetCharacter = targetPlayer.Character
    
    if character and targetCharacter then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart and targetRootPart then
            humanoidRootPart.CFrame = targetRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

-- Функция FullBright (исправленная)
local function toggleFullBright()
    FullBrightEnabled = not FullBrightEnabled
    
    if FullBrightEnabled then
        -- Сохраняем оригинальные значения
        originalBrightness = Lighting.Brightness
        originalAmbient = Lighting.Ambient
        originalOutdoorAmbient = Lighting.OutdoorAmbient
        originalGlobalShadows = Lighting.GlobalShadows
        
        -- Включаем постоянное обновление для FullBright
        local fullBrightConnection
        fullBrightConnection = RunService.Heartbeat:Connect(function()
            if FullBrightEnabled then
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                Lighting.GlobalShadows = false
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
            else
                if fullBrightConnection then
                    fullBrightConnection:Disconnect()
                end
            end
        end)
        
        print("FullBright включен")
    else
        -- Восстанавливаем оригинальные значения
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoorAmbient
        Lighting.GlobalShadows = originalGlobalShadows
        Lighting.FogEnd = originalFogEnd or 100000
        
        print("FullBright выключен")
    end
    
    return FullBrightEnabled
end

-- Функция Fling
local function toggleFling()
    FlingEnabled = not FlingEnabled
    
    if FlingEnabled then
        -- Включаем флай и флинг
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                -- Создаем BodyVelocity для полета
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                bodyVelocity.Parent = humanoidRootPart
                
                -- Включаем Noclip
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                -- Обработчик движения мыши для полета
                local flyConnection
                flyConnection = RunService.Heartbeat:Connect(function()
                    if FlingEnabled and character and humanoidRootPart then
                        -- Получаем направление движения от клавиш
                        local moveDirection = Vector3.new(0, 0, 0)
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            moveDirection = moveDirection + humanoidRootPart.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            moveDirection = moveDirection - humanoidRootPart.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            moveDirection = moveDirection - humanoidRootPart.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            moveDirection = moveDirection + humanoidRootPart.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveDirection = moveDirection + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveDirection = moveDirection + Vector3.new(0, -1, 0)
                        end
                        
                        -- Применяем движение
                        if moveDirection.Magnitude > 0 then
                            moveDirection = moveDirection.Unit * 100
                            bodyVelocity.Velocity = Vector3.new(moveDirection.X, moveDirection.Y, moveDirection.Z)
                        else
                            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                        
                        -- Флинг эффект - вращение
                        humanoidRootPart.RotVelocity = Vector3.new(50, 50, 50)
                    else
                        if flyConnection then
                            flyConnection:Disconnect()
                        end
                    end
                end)
                
                print("Fling включен! Используйте WASD для полета, Space - вверх, Shift - вниз")
            end
        end
    else
        -- Выключаем флай и флинг
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                -- Убираем BodyVelocity
                for _, obj in pairs(humanoidRootPart:GetChildren()) do
                    if obj:IsA("BodyVelocity") then
                        obj:Destroy()
                    end
                end
                
                -- Выключаем вращение
                humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                
                -- Включаем коллизию
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
        print("Fling выключен")
    end
    
    return FlingEnabled
end

-- Создание кнопок в Main табе
local function createMainButtons()
    -- Кнопка ESP
    local espButton = Instance.new("TextButton")
    local espCorner = Instance.new("UICorner")
    
    espButton.Parent = MainContainer
    espButton.Size = UDim2.new(1, 0, 0, 40)
    espButton.Position = UDim2.new(0, 0, 0, 0)
    espButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espButton.Text = "Включить ESP"
    espButton.Font = Enum.Font.GothamBold
    espButton.TextSize = 16
    espButton.BorderSizePixel = 0
    
    espCorner.Parent = espButton
    espCorner.CornerRadius = UDim.new(0, 6)
    
    espButton.MouseButton1Click:Connect(function()
        local status = toggleESP()
        if status then
            espButton.Text = "Выключить ESP"
            espButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        else
            espButton.Text = "Включить ESP"
            espButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
    
    -- Кнопка FullBright
    local fullBrightButton = Instance.new("TextButton")
    local fullBrightCorner = Instance.new("UICorner")
    
    fullBrightButton.Parent = MainContainer
    fullBrightButton.Size = UDim2.new(1, 0, 0, 40)
    fullBrightButton.Position = UDim2.new(0, 0, 0, 45)
    fullBrightButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    fullBrightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fullBrightButton.Text = "Включить FullBright"
    fullBrightButton.Font = Enum.Font.GothamBold
    fullBrightButton.TextSize = 16
    fullBrightButton.BorderSizePixel = 0
    
    fullBrightCorner.Parent = fullBrightButton
    fullBrightCorner.CornerRadius = UDim.new(0, 6)
    
    fullBrightButton.MouseButton1Click:Connect(function()
        local status = toggleFullBright()
        if status then
            fullBrightButton.Text = "Выключить FullBright"
            fullBrightButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
        else
            fullBrightButton.Text = "Включить FullBright"
            fullBrightButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
    
    -- Кнопка Fling
    local flingButton = Instance.new("TextButton")
    local flingCorner = Instance.new("UICorner")
    
    flingButton.Parent = MainContainer
    flingButton.Size = UDim2.new(1, 0, 0, 40)
    flingButton.Position = UDim2.new(0, 0, 0, 90)
    flingButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    flingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flingButton.Text = "Включить Fling"
    flingButton.Font = Enum.Font.GothamBold
    flingButton.TextSize = 16
    flingButton.BorderSizePixel = 0
    
    flingCorner.Parent = flingButton
    flingCorner.CornerRadius = UDim.new(0, 6)
    
    flingButton.MouseButton1Click:Connect(function()
        local status = toggleFling()
        if status then
            flingButton.Text = "Выключить Fling"
            flingButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        else
            flingButton.Text = "Включить Fling"
            flingButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
end

-- Создание разделителя
local function createSeparator(yPosition, text)
    local separator = Instance.new("Frame")
    local separatorLine = Instance.new("Frame")
    local separatorText = Instance.new("TextLabel")
    
    separator.Parent = MainContainer
    separator.Size = UDim2.new(1, 0, 0, 30)
    separator.Position = UDim2.new(0, 0, 0, yPosition)
    separator.BackgroundTransparency = 1
    
    separatorLine.Parent = separator
    separatorLine.Size = UDim2.new(1, 0, 0, 2)
    separatorLine.Position = UDim2.new(0, 0, 0.5, 0)
    separatorLine.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    separatorLine.BorderSizePixel = 0
    
    separatorText.Parent = separator
    separatorText.Size = UDim2.new(0.4, 0, 1, 0)
    separatorText.Position = UDim2.new(0.3, 0, 0, 0)
    separatorText.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    separatorText.TextColor3 = Color3.fromRGB(255, 255, 255)
    separatorText.Text = text
    separatorText.Font = Enum.Font.GothamBold
    separatorText.TextSize = 12
    
    return separator
end

-- Создание списка игроков
local function populatePlayersList()
    local yOffset = 140 -- После кнопок и разделителя
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerFrame = Instance.new("Frame")
            local playerCorner = Instance.new("UICorner")
            local nameLabel = Instance.new("TextLabel")
            local teamLabel = Instance.new("TextLabel")
            local distanceLabel = Instance.new("TextLabel")
            local teleportButton = Instance.new("TextButton")
            local buttonCorner = Instance.new("UICorner")
            
            playerFrame.Parent = MainContainer
            playerFrame.Size = UDim2.new(1, 0, 0, 50)
            playerFrame.Position = UDim2.new(0, 0, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            playerFrame.BorderSizePixel = 0
            
            playerCorner.Parent = playerFrame
            playerCorner.CornerRadius = UDim.new(0, 6)
            
            -- Никнейм
            nameLabel.Parent = playerFrame
            nameLabel.Size = UDim2.new(0.5, -10, 0.5, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 2)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Text = otherPlayer.Name
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.TextStrokeTransparency = 0.3
            
            -- Дистанция
            distanceLabel.Parent = playerFrame
            distanceLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
            distanceLabel.Position = UDim2.new(0.5, 0, 0, 2)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.TextSize = 12
            distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
            distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distanceLabel.TextStrokeTransparency = 0.3
            
            -- Команда
            teamLabel.Parent = playerFrame
            teamLabel.Size = UDim2.new(0.5, -10, 0.5, 0)
            teamLabel.Position = UDim2.new(0, 10, 0.5, 0)
            teamLabel.BackgroundTransparency = 1
            teamLabel.TextColor3 = getTeamColor(otherPlayer)
            teamLabel.Text = getTeamName(otherPlayer)
            teamLabel.Font = Enum.Font.Gotham
            teamLabel.TextSize = 13
            teamLabel.TextXAlignment = Enum.TextXAlignment.Left
            teamLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            teamLabel.TextStrokeTransparency = 0.3
            
            -- Кнопка телепортации
            teleportButton.Parent = playerFrame
            teleportButton.Size = UDim2.new(0.2, 0, 0.6, 0)
            teleportButton.Position = UDim2.new(0.75, 0, 0.2, 0)
            teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            teleportButton.Text = "TP"
            teleportButton.Font = Enum.Font.GothamBold
            teleportButton.TextSize = 12
            teleportButton.BorderSizePixel = 0
            
            buttonCorner.Parent = teleportButton
            buttonCorner.CornerRadius = UDim.new(0, 4)
            
            -- Обновление дистанции
            local function updateDistance()
                local character = player.Character
                local targetCharacter = otherPlayer.Character
                
                if character and targetCharacter then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                    
                    if humanoidRootPart and targetRootPart then
                        local distance = (humanoidRootPart.Position - targetRootPart.Position).Magnitude
                        local distanceText = math.floor(distance) .. "M"
                        distanceLabel.Text = distanceText
                    end
                end
            end
            
            -- Запускаем обновление дистанции
            spawn(function()
                while playerFrame.Parent do
                    updateDistance()
                    wait(0.5)
                end
            end)
            
            teleportButton.MouseButton1Click:Connect(function()
                teleportToPlayer(otherPlayer)
            end)
            
            yOffset = yOffset + 55
        end
    end
    
    -- Обновляем размер контейнера
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- Координаты для телепорта
local locations = {
    ["Церковь"] = Vector3.new(-2672.84, 5.87, -754.98),
    ["Больница"] = Vector3.new(-3297.26, 5.60, 263.10),
    ["Полиция"] = Vector3.new(-2837.66, 5.60, 1014.42),
    ["МЧС"] = Vector3.new(-1785, 5.10, 167.48),
    ["Таксо Парк"] = Vector3.new(-3293.88, 5.10, -208.99),
    ["Деревня"] = Vector3.new(-2905.50, 5.30, 2813),
    ["Пост ДПС"] = Vector3.new(-1710.66, 5.00, 1695.53)
}

-- Создание кнопок телепорта
local function populateTeleportTab()
    local yOffset = 0
    for name, position in pairs(locations) do
        local button = Instance.new("TextButton")
        local buttonCorner = Instance.new("UICorner")
        
        button.Parent = TeleportContainer
        button.Size = UDim2.new(1, 0, 0, 40)
        button.Position = UDim2.new(0, 0, 0, yOffset)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = name
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.BorderSizePixel = 0
        
        buttonCorner.Parent = button
        buttonCorner.CornerRadius = UDim.new(0, 6)
        
        button.MouseButton1Click:Connect(function()
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(position)
                end
            end
        end)
        
        yOffset = yOffset + 45
    end
    
    TeleportContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- Функция для смены клавиши
local function changeMenuKey()
    local currentKey = MENU_KEY
    local listening = false
    
    local keybindButton = Instance.new("TextButton")
    local keybindCorner = Instance.new("UICorner")
    local keybindStatus = Instance.new("TextLabel")
    
    keybindButton.Parent = MiscContainer
    keybindButton.Size = UDim2.new(1, 0, 0, 40)
    keybindButton.Position = UDim2.new(0, 0, 0, 0)
    keybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindButton.Text = "Сменить клавишу открытия"
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.TextSize = 14
    keybindButton.BorderSizePixel = 0
    
    keybindCorner.Parent = keybindButton
    keybindCorner.CornerRadius = UDim.new(0, 6)
    
    keybindStatus.Parent = MiscContainer
    keybindStatus.Size = UDim2.new(1, 0, 0, 30)
    keybindStatus.Position = UDim2.new(0, 0, 0, 45)
    keybindStatus.BackgroundTransparency = 1
    keybindStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindStatus.Text = "Текущая клавиша: " .. tostring(currentKey):gsub("Enum.KeyCode.", "")
    keybindStatus.Font = Enum.Font.Gotham
    keybindStatus.TextSize = 12
    
    keybindButton.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keybindButton.Text = "Нажмите любую клавишу..."
            keybindButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode ~= Enum.KeyCode.Unknown then
                    MENU_KEY = input.KeyCode
                    keybindStatus.Text = "Текущая клавиша: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                    keybindButton.Text = "Сменить клавишу открытия"
                    keybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    listening = false
                    connection:Disconnect()
                end
            end)
        end
    end)
end

-- Функция для выдачи предметов
local function createToolGive()
    local tools = {}
    local selectedTool = nil
    
    -- Заголовок
    local toolsTitle = Instance.new("TextLabel")
    toolsTitle.Parent = MiscContainer
    toolsTitle.Size = UDim2.new(1, 0, 0, 30)
    toolsTitle.Position = UDim2.new(0, 0, 0, 90)
    toolsTitle.BackgroundTransparency = 1
    toolsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toolsTitle.Text = "Выдача предметов"
    toolsTitle.Font = Enum.Font.GothamBold
    toolsTitle.TextSize = 16
    toolsTitle.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Кнопка обновления списка
    local refreshButton = Instance.new("TextButton")
    local refreshCorner = Instance.new("UICorner")
    
    refreshButton.Parent = MiscContainer
    refreshButton.Size = UDim2.new(1, 0, 0, 35)
    refreshButton.Position = UDim2.new(0, 0, 0, 125)
    refreshButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.Text = "Обновить список"
    refreshButton.Font = Enum.Font.GothamBold
    refreshButton.TextSize = 14
    refreshButton.BorderSizePixel = 0
    
    refreshCorner.Parent = refreshButton
    refreshCorner.CornerRadius = UDim.new(0, 6)
    
    -- Список предметов
    local toolsList = Instance.new("ScrollingFrame")
    toolsList.Parent = MiscContainer
    toolsList.Size = UDim2.new(1, 0, 0, 120)
    toolsList.Position = UDim2.new(0, 0, 0, 165)
    toolsList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toolsList.BorderSizePixel = 0
    toolsList.ScrollBarThickness = 6
    toolsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local toolsListCorner = Instance.new("UICorner")
    toolsListCorner.Parent = toolsList
    toolsListCorner.CornerRadius = UDim.new(0, 6)
    
    -- Кнопка выдачи предмета
    local giveButton = Instance.new("TextButton")
    local giveCorner = Instance.new("UICorner")
    
    giveButton.Parent = MiscContainer
    giveButton.Size = UDim2.new(1, 0, 0, 35)
    giveButton.Position = UDim2.new(0, 0, 0, 290)
    giveButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    giveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    giveButton.Text = "Выдать предмет"
    giveButton.Font = Enum.Font.GothamBold
    giveButton.TextSize = 14
    giveButton.BorderSizePixel = 0
    
    giveCorner.Parent = giveButton
    giveCorner.CornerRadius = UDim.new(0, 6)
    
    -- Функция обновления списка предметов
    local function updateToolsList()
        toolsList:ClearAllChildren()
        tools = {}
        
        -- Ищем все инструменты в рабочем месте
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Tool") then
                table.insert(tools, item)
            end
        end
        
        -- Ищем в ReplicatedStorage
        for _, item in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if item:IsA("Tool") then
                table.insert(tools, item)
            end
        end
        
        -- Ищем в ServerStorage
        for _, item in pairs(game:GetService("ServerStorage"):GetDescendants()) do
            if item:IsA("Tool") then
                table.insert(tools, item)
            end
        end
        
        -- Создаем элементы списка
        local yOffset = 0
        for i, tool in ipairs(tools) do
            local toolButton = Instance.new("TextButton")
            local toolCorner = Instance.new("UICorner")
            
            toolButton.Parent = toolsList
            toolButton.Size = UDim2.new(1, -10, 0, 30)
            toolButton.Position = UDim2.new(0, 5, 0, yOffset)
            toolButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            toolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            toolButton.Text = tool.Name
            toolButton.Font = Enum.Font.Gotham
            toolButton.TextSize = 12
            toolButton.BorderSizePixel = 0
            
            toolCorner.Parent = toolButton
            toolCorner.CornerRadius = UDim.new(0, 4)
            
            toolButton.MouseButton1Click:Connect(function()
                selectedTool = tool
                -- Подсвечиваем выбранный предмет
                for _, btn in pairs(toolsList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end
                end
                toolButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
            end)
            
            yOffset = yOffset + 35
        end
        
        toolsList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- Функция выдачи предмета
    local function giveTool()
        if selectedTool then
            local clone = selectedTool:Clone()
            clone.Parent = player.Backpack
            print("Выдан предмет: " .. selectedTool.Name)
        else
            print("Выберите предмет из списка!")
        end
    end
    
    -- Обработчики событий
    refreshButton.MouseButton1Click:Connect(updateToolsList)
    giveButton.MouseButton1Click:Connect(giveTool)
    
    -- Первоначальное обновление списка
    updateToolsList()
end

-- Функции переключения табов
local function switchTab(selectedTab)
    MainContainer.Visible = (selectedTab == "Main")
    TeleportContainer.Visible = (selectedTab == "Teleport")
    MiscContainer.Visible = (selectedTab == "Misc")
    
    MainTab.BackgroundColor3 = (selectedTab == "Main") and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(60, 60, 60)
    TeleportTab.BackgroundColor3 = (selectedTab == "Teleport") and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(60, 60, 60)
    MiscTab.BackgroundColor3 = (selectedTab == "Misc") and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(60, 60, 60)
    
    if selectedTab == "Main" then
        -- Обновляем список игроков при открытии Main таба
        MainContainer:ClearAllChildren()
        createMainButtons()
        createSeparator(135, "СПИСОК ИГРОКОВ")
        populatePlayersList()
    end
end

-- Обработчики событий
MainTab.MouseButton1Click:Connect(function()
    switchTab("Main")
end)

TeleportTab.MouseButton1Click:Connect(function()
    switchTab("Teleport")
end)

MiscTab.MouseButton1Click:Connect(function()
    switchTab("Misc")
end)

-- Управление меню
local function toggleMenu()
    MainFrame.Visible = not MainFrame.Visible
    UIBlur.Enabled = MainFrame.Visible
    
    if MainFrame.Visible then
        -- Обновляем информацию при открытии
        switchTab("Main")
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == MENU_KEY then
        toggleMenu()
    end
end)

-- Заполнение табов
switchTab("Main")
populateTeleportTab()
changeMenuKey()
createToolGive()

-- Увеличиваем размер Misc контейнера для новых функций
MiscContainer.CanvasSize = UDim2.new(0, 0, 0, 350)

-- Запуск обновлений
RunService.Heartbeat:Connect(updateESP)

-- Обработка новых игроков
Players.PlayerAdded:Connect(function(newPlayer)
    if ESPEnabled and newPlayer ~= player then
        createESP(newPlayer)
    end
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
    removeESP(leftPlayer)
end)

print("Province RP Menu by Tulen Hack загружен!")
print("Открыть меню: " .. tostring(MENU_KEY):gsub("Enum.KeyCode.", ""))
print("Новые функции в Main:")
print("- ESP: Отслеживание игроков")
print("- FullBright: Постоянная видимость в темноте")
print("- Fling: Полёт и вращение (WASD + Space/Shift)")
