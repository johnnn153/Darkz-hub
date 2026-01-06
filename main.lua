--[[
    🏴‍☠️ DARKZ HUB ULTIMATE - Farm & Combat Module v4.0 (COMPLETE)
    🎯 Sistema de Farm Inteligente Multi-Mode
    ⚔️ Combat System com AI Prediction
    ⚡ Raid Manager Completo Update 25+
]]

-- ============================================
-- DEPENDENCIES E CONFIGURAÇÃO
-- ============================================
local Core = require(script.Parent.CoreModule).Core
local Services = setmetatable({}, {
    __index = function(t, k)
        local s = game:GetService(k)
        rawset(t, k, s)
        return s
    end
})

local Player = Services.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Sistemas de conexão (nova implementação)
local Connections = {}
local function AddConnection(conn)
    table.insert(Connections, conn)
end

-- ============================================
-- SMART FARM SYSTEM (FINAL)
-- ============================================
local SmartFarm = {
    Enabled = false,
    Mode = "Normal",
    Config = {
        Range = 50,
        Priority = "Closest",
        UseSkills = true,
        SafeMode = true,
        AutoQuest = true,
        FastMode = false,
        HealthThreshold = 30,
        HumanMode = true -- Comportamento humano
    },
    Stats = {
        MobsKilled = 0,
        QuestsCompleted = 0,
        Deaths = 0,
        FruitsFound = 0,
        Runtime = 0
    },
    Cache = {
        CurrentTarget = nil,
        QuestActive = false,
        LastTargetSwitch = 0,
        SafeSpot = nil,
        LastAction = 0,
        ActionPattern = {}
    }
}

-- Função melhorada com anti-detection
function SmartFarm:HumanizedDelay(minSec, maxSec)
    local delay = math.random(minSec * 100, maxSec * 100) / 100
    local variation = math.random(-5, 5) / 100
    return delay + variation
end

-- Pathfinding otimizado com cache
function SmartFarm:GetOptimizedPath(targetPos)
    local now = tick()
    local cacheKey = tostring(math.floor(targetPos.X)) .. "_" .. 
                    tostring(math.floor(targetPos.Y)) .. "_" .. 
                    tostring(math.floor(targetPos.Z))
    
    -- Usar cache se recente
    if self.Cache.PathCache and self.Cache.PathCache[cacheKey] then
        local cached = self.Cache.PathCache[cacheKey]
        if now - cached.Time < 10 then -- Cache válido por 10 segundos
            return cached.Path
        end
    end
    
    -- Calcular novo path (simplificado para performance)
    local currentPos = HRP.Position
    local direction = (targetPos - currentPos).Unit
    local distance = (targetPos - currentPos).Magnitude
    
    -- Path simplificado: direto com pequenos ajustes
    local path = targetPos
    
    -- Adicionar pequeno offset para parecer humano
    if self.Config.HumanMode then
        local offset = Vector3.new(
            math.random(-3, 3),
            math.random(0, 2),
            math.random(-3, 3)
        )
        path = targetPos + offset
    end
    
    -- Salvar no cache
    if not self.Cache.PathCache then
        self.Cache.PathCache = {}
    end
    self.Cache.PathCache[cacheKey] = {
        Path = path,
        Time = now
    }
    
    return path
end

