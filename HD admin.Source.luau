warn("Verifyng the user if is allowed...")
local LAdmins = {
[9008578450] = true,
[2] = true,
}
local player = game:GetService("Players").LocalPlayer
local VerifyUser = player.UserId
if not LAdmins[VerifyUser] then
warn("the user no is allowed. wait 1 min to kick the user")
for m = 1, 60 do
warn("passed one second")
task.wait(1)
end

player:Kick("Você não conseguiu sair do servidor antes do cronômetro. Tente denovo.")
return
end

if LAdmins[VerifyUser] then
print("the user is allowed. use this panel with conscience and protect the normal players.")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local alvoAtual = nil
local loopAtivo = false

local function executarScriptPrincipal()
    local player = LocalPlayer
    if not player then return end
    local replicatedStorage = game:GetService("ReplicatedStorage")

    local character = player.Character or player.CharacterAdded:Wait()
    local rootpart = character:WaitForChild("HumanoidRootPart", 10)
    if not rootpart then return end
    local oldcf = rootpart.CFrame

    local re = replicatedStorage:FindFirstChild("RE")
    local toolRemote = re and re:FindFirstChild("1Too1l")
    if not toolRemote then return end

    task.spawn(function()
        for m = 1, 500 do
            task.spawn(function()
                if toolRemote:IsA("RemoteFunction") then
                    toolRemote:InvokeServer("PickingTools", "FireHose")
                else
                    toolRemote:FireServer("PickingTools", "FireHose")
                end
            end)

            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local fireHose = backpack:FindFirstChild("FireHose")
                if fireHose and fireHose:FindFirstChild("ToolSound") then
                    fireHose.ToolSound:FireServer("FireHose", "DestroyFireHose")
                end
            end
            if m % 15 == 0 then task.wait(0.4) end
        end
    end)

    task.wait(0.4)
    player.CharacterRemoving:Wait()
    local newCharacter = player.CharacterAdded:Wait()
    local newRootPart = newCharacter:WaitForChild("HumanoidRootPart", 15)
    local humanoid = newCharacter:WaitForChild("Humanoid", 15)

    if newRootPart and humanoid then
        task.wait(0.7)
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        newRootPart.CFrame = oldcf
        newRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    task.wait(0.5)

    local backpack = player:WaitForChild("Backpack", 10)
    if backpack then
        local items = backpack:GetChildren()
        local equipCount = 0
        for i = 1, #items do
            local item = items[i]
            if item:IsA("Tool") and item.Name == "FireHose" then
                equipCount = equipCount + 1
                task.defer(function() item.Parent = newCharacter end)
                if equipCount % 8 == 0 then task.wait(0.02) end 
            end
        end
    end
    task.wait(0.5)
end

local function gerenciarLoop(alvo)
    local execucoesAtivas = 0
    loopAtivo = true

    task.spawn(function()
        while loopAtivo do
            if not Players:FindFirstChild(alvo.Name) then
                loopAtivo = false
                alvoAtual = nil
                break
            end

            if execucoesAtivas < 2 then
                execucoesAtivas = execucoesAtivas + 1
                
                task.spawn(function()
                    executarScriptPrincipal()
                    execucoesAtivas = execucoesAtivas - 1
                end)
                
                task.wait(0.20)
            else
                task.wait()
            end
        end
    end)
end

