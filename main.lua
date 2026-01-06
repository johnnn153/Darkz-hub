--// DARKZ HUB V5 – ULTIMATE PERFORMANCE
--// Best Blox Fruits Script (Performance First)
--// No Key | Pro UI | Smart Systems | Ultra Light

--====================================================
-- PROTECTION
--====================================================
if getgenv().DarkzLoaded then return end
getgenv().DarkzLoaded = true

--====================================================
-- SERVICES
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

--====================================================
-- FAST CACHE
--====================================================
local function Char() return Player.Character or Player.CharacterAdded:Wait() end
local function HRP() return Char():WaitForChild("HumanoidRootPart") end
local function Hum() return Char():WaitForChild("Humanoid") end
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

--====================================================
-- GLOBAL STATE (MINIMAL)
--====================================================
local State = {
    Farm = false,
    Boss = false,
    Raid = false,
    Sea = false,
    Click = false,
    FruitESP = true,
    Panic = false
}

--====================================================
-- SMART DELAY (ANTI FLAG)
--====================================================
local function HumanDelay(min,max)
    task.wait(math.random(min,max)/100)
end

--====================================================
-- SMART TARGET SYSTEM (CORE)
--====================================================
local function SmartEnemy()
    local best, score = nil, -1e9
    for _,v in ipairs(Workspace.Enemies:GetChildren()) do
        local hrp = v:FindFirstChild("HumanoidRootPart")
        local hum = v:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local d = (HRP().Position - hrp.Position).Magnitude
            local s = (hum.MaxHealth - hum.Health) - d
            if s > score then
                score, best = s, v
            end
        end
    end
    return best
end

--====================================================
-- CENTRAL LOOP (PERFORMANCE CORE)
--====================================================
RunService.Heartbeat:Connect(function()
    if State.Panic then return end

    if State.Click then
        VirtualUser:ClickButton1(Vector2.new())
    end

    if State.Farm then
        local mob = SmartEnemy()
        if mob then
            HRP().CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,8,6)
        end
    end
end)

--====================================================
-- AUTO BOSS (LOW FREQUENCY)
--====================================================
task.spawn(function()
    while task.wait(0.4) do
        if State.Boss and not State.Panic then
            for _,v in ipairs(Workspace.Enemies:GetChildren()) do
                if v.Name:find("Boss") and v:FindFirstChild("HumanoidRootPart") then
                    HRP().CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,15,0)
                end
            end
        end
    end
end)

--====================================================
-- AUTO RAID (SAFE)
--====================================================
task.spawn(function()
    while task.wait(2) do
        if State.Raid and not State.Panic then
            pcall(function()
                CommF:InvokeServer("RaidsNpc","Select","Flame")
                CommF:InvokeServer("RaidsNpc","Start")
            end)
        end
    end
end)

--====================================================
-- SEA EVENTS (LEVIATHAN / SEA BEAST)
--====================================================
task.spawn(function()
    while task.wait(2) do
        if State.Sea then
            local sea = Workspace:FindFirstChild("SeaBeasts")
            if sea then
                for _,v in ipairs(sea:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") then
                        HRP().CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,30,0)
                    end
                end
            end
        end
    end
end)

--====================================================
-- FRUIT ESP (RARITY AWARE)
--====================================================
local Rare = {Dragon=true,Leopard=true,Kitsune=true,Dough=true,["T-Rex"]=true}

task.spawn(function()
    while task.wait(3) do
        if State.FruitESP then
            for _,v in ipairs(Workspace:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    for r in pairs(Rare) do
                        if v.Name:find(r) then
                            warn("[DARKZ HUB] FRUTA RARA:",v.Name)
                        end
                    end
                end
            end
        end
    end
end)

--====================================================
-- SMART SERVER HOP
--====================================================
task.spawn(function()
    while task.wait(300) do
        if #Players:GetPlayers() <= 4 then
            TeleportService:Teleport(game.PlaceId)
        end
    end
end)

--====================================================
-- PANIC MODE
--====================================================
function _G.DarkzPanic()
    for k in pairs(State) do State[k] = false end
    State.Panic = true
end

--====================================================
-- UI (RAYFIELD – PRO)
--====================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🍌 Darkz Hub V5",
    LoadingTitle = "Darkz Hub",
    LoadingSubtitle = "Ultimate Performance",
    ConfigurationSaving = false
})

local Main = Window:CreateTab("⚡ Main")
Main:CreateToggle({Name="Auto Farm",Callback=function(v) State.Farm=v end})
Main:CreateToggle({Name="Auto Boss",Callback=function(v) State.Boss=v end})
Main:CreateToggle({Name="Auto Click",Callback=function(v) State.Click=v end})

local Raid = Window:CreateTab("🔥 Raids")
Raid:CreateToggle({Name="Auto Raid",Callback=function(v) State.Raid=v end})

local Sea = Window:CreateTab("🌊 Sea")
Sea:CreateToggle({Name="Sea Events",Callback=function(v) State.Sea=v end})

local ESP = Window:CreateTab("🍏 ESP")
ESP:CreateToggle({Name="Fruit ESP (Rare)",Callback=function(v) State.FruitESP=v end})

local Safety = Window:CreateTab("⚠ Safety")
Safety:CreateButton({Name="PANIC MODE",Callback=_G.DarkzPanic})

Rayfield:Notify({
    Title="Darkz Hub V5",
    Content="Loaded with maximum performance 🚀",
    Duration=5
})

print("✅ DARKZ HUB V5 LOADED")