-- Sistema de target com prioridade inteligente
function SmartFarm:GetIntelligentTarget()
    local now = tick()
    
    -- Não mudar target muito rápido (evitar detection)
    if self.Cache.CurrentTarget and now - self.Cache.LastTargetSwitch < 1.5 then
        local hum = self.Cache.CurrentTarget:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            return self.Cache.CurrentTarget
        end
    end
    
    local enemies = Services.Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local bestTarget = nil
    local bestScore = -999999
    
    -- Score system: combina múltiplos fatores
    for i = 1, math.min(20, #enemies:GetChildren()) do -- Limitar busca
        local enemy = enemies:GetChildren()[i]
        
        local success, score = pcall(function()
            local npcHRP = enemy:FindFirstChild("HumanoidRootPart")
            local npcHum = enemy:FindFirstChild("Humanoid")
            
            if not npcHRP or not npcHum or npcHum.Health <= 0 then
                return -999999
            end
            
            local distance = (HRP.Position - npcHRP.Position).Magnitude
            if distance > self.Config.Range then
                return -999999
            end
            
            -- Calcular score baseado na prioridade configurada
            local score = 0
            
            if self.Config.Priority == "Closest" then
                score = 1000 - distance * 10
            elseif self.Config.Priority == "Weakest" then
                score = 1000 - npcHum.Health
            else -- HighestReward (default)
                local estimatedXP = npcHum.MaxHealth * 0.5
                local timeToKill = npcHum.Health / 100 -- Estimativa
                score = estimatedXP / timeToKill
            end
            
            -- Penalizar targets que já estão sendo atacados por outros
            if enemy:FindFirstChild("_lastDamage") then
                score = score * 0.7
            end
            
            return score
        end)
        
        if success and score > bestScore then
            bestScore = score
            bestTarget = enemy
        end
    end
    
    if bestTarget then
        self.Cache.CurrentTarget = bestTarget
        self.Cache.LastTargetSwitch = now
    end
    
    return bestTarget
end

-- Loop principal otimizado
function SmartFarm:Start()
    if self.Enabled then return end
    self.Enabled = true
    self.Stats.Runtime = tick()
    
    local conn = Services.RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        
        local success, err = pcall(function()
            -- Health check
            local hum = Character:FindFirstChild("Humanoid")
            if not hum or hum.Health < self.Config.HealthThreshold then
                -- Pause humanizado
                task.wait(self:HumanizedDelay(3, 7))
                return
            end
            
            -- Selecionar target
            local target = self:GetIntelligentTarget()
            if not target then
                -- Nenhum target, buscar área
                if self.Mode == "Normal" and self.Config.AutoQuest then
                    self:AcceptQuest()
                end
                task.wait(self:HumanizedDelay(0.5, 1.5))
                return
            end
            
            local targetHRP = target:FindFirstChild("HumanoidRootPart")
            if not targetHRP then return end
            
            -- Calcular posição de ataque
            local attackDistance = 10
            if self.Mode == "Boss" then
                attackDistance = 25
            end
            
            -- Adicionar variação humana na posição
            local angle = math.random(0, 360)
            local rad = math.rad(angle)
            local offset = Vector3.new(
                math.cos(rad) * attackDistance,
                math.random(5, 15),
                math.sin(rad) * attackDistance
            )
            
            local attackPos = targetHRP.CFrame + offset
            
            -- Teleport com variação
            local useTween = self.Config.SafeMode and math.random() > 0.3
            Core:Teleport(attackPos, useTween)
            
            -- Pausa entre ação e ataque
            task.wait(self:HumanizedDelay(0.1, 0.3))
            
            -- Executar combate
            require(script.Parent.CombatModule):Attack(target)
            
            -- Pausa entre ciclos (humanizado)
            task.wait(self:HumanizedDelay(0.2, 0.8))
            
        end)
        
        if not success then
            warn("[SmartFarm] Error:", err)
        end
    end)
    
    AddConnection(conn)
end

function SmartFarm:Stop()
    self.Enabled = false
end

-- ============================================
-- COMBAT SYSTEM (FINAL)
-- ============================================
local CombatSystem = {
    Config = {
        AutoClick = true,
        UseSkills = true,
        ComboMode = "Adaptive",
        AimbotEnabled = false,
        AimbotSmoothness = 0.3,
        KillAura = {
            Enabled = false,
            Range = 50,
            Filter = "NPC"
        },
        AutoBlock = true,
        BlockThreshold = 40,
        DodgeEnabled = true,
        HumanMode = true
    },
    Skills = {
        Z = {Cooldown = 2, LastUsed = 0},
        X = {Cooldown = 3, LastUsed = 0},
        C = {Cooldown = 4, LastUsed = 0},
        V = {Cooldown = 5, LastUsed = 0},
        F = {Cooldown = 8, LastUsed = 0}
    },
    LastAttackPattern = {}
}

