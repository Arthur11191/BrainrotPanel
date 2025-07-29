-- BrainrotPanel - main.lua
-- Painel Roblox com key, proteção Rekonise e funções básicas

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local REQUIRED_KEY = "KeynovaRoubeumBrainrot"
local ALLOWED_REFERERS = {
    "rekonise.com",
    -- adicione outros domínios permitidos se quiser
}

-- FUNÇÃO PARA CHECAR REFERER (proteção simples)
local function checkReferer()
    local referer = nil
    local success, result = pcall(function()
        return game:GetService("HttpService"):GetAsync("http://httpbin.org/headers") -- exemplo, não usado aqui pois é local
    end)
    -- No Roblox, não tem como obter referer HTTP, então essa função é só ilustrativa.
    -- A proteção de Rekonise normalmente é feita na página web que carrega o script.
    return true -- aqui você pode fazer lógica externa para verificar o link de origem
end

-- FUNÇÃO PARA PEDIR A KEY
local function requestKey()
    local input = ""
    repeat
        input = LocalPlayer:WaitForChild("PlayerGui"):SetCore("PromptInput", {
            Title = "Digite a key para acessar o painel";
            PlaceholderText = "Key";
        })
        wait(0.5)
    until input == REQUIRED_KEY
end

-- CRIAÇÃO DO GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Text = "BrainrotPanel"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24
title.Parent = mainFrame

-- Botão minimizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Text = "-"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 20
minimizeButton.Parent = mainFrame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in pairs(mainFrame:GetChildren()) do
        if child ~= title and child ~= minimizeButton then
            child.Visible = not minimized
        end
    end
    if minimized then
        mainFrame.Size = UDim2.new(0, 320, 0, 30)
    else
        mainFrame.Size = UDim2.new(0, 320, 0, 260)
    end
end)

-- Rodapé assinatura
local footer = Instance.new("TextLabel")
footer.Text = "Criado por Arthur"
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.TextColor3 = Color3.fromRGB(150, 150, 150)
footer.Font = Enum.Font.SourceSansItalic
footer.TextSize = 14
footer.Parent = mainFrame

-- Nome e avatar do jogador
local playerNameLabel = Instance.new("TextLabel")
playerNameLabel.Text = LocalPlayer.Name
playerNameLabel.Size = UDim2.new(0, 150, 0, 30)
playerNameLabel.Position = UDim2.new(0, 10, 0, 30)
playerNameLabel.BackgroundTransparency = 1
playerNameLabel.TextColor3 = Color3.new(1, 1, 1)
playerNameLabel.Font = Enum.Font.SourceSansBold
playerNameLabel.TextSize = 18
playerNameLabel.Parent = mainFrame

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 30, 0, 30)
avatarImage.Position = UDim2.new(0, 165, 0, 30)
avatarImage.BackgroundTransparency = 1
avatarImage.Parent = mainFrame

local thumbnailUrl = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
avatarImage.Image = thumbnailUrl

-- Função para criar botões com ícones e status ON/OFF
local function createToggleButton(text, position, onCallback, offCallback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Text = text.." 🔴"
    btn.Parent = mainFrame

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.Text = text.." 🟢"
            if onCallback then onCallback() end
        else
            btn.Text = text.." 🔴"
            if offCallback then offCallback() end
        end
    end)

    return btn
end

-- Funções dos botões

-- Speed Booster
local function speedOn()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 50
    end
end
local function speedOff()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

-- Infinite Jump
local infiniteJumpEnabled = false
local function infiniteJumpToggle(state)
    infiniteJumpEnabled = state
end

RunService.Stepped:Connect(function()
    if infiniteJumpEnabled then
        LocalPlayer.Character.Humanoid.JumpPower = 100
        if LocalPlayer:GetMouse().KeyDown:Wait() == "space" then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
end)

-- God Mode
local godModeEnabled = false
local function godModeToggle(state)
    godModeEnabled = state
    if godModeEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
            LocalPlayer.Character.Humanoid.Health = math.huge
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
end

-- Auto Slap (exemplo simples)
local autoSlapEnabled = false
local function autoSlapToggle(state)
    autoSlapEnabled = state
end

-- Exemplo de auto slap: bater em jogadores próximos a cada 1 seg
spawn(function()
    while true do
        wait(1)
        if autoSlapEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = player.Character.HumanoidRootPart
                    if (root.Position - targetRoot.Position).Magnitude < 10 then
                        -- Aqui você colocaria a lógica para "slapar" (ex: causar dano)
                        -- Só um print de exemplo:
                        print("Slap em "..player.Name)
                    end
                end
            end
        end
    end
end)

-- Criando botões

createToggleButton("Speed Booster", UDim2.new(0, 10, 0, 70), speedOn, speedOff)
createToggleButton("Infinite Jump", UDim2.new(0, 170, 0, 70), function() infiniteJumpToggle(true) end, function() infiniteJumpToggle(false) end)
createToggleButton("God Mode", UDim2.new(0, 10, 0, 120), function() godModeToggle(true) end, function() godModeToggle(false) end)
createToggleButton("Auto Slap", UDim2.new(0, 170, 0, 120), function() autoSlapToggle(true) end, function() autoSlapToggle(false) end)

-- Início da execução

-- Você pode implementar a key e proteção aqui, mas no Roblox puro fica limitado.
-- A proteção via Rekonise normalmente fica no site que entrega o script.

print("BrainrotPanel carregado com sucesso!")
