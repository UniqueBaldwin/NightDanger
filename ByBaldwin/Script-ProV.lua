--[[
    DANGER NIGHT - HUB by Baldwin
    Versión: 7.0 (Final & Visuals Fixed)
    - Solucionado el bug visual donde los botones no cambiaban a "ON".
    - Todo lo demás se mantiene idéntico a la versión PRO.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--// 1. ANTI-DUPLICACIÓN //--
local existingGui = CoreGui:FindFirstChild("DangerNightHub") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DangerNightHub")
if existingGui then existingGui:Destroy() end

--// CONFIGURACIÓN VISUAL //--
local UI_COLOR = Color3.fromRGB(10, 10, 10)
local ACCENT_COLOR = Color3.fromRGB(255, 30, 30) 
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local DEFAULT_WALKSPEED = 16

--// VARIABLES DE ESTADO //--
local dragging, dragInput, dragStart, startPos
local isMinimised = false
local currentPage = 1

local state = {
    MagicStep = false,
    AntiWall = false,
    MagicVision = false,
    MagicSpeed = false
}

-- Variables Lógicas
local magicPlatform = nil       
local magicHeightY = 0          
local bodyPos = nil             
local espFolder = nil
local HRP_OFFSET = 3.5          

--// INTERFAZ GRÁFICA //--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DangerNightHub"
pcall(function() ScreenGui.Parent = CoreGui end)
if ScreenGui.Parent == nil then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.ResetOnSpawn = false 

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 340)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -170)
MainFrame.BackgroundColor3 = UI_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Estética
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = ACCENT_COLOR
UIStroke.Thickness = 2
UIStroke.Transparency = 0.2

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "Danger Night - Hub by baldwin"
TitleLabel.Size = UDim2.new(1, -90, 0, 40)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = ACCENT_COLOR
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Contenedores de Página
local Page1Container = Instance.new("Frame")
Page1Container.Name = "Page1Container"
Page1Container.Size = UDim2.new(1, -20, 1, -50)
Page1Container.Position = UDim2.new(0, 10, 0, 45)
Page1Container.BackgroundTransparency = 1
Page1Container.Parent = MainFrame

local Page2Container = Page1Container:Clone()
Page2Container.Name = "Page2Container"
Page2Container.Visible = false
Page2Container.Parent = MainFrame

--// SISTEMA DE ARRASTRE //--
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

--// FACTORY DE BOTONES //--
local function createButton(text, parentContainer)
    local count = #parentContainer:GetChildren() + 1
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (count - 1) * 45) 
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = TEXT_COLOR
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = parentContainer
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

--// PAGINACIÓN //--
local function setPage(page)
    currentPage = page
    Page1Container.Visible = (page == 1)
    Page2Container.Visible = (page == 2)
end

--// ---------------------- PAGE 1: CORE FEATURES ---------------------- //--

-- 1. MAGIC STEP 
local btnMagic = createButton("Magic Step: OFF ❌", Page1Container)

local magicControls = Instance.new("Frame")
magicControls.Size = UDim2.new(1, 0, 0, 30)
magicControls.Position = UDim2.new(0, 0, 0, (#Page1Container:GetChildren()) * 45 - 7)
magicControls.BackgroundTransparency = 1
magicControls.Visible = false
magicControls.Parent = Page1Container

local btnUp = Instance.new("TextButton")
btnUp.Size = UDim2.new(0.48, 0, 1, 0)
btnUp.Text = "UP (+)"
btnUp.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
btnUp.TextColor3 = Color3.fromRGB(100, 255, 100)
btnUp.Font = Enum.Font.GothamBold
btnUp.Parent = magicControls
Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0,5)

local btnDown = Instance.new("TextButton")
btnDown.Size = UDim2.new(0.48, 0, 1, 0)
btnDown.Position = UDim2.new(0.52, 0, 0, 0)
btnDown.Text = "DOWN (-)"
btnDown.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
btnDown.TextColor3 = Color3.fromRGB(255, 100, 100)
btnDown.Font = Enum.Font.GothamBold
btnDown.Parent = magicControls
Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0,5)

btnMagic.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    state.MagicStep = not state.MagicStep
    if state.MagicStep and hrp then
        btnMagic.Text = "Magic Step: ON ✅"
        btnMagic.TextColor3 = ACCENT_COLOR
        magicControls.Visible = true
        
        magicPlatform = Instance.new("Part")
        magicPlatform.Name = "DangerPlatform"
        magicPlatform.Size = Vector3.new(12, 1, 12)
        magicPlatform.Color = ACCENT_COLOR
        magicPlatform.Material = Enum.Material.Neon
        magicPlatform.Transparency = 0.6
        magicPlatform.Anchored = true
        magicPlatform.CanCollide = true
        magicPlatform.Parent = workspace

        bodyPos = Instance.new("BodyPosition")
        bodyPos.MaxForce = Vector3.new(0, math.huge, 0) 
        bodyPos.D = 1000 
        bodyPos.P = 10000 
        bodyPos.Parent = hrp

        magicHeightY = hrp.Position.Y - HRP_OFFSET
        bodyPos.Position = Vector3.new(hrp.Position.X, magicHeightY + HRP_OFFSET, hrp.Position.Z)
    else
        btnMagic.Text = "Magic Step: OFF ❌"
        btnMagic.TextColor3 = TEXT_COLOR
        magicControls.Visible = false
        if magicPlatform then magicPlatform:Destroy() magicPlatform = nil end
        if bodyPos then bodyPos:Destroy() bodyPos = nil end
    end