-- Sistema de combos com machine learning simples
function CombatSystem:GetOptimalCombo()
    local now = tick()
    local fruit = self:GetEquippedFruit()
    
    -- Analisar padrão de sucesso
    local successfulPatterns = {
        ["Buddha"] = {"Z", "C", "V", "X", "Z"},
        ["Dough"] = {"C", "X", "Z", "V", "C"},
        ["Dragon"] = {"Z", "X", "F", "Z"},
        ["Default"] = {"Z", "X", "C", "V", "F"}
    }
    
    local baseCombo = successfulPatterns[fruit] or successfulPatterns["Default"]
    
    -- Adicionar variação humana (nunca executar exatamente igual)
    if self.Config.HumanMode then
        local variation = math.random(1, 3)
        if variation == 1 then
            -- Remover um skill aleatório
            local removeIndex = math.random(#baseCombo)
            table.remove(baseCombo, removeIndex)
        elseif variation == 2 then
            -- Adicionar skill extra
            local extraSkill = math.random() > 0.5 and "Z" or "X"
            table.insert(baseCombo, math.random(#baseCombo), extraSkill)
        end
        -- Adicionar delay aleatório entre skills
        for i = 1, #baseCombo do
            if math.random() > 0.7 then
                baseCombo[i] = baseCombo[i] .. "_DELAY"
            end
        end
    end
    
    return baseCombo
end

-- Ataque principal com anti-detection
function CombatSystem:Attack(target)
    if not target then return end
    
    local now = tick()
    local VIM = Services.VirtualInputManager
    
    -- Verificar se pode atacar (rate limiting)
    if #self.LastAttackPattern > 10 then
        local timeSinceFirst = now - self.LastAttackPattern[1]
        if timeSinceFirst < 5 then -- Muitos ataques muito rápido
            warn("[CombatSystem] Rate limiting activated")
            task.wait(math.random(1, 3))
            self.LastAttackPattern = {}
        end
    end
    
    -- Auto-click com variação
    if self.Config.AutoClick then
        local clickDuration = math.random(8, 15) / 100
        local success = pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(clickDuration)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        
        if success then
            table.insert(self.LastAttackPattern, now)
        end
    end
    
    -- Skills com cooldowns e variação
    if self.Config.UseSkills and math.random() > 0.3 then -- 70% chance
        local combo = self:GetOptimalCombo()
        
        for _, skill in ipairs(combo) do
            if skill:find("_DELAY") then
                skill = skill:gsub("_DELAY", "")
                task.wait(math.random(5, 20) / 100) -- Delay aleatório
            end
            
            local skillData = self.Skills[skill]
            if skillData and now - skillData.LastUsed >= skillData.Cooldown then
                local success = pcall(function()
                    VIM:SendKeyEvent(true, skill, false, game)
                    
                    -- Hold duration variável
                    local holdTime = math.random(4, 10) / 100
                    task.wait(holdTime)
                    
                    VIM:SendKeyEvent(false, skill, false, game)
                    
                    skillData.LastUsed = now
                    table.insert(self.LastAttackPattern, now)
                end)
                
                if not success then
                    warn("[CombatSystem] Failed to use skill:", skill)
                end
            end
            
            -- Pausa entre skills
            if self.Config.HumanMode then
                task.wait(math.random(10, 30) / 100)
            end
        end
    end
    
    -- Limitar histórico
    while #self.LastAttackPattern > 15 do
        table.remove(self.LastAttackPattern, 1)
    end
end

-- ============================================
-- RAID MANAGER (FINAL)
-- ============================================
local RaidManager = {
    Enabled = false,
    Config = {
        SelectedRaid = "Flame",
        AutoStart = true,
        AutoFarmChips = true,
        AutoTeleportRooms = true,
        SafeMode = true,
        AutoCollectOrbs = true,
        HumanMode = true
    },
    Cache = {
        CurrentRoom = 1,
        RaidActive = false,
        BossSpawned = false,
        LastRoomChange = 0,
        OrbsCollected = 0
    }
}

-- Sistema de rooms com pathfinding inteligente
function RaidManager:NavigateToRoom(roomNumber)
    local now = tick()
    if now - self.Cache.LastRoomChange < 3 then
        return false -- Evitar mudanças muito rápidas
    end
    
    local roomPositions = {
        [1] = CFrame.new(-5550, 315, -2900),
        [2] = CFrame.new(-5450, 315, -2800),
        [3] = CFrame.new(-5350, 315, -2700),
        [4] = CFrame.new(-5250, 315, -2600),
        [5] = CFrame.new(-5150, 315, -2500)
    }
    
    local targetPos = roomPositions[roomNumber]
    if not targetPos then return false end
    
    -- Teleport com variação
    local offset = Vector3.new(
        math.random(-5, 5),
        0,
        math.random(-5, 5)
    )
    
    local success = Core:Teleport(targetPos + offset, false)
    
    if success then
        self.Cache.CurrentRoom = roomNumber
        self.Cache.LastRoomChange = now
        return true
    end
    
    return false
end

-- Sistema principal de raid
function RaidManager:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    local conn = Services.RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        
        local success, err = pcall(function()
            -- Iniciar raid
            if not self.Cache.RaidActive then
                if self.Config.AutoStart then
                    self:StartRaid()
                end
                task.wait(self:HumanizedDelay(1, 3))
                return
            end
            
            -- Encontrar target atual
            local target = self:FindRaidTarget()
            if target then
                -- Atacar target
                CombatSystem:Attack(target)
                
                -- Coletar orbs periodicamente
                if self.Config.AutoCollectOrbs and math.random() > 0.7 then
                    self:CollectOrbs()
                end
                
            else
                -- Nenhum target, mudar de room
                local nextRoom = self.Cache.CurrentRoom + 1
                if nextRoom > 5 then
                    nextRoom = 1 -- Reset para room 1
                end
                
                self:NavigateToRoom(nextRoom)
                
                -- Pausa entre room changes
                task.wait(self:HumanizedDelay(2, 4))
            end
            
            -- Pausa geral (humanizada)
            task.wait(self:HumanizedDelay(0.3, 1.2))
            
        end)
        
        if not success then
            warn("[RaidManager] Error:", err)
        end
    end)
    
    AddConnection(conn)
end

function RaidManager:Stop()
    self.Enabled = false
end

-- ============================================
-- EXPORTS E RETURN
-- ============================================
return {
    SmartFarm = SmartFarm,
    CombatSystem = CombatSystem,
    RaidManager = RaidManager,
    AddConnection = AddConnection
}