local function encontrarJogador(nomeParcial)
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, #nomeParcial) == string.lower(nomeParcial) or 
           string.sub(string.lower(p.DisplayName), 1, #nomeParcial) == string.lower(nomeParcial) then
            return p
        end
    end
    return nil
end

LocalPlayer.Chatted:Connect(function(mensagem)
    local comando, argumento = mensagem:match("^(;kick)%s+(.+)$")
    
    if comando == ";kick" and argumento then
        local alvo = encontrarJogador(argumento)
        
        if alvo then
            if alvo == LocalPlayer then
                return
            end
            
            alvoAtual = alvo
            if not loopAtivo then
                gerenciarLoop(alvo)
            end
        end
    end
end)

local AlvosPersistentes = {}

local function executarPersistentPunish(nomeDigitado)
    if nomeDigitado == "" then return end
    local Players = game:GetService("Players")
    local WorkspaceCom = workspace:FindFirstChild("WorkspaceCom")
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(nomeDigitado)) == 1 or string.find(string.lower(player.DisplayName), string.lower(nomeDigitado)) == 1 then
            targetPlayer = player
            break
        end
    end
    if targetPlayer then
        local trafficCones = WorkspaceCom and WorkspaceCom:FindFirstChild("001_TrafficCones")
        if not trafficCones then return end
        if AlvosPersistentes[targetPlayer.UserId] then return end
        AlvosPersistentes[targetPlayer.UserId] = true
        task.spawn(function()
            while targetPlayer and targetPlayer.Parent == Players and AlvosPersistentes[targetPlayer.UserId] do
                local character = targetPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = character.HumanoidRootPart
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local destinoPunishCFrame = targetHRP.CFrame
                        if humanoid.Sit or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat") or humanoid.SeatPart then
                            destinoPunishCFrame = CFrame.new(99999999999999, -501, -9999999999999999)
                            local cadeiraFisica = humanoid.SeatPart or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat")
                            if cadeiraFisica and cadeiraFisica:IsA("BasePart") then
                                pcall(function()
                                    if cadeiraFisica.Anchored then
                                        cadeiraFisica.Anchored = false
                                    end
                                end)
                            end
                        else
                            local pernaDireita = character:FindFirstChild("RightLeg") or character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg")
                            if pernaDireita and pernaDireita:IsA("BasePart") then
                                destinoPunishCFrame = pernaDireita.CFrame
                            end
                        end
                        local props = trafficCones:GetChildren()
                        if #props > 0 then
                            for _, prop in pairs(props) do
                                if not AlvosPersistentes[targetPlayer.UserId] then break end
                                local setCFrameRemote = prop:FindFirstChild("SetCurrentCFrame")
                                if setCFrameRemote and setCFrameRemote:IsA("RemoteFunction") then
                                    task.spawn(function()
                                        pcall(function()
                                            setCFrameRemote:InvokeServer(destinoPunishCFrame)
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end

local function executarUnpersistentPunish(nomeDigitado)
    if nomeDigitado == "" then return end
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(nomeDigitado)) == 1 or string.find(string.lower(player.DisplayName), string.lower(nomeDigitado)) == 1 then
            if AlvosPersistentes[player.UserId] then
                AlvosPersistentes[player.UserId] = nil
                break
            end
        end
    end
end

game:GetService("Players").LocalPlayer.Chatted:Connect(function(message)
    local msgLower = string.lower(message)
    if string.sub(msgLower, 1, 18) == ";persistentpunish " then
        executarPersistentPunish(string.sub(message, 19))
    elseif string.sub(msgLower, 1, 20) == ";unpersistentpunish " then
        executarUnpersistentPunish(string.sub(message, 21))
    end
end)

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function executarKillPorChat(nomeDigitado)
    if nomeDigitado == "" then return end
    local WorkspaceCom = workspace:FindFirstChild("WorkspaceCom")
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(nomeDigitado)) == 1 or string.find(string.lower(player.DisplayName), string.lower(nomeDigitado)) == 1 then
            targetPlayer = player
            break
        end
    end
    if targetPlayer then
        local trafficCones = WorkspaceCom and WorkspaceCom:FindFirstChild("001_TrafficCones")
        if trafficCones then
            if _G.KillAtivo then 
                _G.KillAtivo = false 
                task.wait(0.1) 
            end
            _G.KillAtivo = true
            task.spawn(function()
                local finalizado = false
                while _G.KillAtivo and targetPlayer and targetPlayer.Parent == Players and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
                    if finalizado then break end
                    local character = targetPlayer.Character
                    local targetHRP = character.HumanoidRootPart
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        break
                    end
                    local destinoPunishCFrame = targetHRP.CFrame
                    local alvoSentou = false
                    if humanoid and (humanoid.Sit or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat") or humanoid.SeatPart) then
                        destinoPunishCFrame = CFrame.new(1, -501, -1)
                        alvoSentou = true
                        local cadeiraFisica = humanoid.SeatPart or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat")
                        if cadeiraFisica and cadeiraFisica:IsA("BasePart") then
                            pcall(function()
                                if cadeiraFisica.Anchored then
                                    cadeiraFisica.Anchored = false
                                end
                            end)
                        end
                    else
                        local pernaDireita = character:FindFirstChild("RightLeg") 
                            or character:FindFirstChild("RightLowerLeg") 
                            or character:FindFirstChild("Right Leg")
                        if pernaDireita and pernaDireita:IsA("BasePart") then
                            destinoPunishCFrame = pernaDireita.CFrame
                        end
                    end
                    local props = {trafficCones:FindFirstChild("Prop" .. game.Players.LocalPlayer.Name)}
                    if #props > 0 and props then
                        for _, prop in pairs(props) do
                            if not _G.KillAtivo or not (targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) then break end
                            local setCFrameRemote = prop:FindFirstChild("SetCurrentCFrame")
                            if setCFrameRemote and setCFrameRemote:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function()
                                        setCFrameRemote:InvokeServer(destinoPunishCFrame)
                                    end)
                                end)
                            end
                        end
                    end
                    if alvoSentou then
                        finalizado = true
                        task.wait(0.1) 
                        pcall(function()
                            local pastaPropMaker = (localPlayer.Character and localPlayer.Character:FindFirstChild("PropMaker")) or localPlayer:WaitForChild("Backpack"):WaitForChild("PropMaker")
                            pastaPropMaker:WaitForChild("Tool_PropMake"):FireServer(workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_TrafficCones"):WaitForChild("Prop" .. localPlayer.Name):WaitForChild("Touch"), vector.create(-93.44210815429688, 49.86747741699219, 33.19981002807617))
                        end)
                        break
                    end
                    task.wait(0.1) 
                end
                if _G.KillAtivo then
                    _G.KillAtivo = false
                end
            end)
        end
    end
end

if localPlayer and localPlayer:IsA("Player") then
    localPlayer.Chatted:Connect(function(message)
        if string.sub(string.lower(message), 1, 6) == ";kill " then
            executarKillPorChat(string.sub(message, 7))
        end
    end)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function executarPunishPorChat(nomeDigitado)
    if nomeDigitado == "" then return end
    local WorkspaceCom = workspace:FindFirstChild("WorkspaceCom")
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(nomeDigitado)) == 1 or string.find(string.lower(player.DisplayName), string.lower(nomeDigitado)) == 1 then
            targetPlayer = player
            break
        end
    end
    if targetPlayer then
        local trafficCones = WorkspaceCom and WorkspaceCom:FindFirstChild("001_TrafficCones")
        if trafficCones then
            if _G.PunishAtivo then 
                _G.PunishAtivo = false 
                task.wait(0.1) 
            end
            _G.PunishAtivo = true
            task.spawn(function()
                while _G.PunishAtivo and targetPlayer and targetPlayer.Parent == Players and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
                    local character = targetPlayer.Character
                    local targetHRP = character.HumanoidRootPart
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        break
                    end
                    local destinoPunishCFrame = targetHRP.CFrame
                    if humanoid and (humanoid.Sit or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat") or humanoid.SeatPart) then
                        destinoPunishCFrame = CFrame.new(99999999999999, -501, -9999999999999999)
                        local cadeiraFisica = humanoid.SeatPart or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat")
                        if cadeiraFisica and cadeiraFisica:IsA("BasePart") then
                            pcall(function()
                                if cadeiraFisica.Anchored then
                                    cadeiraFisica.Anchored = false
                                end
                            end)
                        end
                    else
                        local pernaDireita = character:FindFirstChild("RightLeg") 
                            or character:FindFirstChild("RightLowerLeg") 
                            or character:FindFirstChild("Right Leg")
                        if pernaDireita and pernaDireita:IsA("BasePart") then
                            destinoPunishCFrame = pernaDireita.CFrame
                        end
                    end
                    local props = trafficCones:GetChildren()
                    if #props > 0 then
                        for _, prop in pairs(props) do
                            if not _G.PunishAtivo or not (targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) then break end
                            local setCFrameRemote = prop:FindFirstChild("SetCurrentCFrame")
                            if setCFrameRemote and setCFrameRemote:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function()
                                        setCFrameRemote:InvokeServer(destinoPunishCFrame)
                                    end)
                                end)
                            end
                        end
                    end
                    task.wait(0.1) 
                end
                if _G.PunishAtivo then
                    _G.PunishAtivo = false
                end
            end)
        end
    end