end)

btnUp.MouseButton1Click:Connect(function() magicHeightY = magicHeightY + 1 end)
btnDown.MouseButton1Click:Connect(function() magicHeightY = magicHeightY - 1 end)

-- Loop de Sincronización
RunService.RenderStepped:Connect(function()
    if state.MagicStep and LocalPlayer.Character and bodyPos and magicPlatform then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        magicPlatform.CFrame = CFrame.new(hrp.Position.X, magicHeightY, hrp.Position.Z)
        bodyPos.Position = Vector3.new(hrp.Position.X, magicHeightY + HRP_OFFSET, hrp.Position.Z)
    end
end)

-- 2. ANTI-WALL (FIXED VISUALS)
local function restoreCollision()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local btnAntiWall = createButton("Anti-Wall: OFF ❌", Page1Container)
btnAntiWall.Name = "Start_AntiWall"
btnAntiWall.MouseButton1Click:Connect(function()
    state.AntiWall = not state.AntiWall
    if state.AntiWall then
        btnAntiWall.Text = "Anti-Wall: ON ✅"
        btnAntiWall.TextColor3 = ACCENT_COLOR
    else
        btnAntiWall.Text = "Anti-Wall: OFF ❌"
        btnAntiWall.TextColor3 = TEXT_COLOR
        restoreCollision()
    end
end)

RunService.Stepped:Connect(function()
    if state.AntiWall and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- 3. MAGIC VISION (FIXED VISUALS)
local btnVision = createButton("Magic Vision: OFF ❌", Page1Container)
btnVision.Name = "Start_Vision"
btnVision.MouseButton1Click:Connect(function()
    state.MagicVision = not state.MagicVision
    if state.MagicVision then
        btnVision.Text = "Magic Vision: ON ✅"
        btnVision.TextColor3 = ACCENT_COLOR
    else
        btnVision.Text = "Magic Vision: OFF ❌"
        btnVision.TextColor3 = TEXT_COLOR
        if espFolder then espFolder:Destroy() espFolder = nil end
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    end
end)

RunService.Heartbeat:Connect(function()
    if state.MagicVision then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        
        if not espFolder then
            espFolder = Instance.new("Folder")
            espFolder.Name = "BaldwinESP"
            espFolder.Parent = CoreGui
        end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
                if not obj:FindFirstChild("DangerHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "DangerHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.6
                    hl.Parent = obj
                end
            end
        end
    end
end)

-- Botón de Siguiente Página
local btnNextPage = createButton("Next Page >>", Page1Container)
btnNextPage.Position = UDim2.new(0, 0, 0, 290)
btnNextPage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnNextPage.MouseButton1Click:Connect(function() setPage(2) end)


--// ---------------------- PAGE 2: UTILITY FEATURES ---------------------- //--

-- 4. MAGIC SPEED (FIXED VISUALS)
local btnMagicSpeed = createButton("Magic Speed: OFF ❌", Page2Container)

local speedControls = Instance.new("Frame")
speedControls.Size = UDim2.new(1, 0, 0, 30)
speedControls.Position = UDim2.new(0, 0, 0, (#Page2Container:GetChildren()) * 45 - 7)
speedControls.BackgroundTransparency = 1
speedControls.Visible = false
speedControls.Parent = Page2Container

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, 0, 1, 0)
speedBox.Text = "25"
speedBox.PlaceholderText = "Enter Speed (e.g., 25)"
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.TextColor3 = TEXT_COLOR
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.Parent = speedControls
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,5)

local function updateWalkSpeed(speedValue)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local speed = tonumber(speedValue)
        if speed and speed >= 16 then 
            char.Humanoid.WalkSpeed = speed 
        else
            char.Humanoid.WalkSpeed = 16
        end
    end
end

btnMagicSpeed.MouseButton1Click:Connect(function()
    state.MagicSpeed = not state.MagicSpeed
    if state.MagicSpeed then
        btnMagicSpeed.Text = "Magic Speed: ON ✅"
        btnMagicSpeed.TextColor3 = ACCENT_COLOR
        speedControls.Visible = true
        updateWalkSpeed(speedBox.Text)
    else
        btnMagicSpeed.Text = "Magic Speed: OFF ❌"
        btnMagicSpeed.TextColor3 = TEXT_COLOR
        speedControls.Visible = false
        updateWalkSpeed(DEFAULT_WALKSPEED)
    end
end)

speedBox.FocusLost:Connect(function()
    if state.MagicSpeed then updateWalkSpeed(speedBox.Text) end
end)


-- 5. GEMS FARM TP
local targetCoords = Vector3.new(-4683, 3.9, 247.8)
local btnGemsFarm = createButton("Gems Farm TP", Page2Container)
btnGemsFarm.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(targetCoords)
        game.StarterGui:SetCore("SendNotification", {Title = "TP Success!"; Text = "Teleported to Gems Farm coordinates."; Duration = 2;})
    end
end)

-- Botón de Página Anterior
local btnPrevPage = createButton("<< Previous Page", Page2Container)
btnPrevPage.Position = UDim2.new(0, 0, 0, 290)
btnPrevPage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnPrevPage.MouseButton1Click:Connect(function() setPage(1) end)


--// MANEJO DE RESET //--
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if state.MagicStep then
        local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            bodyPos = Instance.new("BodyPosition")
            bodyPos.MaxForce = Vector3.new(0, math.huge, 0)
            bodyPos.D = 1000 
            bodyPos.P = 10000
            bodyPos.Parent = hrp
            bodyPos.Position = Vector3.new(hrp.Position.X, magicHeightY + HRP_OFFSET, hrp.Position.Z)
        end
    end
    if not state.AntiWall then restoreCollision() end
    if state.MagicSpeed then updateWalkSpeed(speedBox.Text) end
end)


