-- Darkz Hub - Blox Fruits 2026  
-- Complete AIO Script with All Features  
-- GUI + Auto Farm + ESP + Teleport + Combat + More  
-- Inspired by W-azure, Redz Hub, Astral Hub, Banana Hub  
  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
-- [INITIALIZATION]  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
  
-- Services  
local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local Workspace = game:GetService("Workspace")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local CoreGui = game:GetService("CoreGui")  
local TweenService = game:GetService("TweenService")  
local UserInputService = game:GetService("UserInputService")  
local TeleportService = game:GetService("TeleportService")  
local Lighting = game:GetService("Lighting")  
local VirtualUser = game:GetService("VirtualUser")  
local HttpService = game:GetService("HttpService")  
local VirtualInputManager = game:GetService("VirtualInputManager")  
  
-- Player  
local Player = Players.LocalPlayer  
local Mouse = Player:GetMouse()  
  
-- Cleanup old GUI  
for _, gui in pairs(CoreGui:GetChildren()) do  
    if gui.Name == "DarkzHub" then  
        gui:Destroy()  
    end  
end  
  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
-- [CORE MODULE - Universal Functions]  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
  
local Core = {  
    Connections = {},  
    ESPObjects = {},  
    Settings = {  
        -- Auto Farm  
        AutoLevel = false,  
        SelectedLevelMethod = "Normal",  
        AutoBoss = false,  
        SelectedBoss = "",  
        AutoKaitun = false,  
        AutoMaterial = false,  
        AutoRaid = false,  
        RaidChip = "Flame",  
        AutoElite = false,  
        AutoSeaEvent = false,  
        SeaEventType = "Leviathan",  
          
        -- Quest System  
        AutoYama = false,  
        AutoTushita = false,  
        AutoCDK = false,  
        AutoGodHuman = false,  
        AutoSoulGuitar = false,  
          
        -- Combat  
        AutoClick = false,  
        AutoSkill = false,  
        SkillZ = true,  
        SkillX = true,  
        SkillC = true,  
        SkillV = true,  
        SkillF = true,  
        Aimbot = false,  
        KillAura = false,  
        AutoGun = false,  
          
        -- Movement  
        WalkSpeed = 50,  
        JumpPower = 50,  
        FlySpeed = 100,  
        FlyEnabled = false,  
        NoClip = false,  
        InfJump = false,  
        AutoDash = false,  
          
        -- Misc  
        AutoStats = false,  
        StatSelected = "Melee",  
        AutoRace = false,  
        AutoGear = false,  
        AutoBuyFruit = false,  
        AutoStoreFruits = false,  
        FullBright = false,  
        AntiAFK = true,  
        AutoHide = false,  
        WhiteScreen = false,  
        FixLag = false,  
          
        -- ESP  
        ESPEnabled = false,  
        ESPBosses = true,  
        ESPFruits = true,  
        ESPChests = true,  
        ESPPlayers = false,  
        ESPIslands = false,  
        Tracers = true,  
        BoxESP = true  
    }  
}  
  
-- Character Functions  
function Core:GetCharacter()  
    return Player.Character or Player.CharacterAdded:Wait()  
end  
  
function Core:GetHumanoid()  
    local char = self:GetCharacter()  
    return char:WaitForChild("Humanoid")  
end  
  
function Core:GetRoot()  
    local char = self:GetCharacter()  
    return char:WaitForChild("HumanoidRootPart")  
end  
  
function Core:GetSea()  
    local level = Player.Data.Level.Value  
    if level >= 700 and level < 1500 then  
        return "Second"  
    elseif level >= 1500 then  
        return "Third"  
    else  
        return "First"  
    end  
end  
  
-- Remote Functions  
function Core:InvokeServer(...)  
    local remote = ReplicatedStorage:FindFirstChild("Remotes")  
    if remote then  
        remote = remote:FindFirstChild("CommF_")  
        if remote then  
            return remote:InvokeServer(...)  
        end  
    end  
    return nil  
end  
  
function Core:FireServer(...)  
    local remote = ReplicatedStorage:FindFirstChild("Remotes")  
    if remote then  
        remote = remote:FindFirstChild("CommF_")  
        if remote then  
            return remote:FireServer(...)  
        end  
    end  
    return nil  
end  
  