end

if localPlayer and localPlayer:IsA("Player") then
    localPlayer.Chatted:Connect(function(message)
        if string.sub(string.lower(message), 1, 8) == ";punish " then
            executarPunishPorChat(string.sub(message, 9))
        end
    end)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function executarBringPorChat(nomeDigitado)
    if nomeDigitado == "" then return end
    local WorkspaceCom = workspace:FindFirstChild("WorkspaceCom")
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(nomeDigitado)) == 1 or string.find(string.lower(player.DisplayName), string.lower(nomeDigitado)) == 1 then
            targetPlayer = player
            break
        end
    end
    if targetPlayer then
        local trafficCones = WorkspaceCom and WorkspaceCom:FindFirstChild("001_TrafficCones")
        if trafficCones then
            task.spawn(function()
                local finalizado = false
                while targetPlayer and targetPlayer.Parent == Players and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
                    if finalizado then break end
                    local character = targetPlayer.Character
                    local targetHRP = character.HumanoidRootPart
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        break
                    end
                    local destinoPunishCFrame = targetHRP.CFrame
                    local alvoSentou = false
                    if humanoid and (humanoid.Sit or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat") or humanoid.SeatPart) then
                        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            destinoPunishCFrame = localPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                        end
                        alvoSentou = true
                        local cadeiraFisica = humanoid.SeatPart or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat")
                        if cadeiraFisica and cadeiraFisica:IsA("BasePart") then
                            pcall(function()
                                if cadeiraFisica.Anchored then
                                    cadeiraFisica.Anchored = false
                                end
                            end)
                        end
                    else
                        local pernaDireita = character:FindFirstChild("RightLeg") 
                            or character:FindFirstChild("RightLowerLeg") 
                            or character:FindFirstChild("Right Leg")
                        if pernaDireita and pernaDireita:IsA("BasePart") then
                            destinoPunishCFrame = pernaDireita.CFrame
                        end
                    end
                    local props = {trafficCones:FindFirstChild("Prop" .. game.Players.LocalPlayer.Name)}
                    if #props > 0 then
                        for _, prop in pairs(props) do
                            if not (targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) then break end
                            local setCFrameRemote = prop:FindFirstChild("SetCurrentCFrame")
                            if setCFrameRemote and setCFrameRemote:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function()
                                        setCFrameRemote:InvokeServer(destinoPunishCFrame)
                                    end)
                                end)
                            end
                        end
                    end
                    if alvoSentou then
                        finalizado = true
                        task.wait(0.1)
                        pcall(function()
                            local reFolder = ReplicatedStorage:FindFirstChild("RE")
                            local clearEvent = reFolder and reFolder:FindFirstChild("1Clea1rTool1s")
                            if clearEvent then
                                clearEvent:FireServer("ClearAllProps")
                            end
                        end)
                        break 
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
end