--// BOTONES VENTANA //--
local btnClose = Instance.new("TextButton")
btnClose.Text = "X"
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -35, 0, 5)
btnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnClose.TextColor3 = Color3.White
btnClose.Font = Enum.Font.GothamBlack
btnClose.Parent = MainFrame
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)

local btnMini = Instance.new("TextButton")
btnMini.Text = "-"
btnMini.Size = UDim2.new(0, 30, 0, 30)
btnMini.Position = UDim2.new(1, -70, 0, 5)
btnMini.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btnMini.TextColor3 = Color3.White
btnMini.Font = Enum.Font.GothamBlack
btnMini.Parent = MainFrame
Instance.new("UICorner", btnMini).CornerRadius = UDim.new(0, 6)

btnMini.MouseButton1Click:Connect(function()
    isMinimised = not isMinimised
    if isMinimised then
        Page1Container.Visible = false
        Page2Container.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 360, 0, 40), "Out", "Quad", 0.3, true)
        btnMini.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 360, 0, 340), "Out", "Quad", 0.3, true)
        wait(0.2)
        setPage(currentPage)
        btnMini.Text = "-"
    end
end)

local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.new(1, 0, 1, 0)
ConfirmFrame.BackgroundColor3 = Color3.new(0,0,0)
ConfirmFrame.BackgroundTransparency = 0.1
ConfirmFrame.Visible = false
ConfirmFrame.ZIndex = 20
ConfirmFrame.Parent = MainFrame
Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 10)

local ConfirmText = Instance.new("TextLabel")
ConfirmText.Text = "¿Cerrar Danger Night?"
ConfirmText.Size = UDim2.new(1, 0, 0.4, 0)
ConfirmText.Position = UDim2.new(0,0,0.2,0)
ConfirmText.TextColor3 = Color3.White
ConfirmText.Font = Enum.Font.GothamBold
ConfirmText.TextSize = 20
ConfirmText.BackgroundTransparency = 1
ConfirmText.ZIndex = 21
ConfirmText.Parent = ConfirmFrame

local btnYes = Instance.new("TextButton")
btnYes.Text = "SÍ"
btnYes.Size = UDim2.new(0.4, 0, 0.2, 0)
btnYes.Position = UDim2.new(0.05, 0, 0.6, 0)
btnYes.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnYes.TextColor3 = Color3.White
btnYes.Font = Enum.Font.GothamBold
btnYes.ZIndex = 21
btnYes.Parent = ConfirmFrame
Instance.new("UICorner", btnYes).CornerRadius = UDim.new(0, 6)

local btnNo = Instance.new("TextButton")
btnNo.Text = "NO"
btnNo.Size = UDim2.new(0.4, 0, 0.2, 0)
btnNo.Position = UDim2.new(0.55, 0, 0.6, 0)
btnNo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btnNo.TextColor3 = Color3.White
btnNo.Font = Enum.Font.GothamBold
btnNo.ZIndex = 21
btnNo.Parent = ConfirmFrame
Instance.new("UICorner", btnNo).CornerRadius = UDim.new(0, 6)

btnClose.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
btnNo.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)

btnYes.MouseButton1Click:Connect(function()
    state.MagicStep = false
    state.AntiWall = false
    state.MagicVision = false
    state.MagicSpeed = false
    updateWalkSpeed(DEFAULT_WALKSPEED)
    if magicPlatform then magicPlatform:Destroy() end
    if bodyPos then bodyPos:Destroy() end
    if espFolder then espFolder:Destroy() end
    restoreCollision() 
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    ScreenGui:Destroy()
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Danger Night V1";
    Text = "Version Free Pro.";
    Duration = 3;
})