-- Target Finding  
function Core:GetNearestEnemy(maxDist)  
    local nearest = nil  
    local dist = maxDist or math.huge  
    local root = self:GetRoot()  
      
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do  
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then  
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")  
            if enemyRoot then  
                local distance = (root.Position - enemyRoot.Position).Magnitude  
                if distance < dist then  
                    dist = distance  
                    nearest = enemy  
                end  
            end  
        end  
    end  
      
    return nearest, dist  
end  
  
function Core:GetNearestBoss()  
    local bosses = {  
        "The Gorilla King", "Bobby", "Yeti", "Vice Admiral", "Warden",  
        "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Thunder God",  
        "Cyborg", "Darkbeard", "Dough King", "Rip Indra", "Beautiful Pirate",  
        "Longma", "Soul Reaper", "Cake Queen"  
    }  
      
    local nearest = nil  
    local distance = math.huge  
    local root = self:GetRoot()  
      
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do  
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then  
            for _, bossName in pairs(bosses) do  
                if string.find(enemy.Name, bossName) then  
                    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")  
                    if enemyRoot then  
                        local dist = (root.Position - enemyRoot.Position).Magnitude  
                        if dist < distance then  
                            distance = dist  
                            nearest = enemy  
                        end  
                    end  
                    break  
                end  
            end  
        end  
    end  
      
    return nearest, distance  
end  
  
function Core:GetNearestPlayer(maxDist)  
    local nearest = nil  
    local distance = maxDist or math.huge  
    local root = self:GetRoot()  
      
    for _, plr in pairs(Players:GetPlayers()) do  
        if plr ~= Player and plr.Character then  
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")  
            if targetRoot then  
                local dist = (root.Position - targetRoot.Position).Magnitude  
                if dist < distance then  
                    distance = dist  
                    nearest = plr  
                end  
            end  
        end  
    end  
      
    return nearest, distance  
end  
  
-- Teleport Functions  
function Core:Teleport(cframe)  
    local root = self:GetRoot()  
    root.CFrame = cframe  
end  
  
function Core:TweenTeleport(cframe, duration)  
    local root = self:GetRoot()  
    local tweenInfo = TweenInfo.new(duration or 1, Enum.EasingStyle.Linear)  
    local tween = TweenService:Create(root, tweenInfo, {CFrame = cframe})  
    tween:Play()  
    tween.Completed:Wait()  
end  
  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
-- [AUTO FARM SYSTEMS]  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
  
function Core:ToggleAutoLevel(state)  
    self.Settings.AutoLevel = state  
    if state then  
        local conn = RunService.Heartbeat:Connect(function()  
            if not self.Settings.AutoLevel then  
                conn:Disconnect()  
                return  
            end  
              
            local enemy, dist = self:GetNearestEnemy(200)  
            if enemy and dist < 50 then  
                local root = self:GetRoot()  
                local enemyRoot = enemy.HumanoidRootPart  
                  
                if self.Settings.SelectedLevelMethod == "Teleport" then  
                    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 10, 0)  
                else  
                    -- Normal farm method  
                    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 10, 10)  
                end  
                  
                if self.Settings.AutoClick then  
                    VirtualUser:ClickButton1(Vector2.new())  
                end  
                  
                if self.Settings.AutoSkill then  
                    local skills = {"Z", "X", "C", "V", "F"}  
                    for _, key in pairs(skills) do  
                        if self.Settings["Skill"..key] then  
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)  
                            task.wait(0.1)  
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)  
                        end  
                    end  
                end  
            end  
        end)  
        table.insert(self.Connections, conn)  
    end  
end  
  
function Core:ToggleAutoBoss(state)  
    self.Settings.AutoBoss = state  
    if state and self.Settings.SelectedBoss ~= "" then  
        local conn = RunService.Heartbeat:Connect(function()  
            if not self.Settings.AutoBoss then  
                conn:Disconnect()  
                return  
            end  
              
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do  
                if string.find(enemy.Name, self.Settings.SelectedBoss) and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then  
                    local root = self:GetRoot()  
                    local enemyRoot = enemy.HumanoidRootPart  
                      
                    root.CFrame = enemyRoot.CFrame * CFrame.new(0, 15, 0)  
                      
                    if self.Settings.AutoClick then  
                        VirtualUser:ClickButton1(Vector2.new())  
                    end  
                      
                    if self.Settings.AutoSkill then  
                        for _, key in pairs({"Z", "X", "C", "V", "F"}) do  
                            if self.Settings["Skill"..key] then  
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)  
                                task.wait(0.1)  
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)  
                            end  
                        end  
                    end  
                    break  
                end  
            end  
        end)  
        table.insert(self.Connections, conn)  
    end  