if localPlayer and localPlayer:IsA("Player") then
    localPlayer.Chatted:Connect(function(message)
        if string.sub(string.lower(message), 1, 7) == ";bring " then
            executarBringPorChat(string.sub(message, 8))
        end
    end)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function executarJailPorChat(nomeDigitado)
    if nomeDigitado == "" then return end
    local WorkspaceCom = workspace:FindFirstChild("WorkspaceCom")
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(nomeDigitado)) == 1 or string.find(string.lower(player.DisplayName), string.lower(nomeDigitado)) == 1 then
            targetPlayer = player
            break
        end
    end
    if targetPlayer then
        local trafficCones = WorkspaceCom and WorkspaceCom:FindFirstChild("001_TrafficCones")
        if trafficCones then
            task.spawn(function()
                local finalizado = false
                while targetPlayer and targetPlayer.Parent == Players and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
                    if finalizado then break end
                    local character = targetPlayer.Character
                    local targetHRP = character.HumanoidRootPart
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        break
                    end
                    local destinoPunishCFrame = targetHRP.CFrame
                    local alvoSentou = false
                    if humanoid and (humanoid.Sit or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat") or humanoid.SeatPart) then
                        destinoPunishCFrame = CFrame.new(-153, -55, 234)
                        alvoSentou = true
                        local cadeiraFisica = humanoid.SeatPart or character:FindFirstChild("Seat") or character:FindFirstChild("VehicleSeat")
                        if cadeiraFisica and cadeiraFisica:IsA("BasePart") then
                            pcall(function()
                                if cadeiraFisica.Anchored then
                                    cadeiraFisica.Anchored = false
                                end
                            end)
                        end
                    else
                        local pernaDireita = character:FindFirstChild("RightLeg") 
                            or character:FindFirstChild("RightLowerLeg") 
                            or character:FindFirstChild("Right Leg")
                        if pernaDireita and pernaDireita:IsA("BasePart") then
                            destinoPunishCFrame = pernaDireita.CFrame
                        end
                    end
                    local props = {trafficCones:FindFirstChild("Prop" .. game.Players.LocalPlayer.Name)}
                    if #props > 0 then
                        for _, prop in pairs(props) do
                            if not (targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")) then break end
                            local setCFrameRemote = prop:FindFirstChild("SetCurrentCFrame")
                            if setCFrameRemote and setCFrameRemote:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function()
                                        setCFrameRemote:InvokeServer(destinoPunishCFrame)
                                    end)
                                end)
                            end
                        end
                    end
                    if alvoSentou then
                        finalizado = true
                        task.wait(0.1) 
                        pcall(function()
                            local reFolder = ReplicatedStorage:FindFirstChild("RE")
                            local clearEvent = reFolder and reFolder:FindFirstChild("1Clea1rTool1s")
                            if clearEvent then
                                clearEvent:FireServer("ClearAllProps")
                            end
                        end)
                        break 
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
end

if localPlayer and localPlayer:IsA("Player") then
    localPlayer.Chatted:Connect(function(message)
        if string.sub(string.lower(message), 1, 6) == ";jail " then
            executarJailPorChat(string.sub(message, 7))
        end
    end)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function executarShutdownPorChat()
    local re = ReplicatedStorage:FindFirstChild("RE")
    local toolRemote = re and re:FindFirstChild("1Too1l")
    if not toolRemote then return end
    for i = 1, 3 do
        task.spawn(function()
            for m = 1, 150000 do
                pcall(function()
                    toolRemote:FireServer("PickingTools", "FireHose")
                end)
                if m % 5 == 0 then
                    local backpack = localPlayer:FindFirstChild("Backpack")
                    local fireHose = backpack and backpack:FindFirstChild("FireHose")
                    if fireHose and fireHose:FindFirstChild("ToolSound") then
                        pcall(function()
                            fireHose.ToolSound:FireServer("FireHose", "DestroyFireHose")
                        end)
                    end
                end
                if m % 20 == 0 then 
                    task.wait(0.05)
                end
            end
        end)
    end
end

if localPlayer and localPlayer:IsA("Player") then
    localPlayer.Chatted:Connect(function(message)
        if string.lower(message) == ";shutdown" then
            executarShutdownPorChat()
        end
    end)
end

local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui

local HDUI = Instance.new("ScreenGui")
HDUI.Name = "HDadmin"
HDUI.Parent = PlayerGui
HDUI.ResetOnSpawn = false

local HD = Instance.new("Frame")
HD.Name = "UI"
HD.Parent = HDUI
HD.Position = UDim2.new(0, 234, 0, -35)
HD.Size = UDim2.new(0, 350, 0, 380)
HD.BackgroundColor3 = Color3.fromRGB(80, 0, 0)

local HDLabel = Instance.new("TextLabel")
HDLabel.Name = "Label"
HDLabel.Parent = HD
HDLabel.Position = UDim2.new(0, 0, 0, 0)
HDLabel.Size = UDim2.new(0, 355, 0, 50)
HDLabel.Text = "HD ADMIN"
HDLabel.TextSize = 25
HDLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HDLabel.BackgroundColor3 = Color3.fromRGB(80, 0, 0)

local HDToggle = Instance.new("TextButton")
HDToggle.Name = "OpenHD"
HDToggle.Parent = HDUI
HDToggle.Position = UDim2.new(0.5, -216, 0.5, -212)
HDToggle.Size = UDim2.new(0, 35, 0, 35)
HDToggle.Text = "HD"
HDToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
HDToggle.TextSize = 10
HDToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HDToggle.MouseButton1Click:Connect(function()
HD.Visible = true
end)

local HDStyle = Instance.new("UICorner")
HDStyle.Name = "HDStyle"
HDStyle.Parent = HDToggle

local HDToggleT = Instance.new("TextButton")
HDToggleT.Name = "CloseHD"
HDToggleT.Parent = HD
HDToggleT.Position = UDim2.new(0, 280, 0, 0)
HDToggleT.Size = UDim2.new(0, 35, 0, 35)
HDToggleT.Text = "X"
HDToggleT.TextColor3 = Color3.fromRGB(255, 255, 255)
HDToggleT.TextSize = 10
HDToggleT.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HDToggleT.MouseButton1Click:Connect(function()
HD.Visible = false
end)

local NTabs = Instance.new("ScrollingFrame")
NTabs.Name = "Tabs"
NTabs.Parent = HD
NTabs.Position = UDim2.new(0, 10, 0, 100)
NTabs.Size = UDim2.new(0, 330, 0, 270)
NTabs.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
NTabs.ScrollBarThickness = 0
NTabs.BorderSizePixel = 0
NTabs.Visible = true

local function NTab(TextLabel, TabAcessing)
local NewTab = Instance.new("TextButton")
NewTab.Name = "HDTab"
NewTab.Parent = NTabs
NewTab.Size = UDim2.new(0, 340, 0, 30)
NewTab.Text = TextLabel
NewTab.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
NewTab.TextColor3 = Color3.fromRGB(255, 255, 255)
NewTab.TextSize = 15
NewTab.MouseButton1Click:Connect(TabAcessing)
return NewTab
end

local HDCmdList= Instance.new("UIListLayout")
HDCmdList.Name = "HDCmdsList"
HDCmdList.Parent = NTabs

local TabCmds = Instance.new("ScrollingFrame")
TabCmds.Name = "Cmds"
TabCmds.Parent = HD
TabCmds.Visible = false
TabCmds.Position = UDim2.new(0, 10, 0, 50)
TabCmds.Size = UDim2.new(0, 330, 0, 320)
TabCmds.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
TabCmds.ScrollBarThickness = 0
TabCmds.BorderSizePixel = 0

local function NCmd(Cmd)
local NewCmd = Instance.new("TextLabel")
NewCmd.Name = "HDCmd"
NewCmd.Parent =TabCmds
NewCmd.Size = UDim2.new(0, 340, 0, 30)
NewCmd.Text = Cmd
NewCmd.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
NewCmd.TextColor3 = Color3.fromRGB(255, 255, 255)
NewCmd.TextSize = 15
return NewCmd
end

local ReturnTabs = Instance.new("TextButton")
ReturnTabs.Name = "Return"
ReturnTabs.Parent =TabCmds
ReturnTabs.Size = UDim2.new(0, 340, 0, 30)
ReturnTabs.Text = "<"
ReturnTabs.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
ReturnTabs.TextColor3 = Color3.fromRGB(255, 255, 255)
ReturnTabs.TextSize = 15
ReturnTabs.LayoutOrder = 0
ReturnTabs.MouseButton1Click:Connect(function()
NTabs.Visible = true
TabCmds.Visible = false
end)

local CmdList = Instance.new("UIListLayout")
CmdList.Name = "HDCmdList"
CmdList.Parent = TabCmds

local TabSettings = Instance.new("ScrollingFrame")
TabSettings.Name = "Settings"
TabSettings.Parent = HD
TabSettings.Visible = false
TabSettings.Position = UDim2.new(0, 10, 0, 50)
TabSettings.Size = UDim2.new(0, 330, 0, 320)
TabSettings.BackgroundColor3 =Color3.fromRGB(80, 0, 0)
TabSettings.ScrollBarThickness = 0
TabSettings.BorderSizePixel = 0

local Settings = Instance.new("UIListLayout")
Settings.Name = "HDSettings"
Settings.Parent = TabSettings

local function NSetting(Setting, TabAcessingS, ColorR, ColorG, ColorB)
local NewSetting = Instance.new("TextButton")
NewSetting.Name = "HDSetting"
NewSetting.Parent = TabSettings
NewSetting.Size = UDim2.new(0, 340, 0, 30)
NewSetting.Text = Setting
NewSetting.BackgroundColor3 = Color3.fromRGB(ColorR, ColorG, ColorB)
NewSetting.TextSize = 15
NewSetting.TextColor3 = Color3.fromRGB(255, 255, 255)
NewSetting.MouseButton1Click:Connect(TabAcessingS)
return NewSetting
end

local ReturnTabs1 = Instance.new("TextButton")
ReturnTabs1.Name = "Return"
ReturnTabs1.Parent = TabSettings
ReturnTabs1.Size = UDim2.new(0, 330, 0, 30)
ReturnTabs1.Text = "<"
ReturnTabs1.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
ReturnTabs1.TextColor3 = Color3.fromRGB(255, 255, 255)
ReturnTabs1.TextSize = 15
ReturnTabs1.MouseButton1Click:Connect(function()
NTabs.Visible = true
TabSettings.Visible = false
TabCmds.Visible = false
end)

local ADMINS = Instance.new("ScrollingFrame")
ADMINS.Name = "Admins"
ADMINS.Parent = HD
ADMINS.Visible = false
ADMINS.Position = UDim2.new(0, 10, 0, 50)
ADMINS.Size = UDim2.new(0, 330, 0, 320)
ADMINS.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
ADMINS.ScrollBarThickness = 0
ADMINS.BorderSizePixel = 0

local LModders = Instance.new("UIListLayout")
LModders.Name = "LModders"
LModders.Parent = ADMINS

local ReturnTabs2 = Instance.new("TextButton")
ReturnTabs2.Name = "Return"
ReturnTabs2.Parent = ADMINS
ReturnTabs2.Size = UDim2.new(0, 330, 0, 30)
ReturnTabs2.Text = "<"
ReturnTabs2.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
ReturnTabs2.TextColor3 = Color3.fromRGB(255, 255, 255)
ReturnTabs2.TextSize = 15
ReturnTabs2.MouseButton1Click:Connect(function()
NTabs.Visible = true
TabSettings.Visible = false
TabCmds.Visible = false
ADMINS.Visible = false
end)

local function Admin(ADMIN)
local NewAdmin = Instance.new("TextLabel")
NewAdmin.Name = "HDAdmin"
NewAdmin.Parent = ADMINS
NewAdmin.Size = UDim2.new(0, 340, 0, 30)
NewAdmin.Text = ADMIN
NewAdmin.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
NewAdmin.TextSize = 15
NewAdmin.TextColor3 = Color3.fromRGB(255, 255, 255)
return NewAdmin
end

local ABOUT = Instance.new("ScrollingFrame")
ABOUT.Name = "ABOUT"
ABOUT.Parent = HD
ABOUT.Visible = false
ABOUT.Position = UDim2.new(0, 10, 0, 50)
ABOUT.Size = UDim2.new(0, 330, 0, 320)
ABOUT.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
ABOUT.ScrollBarThickness = 0
ABOUT.BorderSizePixel = 0

local About = Instance.new("UIListLayout")
About.Name = "About"
About.Parent = ABOUT

local ReturnTabs3 = Instance.new("TextButton")
ReturnTabs3.Name = "Return"
ReturnTabs3.Parent = ABOUT
ReturnTabs3.Size = UDim2.new(0, 330, 0, 30)
ReturnTabs3.Text = "<"
ReturnTabs3.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
ReturnTabs3.TextColor3 = Color3.fromRGB(255, 255, 255)
ReturnTabs3.TextSize = 15
ReturnTabs3.MouseButton1Click:Connect(function()
NTabs.Visible = true
TabSettings.Visible = false
TabCmds.Visible = false
ADMINS.Visible = false
end)

local function ABOUT(ABOUT1)
local NewAbout = Instance.new("TextLabel")
NewAbout.Name = "HDAdmin"
NewAbout.Parent = ABOUT1
NewAbout.Size = UDim2.new(0, 340, 0, 30)
NewAbout.Text = ABOUT
NewAbout.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
NewAbout.TextSize = 15
NewAbout.TextColor3 = Color3.fromRGB(255, 255, 255)
return NewAbout
end


NTab("ABOUT                                     >", function()
TabCmds.Visible = false
NTabs.Visible = false
TabSettings.Visible = false
ADMINS.Visible = false
ABOUT.Visible = true
end)

NTab("COMMANDS                            >", function()
NTabs.Visible = false
TabCmds.Visible = true
end)
NTab("SPECIAL                                  >", function()

end)
NTab("ADMINS                                   >", function()
TabCmds.Visible = false
NTabs.Visible = false
TabSettings.Visible = false
ADMINS.Visible = true
end)
NTab("SETTINGS                               >", function()
TabCmds.Visible = false
NTabs.Visible = false
TabSettings.Visible = true
end)
NCmd(";kill [Player]")
NCmd(";punish [Player]")
NCmd(";bring [Player]")
NCmd(";jail [Player]")
NCmd(";shutdown")
NCmd(";persistentpunish [Player]")
NCmd(";unpersistentpunish [Player]")
NCmd(";kick [Player]")
NSetting("Theme:", 255, 255, 0, function()
HD.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
HDLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
end)

Admin("Magnesium [senior local moderator]")

ABOUT("The ;kick Cmd its in version 1")
ABOUT("use this panel with conscience")
ABOUT("the cmds its Brutal")
ABOUT("caution for use the expulsion cmd")
end