end  
  
function Core:ToggleKaitun(state)  
    self.Settings.AutoKaitun = state  
    if state and self:GetSea() == "Third" then  
        local conn = RunService.Heartbeat:Connect(function()  
            if not self.Settings.AutoKaitun then  
                conn:Disconnect()  
                return  
            end  
              
            -- Kaitun locations (Third Sea)  
            local locations = {  
                ["Hydra Island"] = CFrame.new(5228.03, 604.24, 345.08),  
                ["Great Tree"] = CFrame.new(2681.82, 1682.81, -719.33),  
                ["Castle on Sea"] = CFrame.new(-5081.35, 314.52, -3155.50),  
                ["Floating Turtle"] = CFrame.new(-13274.53, 531.82, -7579.22),  
                ["Haunted Castle"] = CFrame.new(-9515.40, 142.13, 6076.41)  
            }  
              
            local enemy, dist = self:GetNearestEnemy(150)  
            if enemy and dist < 50 then  
                local root = self:GetRoot()  
                local enemyRoot = enemy.HumanoidRootPart  
                  
                root.CFrame = enemyRoot.CFrame * CFrame.new(0, 10, 0)  
                  
                if self.Settings.AutoClick then  
                    VirtualUser:ClickButton1(Vector2.new())  
                end  
            else  
                -- Teleport to random Kaitun location  
                local locNames = {}  
                for name in pairs(locations) do  
                    table.insert(locNames, name)  
                end  
                local randomLoc = locNames[math.random(#locNames)]  
                self:Teleport(locations[randomLoc])  
            end  
        end)  
        table.insert(self.Connections, conn)  
    end  
end  
  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
-- [MATERIAL FARMER MODULE - Tier 2 Systems]  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
  
local MaterialFarm = {}  
  
function MaterialFarm:MiniTusk()  
    -- Farms Mythological Pirates for Tushita quest  
    if Core:GetSea() ~= "Third" then return end  
      
    local pirates = {  
        "Mythological Pirate [Lv. 1850]",  
        "Mythological Pirate Captain [Lv. 1875]"  
    }  
      
    local found = false  
    for _, pirate in pairs(pirates) do  
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do  
            if string.find(enemy.Name, pirate) and enemy.Humanoid.Health > 0 then  
                local root = Core:GetRoot()  
                local enemyRoot = enemy.HumanoidRootPart  
                root.CFrame = enemyRoot.CFrame * CFrame.new(0, 10, 0)  
                found = true  
                break  
            end  
        end  
        if found then break end  
    end  
end  
  
function MaterialFarm:EliteHunter()  
    -- Hunts Elite Pirates for Elite Hunter quest (Yama prerequisite)  
    local eliteTypes = {  
        "Deandre [Lv. 1750]",  
        "Urban [Lv. 1750]",  
        "Diablo [Lv. 1750]"  
    }  
      
    for _, elite in pairs(eliteTypes) do  
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do  
            if string.find(enemy.Name, elite) and enemy.Humanoid.Health > 0 then  
                local root = Core:GetRoot()  
                local enemyRoot = enemy.HumanoidRootPart  
                root.CFrame = enemyRoot.CFrame * CFrame.new(0, 15, 0)  
                return true  
            end  
        end  
    end  
    return false  
end  
  
function MaterialFarm:BoneFarm()  
    -- Auto farm bones in Haunted Castle  
    local bones = {}  
    for _, item in pairs(Workspace:GetChildren()) do  
        if item.Name:find("Bone") and item:FindFirstChild("ClickDetector") then  
            table.insert(bones, item)  
        end  
    end  
      
    if #bones > 0 then  
        local root = Core:GetRoot()  
        root.CFrame = bones[1].CFrame  
        fireclickdetector(bones[1].ClickDetector)  
        return true  
    end  
    return false  
end  
  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
-- [LEGENDARY QUEST MODULES - Tier 3 Systems]  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
  
local QuestYama = {  
    EliteKills = 0,  
    MaxElites = 30  
}  
  
function QuestYama:Start()  
    -- Auto Yama Quest System  
    if Core:GetSea() ~= "Third" then return end  
      
    -- Check if already have Yama  
    local backpack = Player.Backpack  
    local character = Core:GetCharacter()  
    local hasYama = false  
      
    for _, tool in pairs(backpack:GetChildren()) do  
        if tool.Name == "Yama" then hasYama = true break end  
    end  
    for _, tool in pairs(character:GetChildren()) do  
        if tool.Name == "Yama" then hasYama = true break end  
    end  
      
    if hasYama then return end  
      
    -- Accept Elite Hunter quest  
    Core:InvokeServer("EliteHunter", "Progress")  
      
    -- Hunt Elites  
    if MaterialFarm:EliteHunter() then  
        self.EliteKills = self.EliteKills + 1  
    end  
      
    -- Check if completed  
    if self.EliteKills >= self.MaxElites then  
        -- Go to Tushita puzzle  
        local puzzleSpot = CFrame.new(-12463.32, 374.49, -7523.96)  
        Core:Teleport(puzzleSpot)  
          
        -- Solve puzzle (simplified version)  
        task.wait(2)  
        -- This would normally involve clicking specific parts in order  
    end  
end  
  
local QuestCDK = {  
    StepsCompleted = 0  
}  
  
function QuestCDK:Start()  
    -- Auto Cursed Dual Katana Quest  
    -- Prerequisites: Yama + Tushita with 350 mastery each  
    local hasYama = false  
    local hasTushita = false  
      
    for _, tool in pairs(Player.Backpack:GetChildren()) do  
        if tool.Name == "Yama" then hasYama = true end  
        if tool.Name == "Tushita" then hasTushita = true end  
    end  
      
    if not (hasYama and hasTushita) then  
        warn("Need both Yama and Tushita for CDK quest")  
        return  
    end  
      
    -- Check mastery levels (simplified)  
    -- In real implementation, you would check the mastery values  
      
    -- Go to Forgotten Island  
    local forgottenIsland = CFrame.new(-11342.62, 346.48, -9506.18)  
    Core:Teleport(forgottenIsland)  
      
    -- Complete CDK puzzle steps  
    -- This is simplified - actual implementation would be complex  
    task.wait(3)  
      
    -- Move to next puzzle location  
    local nextSpot = CFrame.new(-11502.85, 316.94, -9635.71)  
    Core:Teleport(nextSpot)  
end  
  
local QuestGodHuman = {}  
  
function QuestGodHuman:Start()  
    -- Auto God Human Quest  
    if Core:GetSea() ~= "Third" then return end  
      
    local materials = {  
        "Magma Ore",  
        "Mystic Droplet",  
        "Leather",  
        "Scrap Metal",  
        "Angel Wings",  
        "Fish Tail"  
    }  
      
    -- Check inventory for materials  
    -- Farm missing materials  
    for _, mat in pairs(materials) do  
        -- Search for material in workspace  
        for _, item in pairs(Workspace:GetChildren()) do  
            if item.Name:find(mat) and item:FindFirstChild("ClickDetector") then  
                Core:Teleport(item.CFrame)  
                fireclickdetector(item.ClickDetector)  
                task.wait(1)  
            end  
        end  
    end  
end  
  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
-- [COMBAT SYSTEMS]  
--=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#  
  
function Core:ToggleAutoClick(state)  
    self.Settings.AutoClick = state  
    if state then  
        local conn = RunService.Heartbeat:Connect(function()  
            if not self.Settings.AutoClick then  
                conn:Disconnect()  
                return  
            end  
            VirtualUser:ClickButton1(Vector2.new())  
        end)  
        table.insert(self.Connections, conn)  
    end  
end  
  
function Core:ToggleAimbot(state)  
    self.Settings.Aimbot = state  
    if state then  
        local conn = RunService.Heartbeat:Connect(function()  
            if not self.Settings.Aimbot then  
                conn:Disconnect()  
                return  
            end  
              
            local target, dist = self:GetNearestPlayer(100)  
            if target and target.Character then  
                local root = self:GetRoot()  
                local targetRoot = target.Character.HumanoidRootPart  
                  
                -- Aim at player  
                root.CFrame = CFrame.new(root.Position, targetRoot.Position)  
                  
                -- Auto attack if close  
                if dist < 20 and self.Settings.AutoClick then  
                    VirtualUser:ClickButton1(Vector2.new())  
                end  
            end  
        end)  
        table.insert(self.Connections, conn)  
    end  
end  
  
function Core:ToggleKillAura(state)  
    self.Settings.KillAura = state  
    if state then  
        local conn = RunService.Heartbeat:Connect(function()  
            if not self.Settings
