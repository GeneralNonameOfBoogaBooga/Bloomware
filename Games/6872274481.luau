local Bloomware = getgenv().Bloomware
local Windows = Bloomware.UIData
local Assets = Bloomware.Assets
local OnUnject: BindableEvent = Bloomware.OnUninject

local Players: Players = Bloomware.cloneref(game:GetService("Players"))
local RunService: RunService = Bloomware.cloneref(game:GetService("RunService"))
local ReplicatedStorage: ReplicatedStorage = Bloomware.cloneref(game:GetService("ReplicatedStorage"))
local CollectionService: CollectionService = Bloomware.cloneref(game:GetService("CollectionService"))
local TweenService: TweenService = Bloomware.cloneref(game:GetService("TweenService"))
local UserInputService: UserInputService = Bloomware.cloneref(game:GetService("UserInputService"))
local HttpService: HttpService = Bloomware.cloneref(game:GetService("HttpService"))
local StarterGui: StarterGui = Bloomware.cloneref(game:GetService("StarterGui"))
local Stats: Stats = Bloomware.cloneref(game:GetService("Stats")):FindFirstChild("PerfromanceStats")
local TextChatService: TextChatService = Bloomware.cloneref(game:GetService("TextChatService"))
local ContextActionService: ContextActionService = Bloomware.cloneref(game:GetService("ContextActionService"))

local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Bloomware.cloneref(LocalPlayer:WaitForChild("PlayerGui"))
local CurrentCamera: Camera = workspace.CurrentCamera

local Knit = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"].knit.src).KnitClient
local Flamework = require(ReplicatedStorage.rbxts_include.node_modules["@flamework"].core.out).Flamework

repeat task.wait() until Knit and Knit.Controllers and debug.getupvalue(Knit.Start, 1)

local BlockEngine = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["block-engine"].out)
local GameData = {
    Utils = {
        Remotes = require(ReplicatedStorage.TS.remotes).default.Client,
        Network = require(LocalPlayer.PlayerScripts.TS.lib.network),
        DamageTypes = require(ReplicatedStorage.TS.damage["damage-type"]).DamageType,
        ItemMeta = require(ReplicatedStorage.TS.item["item-meta"]).items,
        Store = require(LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
        InventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil,
        ViewmodelController = Knit.Controllers.ViewmodelController,
        MatchStates = require(ReplicatedStorage.TS.match["match-state"]).MatchState,
        Animation = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["game-core"].out).AnimationUtil,
        AnimationType = require(ReplicatedStorage.TS.animation["animation-type"]).AnimationType,
        ProdAnimations = require(ReplicatedStorage.TS.animation.definitions["prod-animations"]).ProdAnimations,
        BlockEngine = BlockEngine.BlockEngine,
        BlockRemotes = BlockEngine.BlockEngineRemotes.Client,
        BlockBreaker = Knit.Controllers.BlockBreakController.blockBreaker,
        TeamController = Knit.Controllers.TeamController,
        Sprint = Knit.Controllers.SprintController,
        Knockback = require(ReplicatedStorage.TS.damage["knockback-util"]).KnockbackUtil,
        Chest = Knit.Controllers.ChestController,
        App = Flamework.resolveDependency("@easy-games/game-core:client/controllers/app-controller@AppController"),
        Party = Flamework.resolveDependency("@easy-games/lobby:client/controllers/party-controller@PartyController"),
        AppIds = require(LocalPlayer.PlayerScripts.TS.ui.types["app-config"]).BedwarsAppIds,
        Projectile = Knit.Controllers.ProjectileController,
        Sound = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["game-core"].out).SoundManager,
        ProjMeta = require(ReplicatedStorage.TS.projectile["projectile-meta"]).ProjectileMeta,
        GameQuery = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["game-core"].out.shared["game-world-query"]["game-query-util"]).GameQueryUtil,
        TeamUpgradesController = Knit.Controllers.TeamUpgradeController,
        TeamUpgradeMeta = debug.getupvalue(require(ReplicatedStorage.TS.games.bedwars["team-upgrade"]["team-upgrade-meta"]).getTeamUpgradeMetaForQueue, 2),
        Shop = require(ReplicatedStorage.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.ShopItems,
        BlockPlacer = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
        BlockClient = require(LocalPlayer.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
        QueueController = Knit.Controllers.QueueController,
        ClawHandController = Knit.Controllers.SummonerClawHandController,
        Cannon = Knit.Controllers.CannonHandController,
        DaoController = Knit.Controllers.DaoController,
        SwordController = Knit.Controllers.SwordController,
        PlaceController = Knit.Controllers.BlockPlacementController,
        SummonerKitBalance = require(ReplicatedStorage.TS.games.bedwars.kit.kits.summoner["summoner-kit-balance"]).SummonerKitBalance,
        AbilityController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController"),
        UILayer = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["game-core"].out).UILayers,
        MatchHistroyApp = require(LocalPlayer.PlayerScripts.TS.controllers.global["match-history"].ui["match-history-moderation-app"]).MatchHistoryModerationApp,
        MatchHistroyController = Knit.Controllers.MatchHistoryController,
        CombatConstant = require(ReplicatedStorage.TS.combat['combat-constant']).CombatConstant,
        GameSound = require(ReplicatedStorage.TS.sound['game-sound']).GameSound
    },
    Events = {
        Damage = Instance.new("BindableEvent"),
        Death = Instance.new("BindableEvent"),
        BedBreak = Instance.new("BindableEvent"),
        MatchEnd = Instance.new("BindableEvent")
    },
    Data = {
        KillAuraTargets = {},
        Target = nil
    }
}

local Materials = {}
for _, Material in next, Enum.Material:GetEnumItems() do
    table.insert(Materials, Material.Name)
end

local AimParts: {string} = {"HumanoidRootPart", "Head"}
if LocalPlayer.Character then
    for _, v in LocalPlayer.Character:GetChildren() do
        if (v:IsA("Part") or v:IsA("MeshPart")) and not table.find(AimParts, v.Name) then
            table.insert(AimParts, v.name)
        end
    end
end

Assets.Connections:Add(OnUnject.Event:Connect(function()
    for i,v in GameData.Events do
        v:Destroy()
    end

    task.delay(1, table.clear, GameData)
end))

Assets.Connections:Add(GameData.Utils.Network.EntityDamageEventZap.On(function(...)
    local Data = table.pack(...)
    GameData.Events.Damage:Fire({
        Damaged = Data[1],
        DamagedPlayer = Players:GetPlayerFromCharacter(Data[1]),
        Damage = Data[2],
        Type = {Value = GameData.Utils.DamageTypes[Data[3]], Number = Data[3]},
        Damager = Data[5],
        DamagerPlayer = Players:GetPlayerFromCharacter(Data[5])
    })
end))

task.spawn(function()
    Assets.Connections:Add(GameData.Utils.Remotes:Get("EntityDeathEvent"):Connect(function(Data)
        GameData.Events.Death:Fire({
            RespawnTime = Data.respawnDuration,
            Type = {Value = GameData.Utils.DamageTypes[Data.damageType], Number = Data.damageType},
            Final = Data.finalKill,
            Killer = Data.fromEntity,
            Killed = Data.entityInstance,
            KilledPlayer = Players:GetPlayerFromCharacter(Data.entityInstance)
        })
    end))

    Assets.Connections:Add(GameData.Utils.Remotes:Get("BedwarsBedBreak"):Connect(function(Data)
        if Data.player == LocalPlayer then
            GameData.Events.BedBreak:Fire({
                BedBlockPos = Data.bedBlockPosition,
                TeamName = Data.brokenBedTeam.displayName or "Unknown",
                TeamColor = Data.brokenBedTeam.colorHex or 0
            })
        end
    end))

    Assets.Connections:Add(GameData.Utils.Remotes:Get("MatchEndEvent"):Connect(function(Data)
        if Windows.Utility.Modules.AntiAFK and Windows.Utility.Modules.AntiAFK.Enabled then
            GameData.Utils.Remotes:Get("AfkInfo"):SendToServer({
                afk = false
            })
        end

        GameData.Events.MatchEnd:Fire({
            TeamID = Data.winningTeamId,
            OldLeaderboard = Data.previousLeaderboardPosition,
            NewLeaderboard = Data.newLeaderboardPosition
        })
    end))
end)

local BlockList: {Instance} = CollectionService:GetTagged("block")
Assets.Connections:Add(CollectionService:GetInstanceAddedSignal("block"):Connect(function(inst: Instance) table.insert(BlockList, inst) end))
Assets.Connections:Add(CollectionService:GetInstanceRemovedSignal("block"):Connect(function(inst: Instance)
    for i, v in next, BlockList do
        if v == inst then
            table.remove(BlockList, i)
            break
        end
    end
end))

local function Warning(Title: string, Description: string, Duration: number)
    pcall(function()
		setthreadidentity(8)
    end)

    Bloomware:CreateNotification({
        Title = Title,
        Description = Description,
        Duration = Duration
    })
end

local function Separate(Input: string)
    local Text = string.split(Input, ",")
    local Table = {}
    for _, Item in next, Text do
        local Selected = Item:gsub("^%s*(.-)%s*$", "%1")
        if Selected ~= "" then
            table.insert(Table, Selected)
        end
    end
    return Table
end

local function GetIcon(Item, Inv)
	local Meta = GameData.Utils.ItemMeta[Item.itemType]
	return Meta and Inv and Meta.image or ''
end

local function GetInventory(Player: Player?)
    Player = Player or LocalPlayer
    return GameData.Utils.InventoryUtil.getInventory(Player)
end

local function GetPlayersTeam(Player: Player): string
    local PlayerTeam = GameData.Utils.TeamController:getPlayerTeam(Player)
    if PlayerTeam and PlayerTeam.id then
        return PlayerTeam.id
    end

    return
end

local function GetSword(): {AttackSpeed: number, Damage: number, Item: Instance?, Meta: {itemType: string}}
    local Inventory = GetInventory()
    local Sword = {
        Item = nil,
        Damage = 0,
        AttackSpeed = 0,
        InvData = nil
    }

    if Inventory then
        local Items = Inventory.items
        if Items then
            for i,v in Items do
                local ItemMeta = GameData.Utils.ItemMeta[v.itemType]
                if ItemMeta then
                    local SwordData = ItemMeta.sword
                    if SwordData then
                        local Value: number = (SwordData.damage / SwordData.attackSpeed)
                        local CurValue: number = (Sword.Damage / Sword.AttackSpeed)
                        if CurValue ~= CurValue then
                            CurValue = 0
                        end

                        if Value > CurValue then
                            Sword = {
                                Item = v.tool,
                                Damage = SwordData.damage,
                                AttackSpeed = SwordData.attackSpeed,
                                InvData = v,
                                Meta = ItemMeta
                            }
                        end
                    end
                end
            end
        end
    end

    return Sword
end

local function GetItemFromShop(ItemType: string)
    for i,v in GameData.Utils.Shop do
        if v.itemType == ItemType then
            return v
        end
    end

    return
end

local function GetNextSword()
    local CurrentSword = GetSword()
    if CurrentSword.Item then
        local CurrentSwordType = CurrentSword.InvData.itemType
        local Shopitem = GetItemFromShop(CurrentSwordType)
        if Shopitem and Shopitem.superiorItems and #Shopitem.superiorItems > 0 then
            return GetItemFromShop(Shopitem.superiorItems[1]), Shopitem, Shopitem.superiorItems[1]
        end
    end

    return
end

local function GetCurrentArmor(): string
    for i,v in GetInventory().armor do 
        if typeof(v) == "table" then
            local Type: string = v.itemType
            if Type:find("_") then
                return Type:split("_")[1].."_chestplate", v
            end
        end
    end

    for i,v in GetInventory().items do
        if v.itemType:find("chestplate") then
            return v.itemType, v
        end
    end

    return
end

local function AimPos(Root: BasePart, Humanoid: Humanoid): Vector3
    local Pos = Root.Position
    local Vel = Root.AssemblyLinearVelocity
    local Lift = math.clamp(Humanoid.HipHeight * 0.35, 0.6, 1.35)

    if Humanoid.FloorMaterial == Enum.Material.Air or Vel.Y > 3 then
        local Map = workspace:FindFirstChild("Map")
        local GroundCheck = RaycastParams.new()
        GroundCheck.FilterType = Enum.RaycastFilterType.Include
        GroundCheck.FilterDescendantsInstances = Map and {Map} or {}
        GroundCheck.RespectCanCollide = true

        local Ground = workspace:Raycast(Pos, Vector3.new(0, -18, 0), GroundCheck)
        if Ground then
            local GroundedRootY = Ground.Position.Y + Humanoid.HipHeight + 1.5
            Pos = Vector3.new(Pos.X, math.min(Pos.Y, GroundedRootY), Pos.Z)
        end
    end

    return Pos + Vector3.new(0, Lift, 0)
end

    local function FlatVel(Root: BasePart): Vector3
        local Vel = Root.AssemblyLinearVelocity
        return Vector3.new(Vel.X, 0, Vel.Z)
    end

    local function SolveShot(Start: Vector3, Speed: number, Gravity: number, HitPos: Vector3, HitVel: Vector3): Vector3?
        if Speed <= 0 then return end
        if Gravity <= 0 then
            local Time = (HitPos - Start).Magnitude / Speed
            return HitPos + (HitVel * Time)
        end

        local Land = HitPos
        local Time = math.max((Vector3.new(HitPos.X, Start.Y, HitPos.Z) - Start).Magnitude / Speed, 0.05)

        for _ = 1, 4 do
            Land = HitPos + (HitVel * Time)

            local Delta = Land - Start
            local Flat = Vector3.new(Delta.X, 0, Delta.Z)
            local Dist = Flat.Magnitude
            if Dist <= 0.05 then
                return Land
            end

            local Speed2 = Speed * Speed
            local Root = Speed2 * Speed2 - Gravity * (Gravity * Dist * Dist + 2 * Delta.Y * Speed2)
            if Root < 0 then
                local FallTime = Dist / Speed
                return Land + Vector3.new(0, 0.5 * Gravity * FallTime * FallTime, 0)
            end

            local Angle = math.atan((Speed2 - math.sqrt(Root)) / (Gravity * Dist))
            local Forward = Speed * math.cos(Angle)
            if Forward <= 0.05 then
                return Land
            end

            Time = Dist / Forward
        end

        local Delta = Land - Start
        local Flat = Vector3.new(Delta.X, 0, Delta.Z)
        local Dist = Flat.Magnitude
        if Dist <= 0.05 then
            return Land
        end

        local Speed2 = Speed * Speed
        local Root = Speed2 * Speed2 - Gravity * (Gravity * Dist * Dist + 2 * Delta.Y * Speed2)
        if Root < 0 then
            local FallTime = Dist / Speed
            return Land + Vector3.new(0, 0.5 * Gravity * FallTime * FallTime, 0)
        end

        local Angle = math.atan((Speed2 - math.sqrt(Root)) / (Gravity * Dist))
        return Start + (Flat.Unit * Dist) + Vector3.new(0, math.tan(Angle) * Dist, 0)
    end

local function GetNextArmor()
    local CurrentArmor = GetCurrentArmor()
    if CurrentArmor then
        local Shopitem = GetItemFromShop(CurrentArmor)
        if Shopitem and Shopitem.nextTier and CurrentArmor ~= Shopitem.nextTier then
            return GetItemFromShop(Shopitem.nextTier), Shopitem, Shopitem.nextTier
        end
    end

    return GetItemFromShop("leather_chestplate"), nil, "leather_chestplate"
end

local function GetItem(Name: string, Find: boolean?)
    for i, v in GetInventory().items do
		if v.itemType == Name or (Find and v.itemType:find(Name)) then
			return v
		end
	end

	return
end

local function GetUpgradeFromName(Name: string)
    for i,v in GameData.Utils.TeamUpgradeMeta do
        if v.name == Name then
            return i, v
        end
    end

    return
end

local function GetBestItemToBreakBlock(Type: string)
    local Inventory = GetInventory()
    local Data = {
        Item = nil,
        Damage = 0
    }

    if Inventory and Inventory.items then
        for i,v in Inventory.items do
            local Meta = GameData.Utils.ItemMeta[v.itemType]
            if Meta and Meta.breakBlock then
                for i2: string, v2: number in Meta.breakBlock do
                    if Type:lower():find(i2:lower()) and v2 > Data.Damage then
                        Data = {
                            Item = v.tool,
                            Damage = v2
                        }
                    end
                end

            end
        end
    end

    return Data
end

local function GetBlocks()
    local Inventory = GetInventory()
    local Data = {
        Block = nil,
        Health = math.huge,
        Amount = 0,
        Type = nil
    }

    if Inventory and Inventory.items then
        for i,v in Inventory.items do
            local Meta = GameData.Utils.ItemMeta[v.itemType]
            if Meta and Meta.block then
                local Health: number = Meta.block.health
                if Data.Health > Health or Meta.block.breakType == "wool" then
                    Data = {
                        Block = v.tool,
                        Health = Health,
                        Amount = v.amount,
                        Type = v.itemType
                    }

                    if Meta.block.breakType == "wool" then
                        return Data
                    end
                end
            end
        end
    end

    return Data
end

local function SwitchItem(Tool, Time)
	Time = Time or 0.05
	if not Tool then return false end

	local Item = LocalPlayer.Character:FindFirstChild('HandInvItem')

	if Tool and Item and Item.Value == Tool then
		return true
	end

	if Tool.Parent ~= nil and Item and Item.Value ~= Tool then
		task.spawn(function()
			GameData.Utils.Remotes:Get("SetInvItem"):CallServerAsync({hand = Tool})
		end)

		Item.Value = Tool
		task.wait(Time)

		return true
	end

	return false
end

local function FireProjectileRemote(...)
    local Remote = GameData.Utils.Remotes:Get("ProjectileFire")

    if Remote and Remote.instance and Remote.instance.InvokeServer then
        return Remote.instance:InvokeServer(...)
    end

    if Remote and Remote.InvokeServer then
        return Remote:InvokeServer(...)
    end

    if Remote and Remote.CallServerAsync then
        local Done, Value = false, nil
        local Result = Remote:CallServerAsync(...)

        if Result and Result.andThen then
            Result:andThen(function(Response)
                Value = Response
                Done = true
            end)

            local Started = tick()
            repeat task.wait() until Done or (tick() - Started) > 0.75
            return Value
        end

        return Result
    end

    return nil
end

--[[local function SwitchItem(Item: Instance)
    if not Item then
        return
    end

    local CurrentItem: ObjectValue? = LocalPlayer.Character:FindFirstChild("HandInvItem")
    if CurrentItem and CurrentItem:IsA("ObjectValue") then
        CurrentItem = CurrentItem.Value
    else
        local Inventory = GetInventory()
        if Inventory and Inventory.hand then
            CurrentItem = Inventory.hand.tool
        end
    end

    if CurrentItem == Item then
        return
    end

    -- local Found: boolean = false
    -- for i,v in GameData.Utils.Store:getState().Inventory.observedInventory.hotbar do
    --     if v.item and v.item.tool and v.item.tool == Item then
    --         Found = true
    --         GameData.Utils.Store:dispatch({
    --             type = "InventorySelectHotbarSlot",
    --             slot = (i - 1)
    --         })
    --     end
    -- end

    -- if not Found then
        local Completed: boolean = false
        GameData.Utils.Remotes:Get("SetInvItem"):CallServerAsync({
            hand = Item
        }):andThen(function(suc: boolean)
            Completed = true
        end)

        repeat task.wait() until Completed
    -- else
    --     local CompTime: number = os.clock()
    --     repeat 
    --         local HandItem = LocalPlayer.Character:FindFirstChild("HandInvItem")
    --         if HandItem and HandItem:IsA("ObjectValue") then
    --             HandItem = HandItem.Value
    --         else
    --             local Inventory = GetInventory()
    --             if Inventory and Inventory.hand then
    --                 HandItem = Inventory.hand.tool
    --             end
    --         end

    --         if HandItem == Item then
    --             break
    --         end

    --         task.wait() 
    --     until false or (os.clock() - CompTime) > ((Stats and (Stats.Ping:GetValue() / 1000) + 0.05) or 0.2)

    --     task.wait(0.001)
    -- end
end]]

local function IsPathClear(target: Instance, TargetPart: Part?, Param: RaycastParams): boolean
    local Start: Vector3 = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * 1
    if TargetPart then
        local Direction: Vector3 = (TargetPart.Position - Start)
        local Distance: number = Direction.Magnitude
        Direction = Direction.Unit * math.min(Distance, 1000)
        local Ray: RaycastResult = workspace:Raycast(Start, Direction, Param)
        
        if not Ray or (Ray.Instance and (Ray.Instance:IsDescendantOf(target) or GameData.Utils.GameQuery:isQueryIgnored(Ray.Instance))) then
            return true
        end
    end

    return false
end

local function IsPathClear_Position(Target: Instance, Position2: Vector3, Param: RaycastParams): boolean
    local Start: Vector3 = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * 1
    if Position2 then
        local Direction: Vector3 = (Position2 - Start)
        local Distance: number = Direction.Magnitude
        Direction = Direction.Unit * math.min(Distance, 1000)
        local Ray: RaycastResult = workspace:Raycast(Start, Direction, Param)
        
        if not Ray or (Ray.Instance and (Ray.Instance:IsDescendantOf(Target) or GameData.Utils.GameQuery:isQueryIgnored(Ray.Instance))) then
            return true
        end
    end

    return false
end

local function GetAngle(CFrame: CFrame, TargetPos: Vector3): number
    local LookVector: Vector3 = CFrame.LookVector * Vector3.new(1, 0, 1)
    local Position: Vector3 = CFrame.Position

    local ScaledVector: Vector3 = (TargetPos - Position) * Vector3.new(1, 0, 1)
    return math.acos(math.clamp(LookVector:Dot(ScaledVector.Unit), -1, 1))
end

local CachedEntities = {}
local CachedEntitiesList = {}

local function CheckEntity(v: Instance)
    if not v:IsA("Model") then return end
    local Humanoid = v:FindFirstChild("Humanoid") or v:WaitForChild("Humanoid", 2)
    if not Humanoid then return end
    local Root = v.PrimaryPart or v:WaitForChild("HumanoidRootPart", 2)
    if not Root then return end
    
    local Player = Players:GetPlayerFromCharacter(v)
    local Type = CollectionService:GetTags(v)[3] or ""
    
    local Data = {
        Entity = v,
        Player = Player,
        Humanoid = Humanoid,
        Root = Root,
        Type = Type,
        Health = 100,
        MaxHealth = 100
    }
    CachedEntities[v] = Data
    table.insert(CachedEntitiesList, Data)
end

local function RemoveEntity(v: Instance)
    CachedEntities[v] = nil
    for i, data in ipairs(CachedEntitiesList) do
        if data.Entity == v then
            table.remove(CachedEntitiesList, i)
            break
        end
    end
end

for _, v in ipairs(CollectionService:GetTagged("entity")) do
    task.spawn(CheckEntity, v)
end

Assets.Connections:Add(CollectionService:GetInstanceAddedSignal("entity"):Connect(CheckEntity))
Assets.Connections:Add(CollectionService:GetInstanceRemovedSignal("entity"):Connect(RemoveEntity))

local function GetEntities(): {{Entity: Model, Player: Player?, Health: number, MaxHealth: number, Humanoid: Humanoid, Root: BasePart, Type: string}}
    local Entities = {}
    for _, Data in ipairs(CachedEntitiesList) do
        local Entity = Data.Entity
        local Humanoid = Data.Humanoid
        if Entity and Entity.Parent and Humanoid and Humanoid.Parent then
            Data.Health = Entity:GetAttribute("Health") or Humanoid.Health
            Data.MaxHealth = Entity:GetAttribute("MaxHealth") or Humanoid.MaxHealth
            Data.Root = Entity.PrimaryPart or Data.Root
            table.insert(Entities, Data)
        end
    end
    return Entities
end

local function GetEntity(Data: {TeamCheck: boolean?, Mode: string?, MaxRange: number?, MaxAngle: number?, Targets: {Players: boolean, Npcs: boolean}, Visible: {Params: RaycastParams?} | boolean}): { Data: {Entity: Model, Player: Player?, Health: number, MaxHealth: number, Humanoid: Humanoid, Root: BasePart, Type: string}, Distance: number, Entity: Model? }
    Data = Data or {}
    local Entities = GetEntities()
    local Entity = {
        Entity = nil,
        Distance = math.huge,
        Data = {}
    }

    if not Data.Targets then
        Data.Targets = {
            Players = true,
            Npcs = true
        }
    end

    for i,v in Entities do
        if Bloomware:IsAlive(LocalPlayer) and (Data.TeamCheck and v.Entity:GetAttribute("Team") ~= LocalPlayer.Character:GetAttribute("Team") or not Data.TeamCheck) then
            if Bloomware:IsAlive(v.Entity, true) and ((Data.Targets.Players and v.Player) or (Data.Targets.Npcs and not v.Player)) then
                if Data.Visible then
                    if typeof(Data.Visible) == "boolean" then
                        Data.Visible = {}
                    end

                    if not Data.Visible.Params then
                        local RaycastParams: RaycastParams = RaycastParams.new()
                        RaycastParams.IgnoreWater = true
                        RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
                        RaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("entity")
                        Data.Visible.Params = RaycastParams
                    end
                    
                    if not IsPathClear(v.Entity, v.Root, Data.Visible.Params) then
                        continue
                    end
                end

                local Distance: number = Bloomware:GetDistanceFrom(LocalPlayer.Character.PrimaryPart.Position, v.Root.Position)
                local Angle: number = GetAngle(LocalPlayer.Character.PrimaryPart.CFrame, v.Root.Position)

                if Data.MaxRange and Distance > Data.MaxRange then
                    continue
                end

                if Data.MaxAngle and Angle > (Data.MaxAngle / 2 * math.pi / 180) then
                    continue
                end

                v.Angle = Angle
                if Data.Mode == "Distance" or not Data.Mode then
                    if Entity.Distance >= Distance then
                        Entity = {
                            Entity = v.Entity,
                            Distance = Distance,
                            Data = v
                        }
                    end
                elseif Data.Mode == "Lowest Health" then
                    if (Entity.Data.Health and Entity.Data.Health >= v.Health) or not Entity.Data.Health then
                        Entity = {
                            Entity = v.Entity,
                            Distance = Distance,
                            Data = v
                        }
                    end
                elseif Data.Mode == "Highest Health" then
                    if (Entity.Data.Health and Entity.Data.Health <= v.Health) or not Entity.Data.Health then
                        Entity = {
                            Entity = v.Entity,
                            Distance = Distance,
                            Data = v
                        }
                    end
                elseif Data.Mode == "Angle" then
                    if (Entity.Data.Angle and Entity.Data.Angle >= Angle) or not Entity.Data.Angle then
                        Entity = {
                            Entity = v.Entity,
                            Distance = Distance,
                            Data = v
                        }
                    end
                end
            end
        end
    end

    return Entity
end

local function GetNearestTaggedItem(Tag: string, Ignore: {Part}?): { Distance: number, Id: number?, Item: Instance }
    local Data = {
        Item = nil,
        Distance = math.huge,
        Id = nil
    }

    for i, v: Part in CollectionService:GetTagged(Tag) do
        if Bloomware:IsAlive(LocalPlayer) and (Ignore and not table.find(Ignore, v) or not Ignore) then
            local Position = (v:IsA("Model") and v.PrimaryPart and v.PrimaryPart.Position or v.Position)
            local Distance: number = Bloomware:GetDistanceFrom(LocalPlayer.Character.PrimaryPart.Position, Position)
            if Data.Distance > Distance then
                Data = {
                    Item = v,
                    Distance = Distance,
                    Id = (v:GetAttribute("TreeOrbSecret") or v:GetAttribute("BeeId") or v:GetAttribute("GrimReaperSoulSecret") or v:GetAttribute("Id"))
                }
            end
        end
    end

    return Data
end

local function GetViewModel(): Model?
    return GameData.Utils.ViewmodelController:getViewModel()
end

local function GetSpeedMultiplier(): number
    local Multiplier: number = 0
    for i,v in GameData.Utils.Sprint:getMovementStatusModifier().modifiers do
        if typeof(i) == "table" and i.moveSpeedMultiplier and v then
            Multiplier += (i.moveSpeedMultiplier - 0.05)
        end
    end
    return Multiplier
end

local function MakeClone(): { Clone: BasePart, Destroy: () -> (), PrimaryPart: BasePart }
    if Bloomware:IsAlive(LocalPlayer) then
        local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart

        local Clone = PrimaryPart:Clone()
        Clone.CanCollide = false
        Clone.CFrame = PrimaryPart.CFrame
        Clone.Parent = LocalPlayer.Character

        LocalPlayer.Character.PrimaryPart = Clone
        for i, v in LocalPlayer.Character:GetDescendants() do
            if v:IsA("Weld") or v:IsA("Motor6D") then
                if v.Part0 == PrimaryPart then 
                    v.Part0 = Clone 
                end

                if v.Part1 == PrimaryPart then 
                    v.Part1 = Clone 
                end
            end
        end

        return {
            Clone = Clone,
            PrimaryPart = PrimaryPart,
            Destroy = function()
                LocalPlayer.Character.PrimaryPart = PrimaryPart
                for _, v in LocalPlayer.Character:GetDescendants() do
                    if v:IsA("Weld") or v:IsA("Motor6D") then
                        if v.Part0 == Clone then 
                            v.Part0 = PrimaryPart 
                        end

                        if v.Part1 == Clone then 
                            v.Part1 = PrimaryPart 
                        end
                    end
                end

                Clone:Destroy()
            end
        }
    end

    return false
end

local function GetBlocksAroundPoint(StartPos: Vector3, Exclude: {})
    local Store = GameData.Utils.BlockEngine:getStore()
    local Blocks = {}
    for i,v in Enum.NormalId:GetEnumItems() do
        if v == Enum.NormalId.Bottom then
            continue
        end

        Blocks[v.Name] = {}
        for i2 = 0, 100 do
            local OrginalPosition = StartPos + (Vector3.fromNormalId(v) * i2)
            local Position = GameData.Utils.BlockEngine:getBlockPosition(OrginalPosition)
            local Position2 = GameData.Utils.BlockEngine:getBlockPosition(OrginalPosition + Vector3.new(0, 3, 0))

            local Block = Store:getBlockAt(Position)
            local Block2 = Store:getBlockAt(Position2)
            local BlockExists: boolean = false
            for i,v in Blocks do
                if v.Block == Block then
                    BlockExists = true
                end
            end

            if Block then
                if not BlockExists and (Exclude and not table.find(Exclude, Block) or not Exclude) then
                    table.insert(Blocks[v.Name], {
                        Block = Block,
                        OrginalPosition = OrginalPosition,
                        BlockPosition = Position,
                        HitNormal = v
                    })

                    if not Block2 then
                        break
                    end
                end
            else
                break
            end
        end
    end

    return Blocks
end

local function FindWeakestSide(Bed: Part)
    local BlocksA, BlocksB = GetBlocksAroundPoint(Bed.Position, {}), GetBlocksAroundPoint(Bed.Position + Vector3.new(0, 0, 3), {})
    local BlockASides, BlockBSides = {}, {}
    local Health, Side, ActualSide = math.huge, {}, {}

    for i, v in BlocksA do
        BlockASides[i] = 0
        for i2, v2 in v do
            if not v2.Block:GetAttribute("NoBreak") and not v2.Block:GetAttribute("Team"..tostring(GetPlayersTeam(LocalPlayer).."NoBreak")) and v2.Block ~= Bed then
                local BlockData = GameData.Utils.BlockEngine:getStore():getBlockData(v2.BlockPosition)
                local BlockHealth = BlockData and BlockData:GetAttribute(GameData.Utils.BlockEngine:getDefaultHealthKey())
                if not BlockData or not BlockHealth then
                    BlockHealth = v2.Block:GetAttribute("Health")
                end

                BlockASides[i] += BlockHealth
            end
        end
    end

    for i, v in BlocksB do
        BlockBSides[i] = 0
        for i2, v2 in v do
            if not v2.Block:GetAttribute("NoBreak") and not v2.Block:GetAttribute("Team"..tostring(GetPlayersTeam(LocalPlayer).."NoBreak")) and v2.Block ~= Bed then
                local BlockData = GameData.Utils.BlockEngine:getStore():getBlockData(v2.BlockPosition)
                local BlockHealth = BlockData and BlockData:GetAttribute(GameData.Utils.BlockEngine:getDefaultHealthKey())
                if not BlockData or not BlockHealth then
                    BlockHealth = v2.Block:GetAttribute("Health")
                end

                BlockBSides[i] += BlockHealth
            end
        end
    end

    for i,v in BlockASides do
        if Health > v then
            Health, Side, ActualSide = v, BlocksA, BlocksA[i]
        end
    end

    for i,v in BlockBSides do
        if Health > v then
            Health, Side, ActualSide = v, BlocksB, BlocksB[i]
        end
    end

    return ActualSide, Side, Health
end

local function GetNearestBed(IgnoreTeam: boolean?, IgnoreCanBreak: boolean?, CheckBed: boolean?): { Bed: Part, Distance: any }
    local PlayerTeamId: number = GetPlayersTeam(LocalPlayer)
    local Data = {
        Bed = nil,
        Distance = math.huge
    }

    for i,v: Part in CollectionService:GetTagged("bed") do
        local TeamId = v:GetAttribute("TeamId")
        if (TeamId and TeamId ~= PlayerTeamId or not TeamId or IgnoreTeam) and (not v:GetAttribute("Team"..tostring(PlayerTeamId).."NoBreak") or IgnoreCanBreak) and Bloomware:IsAlive(LocalPlayer) then
            if not CheckBed then
                local Distance = Bloomware:GetDistanceFrom(LocalPlayer.Character.PrimaryPart.Position, v.Position)
                if Data.Distance > Distance then
                    Data = {
                        Bed = v,
                        Distance = Distance
                    }
                end
                return Data
            else
                return true
            end
        end
    end

    return false
end

local function GetNearestChest(Ignore: {Instance})
    local Data = {
        Chest = nil,
        Distance = math.huge
    }

    for i,v in CollectionService:GetTagged("chest") do
        if not table.find(Ignore, v) and v:FindFirstChild("ChestFolderValue") and v.ChestFolderValue.Value and Bloomware:IsAlive(LocalPlayer) then
            local Distance = Bloomware:GetDistanceFrom(LocalPlayer.Character.PrimaryPart.Position, v.Position)
            if Data.Distance > Distance then
                Data = {
                    Chest = v,
                    Distance = Distance,
                    ChestFolder = v.ChestFolderValue.Value
                }
            end
        end
    end

    return Data
end

local function DamageBlock(Block: Instance, Hit: Enum.NormalId)
    local Position: Vector3 = GameData.Utils.BlockEngine:getBlockPosition(Block.Position)
    if Position then
        local Result, Response: string = GameData.Utils.BlockRemotes:Get("DamageBlock"):CallServerAsync({
            blockRef = {blockPosition = Position},
            hitPosition = Position,
            hitNormal = Vector3.fromNormalId(Hit)
        }):awaitStatus()

        if Response == "damaged" then
            local BlockData = GameData.Utils.BlockEngine:getStore():getBlockData(Block.Position)
            local BlockHealth: number = BlockData and BlockData:GetAttribute(GameData.Utils.BlockEngine:getDefaultHealthKey())
            if not BlockData or not BlockHealth and Block then
                BlockHealth = Block:GetAttribute("Health")
            end

            if BlockHealth then
                local MaxHealth: number = Block:GetAttribute("MaxHealth")
                if MaxHealth then
                    GameData.Utils.BlockBreaker:updateHealthbar({blockPosition = Position}, BlockHealth, MaxHealth, 2, Block)
                end
            end
        end

        return Response, Result
    end
    return
end

local function Aim(Start: Vector3, LaunchVel: number, Gravity: number?, TargetPos: Vector3, TargetVel: Vector3, HipHeight: number?): Vector3?
    if not (Start and TargetPos and LaunchVel > 1) then return end

    Gravity = Gravity or workspace.Gravity
    HipHeight = HipHeight or 0
    TargetPos = TargetPos + Vector3.new(0, HipHeight, 0)

    local Dist = TargetPos - Start
    local Vec = Vector3.new(Dist.X, 0, Dist.Z)
    local Mag = Vec.Magnitude
    local Time = Mag / LaunchVel

    local LastTime = 0
    local Iter = 0

    while math.abs(Time - LastTime) > 0.001 and Iter < 8 do
        Iter += 1
        LastTime = Time

        local DampFactor = math.clamp(0.4 + (100 / LaunchVel) * 0.1, 0.35, 0.55)
        local Velocity = Vector3.new(TargetVel.X, TargetVel.Y * DampFactor, TargetVel.Z)

        local Prediction = TargetPos + Velocity * Time
        local Dist2 = Prediction - Start
        local Horiz = Vector3.new(Dist2.X, 0, Dist2.Z)
        local HorizMag = Horiz.Magnitude

        local TimeNew = HorizMag / LaunchVel
        TimeNew = TimeNew + math.abs((Dist2.Y + 0.5 * Gravity * Time^2) / LaunchVel)

        Time = (Time + TimeNew) * 0.5
    end

    Time += ((Stats and Stats.Ping:GetValue() / 1000) or 0.1)

    local Factor = math.clamp(0.42 + (100 / LaunchVel) * 0.1, 0.38, 0.5)
    local FinalPrediction = TargetPos + Vector3.new(TargetVel.X, TargetVel.Y * Factor, TargetVel.Z) * Time

    local DropFactor = math.clamp(0.22 + (80 / LaunchVel) * 0.06 + (Mag / 2000), 0.25, 0.38)
    FinalPrediction -= Vector3.new(0, (DropFactor * Gravity * Time * Time) - 2.2, 0)

    return FinalPrediction
end

Windows.Combat.Modules.UniversalAimbot:Destroy()
Windows.Combat.Modules.UniversalHitboxes:Destroy()
Windows.Movement.Modules.UniversalDesync:Destroy()
Windows.Movement.Modules.UniversalSpeed:Destroy()
Windows.Movement.Modules.UniversalFly:Destroy()
Windows.Movement.Modules.UniversalMouseTP:Destroy()
Windows.Movement.Modules.UniversalWallClimb:Destroy()
Windows.Movement.Modules.UniversalNoClip:Destroy()
Windows.Render.Modules.TargetHUD:Destroy()
Windows.Utility.Modules.UniversalAntiAFK:Destroy();

(function()
    local SpeedData = {
        Settings = {
            Speed = 23,
            PulseDelay = 0,
            PulseTime = 2,
            DamageBoostSpeed = 50,
            DamageBoostTime = 1,
            DamageBoostCooldown = 0.8,
            Mode = "Velocity",
            AutoJump = false,
            Pulse = false,
            UseBoost = false,
            DamageBoost = false
        },
        Data = {
            LastGroundTouch = os.clock(),
            LastDamaged = os.clock()
        }
    }

    local Speed = Windows.Movement:CreateModule({
        Name = "Speed",
        Flag = "Speed",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(GameData.Events.Damage.Event:Connect(function(Values)
                    if Values.Type.Value ~= "FALL" and Values.DamagedPlayer == LocalPlayer then
                        if SpeedData.Settings.DamageBoostCooldown < (os.clock() - SpeedData.Data.LastDamaged) then
                            SpeedData.Data.LastDamaged = os.clock()      
                        end                  
                    end
                end))

                self:Connection(RunService.PreRender:Connect(function(delta: number)
                    local Fly = Windows.Movement.Modules.Fly
                    local LongJump = Windows.Movement.Modules.LongJump
                    if Bloomware:IsAlive(LocalPlayer) and (Fly and not Fly.Enabled or not Fly) and (LongJump and not LongJump.Enabled or not LongJump) and isnetworkowner(LocalPlayer.Character.PrimaryPart) then
                        local Root: BasePart = LocalPlayer.Character.PrimaryPart
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid

                        if Humanoid.MoveDirection.Magnitude > 0 then
                            if SpeedData.Settings.AutoJump then
                                if Humanoid.FloorMaterial ~= Enum.Material.Air then
                                    if (os.clock() - SpeedData.Data.LastGroundTouch) >= SpeedData.Settings.JumpDelay then
                                        SpeedData.Data.LastGroundTouch = os.clock()
                                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                end
                            end

                            local IndexVal: number = 1
                            if SpeedData.Settings.Pulse then
                                IndexVal = (SpeedData.Settings.PulseTime * 80)
                                if 0 >= IndexVal then
                                    IndexVal = 1
                                end
                            end

                            local Speed: number = SpeedData.Settings.Speed
                            for i = 1, IndexVal do
                                if not self.Enabled then
                                    break
                                end

                                if SpeedData.Settings.DamageBoost and SpeedData.Settings.DamageBoostTime > (os.clock() - SpeedData.Data.LastDamaged) then
                                    Speed = SpeedData.Settings.DamageBoostSpeed
                                end

                                local NewSpeed: number = Speed
                                local CurrentVelocity: Vector3 = Root.AssemblyLinearVelocity
                                if SpeedData.Settings.UseBoost then
                                    local Multiplier: number = GetSpeedMultiplier()
                                    if Multiplier ~= 0 then
                                        NewSpeed = math.clamp(Speed * Multiplier, 0, 46)
                                    end 
                                end
                                
                                Root.CFrame += Humanoid.MoveDirection * math.clamp(Speed - 22, 0, math.huge) * delta
                                Root.AssemblyLinearVelocity = Vector3.new(Humanoid.MoveDirection.X * NewSpeed, CurrentVelocity.Y, Humanoid.MoveDirection.Z * NewSpeed)
                                if SpeedData.Settings.Pulse then
                                    task.wait(0.01)
                                end
                            end

                            if SpeedData.Settings.Pulse then
                                task.wait(SpeedData.Settings.PulseDelay)
                            end
                        end
                    end
                end))
            end
        end
    })

    Speed:Slider({
        Name = "Speed",
        Flag = "SpeedValue",
        Default = 23,
        Min = 0,
        Max = 23,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.Speed = value
        end
    })

    local DamageBoostSpeed = Speed:Slider({
        Name = "Damage Boost Speed",
        Flag = "DamageSpeedValue",
        Default = 35,
        Min = 0,
        Max = 60,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.DamageBoostSpeed = value
        end
    })

    local DamageBoostTime = Speed:Slider({
        Name = "Damage Boost Time",
        Flag = "DamageBoostTimeValue",
        Default = 2,
        Min = 0.1,
        Max = 2,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.DamageBoostTime = value
        end
    })

    local DamageBoostDelay = Speed:Slider({
        Name = "Damage Boost Delay",
        Flag = "DamageBoostDelayValue",
        Default = 0.8,
        Min = 0.1,
        Max = 2,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.DamageBoostCooldown = value
        end
    })

    local PulseDelay = Speed:Slider({
        Name = "Pulse Delay",
        Flag = "SpeedPulseDelay",
        Default = 1.5,
        Min = 1,
        Max = 5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.PulseDelay = value
        end
    })

    local PulseTime = Speed:Slider({
        Name = "Pulse Time",
        Flag = "SpeedPulseTime",
        Default = 1,
        Min = 0.5,
        Max = 2.5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.PulseTime = value
        end
    })

    local JumpDelay = Speed:Slider({
        Name = "Jump Delay",
        Flag = "SpeedAutoJumpDelay",
        Default = 0,
        Min = 0,
        Max = 5,
        CallingFunction = function(self, value: number)
            SpeedData.Settings.JumpDelay = value
        end
    })

    Speed:MiniToggle({
        Name = "Consumable Boost",
        Flag = "SpeedConsumableBoost",
        Default = true,
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.UseBoost = value
        end
    })
    
    Speed:MiniToggle({
        Name = "Daamge Boost",
        Flag = "SpeedDamageBoost",
        Default = true,
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.DamageBoost = value
            DamageBoostSpeed:SetVisiblity(value)
            DamageBoostTime:SetVisiblity(value)
            DamageBoostDelay:SetVisiblity(value)
        end
    })
    
    Speed:MiniToggle({
        Name = "Auto Jump",
        Flag = "SpeedAutoJump",
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.AutoJump = value
            JumpDelay:SetVisiblity(value)
        end
    })

    Speed:MiniToggle({
        Name = "Pulse",
        Flag = "PusleSpeed",
        CallingFunction = function(self, value: boolean)
            SpeedData.Settings.Pulse = value

            PulseDelay:SetVisiblity(value)
            PulseTime:SetVisiblity(value)
        end
    })
end)();

(function()
    local FlyData = {
        Settings = {
            Speed = 50,
            VerticalSpeed = 80,
            PulseDelay = 2,
            PulseTime = 2,
            Pulse = false,
            TpDown = false,
            UseBoost = false,
            UseFlyBar = false,
            DisableWhenOutOfTime = false
        },
        Data = {
            Vertical = 0,
            LastBoosted = os.clock(),
            LastOnGround = os.clock(),
            Params = RaycastParams.new(),
            FlyBar = nil
        }
    }

    FlyData.Data.Params.FilterType = Enum.RaycastFilterType.Include
    FlyData.Data.Params.FilterDescendantsInstances = BlockList

    local Fly = Windows.Movement:CreateModule({
        Name = "Fly",
        Flag = "Fly",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if Bloomware.Mobile then
                    local TouchGui: ScreenGui = PlayerGui:FindFirstChild("TouchGui")
                    local TouchControl: Frame = TouchGui and TouchGui:FindFirstChild("TouchControlFrame")
                    local JumpButton: ImageButton = TouchControl and TouchControl:FindFirstChild("JumpButton")
                    if JumpButton then
                        self:Connection(JumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
                            FlyData.Settings.VerticalValue = JumpButton.ImageRectOffset.X == 146 and 1 or 0
                        end))
                    end
                end

                FlyData.Data.LastOnGround = os.clock()
                if FlyData.Settings.UseFlyBar then
                    FlyData.Data.FlyBar = Bloomware:Countdown(2.5)
                end

                self:Connection(RunService.PreRender:Connect(function(delta: number)
                    if Bloomware:IsAlive(LocalPlayer) and isnetworkowner(LocalPlayer.Character.PrimaryPart) then
                        local Root: BasePart = LocalPlayer.Character.PrimaryPart
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid

                        if Humanoid.FloorMaterial ~= Enum.Material.Air then
                            FlyData.Data.LastOnGround = os.clock()
                        end

                        local IndexVal: number = 1
                        if FlyData.Settings.Pulse then
                            IndexVal = (FlyData.Settings.PulseTime * 60)
                            if 0 >= IndexVal then
                                IndexVal = 1
                            end
                        end

                        for i = 1, IndexVal do
                            local YValue: number = 0
                            local Speed: number = FlyData.Settings.Speed
                            local CurrentVelocity: Vector3 = Root.AssemblyLinearVelocity
                            local SpeedVelocity: Vector3 = CurrentVelocity

                            if FlyData.Data.Vertical ~= 0 then
                                if FlyData.Data.Vertical == 1 then
                                    YValue = FlyData.Settings.VerticalSpeed
                                elseif FlyData.Data.Vertical == -1 then
                                    YValue = -FlyData.Settings.VerticalSpeed
                                end
                            end

                            local NewSpeed: number = Speed
                            if ((os.clock() - FlyData.Data.LastBoosted) >= FlyData.Settings.PulseDelay or not FlyData.Settings.Pulse) then
                                if FlyData.Settings.UseBoost then
                                    local Multiplier: number = GetSpeedMultiplier()
                                    if Multiplier ~= 0 then
                                        NewSpeed = math.clamp(Speed * Multiplier, 0, 46)
                                    end 
                                end
                            end

                            if Humanoid.MoveDirection.Magnitude > 0 then
                                SpeedVelocity = Vector3.new(Humanoid.MoveDirection.X * NewSpeed, 0, Humanoid.MoveDirection.Z * NewSpeed) 
                            end

                            Root.CFrame += Humanoid.MoveDirection * math.clamp(Speed - 22, 0, math.huge) * delta
                            Root.AssemblyLinearVelocity = Vector3.new(
                                SpeedVelocity.X,
                                YValue + (CurrentVelocity.Y > 0 and 1 or -CurrentVelocity.Y),
                                SpeedVelocity.Z
                            )

                            if (os.clock() - FlyData.Data.LastOnGround) >= 2.3 and FlyData.Settings.TpDown then
                                local Ray: RaycastResult = workspace:Raycast(Root.Position, Vector3.new(0, -1000, 0), FlyData.Data.Params)
                                if Ray then
                                    local OldCFrame: CFrame = Root.CFrame
                                    Root.CFrame = CFrame.new(Ray.Position + Vector3.new(0, 2, 0))
                                    task.delay(0.1, function()
                                        Root.CFrame = OldCFrame
                                    end)
                                else
                                    if FlyData.Settings.DisableWhenOutOfTime and (os.clock() - FlyData.Data.LastOnGround) >= 2.5 then
                                        self:SetValue(false)
                                        break
                                    end
                                end
                            else
                                if FlyData.Settings.DisableWhenOutOfTime and (os.clock() - FlyData.Data.LastOnGround) >= 2.5 then
                                    self:SetValue(false)
                                    break
                                end
                            end 
                            
                            if FlyData.Data.FlyBar then
                                FlyData.Data.FlyBar:Update(string.format("%.1f", (FlyData.Data.LastOnGround + 2.5) - os.clock()))
                            end
                        end

                        if (os.clock() - FlyData.Data.LastBoosted) >= FlyData.Settings.PulseDelay then
                            FlyData.Data.LastBoosted = os.clock()
                        end
                    end
                end))
            else
                if FlyData.Data.FlyBar then
                    FlyData.Data.FlyBar:Destroy()
                    FlyData.Data.FlyBar = nil
                end
            end
        end
    })

    Fly.Functions:KeyBind({
        Name = "Fly Up",
        MobileText = "Fly Up",
        Flag = "FlyUpKeybind",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.KeyCode.Space,
        Events = {
            Began = function()
                FlyData.Data.Vertical = 1
            end,
            Ended = function()
                FlyData.Data.Vertical = 0
            end
        }
    })

    Fly.Functions:KeyBind({
        Name = "Fly Down",
        MobileText = "Fly Down",
        Flag = "FlyDownKeybind",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.KeyCode.LeftShift,
        Events = {
            Began = function()
                FlyData.Data.Vertical = -1
            end,
            Ended = function()
                FlyData.Data.Vertical = 0
            end
        }
    })

    Fly:Slider({
        Name = "Speed",
        Flag = "FlySpeed",
        Default = 23,
        Min = 0,
        Max = 23,
        CallingFunction = function(self, value: number)
            FlyData.Settings.Speed = value
        end
    })

    Fly:Slider({
        Name = "Vertical Speed",
        Flag = "FlyVerticalSpeed",
        Default = 70,
        Min = 0,
        Max = 130,
        CallingFunction = function(self, value: number)
            FlyData.Settings.VerticalSpeed = value
        end
    })

    local FlyPulseDelay = Fly:Slider({
        Name = "Pulse Delay",
        Flag = "FlySpeedPulseDelay",
        Default = 1.5,
        Min = 1,
        Max = 5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            FlyData.Settings.PulseDelay = value
        end
    })

    local FlyPulseTime = Fly:Slider({
        Name = "Pulse Time",
        Flag = "FlySpeedPulseTime",
        Default = 1,
        Min = 0.5,
        Max = 2.5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            FlyData.Settings.PulseTime = value
        end
    })

    Fly:MiniToggle({
        Name = "Time Bar",
        Flag = "FlyTimeBar",
        Default = true,
        CallingFunction = function(self, value: boolean)
            FlyData.Settings.UseFlyBar = value
            if not value then
                if FlyData.Data.FlyBar then
                    FlyData.Data.FlyBar:Destroy()
                    FlyData.Data.FlyBar = nil
                end
            else
                if Fly.Enabled and not FlyData.Data.FlyBar then
                    FlyData.Data.FlyBar = Bloomware:Countdown(2)
                end
            end
        end
    })

    Fly:MiniToggle({
        Name = "Time Limit",
        Flag = "FlyTimeLimit",
        CallingFunction = function(self, value: boolean)
            FlyData.Settings.DisableWhenOutOfTime = value
        end
    })

    Fly:MiniToggle({
        Name = "TP Down",
        Flag = "FlyTPDown",
        Default = true,
        CallingFunction = function(self, value: boolean)
            FlyData.Settings.TpDown = value
        end
    })

    Fly:MiniToggle({
        Name = "Consumable Boost",
        Flag = "FlyConsumableBoost",
        Default = true,
        CallingFunction = function(self, value: boolean)
            FlyData.Settings.UseBoost = value
        end
    })

    Fly:MiniToggle({
        Name = "Pulse",
        Flag = "FlySpeedPulse",
        CallingFunction = function(self, value: boolean)
            FlyData.Settings.Pulse = value

            FlyPulseDelay:SetVisiblity(value)
            FlyPulseTime:SetVisiblity(value)
        end
    })
end)();

local CanFastHit = false
(function()
    local KillAuraData = {
        Settings = {
            Range = 20,
            SwingRange = 25,
            Delay = 0,
            Hitreg = 36,
            DynamicHits = false,
            SyncHitTime = false,
            ContinueSwinging = 1,
            AnimationRestoreTime = 0.5,
            MaxAngle = 360,
            MaxTargets = 5,
            AttackMode = "Switch",
            AutoSwitch = false,
            NoSwing = false,
            HandCheck = false,
            WallCheck = false,
            AttackableCheck = false,
            UseAnimation = false,
            Cooldown = false,
            TriggerButton = false,
            CustomHitReg = false,
            HitsPerSecond = 50,
            AirHits = true,
            AirHitsChance = 100,
            Boxes = false,
            Particles = false,
            InfRange = false,
            AutoJump = false,
            FastHits = false,
            FastHitsLegit = false,
            FastHitsFireRate = 0.06,
            FastHitsProjectiles = {arrow = true, snowball = true},
            SelectedAnimation = "Bloomware",
            TargetMode = "Distance",
            BoxColor = Color3.fromRGB(255, 0, 0),
            ParticleColor = Color3.fromRGB(255, 0, 0),
            BoxTransparency = 0.5,
            ParticleRate = 40,
            ParticleLifeTime = 2,
            Targets = {
                Players = true,
                Npcs = true
            },
            Priority = "Players"
        },
        Data = {
            OldPlayAnimationViewModel = nil,
            AnimationPlaying = false,
            PlayerDamaged = false,
            OriginalHandPos = nil,
            TimesRanOnCooldown = 0,
            TriggerHeld = false,
            LastSetTarget = false,
            Params = RaycastParams.new(),
            LastHit = 0,
            LastCustomHit = 0,
            LastSwing = -20,
            LastPacket = 0,
            LastFastHit = 0,
            FastHitIndex = 0,
            FastHitDelays = {},
            SwitchIndex = 1,
            SwitchAt = 0,
            Effects = {
                Boxes = {},
                Particles = {}
            }
        },
        Animations = {
            Bloomware = {
                {Position = CFrame.new(0.7, -0.7, 0.65), Angle = CFrame.Angles(math.rad(-70), math.rad(60), math.rad(-70)), Duration = 0.15},
                {Position = CFrame.new(0.5, -0.7, -0.3), Angle = CFrame.Angles(math.rad(-120), math.rad(70), math.rad(-50)), Duration = 0.15}
            },
            Smooth = {
                {Position = CFrame.new(-0.01, -0.3, -1.01), Angle = CFrame.Angles(math.rad(-35), math.rad(90), math.rad(-90)), Duration = 0.45},
                {Position = CFrame.new(-0.01, -0.3, -1.01), Angle = CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Duration = 0.45},
                {Position = CFrame.new(-0.01, -0.3, 0.4), Angle = CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Duration = 0.32},
            },
            Funny = {
                {Position = CFrame.new(0.8, 10.7, 3.6), Angle = CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Duration = 0.1},
                {Position = CFrame.new(5.7, -1.7, 5.6), Angle = CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Duration = 0.15},
                {Position = CFrame.new(2.95, -5.06, -6.25), Angle = CFrame.Angles(math.rad(-180), math.rad(60), math.rad(-80)), Duration = 0.15},
            },
            Stand = {
                {Position = CFrame.new(0.7, -0.7, 0.6), Angle = CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Duration = 0.1}
            },
            Air = {
                {Position = CFrame.new(1.2, -1.5, -1), Angle = CFrame.Angles(math.rad(305), math.rad(55), math.rad(140)), Duration = 0.2},
                {Position = CFrame.new(1.2, -1.5, -1.2), Angle = CFrame.Angles(math.rad(200), math.rad(55), math.rad(230)), Duration = 0.15},
            },
            Hit = {
                {Position = CFrame.new(0, 0, -0.7), Angle = CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-60)), Duration = 0.12},
                {Position = CFrame.new(0, -0.35, -0.7), Angle = CFrame.Angles(math.rad(-150), math.rad(60), math.rad(15)), Duration = 0.2},
            },
            Rise = {
                {Position = CFrame.new(1, 0, 0), Angle = CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-80)), Duration = 0.15},
                {Position = CFrame.new(1, 0, -0.4), Angle = CFrame.Angles(math.rad(-80), math.rad(40), math.rad(-70)), Duration = 0.17},
            },
            Moon = {
                {Position = CFrame.new(0.85, -0.8, 0.6), Angle = CFrame.Angles(math.rad(-40), math.rad(70), math.rad(-90)), Duration = 0.15},
                {Position = CFrame.new(0.5, -0.6, 0.6), Angle = CFrame.Angles(math.rad(-50), math.rad(50), math.rad(-100)), Duration = 0.12},
            },
            Lunar = {
                {Position = CFrame.new(0.3, 0, -1.5), Angle = CFrame.Angles(math.rad(120), math.rad(120), math.rad(140)), Duration = 0.2},
                {Position = CFrame.new(0, -0.3, -1.7), Angle = CFrame.Angles(math.rad(30), math.rad(120), math.rad(190)), Duration = 0.2},
            }
        }
    }

    local function CanHitWithCustomReg(): boolean
        if not KillAuraData.Settings.CustomHitReg then
            return true
        end

        if KillAuraData.Settings.HitsPerSecond >= 36 then
            return true
        end

        local CurrentTime: number = tick()
        local DelayBetweenHits: number = 10 / math.max(KillAuraData.Settings.HitsPerSecond, 1)

        if CurrentTime - KillAuraData.Data.LastCustomHit >= DelayBetweenHits then
            KillAuraData.Data.LastCustomHit += DelayBetweenHits
            if CurrentTime - KillAuraData.Data.LastCustomHit > DelayBetweenHits then
                KillAuraData.Data.LastCustomHit = CurrentTime
            end
            return true
        end

        return false
    end

    local function UpdateFastHitProjectiles(value: string)
        table.clear(KillAuraData.Settings.FastHitsProjectiles)

        for _, Name in value:split(",") do
            Name = Name:lower():gsub("^%s+", ""):gsub("%s+$", "")
            if Name ~= "" then
                KillAuraData.Settings.FastHitsProjectiles[Name] = true
            end
        end
    end

    local function GetFastHitAmmo(source)
        if not source.ammoItemTypes then return nil end

        local Inventory = GetInventory()
        local Items = Inventory and Inventory.items or {}
        for _, AmmoType in source.ammoItemTypes do
            for _, Item in Items do
                if Item.itemType == AmmoType then
                    return AmmoType
                end
            end
        end

        return nil
    end

    local function GetFastHitProjectiles()
        local Projectiles = {}
        local Inventory = GetInventory()
        local Items = Inventory and Inventory.items or {}

        for _, Item in Items do
            local Meta = GameData.Utils.ItemMeta[Item.itemType]
            local Source = Meta and Meta.projectileSource
            local Ammo = Source and GetFastHitAmmo(Source)

            if Ammo and KillAuraData.Settings.FastHitsProjectiles[Ammo] then
                Projectiles[#Projectiles + 1] = {
                    Item = Item,
                    Ammo = Ammo,
                    Projectile = Source.projectileType(Ammo),
                    Source = Source
                }
            end
        end

        return Projectiles
    end

    local function TryFastHit(Target, SelfPos: Vector3, HitPosition: Vector3)
        if not KillAuraData.Settings.FastHits or tick() < KillAuraData.Data.LastFastHit then
            return
        end

        local Root = Target.Data.Root or Target.Entity.PrimaryPart
        local Humanoid = Target.Data.Humanoid or Target.Entity:FindFirstChildOfClass("Humanoid")
        if not Root or not Humanoid then return end

        local Map = workspace:FindFirstChild("Map")
        KillAuraData.Data.Params.FilterType = Enum.RaycastFilterType.Include
        KillAuraData.Data.Params.FilterDescendantsInstances = Map and {Map} or {}
        if not IsPathClear(Target.Entity, Root, KillAuraData.Data.Params) then
            return
        end

        local Projectiles = GetFastHitProjectiles()
        if #Projectiles == 0 then return end

        KillAuraData.Data.FastHitIndex += 1
        if not Projectiles[KillAuraData.Data.FastHitIndex] then
            KillAuraData.Data.FastHitIndex = 1
        end

        local Obj = Projectiles[KillAuraData.Data.FastHitIndex]
        if tick() < (KillAuraData.Data.FastHitDelays[Obj.Item.itemType] or 0) then
            return
        end

        local ProjMeta = GameData.Utils.ProjMeta[Obj.Projectile]
        if not ProjMeta then return end

        SwitchItem(Obj.Item.tool, 0)
        if KillAuraData.Settings.FastHitsLegit then
            task.wait(0.05)
        end

        local LaunchVelocity = ProjMeta.launchVelocity or 100
        local Gravity = ProjMeta.gravitationalAcceleration or 196.2
        local TargetVelocity = FlatVel(Root)
        local TargetPos = AimPos(Root, Humanoid)
        local Calc = SolveShot(SelfPos, LaunchVelocity, Gravity, TargetPos, TargetVelocity)
        if not Calc then return end

        local Direction = CFrame.lookAt(SelfPos, Calc).LookVector
        local Id = HttpService:GenerateGUID(true)
        local ShootPosition = CFrame.new(SelfPos, Calc).Position

        FireProjectileRemote(Obj.Item.tool, Obj.Ammo, Obj.Projectile, ShootPosition, HitPosition, Direction * LaunchVelocity, Id,
            {
                drawDurationSeconds = 1,
                drawDurationSec = 1,
                shotId = HttpService:GenerateGUID(false)
            },
            workspace:GetServerTimeNow() - 0.045
        )

        KillAuraData.Data.FastHitDelays[Obj.Item.itemType] = tick() + (Obj.Source.fireDelaySec or 0)
        KillAuraData.Data.LastFastHit = tick() + (LocalPlayer:GetNetworkPing() + KillAuraData.Settings.FastHitsFireRate)
    end

    local function IsInAir(Entity: Model): boolean
        local Humanoid: Humanoid? = Entity and Entity:FindFirstChildOfClass("Humanoid")
        if not Humanoid then
            return false
        end

        local State = Humanoid:GetState()
        return Humanoid.FloorMaterial == Enum.Material.Air or State == Enum.HumanoidStateType.Jumping or State == Enum.HumanoidStateType.Freefall or State == Enum.HumanoidStateType.Physics
    end

    local function CanAirHit(Entity: Model): boolean
        if not KillAuraData.Settings.AirHits or not IsInAir(Entity) then
            return true
        end

        return math.random(1, 100) <= KillAuraData.Settings.AirHitsChance
    end

    local function GetHitreg(Distance: number): number
        local Hitreg: number = KillAuraData.Settings.Hitreg + 1

        if KillAuraData.Settings.DynamicHits then
            local Limit: number = GameData.Utils.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE or 14.4
            local SafeRange: number = Hitreg < Limit and Hitreg or Limit
            local Window: number = KillAuraData.Settings.Range - SafeRange

            if Window < 1 then
                Window = 1
            end

            local Scale: number = (Distance - SafeRange) / Window

            if Scale < 0 then
                Scale = 0
            elseif Scale > 1 then
                Scale = 1
            end

            Hitreg = Hitreg + (SafeRange - Hitreg) * Scale
        end

        return Hitreg
    end

    local function CalculateAuraPosition(SelfPos: Vector3, TargetRoot: BasePart): Vector3
        local Ping: number = LocalPlayer:GetNetworkPing()
        local Velocity: Vector3 = TargetRoot.AssemblyLinearVelocity

        local Scale: number = Ping <= 0.03 and 0.03 or (Ping >= 0.4 and 0.4 or Ping)

        return Velocity * Scale
    end

    local function ResetAuraVisuals()
        KillAuraData.Data.AnimationPlaying = false

        for _, Group in KillAuraData.Data.Effects do
            for _, Object in Group do
                Object:Destroy()
            end

            table.clear(Group)
        end

        if KillAuraData.Data.OriginalHandPos then
            local ViewModel: Model = GetViewModel()
            local RightHand: MeshPart = ViewModel and ViewModel:FindFirstChild("RightHand")
            if ViewModel and RightHand then
                local RightWrist: Motor6D = RightHand:FindFirstChild("RightWrist")
                if RightWrist then
                    TweenService:Create(RightWrist, TweenInfo.new(KillAuraData.Settings.AnimationRestoreTime), {C0 = KillAuraData.Data.OriginalHandPos}):Play()
                end
            end
        end
    end

    local function RenderAuraTarget(Target)
        if KillAuraData.Settings.Boxes then
            coroutine.wrap(function()
                local Box: Part = KillAuraData.Data.Effects.Boxes[Target.Entity]
                if not Box then
                    Box = Instance.new("Part", Target.Entity)
                    Box.Size = Vector3.new(5, 6, 5)
                    Box.Material = Enum.Material.Air
                    Box.CanCollide = false
                    Box.Anchored = true

                    KillAuraData.Data.Effects.Boxes[Target.Entity] = Box
                end

                Box.CFrame = Target.Entity.PrimaryPart.CFrame
                Box.Transparency = KillAuraData.Settings.BoxTransparency
                Box.Color = KillAuraData.Settings.BoxColor
            end)()
        end

        if KillAuraData.Settings.Particles then
            coroutine.wrap(function()
                local Emitter: ParticleEmitter = KillAuraData.Data.Effects.Particles[Target.Entity]
                if not Emitter then
                    Emitter = Instance.new("ParticleEmitter", Target.Entity.PrimaryPart)
                    Emitter.EmissionDirection = Enum.NormalId.Front
                    Emitter.SpreadAngle = Vector2.new(1, 1)
                    Emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 2.5)})

                    KillAuraData.Data.Effects.Particles[Target.Entity] = Emitter
                end

                Emitter.Lifetime = NumberRange.new(KillAuraData.Settings.ParticleLifeTime, KillAuraData.Settings.ParticleLifeTime)
                Emitter.Rate = KillAuraData.Settings.ParticleRate
                Emitter.Color = ColorSequence.new(KillAuraData.Settings.ParticleColor)
            end)()
        end
    end

    local LastSwing: number = 0
    local function PlayAnim(Module)
        if not KillAuraData.Settings.NoSwing then
            if os.clock() - LastSwing >= 0.22 then
                LastSwing = os.clock()
                GameData.Utils.Animation:playAnimation(LocalPlayer, GameData.Utils.ProdAnimations[GameData.Utils.AnimationType.SWORD_SWING])
            end
        end

        if KillAuraData.Settings.UseAnimation then
            coroutine.wrap(function()
                local ViewModel: Model = GetViewModel()
                local RightHand: MeshPart = ViewModel and ViewModel:FindFirstChild("RightHand")
                local SelectedAnimation: {[string]: {Position: CFrame, Angle: CFrame, Duration: number}} = KillAuraData.Animations[KillAuraData.Settings.SelectedAnimation]

                if ViewModel and RightHand and SelectedAnimation and not KillAuraData.Data.AnimationPlaying then
                    local RightWrist: Motor6D = RightHand:FindFirstChild("RightWrist")
                    if RightWrist then
                        if not KillAuraData.Data.OriginalHandPos then
                            KillAuraData.Data.OriginalHandPos = RightWrist.C0
                        end

                        KillAuraData.Data.AnimationPlaying = true
                        for _, Step in SelectedAnimation do
                            local Tween: Tween = TweenService:Create(RightWrist, TweenInfo.new(Step.Duration), {C0 = KillAuraData.Data.OriginalHandPos * Step.Position * Step.Angle})
                            Tween:Play()
                            Tween.Completed:Wait()

                            if not Module.Enabled or not KillAuraData.Settings.UseAnimation then
                                break
                            end
                        end
                    end

                    KillAuraData.Data.AnimationPlaying = false
                end
            end)()
        elseif not KillAuraData.Settings.NoSwing then
            if os.clock() - LastSwing >= 0.22 then
                LastSwing = os.clock()
                GameData.Utils.ViewmodelController:playAnimation(GameData.Utils.AnimationType.FP_SWING_SWORD)
            end
        end
    end

    local function GetAuraTargets(MaxRange: number)
        local Found = {}
        local Character = LocalPlayer.Character
        local Root: BasePart? = Character and Character.PrimaryPart
        if not Root then
            return Found
        end

        local Params
        if KillAuraData.Settings.WallCheck then
            Params = RaycastParams.new()
            Params.IgnoreWater = true
            Params.FilterType = Enum.RaycastFilterType.Exclude
            Params.FilterDescendantsInstances = CollectionService:GetTagged("entity")
        end

        for _, Data in GetEntities() do
            if Data.Entity == Character then
                continue
            end

            if not Bloomware:IsAlive(Data.Entity, true) then
                continue
            end

            if Data.Entity:GetAttribute("Team") == Character:GetAttribute("Team") then
                continue
            end

            if (Data.Player and not KillAuraData.Settings.Targets.Players) or (not Data.Player and not KillAuraData.Settings.Targets.Npcs) then
                continue
            end

            if not Data.Root then
                continue
            end

            local Distance: number = Bloomware:GetDistanceFrom(Root.Position, Data.Root.Position)
            if Distance > MaxRange then
                continue
            end

            local Angle: number = GetAngle(Root.CFrame, Data.Root.Position)
            if Angle > (KillAuraData.Settings.MaxAngle / 2 * math.pi / 180) then
                continue
            end

            if Params and not IsPathClear(Data.Entity, Data.Root, Params) then
                continue
            end

            Found[#Found + 1] = {
                Entity = Data.Entity,
                Distance = Distance,
                Data = Data,
                Angle = Angle,
                Priority = (KillAuraData.Settings.Priority == "Players" and Data.Player) and 0 or ((KillAuraData.Settings.Priority == "NPCs" and not Data.Player) and 0 or 1)
            }
        end

        table.sort(Found, function(A, B)
            if A.Priority ~= B.Priority then
                return A.Priority < B.Priority
            end

            if KillAuraData.Settings.TargetMode == "Lowest Health" then
                return (A.Data.Health or math.huge) < (B.Data.Health or math.huge)
            elseif KillAuraData.Settings.TargetMode == "Highest Health" then
                return (A.Data.Health or 0) > (B.Data.Health or 0)
            elseif KillAuraData.Settings.TargetMode == "Angle" then
                return A.Angle < B.Angle
            end

            return A.Distance < B.Distance
        end)

        if KillAuraData.Settings.AttackMode == "Switch" and #Found > 1 then
            if tick() > KillAuraData.Data.SwitchAt then
                KillAuraData.Data.SwitchAt = tick() + 0.7
                KillAuraData.Data.SwitchIndex += 1
            end

            if not Found[KillAuraData.Data.SwitchIndex] then
                KillAuraData.Data.SwitchIndex = 1
            end

            return {Found[KillAuraData.Data.SwitchIndex]}
        end

        local Limit: number = KillAuraData.Settings.AttackMode == "Multi" and KillAuraData.Settings.MaxTargets or 1
        while #Found > Limit do
            table.remove(Found)
        end

        return Found
    end

    local KillAura = Windows.Combat:CreateModule({
        Name = "Kill Aura",
        Flag = "KillAura",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                coroutine.wrap(function()
                    repeat task.wait() until GameData.Utils.ViewmodelController and GameData.Utils.ViewmodelController.playAnimation
                    task.delay(0.1, function()
                        if not KillAuraData.Data.OldPlayAnimationViewModel then
                            KillAuraData.Data.OldPlayAnimationViewModel = GameData.Utils.ViewmodelController.playAnimation
                        end
                        
                        GameData.Utils.ViewmodelController.playAnimation = function(self, animation: number, ...)
                            if KillAuraData.Data.AnimationPlaying then
                                local Animation: string = GameData.Utils.AnimationType[animation]
                                if Animation and typeof(Animation) == "string" then
                                    if Animation:lower():find("swing_sword") then
                                        return
                                    end
                                end
                            end

                            return KillAuraData.Data.OldPlayAnimationViewModel(self, animation, ...)
                        end
                    end)
                end)()

                self:Connection(RunService.PreRender:Connect(function()
                    if KillAuraData.Settings.Delay > (os.clock() - KillAuraData.Data.LastHit) then
                        return
                    end

                    local Sword = GetSword()
                    if Sword.Item and GameData.Utils.Store:getState().Game.matchState == GameData.Utils.MatchStates.RUNNING and Bloomware:IsAlive(LocalPlayer) then                        
                        if KillAuraData.Settings.TriggerButton and not KillAuraData.Data.TriggerHeld then
                            task.wait()
                            return
                        end

                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid
                        local HandItem = GetInventory().hand
                        if KillAuraData.Settings.HandCheck then
                            if HandItem and HandItem.tool then
                                local Meta = GameData.Utils.ItemMeta[HandItem.itemType]
                                if not Meta or not Meta.sword then
                                    task.wait()
                                    return
                                end
                            else
                                task.wait()
                                return
                            end
                        end

                        if KillAuraData.Settings.AttackableCheck then
                            local StunnedUntil = LocalPlayer.Character:GetAttribute("StunnedUntilTime") or 0
                            if StunnedUntil > workspace:GetServerTimeNow() then
                                task.wait()
                                return
                            end
                        end

                        if KillAuraData.Settings.AutoSwitch and (not HandItem or HandItem and (not HandItem.tool or HandItem.tool ~= Sword.Item)) then
                            SwitchItem(Sword.Item, 0)
                        end

                        if KillAuraData.Settings.AutoJump and Humanoid.FloorMaterial ~= Enum.Material.Air and Humanoid.MoveDirection.Magnitude > 0 then
                            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end

                        local SwingRangeValue: number = math.max(KillAuraData.Settings.SwingRange, KillAuraData.Settings.Range)
                        local Targets = GetAuraTargets(SwingRangeValue)

                        if #Targets > 0 then
                            KillAuraData.Data.LastSetTarget = true
                            GameData.Data.KillAuraTargets = Targets
                            GameData.Data.Target = Targets[1]

                            local HasPlayedSwing = false
                            for Index, Target in Targets do
                                RenderAuraTarget(Target)
                                if not GameData.Data.Target then
                                    GameData.Data.Target = Target
                                end

                                if Target.Distance <= KillAuraData.Settings.Range then
                                    local TargetRoot: BasePart? = Target.Data.Root or Target.Entity.PrimaryPart
                                    if not TargetRoot then
                                        continue
                                    end

                                    if not CanAirHit(Target.Entity) then
                                        continue
                                    end

                                    local SelfPos: Vector3 = LocalPlayer.Character.PrimaryPart.Position
                                    local TargetPos: Vector3 = TargetRoot.Position + CalculateAuraPosition(SelfPos, TargetRoot)
                                    local Direction: Vector3 = CFrame.lookAt(SelfPos, TargetPos).LookVector
                                    local Distance: number = (TargetPos - SelfPos).Magnitude
                                    local Hitreg: number = GetHitreg(Distance)
                                    local HitPosition: Vector3 = SelfPos + Direction * math.max(Distance - Hitreg, 0)
                                    local SyncDelay: number = KillAuraData.Settings.SyncHitTime and math.max(36 - Hitreg, 0) / 36 or 0

                                    if tick() < KillAuraData.Data.LastPacket then
                                        continue
                                    end

                                    if not CanHitWithCustomReg() then
                                        continue
                                    end

                                    KillAuraData.Data.LastPacket = tick() + SyncDelay
                                    KillAuraData.Data.LastHit = os.clock()
                                    KillAuraData.Data.LastSwing = tick()
                                    GameData.Utils.SwordController.lastAttack = workspace:GetServerTimeNow()

                                    GameData.Utils.Remotes:Get("SwordHit"):SendToServer({
                                        entityInstance = Target.Entity,
                                        chargedAttack = {chargeRatio = 0},
                                        validate = {
                                            targetPosition = {value = TargetPos},
                                            raycast = {
                                                cursorDirection = {value = Direction},
                                                cameraPosition = {value = HitPosition}
                                            },
                                            selfPosition = {value = HitPosition}
                                        },
                                        weapon = Sword.Item
                                    })

                                    --TryFastHit(Target, SelfPos, HitPosition)

                                    if not HasPlayedSwing then
                                        HasPlayedSwing = true
                                        PlayAnim(self)
                                    end
                                end
                            end
                        elseif KillAuraData.Settings.ContinueSwinging > 0 and (tick() - KillAuraData.Data.LastSwing) <= KillAuraData.Settings.ContinueSwinging then
                            PlayAnim(self)
                        else
                            if KillAuraData.Data.LastSetTarget then
                                GameData.Data.Target = nil
                                KillAuraData.Data.LastSetTarget = false
                            end

                            table.clear(GameData.Data.KillAuraTargets)
                            ResetAuraVisuals()
                        end
                    end
                end))
            else
                if KillAuraData.Data.LastSetTarget then
                    GameData.Data.Target = nil
                    KillAuraData.Data.LastSetTarget = false
                end

                table.clear(GameData.Data.KillAuraTargets)
                KillAuraData.Data.AnimationPlaying = false

                for i,v in KillAuraData.Data.Effects do
                    for i2, v2 in v do
                        v2:Destroy()
                    end

                    table.clear(v)
                end

                if KillAuraData.Data.OriginalHandPos then
                    local ViewModel: Model = GetViewModel()
                    local RightHand: MeshPart = ViewModel and ViewModel:FindFirstChild("RightHand")
                    if ViewModel and RightHand then
                        local RightWrist: Motor6D = RightHand:FindFirstChild("RightWrist")
                        if RightWrist then
                            TweenService:Create(RightWrist, TweenInfo.new(KillAuraData.Settings.AnimationRestoreTime), {C0 = KillAuraData.Data.OriginalHandPos}):Play()
                        end
                    end
                end
            end
        end
    })

    local Trigger = KillAura:KeyBind({
        Name = "Trigger",
        Flag = "KillAuraTrigger",
        Default = Enum.UserInputType.MouseButton1,
        Events = {
            Began = function()
                KillAuraData.Data.TriggerHeld = true
            end,
            Ended = function()
                KillAuraData.Data.TriggerHeld = false
            end
        }
    })
    local MaxTargets
    
    KillAura:Slider({
        Name = "Range",
        Flag = "KillAuraRange",
        Min = 1,
        Max = 22,
        Default = 22,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.Range = value
        end
    })

    KillAura:Slider({
        Name = "Swing Range",
        Flag = "KillAuraSwingRange",
        Min = 1,
        Max = 30,
        Default = 22,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.SwingRange = value
        end
    })

    KillAura:Slider({
        Name = "Hitreg",
        Flag = "KillAuraHitreg",
        Min = 1,
        Max = 36,
        Default = 36,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.Hitreg = value
        end
    })

    KillAura:Slider({
        Name = "Continue Swinging",
        Flag = "KillAuraContinueSwinging",
        Min = 0,
        Max = 2,
        Default = 0,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.ContinueSwinging = value
        end
    })

    KillAura:Slider({
        Name = "Max Angle",
        Flag = "KillAuraMaxAngle",
        Min = 1,
        Max = 360,
        Default = 360,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.MaxAngle = value
        end
    })

    MaxTargets = KillAura:Slider({
        Name = "Max Targets",
        Flag = "KillAuraMaxTargets",
        Min = 1,
        Max = 10,
        Default = 5,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.MaxTargets = value
        end
    })

    KillAura:Dropdown({
        Name = "Attack Mode",
        Flag = "KillAuraAttackMode",
        Default = "Switch",
        Options = {"Single", "Multi", "Switch"},
        CallingFunction = function(self, value: string)
            KillAuraData.Settings.AttackMode = value
            MaxTargets:SetVisiblity(value == "Multi")
            KillAuraData.Data.SwitchIndex = 1
            KillAuraData.Data.SwitchAt = 0
        end
    })

    KillAura:Dropdown({
        Name = "Targets",
        Flag = "KillAuraTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value: {})
            if value.Players ~= nil or value.Npcs ~= nil then
                KillAuraData.Settings.Targets = value
            else
                KillAuraData.Settings.Targets = {
                    Players = table.find(value, "Players") ~= nil,
                    Npcs = table.find(value, "Npcs") ~= nil
                }
            end
        end
    })  
    
    KillAura:Dropdown({
        Name = "Target Mode",
        Flag = "KillAuraTargetMode",
        Default = "Distance",
        Options = {"Distance", "Angle", "Lowest Health", "Highest Health"},
        CallingFunction = function(self, value: string)
            KillAuraData.Settings.TargetMode = value
        end
    })    

    KillAura:Dropdown({
        Name = "Target Priority",
        Flag = "KillAuraTargetPriority",
        Default = "Players",
        Options = {"Players", "NPCs"},
        CallingFunction = function(self, value: string)
            KillAuraData.Settings.Priority = value
        end
    })

    KillAura:Slider({
        Name = "Delay",
        Flag = "KillAuraDelay",
        Min = 0,
        Max = 3,
        Default = 0,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.Delay = value
        end
    })

    local HitsPerSecond = KillAura:Slider({
        Name = "Hits Per Second",
        Flag = "KillAuraHitsPerSecond",
        Min = 1,
        Max = 100,
        Default = 50,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.HitsPerSecond = value
        end
    })

    local FastHitsFireRate = KillAura:Slider({
        Name = "Fast Hits Fire Rate",
        Flag = "KillAuraFastHitsFireRate",
        Min = 0,
        Max = 2,
        Default = 0.06,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.FastHitsFireRate = value
        end
    })

    local AirHitsChance = KillAura:Slider({
        Name = "Air Hits Chance",
        Flag = "KillAuraAirHitsChance",
        Min = 0,
        Max = 100,
        Default = 100,
        Increment = 5,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.AirHitsChance = value
        end
    })

    local TargetBoxTransparency = KillAura:Slider({
        Name = "Box Transparency",
        Flag = "KillAuraTargetBoxTransparency",
        Min = 0,
        Max = 1,
        Default = 0.5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.BoxTransparency = value
        end
    })

    local ParticleRate = KillAura:Slider({
        Name = "Particle Rate",
        Flag = "KillAuraParticleRate",
        Min = 0,
        Max = 50,
        Default = 40,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.ParticleRate = value
        end
    })

    local ParticleLifeTime = KillAura:Slider({
        Name = "Particle Time",
        Flag = "KillAuraParticleLifeTime",
        Min = 0,
        Max = 5,
        Default = 2,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.ParticleLifeTime = value
        end
    })

    local TargetBoxColor = KillAura:ColorSlider({
        Name = "Box Color",
        Flag = "KillAuraTargetBoxColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, value: Color3)
            KillAuraData.Settings.BoxColor = value
        end
    })

    local ParticleColor = KillAura:ColorSlider({
        Name = "Particle Color",
        Flag = "KillAuraParticleColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, value: Color3)
            KillAuraData.Settings.ParticleColor = value
        end
    })

    local AnimationRestoreTime = KillAura:Slider({
        Name = "Animation Restore",
        Flag = "KillAuraAnimationRestoreTime",
        Min = 0,
        Max = 1,
        Default = 0.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            KillAuraData.Settings.AnimationRestoreTime = value
        end
    })

    local AnimationPicker = KillAura:Dropdown({
        Name = "Animation",
        Flag = "KillAuraAnimation",
        Default = "Bloomware",
        Options = {"Bloomware", "Smooth", "Funny", "Stand", "Air", "Hit", "Rise", "Moon", "Lunar"},
        CallingFunction = function(self, value: string)
            KillAuraData.Settings.SelectedAnimation = value
        end
    })

    KillAura:MiniToggle({
        Name = "Custom Hit Reg",
        Flag = "KillAuraCustomHitReg",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.CustomHitReg = value
            KillAuraData.Data.LastCustomHit = 0
            HitsPerSecond:SetVisiblity(value)
        end
    })

    KillAura:MiniToggle({
        Name = "Dynamic Hits",
        Flag = "KillAuraDynamicHits",
        Default = true,
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.DynamicHits = value
        end
    })

    KillAura:MiniToggle({
        Name = "Fast Hits",
        Flag = "KillAuraFastHits",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.FastHits = value
            FastHitsFireRate:SetVisiblity(value)
            CanFastHit = value
        end
    })

    KillAura:MiniToggle({
        Name = "Fast Hits RL",
        Flag = "KillAuraFastHitsLegit",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.FastHitsLegit = value
        end
    })

    KillAura:TextBox({
        Name = "Fast Hits Projectiles",
        Flag = "KillAuraFastHitsProjectiles",
        Default = "arrow, snowball",
        CallingFunction = function(self, value: string)
            UpdateFastHitProjectiles(value)
        end
    })

    KillAura:MiniToggle({
        Name = "Sync Hit Time",
        Flag = "KillAuraSyncHitTime",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.SyncHitTime = value
        end
    })

    KillAura:MiniToggle({
        Name = "Air Hits",
        Flag = "KillAuraAirHits",
        Default = true,
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.AirHits = value
            AirHitsChance:SetVisiblity(value)
        end
    })

    KillAura:MiniToggle({
        Name = "Auto Jump",
        Flag = "KillAuraAutoJump",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.AutoJump = value
        end
    })

    KillAura:MiniToggle({
        Name = "Target Box",
        Flag = "KillAuraTargetBox",
        Default = true,
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.Boxes = value
            TargetBoxTransparency:SetVisiblity(value)
            TargetBoxColor:SetVisiblity(value)
        end
    })

    KillAura:MiniToggle({
        Name = "Particles",
        Flag = "KillAuraParticles",
        Default = true,
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.Particles = value

            ParticleLifeTime:SetVisiblity(value)
            ParticleRate:SetVisiblity(value)
            ParticleColor:SetVisiblity(value)
        end
    })

    KillAura:MiniToggle({
        Name = "Auto Switch",
        Flag = "KillAuraAutoSwitch",
        Default = true,
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.AutoSwitch = value
        end
    })

    KillAura:MiniToggle({
        Name = "Hand Check",
        Flag = "KillAuraHandCheck",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.HandCheck = value
        end
    })

    KillAura:MiniToggle({
        Name = "Wall Check",
        Flag = "KillAuraWallCheck",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.WallCheck = value
        end
    })

    KillAura:MiniToggle({
        Name = "Attackable Check",
        Flag = "KillAuraAttackableCheck",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.AttackableCheck = value
        end
    })

    KillAura:MiniToggle({
        Name = "No Swing",
        Flag = "KillAuraNoSwing",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.NoSwing = value
        end
    })

    KillAura:MiniToggle({
        Name = "Trigger",
        Flag = "KillAuraTriggerEnabled",
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.TriggerButton = value
            Trigger:SetVisiblity(value)
        end
    })

    KillAura:MiniToggle({
        Name = "Animation",
        Flag = "KillAuraUseAnimation",
        Default = true,
        CallingFunction = function(self, value: boolean)
            KillAuraData.Settings.UseAnimation = value
            AnimationRestoreTime:SetVisiblity(value)
            AnimationPicker:SetVisiblity(value)
        end
    })

    HitsPerSecond:SetVisiblity(KillAuraData.Settings.CustomHitReg)
    FastHitsFireRate:SetVisiblity(KillAuraData.Settings.FastHits)
    AirHitsChance:SetVisiblity(KillAuraData.Settings.AirHits)
    MaxTargets:SetVisiblity(KillAuraData.Settings.AttackMode == "Multi")
end)();

(function()
    local AimbotData = {
        Settings = {
            Smoothness = 0,
            CircleSize = 80,
            Distance = 50,
            CircleEnabled = true,
            Mode = "Smooth",
            Prediction = false,
            PredictionAmount = 0.12,
            Jitter = false,
            JitterAmount = 0,
            Deadzone = 0,
            TeamCheck = false,
            TriggerDistance = false,
            WallCheck = false,
            UseTriggerButton = false,
            TargetPart = "HumanoidRootPart",
            CircleColor = Color3.fromRGB(255, 0, 0),
            Targets = {
                Players = false,
                Npcs = false
            }
        },
        Data = {
            RayParams = RaycastParams.new(),
            Circle = nil,
            HoldingTrigger = false,
        }
    }

    local AimRandom = Random.new()

    local function GetAimPosition(TargetPart: BasePart): Vector3
        local Position = TargetPart.Position

        if AimbotData.Settings.Prediction then
            Position += TargetPart.AssemblyLinearVelocity * AimbotData.Settings.PredictionAmount
        end

        if AimbotData.Settings.Jitter and AimbotData.Settings.JitterAmount > 0 then
            local Amount = AimbotData.Settings.JitterAmount / 100
            local Right = CurrentCamera.CFrame.RightVector * AimRandom:NextNumber(-Amount, Amount)
            local Up = CurrentCamera.CFrame.UpVector * AimRandom:NextNumber(-Amount, Amount)
            Position += Right + Up
        end

        return Position
    end

    local function AimAt(Position: Vector3, Delta: number)
        local NewCF = CFrame.new(CurrentCamera.CFrame.Position, Position)

        if AimbotData.Settings.Mode == "Snap" or AimbotData.Settings.Smoothness >= 100 then
            CurrentCamera.CFrame = NewCF
        elseif AimbotData.Settings.Mode == "Humanized" then
            CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(NewCF, math.clamp((AimbotData.Settings.Smoothness * Delta) * 0.65, 0, 1))
        else
            CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(NewCF, math.clamp(AimbotData.Settings.Smoothness * Delta, 0, 1))
        end
    end

    local Aimbot = Windows.Combat:CreateModule({
        Name = "Aimbot",
        Flag = "Aimbot",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if AimbotData.Settings.CircleEnabled and not AimbotData.Data.Circle then
                    local Circle = Drawing.new("Circle")
                    Circle.Visible = true
                    Circle.Color = AimbotData.Settings.CircleColor
                    Circle.Radius = AimbotData.Settings.CircleSize
                    Circle.Thickness = 2
                    Circle.Filled = false
                    Circle.Transparency = 0.8
                    AimbotData.Data.Circle = Circle
                end

                self:Connection(RunService.PreRender:Connect(function(Delta: number)
                    if not Bloomware:IsAlive(LocalPlayer) then 
                        return 
                    end

                    if AimbotData.Data.Circle then
                        AimbotData.Data.Circle.Position = UserInputService:GetMouseLocation()
                    end

                    if not AimbotData.Data.HoldingTrigger and AimbotData.Settings.UseTriggerButton then return end

                    local Entities = GetEntities()
                    local AllEntities = {}
                    for i,v in Entities do
                        table.insert(AllEntities, v.Entity)
                    end

                    local NearestToMouse: {DistanceFromMouse: number, DistanceFromPlayer: number, Player: Player?, Character: Model?} = Bloomware:GetNerestPlayerToMouse({
                        TeamCheck = AimbotData.Settings.TeamCheck,
                        Exclude = {LocalPlayer},
                        Extras = AllEntities,
                        Targets = AimbotData.Settings.Targets
                    })

                    if NearestToMouse.Character then
                        local Target = NearestToMouse.Character
                        local TargetPart = Target:FindFirstChild(AimbotData.Settings.TargetPart) or Target.PrimaryPart
                        if TargetPart then
                            local Pos, OnScreen = CurrentCamera:WorldToViewportPoint(TargetPart.Position)
                            local MousePos = UserInputService:GetMouseLocation()
                            local DistToMouse = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude

                            if OnScreen and (DistToMouse <= AimbotData.Settings.CircleSize or not AimbotData.Settings.CircleEnabled) then
                                if AimbotData.Settings.Deadzone > 0 and DistToMouse <= AimbotData.Settings.Deadzone then
                                    return
                                end

                                if AimbotData.Settings.TriggerDistance and NearestToMouse.DistanceFromPlayer >= AimbotData.Settings.Distance then
                                    return
                                end
                                
                                if AimbotData.Settings.WallCheck then
                                    AimbotData.Data.RayParams.FilterType = Enum.RaycastFilterType.Exclude
                                    AimbotData.Data.RayParams.FilterDescendantsInstances = CollectionService:GetTagged("entity")
                                    if not IsPathClear(Target, TargetPart, AimbotData.Data.RayParams) then 
                                        return 
                                    end
                                end

                                AimAt(GetAimPosition(TargetPart), Delta)
                            end
                        end
                    end
                end))
            else
                if AimbotData.Data.Circle then
                    AimbotData.Data.Circle:Destroy()
                    AimbotData.Data.Circle = nil
                end
            end
        end
    })

    local KeyTrigger = Aimbot.Functions:KeyBind({
        Name = "Trigger",
        MobileText = "Trigger",
        Flag = "AimbotTrigger",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.UserInputType.MouseButton2,
        Events = {
            Began = function()
                AimbotData.Data.HoldingTrigger = true
            end,
            Ended = function()
                AimbotData.Data.HoldingTrigger = false
            end
        }
    })

    Aimbot:Dropdown({
        Name = "Part",
        Flag = "AimbotPart",
        Default = "Head",
        Options = AimParts,
        CallingFunction = function(self, Value: string)
            AimbotData.Settings.TargetPart = Value
        end
    })

    Aimbot:Dropdown({
        Name = "Targets",
        Flag = "AimbotTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value: {})
            AimbotData.Settings.Targets = value
        end
    })  

    Aimbot:Dropdown({
        Name = "Mode",
        Flag = "AimbotMode",
        Default = "Humanized",
        Options = {"Smooth", "Snap", "Humanized"},
        CallingFunction = function(self, value: string)
            AimbotData.Settings.Mode = value
        end
    })

    Aimbot:Slider({
        Name = "Aim Speed",
        Flag = "AimbotSpeed",
        Default = 15,
        Min = 1,
        Max = 50,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.Smoothness = value
        end
    })

    Aimbot:Slider({
        Name = "Deadzone",
        Flag = "AimbotDeadzone",
        Default = 20,
        Min = 0,
        Max = 40,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.Deadzone = value
        end
    })

    Aimbot:Slider({
        Name = "Prediction",
        Flag = "AimbotPredictionAmount",
        Default = 0.12,
        Min = 0,
        Max = 0.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.PredictionAmount = value
        end
    })

    Aimbot:Slider({
        Name = "Jitter",
        Flag = "AimbotJitterAmount",
        Default = 5,
        Min = 1,
        Max = 20,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.JitterAmount = value
        end
    })

    local FovSize = Aimbot:Slider({
        Name = "FOV Size",
        Flag = "AimbotFOVSize",
        Default = 80,
        Min = 1,
        Max = 450,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.CircleSize = value
            if AimbotData.Data.Circle then
                AimbotData.Data.Circle.Radius = value
            end
        end
    })

    Aimbot:Slider({
        Name = "Distance",
        Flag = "AimbotDistance",
        Default = 20,
        Min = 1,
        Max = 30,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.Distance = value
        end
    })

    local FovColor = Aimbot:ColorSlider({
        Name = "FOV Color",
        Flag = "AimbotFOVCircleColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, Color: Color3)
            AimbotData.Settings.CircleColor = Color
            if AimbotData.Data.Circle then
                AimbotData.Data.Circle.Color = Color
            end
        end
    })

    Aimbot:MiniToggle({
        Name = "FOV",
        Flag = "AimbotFOV",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.CircleEnabled = value

            FovColor:SetVisiblity(value)
            FovSize:SetVisiblity(value)
            if not AimbotData.Data.Circle then
                if Aimbot.Enabled then
                    local Circle = Drawing.new("Circle")
                    Circle.Visible = true
                    Circle.Color = AimbotData.Settings.CircleColor
                    Circle.Radius = AimbotData.Settings.CircleSize
                    Circle.Thickness = 2
                    Circle.Filled = false
                    Circle.Transparency = 0.8
                    AimbotData.Data.Circle = Circle
                end
            else
                if not value then
                    AimbotData.Data.Circle:Destroy()
                    AimbotData.Data.Circle = nil
                end
            end
        end
    })

    Aimbot:MiniToggle({
        Name = "Team Check",
        Flag = "AimbotTeamCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.TeamCheck = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Distance Check",
        Flag = "AimbotDistanceCheck",
        Default = true,
        CallingFunction = function(self, value: number)
            AimbotData.Settings.TriggerDistance = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Wall Check",
        Flag = "AimbotWallCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.WallCheck = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Prediction",
        Flag = "AimbotPrediction",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.Prediction = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Jitter",
        Flag = "AimbotJitter",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.Jitter = value
        end
    })

    Aimbot:MiniToggle({
        Name = "Trigger Button",
        Flag = "AimbotUseTriggerButton",
        CallingFunction = function(self, value: boolean)
            AimbotData.Settings.UseTriggerButton = value
            KeyTrigger:SetVisiblity(value)
        end
    })
end)();

(function()
    local TeamCheck = false
    local Distance = 30
    local Targets = {
        Players = false,
        Npcs = false
    }

    local TargetHud = Windows.Render:CreateModule({
        Name = "Target HUD",
        Flag = "TargetHUD",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                local Health = {
                    Current = (LocalPlayer.Character and math.round(LocalPlayer.Character:GetAttribute("Health"))) or 0,
                    Max = (LocalPlayer.Character and math.round(LocalPlayer.Character:GetAttribute("MaxHealth"))) or 0
                }

                Bloomware:GetTargetHud(true, {Player = LocalPlayer, Health = Health})
                repeat
                    local Target = GameData.Data.Target
                    if not Target or not Target.Entity then
                        Target = GetEntity({
                            TeamCheck = TeamCheck,
                            MaxRange = Distance,
                            Targets = Targets
                        })
                    end

                    if Target.Entity then
                        Health = {
                            Current = math.round(Target.Entity:GetAttribute("Health")) or 0,
                            Max = math.round(Target.Entity:GetAttribute("MaxHealth")) or 0
                        }

                        local Display: string = Target.Entity.Humanoid.DisplayName
                        if Display == "" then
                            Display = Target.Entity.Name
                        end

                        Bloomware:GetTargetHud():Update({
                            Player = Target.Data.Player,
                            UserData = {
                                Name = Target.Entity.Name, 
                                DisplayName = Display, 
                                ProfilePic = "",
                            },
                            Health = Health,
                            Visible = true
                        })
                    else
                        Health = {
                            Current = (LocalPlayer.Character and math.round(LocalPlayer.Character:GetAttribute("Health"))) or 0,
                            Max = (LocalPlayer.Character and math.round(LocalPlayer.Character:GetAttribute("MaxHealth"))) or 0
                        }

                        Bloomware:GetTargetHud():Update({
                            Player = LocalPlayer,
                            Health = Health,
                            Visible = Bloomware.UIData.UIOpen
                        })
                    end
                    task.wait(0.5)
                until not self.Enabled
            else
                Bloomware:DestroyTargetHud()
            end
        end
    })

    TargetHud:Slider({
        Name = "Distance",
        Flag = "TargetHUDDistance",
        Min = 1,
        Max = 100,
        Default = 30,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })

    TargetHud:Dropdown({
        Name = "Targets",
        Flag = "TargetHUDTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value: {})
            Targets = value
        end
    })  

    TargetHud:MiniToggle({
        Name = "Team Check",
        Flag = "TargetHUDTeamCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            TeamCheck = value
        end
    })
end)();

(function()
    local Distance = 28
    local HandCheck = false
    local AutoSwitch = false
    local LastHitNormal = Enum.NormalId.Top

    local Nuker = Windows.Utility:CreateModule({
        Name = "Nuker",
        Flag = "Nuker",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat 
                    if HandCheck then
                        local CurrentHand = GetInventory().hand
                        if CurrentHand and CurrentHand.tool then
                            local Meta = GameData.Utils.ItemMeta[CurrentHand.itemType]
                            if not Meta or not Meta.breakBlock then
                                task.wait()
                                continue
                            end
                        else
                            task.wait()
                            continue
                        end
                    end

                    local Bed = GetNearestBed()
                    if Bed.Bed and Distance >= Bed.Distance then
                        local BestSide = FindWeakestSide(Bed.Bed)
                        local Item = BestSide[#BestSide]
                        local ItemName = Item.Block.Name
                        if Item then
                            if table.find(CollectionService:GetTagged("bed"), Item.Block) then
                                ItemName = "wood"
                                Item.HitNormal = LastHitNormal
                            else
                                LastHitNormal = Item.HitNormal
                            end

                            local BestTool = GetBestItemToBreakBlock(ItemName)
                            if BestTool.Item then
                                SwitchItem(BestTool.Item)
                            else
                                if AutoSwitch then
                                    BestTool = GetBestItemToBreakBlock("stone")
                                    if BestTool.Item then
                                        SwitchItem(BestTool.Item)
                                    end
                                end
                            end

                            local Result = DamageBlock(Item.Block, LastHitNormal)
                            if Result == "cancelled" then
                                task.wait(0.15)
                            end

                            task.wait(0.05)
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    Nuker:Slider({
        Name = "Distance",
        Flag = "NukerDistance",
        Min = 1,
        Max = 28,
        Default = 28,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })

    Nuker:MiniToggle({
        Name = "Switch Item",
        Flag = "NukerSwitchItem",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AutoSwitch = value
        end
    })

    Nuker:MiniToggle({
        Name = "HandCheck",
        Flag = "NukerHandCheck",
        CallingFunction = function(self, value: boolean)
            HandCheck = value
        end
    })
end)();

(function()
    local Old
    Windows.Movement:CreateModule({
        Name = "Sprint",
        Flag = "Sprint",
        CallingFunction = function(self, enabled: boolean) 
            if enabled then
                Old = GameData.Utils.Sprint.stopSprinting
                GameData.Utils.Sprint.stopSprinting = function()
                    return
                end

                repeat
                    if not GameData.Utils.Sprint:isSprinting() then
                        GameData.Utils.Sprint:startSprinting()
                    end
                    task.wait()
                until not self.Enabled
            else
                GameData.Utils.Sprint.stopSprinting = Old
                GameData.Utils.Sprint:stopSprinting()
            end
        end
    })
end)();

(function()
    local OldApply = nil
    local KnockbackValue = 0

    local Knockback = Windows.Movement:CreateModule({
        Name = "Knockback",
        Flag = "KnockbackChanger",
        CallingFunction = function(self, enabled: boolean) 
            if enabled then
                OldApply = GameData.Utils.Knockback.applyKnockback
                GameData.Utils.Knockback.applyKnockback = function(Part: BasePart, RealKnockback: number, ...)
                    if KnockbackValue == 0 then return end

                    return OldApply(Part, KnockbackValue, ...)
                end
            else
                if OldApply then
                    GameData.Utils.Knockback.applyKnockback = OldApply
                end
            end
        end
    })
    
    Knockback:Slider({
        Name = "Knockback",
        Flag = "KnockbackChangerValue",
        Min = 0,
        Max = 30,
        Default = 0,
        CallingFunction = function(self, value: number)
            KnockbackValue = value
        end
    })
end)();

local function GetBlockPlace(pos: Vector3)
    local Round = GameData.Utils.BlockEngine:getBlockPosition(pos)
    return GameData.Utils.BlockEngine:getStore():getBlockAt(Round), Round
end

(function()
    local ScaffoldData = {
        Settings = {
            Extend = 1,
            DownValue = 4,
            Boost = 5
        },
        Data = {
            Blocks = {},
            Placed = {},
            HoldingDown = false,
            HoldingUp = false,
            Pos = Vector3.zero
        }
    }

    local function CheckBlockPos(pos: Vector3)
        for _, Offset in next, ScaffoldData.Data.Blocks do
            return GetBlockPlace(pos + Offset)
        end
        return nil
    end

    local function GetPositions(min: Vector3, max: Vector3)
        local Store, List = GameData.Utils.BlockEngine:getStore(), {}
        for x = min.X, max.X do
            for y = min.Y, max.Y do
                for z = min.Z, max.Z do
                    if Store:getBlockAt(Vector3.new(x, y, z)) then
                        List[#List + 1] = Vector3.new(x * 3, y * 3, z * 3)
                    end
                end
            end
        end
        return List
    end

    local function GetCorner(a: Vector3, b: Vector3)
        local Pos = a + (b - a).Unit * 100
        local Vec = Vector3.new(3, 3, 3)
        return Vector3.new(
            math.clamp(Pos.X, a.X - Vec.X, a.X + Vec.X),
            math.clamp(Pos.Y, a.Y - Vec.Y, a.Y + Vec.Y),
            math.clamp(Pos.Z, a.Z - Vec.Z, a.Z + Vec.Z)
        )
    end

    local function GetBuild(pos: Vector3)
        local Vec = Vector3.new(21, 21, 21)
        local Dist, Point = 60, nil
        for _, v in next, GetPositions(GameData.Utils.BlockEngine:getBlockPosition(pos - Vec), GameData.Utils.BlockEngine:getBlockPosition(pos + Vec)) do
            local Corner = GetCorner(v, pos)
            local Mag = (pos - Corner).Magnitude
            if Mag < Dist then
                Dist, Point = Mag, Corner
            end
        end
        return Point
    end

    local function PlaceBlock(pos: Vector3)
        local Block = GetBlocks()
        if not Block then return end
        if not ScaffoldData.Data.Placed[Block] then
            ScaffoldData.Data.Placed[Block] = GameData.Utils.BlockPlacer.new(GameData.Utils.BlockClient, Block.Type)
        end
        return ScaffoldData.Data.Placed[Block]:placeBlock(GameData.Utils.BlockEngine:getBlockPosition(pos))
    end

    local function IsDiagonal()
        local Move = LocalPlayer.Character.Humanoid.MoveDirection
        local X, Z = math.abs(Move.X), math.abs(Move.Z)
        return X > 0.1 and Z > 0.1 and math.abs(X - Z) < 0.3
    end

    local Scaffold = Windows.Utility:CreateModule({
        Name = "Scaffold",
        Flag = "Scaffold",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    if Bloomware:IsAlive(LocalPlayer) then
                        local Root = LocalPlayer.Character.HumanoidRootPart
                        local Hum = LocalPlayer.Character.Humanoid
                        for i = 1, ScaffoldData.Settings.Extend do
                            local YLevel = Root.Position.Y - Hum.HipHeight - (ScaffoldData.Data.HoldingDown and ScaffoldData.Settings.DownValue or 1.5)
                            local Dir = Hum.MoveDirection * i
                            local CFrame = CFrame.new(Root.Position) * CFrame.new(Dir.X, -Root.Position.Y + YLevel, Dir.Z)
                            local Pos = Vector3.new(math.round(CFrame.X / 3) * 3, math.round(CFrame.Y / 3) * 3, math.round(CFrame.Z / 3) * 3)

                            if IsDiagonal() then
                                local Hor = (ScaffoldData.Data.Pos - Root.Position) * Vector3.new(1, 0, 1)
                                if Hor.X ^ 2 + Hor.Z ^ 2 < 6.25 then
                                    Pos = ScaffoldData.Data.Pos
                                end
                            end

                            local _, res = pcall(function()
                                return GetBlockPlace(Pos)
                            end)

                            if not res then
                                local Place = CheckBlockPos(Pos * 3) or GetBuild(Pos)
                                if Place then
                                    task.spawn(function()
                                        PlaceBlock(Place)
                                    end)
                                end
                            end

                            ScaffoldData.Data.Pos = Pos
                        end

                        if ScaffoldData.Settings.Tower and ScaffoldData.Data.HoldingUp and not UserInputService:GetFocusedTextBox() then
                            local Velo = Root.Velocity
                            Root.Velocity = Vector3.new(Velo.X, ScaffoldData.Settings.Boost * 6 + 3, Velo.Z)
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    Scaffold:KeyBind({
        Name = "Down",
        MobileText = "Scaffold Down",
        Flag = "ScaffoldDownKeybind",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.KeyCode.LeftShift,
        Events = {
            Began = function()
                ScaffoldData.Data.HoldingDown = true
            end,
            Ended = function()
                ScaffoldData.Data.HoldingDown = false
            end
        }
    })

    Scaffold:KeyBind({
        Name = "Up",
        MobileText = "Scaffold Up",
        Flag = "ScaffoldUpKeybind",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.KeyCode.Space,
        Events = {
            Began = function()
                ScaffoldData.Data.HoldingUp = true
            end,
            Ended = function()
                ScaffoldData.Data.HoldingUp = false
            end
        }
    })

    Scaffold:Slider({
        Name = "Extend",
        Flag = "ScaffoldExtend",
        Min = 1,
        Max = 10,
        Default = 2,
        CallingFunction = function(self, value: number)
            ScaffoldData.Settings.Extend = value
        end
    })

    Scaffold:Slider({
        Name = "Down",
        Flag = "ScaffoldDown",
        Min = 1,
        Max = 10,
        Default = 4,
        CallingFunction = function(self, value: number)
            ScaffoldData.Settings.DownValue = value
        end
    })

    Scaffold:Slider({
        Name = "Up",
        Flag = "ScaffoldUp",
        Min = 1,
        Max = 10,
        Default = 5,
        CallingFunction = function(self, value: number)
            ScaffoldData.Settings.Boost = value
        end
    })
end)();

(function()
    local Potions, HealthConsumables = false, false
    local Delay = 0
    local RequiredHealth = 60
    local Whitelisted = {
        "shield",
        "star",
        "apple_juice",
        "pie"
    }

    local AutoConsume = Windows.Utility:CreateModule({
        Name = "Auto Consume",
        Flag = "AutoConsume",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    for i,v in GetInventory().items do
                        local Meta = GameData.Utils.ItemMeta[v.itemType]
                        local IsWhitelisted: boolean = false
                        for i2,v2 in Whitelisted do
                            if v.itemType:lower():find(v2) then
                                IsWhitelisted = true
                                break
                            end
                        end

                        if Meta and Meta.consumable and ((HealthConsumables and Meta.consumable.requiresMissingHealth) or (Potions and Meta.consumable.potion) or IsWhitelisted) then
                            if (v.itemType == "speed_potion" and LocalPlayer.Character:GetAttribute("SpeedBoost")) then
                                continue
                            end

                            if (v.itemType == "pie" and LocalPlayer.Character:GetAttribute("SpeedPieBuff")) then
                                continue
                            end

                            if v.itemType:lower():find("shield") then
                                local Potion: number = LocalPlayer.Character:GetAttribute("Shield_POTION")
                                if Potion >= 200 then
                                    continue
                                end
                            end

                            if LocalPlayer.Character:GetAttribute("StatusEffect_"..v.itemType) then
                                continue
                            end

                            if Meta.consumable.requiresMissingHealth and RequiredHealth < LocalPlayer.Character:GetAttribute("Health") then
                                continue
                            end

                            task.wait(Delay)
                            GameData.Utils.Remotes:Get("ConsumeItem"):CallServerAsync({
                                item = v.tool
                            })
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    local HealthSlider = AutoConsume:Slider({
        Name = "Health",
        Flag = "AutoConsumeHealthValue",
        Min = 1,
        Max = 100,
        Default = 60,
        CallingFunction = function(self, value: number)
            RequiredHealth = value
        end
    })

    AutoConsume:Slider({
        Name = "Delay",
        Flag = "AutoConsumeDelay",
        Min = 0,
        Max = 10,
        Default = 0,
        CallingFunction = function(self, value: number)
            Delay = value
        end
    })

    AutoConsume:MiniToggle({
        Name = "Potions",
        Flag = "AutoConsumePotions",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Potions = value
        end
    })

    AutoConsume:MiniToggle({
        Name = "Health",
        Flag = "AutoConsumeHealth",
        Default = true,
        CallingFunction = function(self, value: boolean)
            HealthConsumables = value
            HealthSlider:SetVisiblity(value)
        end
    })
end)();

(function()
    local Distance: number = 23
    local Delay: number = 0
    local UICheck: boolean = false
    local Skywars: boolean = false
    local Opened = {}

    local ChestStealer = Windows.Utility:CreateModule({
        Name = "Chest Stealer",
        Flag = "ChestStealer",
        CallingFunction = function(self, enabled: boolean)
            if enabled then 
                repeat
                    task.wait()
                    if Skywars and not GameData.Utils.Store:getState().Game.queueType:find("skywars") then
                        continue
                    end

                    local Chest = GetNearestChest(Opened)
                    if Chest.Chest and Distance >= Chest.Distance and not table.find(Opened, Chest.Chest) and #Chest.ChestFolder:GetChildren() > 0 then
                        if UICheck and not GameData.Utils.App:isAppOpen(GameData.Utils.AppIds.CHEST_INVENTORY) then
                            continue
                        end

                        local InsertValue: number = #Opened + 1
                        table.insert(Opened, InsertValue, Chest.Chest)
                        task.delay(0.5, table.remove, Opened, InsertValue)

                        GameData.Utils.Remotes:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(Chest.Chest)
                        if not Chest.Chest:GetAttribute("ChestOpened") then
                            coroutine.wrap(function()
                                GameData.Utils.Chest:playChestOpenAnimation(Chest.Chest)
                                Chest.Chest:SetAttribute("ChestOpened", true)
                            end)()
                        end

                        task.delay(0.1, function()
                            for i,v in Chest.ChestFolder:GetChildren() do
                                GameData.Utils.Remotes:GetNamespace("Inventory"):Get("ChestGetItem"):CallServerAsync(Chest.ChestFolder, v)
                                if Delay ~= 0 then
                                    task.wait(Delay)
                                end
                            end

                            GameData.Utils.Remotes:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer()
                        end)
                    end
                    task.wait(0.1)
                until not self.Enabled
            end
        end
    })
    
    ChestStealer:Slider({
        Name = "Range",
        Flag = "ChestStealerRange",
        Min = 1,
        Max = 20,
        Default = 20,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })

    ChestStealer:Slider({
        Name = "Delay",
        Flag = "ChestStealerDelay",
        Min = 0,
        Max = 5,
        Default = 0,
        CallingFunction = function(self, value: number)
            Delay = value
        end
    })

    ChestStealer:MiniToggle({
        Name = "Only Skywars",
        Flag = "ChestStealerSkywars",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Skywars = value
        end
    })
end)();

(function()
    Windows.Utility:CreateModule({
        Name = "Health Exploit",
        Flag = "HealthExploit",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.PlayerEatCake:FireServer({
                        block = ReplicatedStorage.Items.cake_one
                    })
                    task.wait()
                until not self.Enabled
            end
        end
    })
end)();

(function()
    local Speed: number, Distance: number = 60, 2

    local Param: RaycastParams = RaycastParams.new()
    Param.FilterType = Enum.RaycastFilterType.Include
    Param.RespectCanCollide = true

    Param.FilterDescendantsInstances = BlockList

    local WallClimb = Windows.Movement:CreateModule({
        Name = "Wall Climb",
        Flag = "WallClimb",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    if Bloomware:IsAlive(LocalPlayer) then
                        local Root: BasePart = LocalPlayer.Character.PrimaryPart
                        local Humanoid: Humanoid = LocalPlayer.Character.Humanoid

                        local Ray: RaycastResult? = workspace:Raycast(
                            Root.Position,
                            Humanoid.MoveDirection * Distance,
                            Param
                        )

                        if Ray and not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            local CurrentVelocity: Vector3 = Root.AssemblyLinearVelocity
                            Root.AssemblyLinearVelocity = Vector3.new(CurrentVelocity.X, Speed, CurrentVelocity.Z)
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })
    
    WallClimb:Slider({
        Name = "Speed",
        Flag = "WallClimbSpeed",
        Min = 1,
        Max = 120,
        Default = 60,
        CallingFunction = function(self, value: number)
            Speed = value
        end
    })

    WallClimb:Slider({
        Name = "Distance",
        Flag = "WallClimbDistance",
        Min = 1,
        Max = 5,
        Default = 2,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })
end)();

(function()
    local ProjAimbotData = {
        Settings = {
            FOV = false,
            Filled = false,
            Other = false,
            WallCheck = false,
            DistCheck = false,
            Distance = 100,
            Radius = 1000,
            TargetPart = "HumanoidRootPart",
            Color = Color3.fromRGB(255, 0, 0),
            Blacklisted = {},
            Targets = {
                Players = false,
                Npcs = false
            }
        },
        Data = {
            RayParams = RaycastParams.new(),
            Target = nil,
            Circle = nil,
            Old = nil
        }
    }

    ProjAimbotData.Data.RayParams.FilterType = Enum.RaycastFilterType.Include
    ProjAimbotData.Data.RayParams.FilterDescendantsInstances = BlockList
    
    local ProjAimbot = Windows.Combat:CreateModule({
        Name = "Projectile Aimbot",
        Flag = "ProjectileAimbot",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if not ProjAimbotData.Data.Circle then
                    local Circle = Drawing.new("Circle")
                    Circle.Visible = ProjAimbotData.Settings.FOV
                    Circle.Color = ProjAimbotData.Settings.Color
                    Circle.Radius = ProjAimbotData.Settings.Radius
                    Circle.Thickness = 2
                    Circle.Filled = ProjAimbotData.Settings.Filled
                    Circle.Transparency = 0.8
                    ProjAimbotData.Data.Circle = Circle
                end

                self:Connection(RunService.PreRender:Connect(function()
                    if not Bloomware:IsAlive(LocalPlayer) then return end

                    if ProjAimbotData.Data.Circle then
                        ProjAimbotData.Data.Circle.Position = UserInputService:GetMouseLocation()
                    end

                    local Entities = GetEntities()
                    local AllEntities = {}
                    for _, v in Entities do
                        table.insert(AllEntities, v.Entity)
                    end

                    local NearestToMouse = Bloomware:GetNerestPlayerToMouse({
                        TeamCheck = true,
                        Exclude = {LocalPlayer},
                        Extras = AllEntities,
                        Targets = ProjAimbotData.Settings.Targets
                    })

                    if NearestToMouse.Character then
                        local Target = NearestToMouse.Character
                        local TargetPart = Target:FindFirstChild(ProjAimbotData.Settings.TargetPart) or Target.PrimaryPart
                        if TargetPart then
                            local Pos, OnScreen = CurrentCamera:WorldToViewportPoint(TargetPart.Position)
                            local MousePos = UserInputService:GetMouseLocation()
                            local DistToMouse = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                            if OnScreen and DistToMouse <= ProjAimbotData.Settings.Radius then
                                if ProjAimbotData.Settings.DistCheck and NearestToMouse.DistanceFromPlayer >= ProjAimbotData.Settings.Distance then
                                    ProjAimbotData.Data.Target = nil
                                    return
                                end
                                
                                if ProjAimbotData.Settings.WallCheck then
                                    if not IsPathClear(Target, TargetPart, ProjAimbotData.Data.RayParams) then
                                        ProjAimbotData.Data.Target = nil
                                        return 
                                    end
                                end

                                ProjAimbotData.Data.Target = Target
                            else
                                ProjAimbotData.Data.Target = nil
                            end
                        end
                    end
                end))

                ProjAimbotData.Data.Old = GameData.Utils.Projectile.calculateImportantLaunchValues
                GameData.Utils.Projectile.calculateImportantLaunchValues = function(proj, data, line, start, pos)
                    local Name = tostring(data.projectile or ""):lower()
                    for _, Blacklisted in next, ProjAimbotData.Settings.Blacklisted do
                        if Name:find(Blacklisted) then
                            return ProjAimbotData.Data.Old(proj, data, line, start, pos)
                        end
                    end

                    local Launch = pos or proj:getLaunchPosition(start)
                    if not ProjAimbotData.Data.Target or not ProjAimbotData.Data.Target.PrimaryPart or not Launch then
                        return ProjAimbotData.Data.Old(proj, data, line, start, pos)
                    end
                    
                    local PrimaryPart = ProjAimbotData.Data.Target.PrimaryPart
                    local Humanoid = ProjAimbotData.Data.Target:FindFirstChildOfClass("Humanoid")
                    local YLevel = Humanoid and PrimaryPart.Position.Y + Humanoid.HipHeight or PrimaryPart.Position.Y
                    local StartPos = CFrame.new(Launch + (data.fromPositionOffset or Vector3.new()), Vector3.new(PrimaryPart.Position.X, YLevel, PrimaryPart.Position.Z)).Position
                    local Disp = Vector3.new(PrimaryPart.Position.X, YLevel, PrimaryPart.Position.Z) - StartPos
                    local Vel = PrimaryPart.Velocity or Vector3.new(0, 0, 0)
                    local Meta = data:getProjectileMeta()
                    local Gravity = (Meta and Meta.gravitationalAcceleration or 0) * (data.gravityMultiplier or 1)
                
                    local IsArrow = type(data.projectile) == "string" and data.projectile:find("arrow")
                    local IsOtherProj = Meta and (Meta.gravitationalAcceleration or 0) > 0
                    local Calc = nil

                    if (IsArrow or (ProjAimbotData.Settings.Other and IsOtherProj)) and Meta and Meta.launchVelocity and Meta.launchVelocity > 0 then
                        local Time = Disp.Magnitude / Meta.launchVelocity
                        if Time > 0 then
                            Calc = StartPos + Vector3.new(
                                (Disp.X + Vel.X * Time) / Time,
                                (Disp.Y - (-0.5 * Gravity) * Time * Time) / Time,
                                (Disp.Z + Vel.Z * Time) / Time
                            )
                        end
                    end

                    if not Calc then
                        Calc = PrimaryPart.Position
                    end
                
                    return {
                        initialVelocity = CFrame.new(StartPos, Calc).LookVector * ((Meta and Meta.launchVelocity) or 100),
                        positionFrom = StartPos,
                        deltaT = (Meta and (Meta.predictionLifetimeSec or Meta.lifetimeSec)) or 1,
                        gravitationalAcceleration = Gravity
                    }
                end
            else
                GameData.Utils.Projectile.calculateImportantLaunchValues = ProjAimbotData.Data.Old
                ProjAimbotData.Data.Target = nil
                if ProjAimbotData.Data.Circle then
                    ProjAimbotData.Data.Circle:Destroy()
                    ProjAimbotData.Data.Circle = nil
                end
            end
        end
    })

    ProjAimbot:Dropdown({
        Name = "Target Part",
        Flag = "ProjAimbotPart",
        Default = "HumanoidRootPart",
        Options = AimParts,
        CallingFunction = function(self, Value: string)
            ProjAimbotData.Settings.TargetPart = Value
        end
    })

    ProjAimbot:Dropdown({
        Name = "Targets",
        Flag = "ProjAimbotTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value: {})
            ProjAimbotData.Settings.Targets = value
        end
    })  

    local FovColor = ProjAimbot:ColorSlider({
        Name = "FOV Color",
        Flag = "ProjAimbotFOVCircleColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, Color: Color3)
            ProjAimbotData.Settings.Color = Color
            if ProjAimbotData.Data.Circle then
                ProjAimbotData.Data.Circle.Color = Color
            end
        end
    })

    local FovSize = ProjAimbot:Slider({
        Name = "FOV Size",
        Flag = "ProjAimbotFOVSize",
        Default = 1000,
        Min = 1,
        Max = 1000,
        CallingFunction = function(self, value: number)
            ProjAimbotData.Settings.Radius = value
            if ProjAimbotData.Data.Circle then
                ProjAimbotData.Data.Circle.Radius = value
            end
        end
    })

    local Distance = ProjAimbot:Slider({
        Name = "Distance",
        Flag = "ProjAimbotDistance",
        Default = 100,
        Min = 1,
        Max = 200,
        CallingFunction = function(self, value: number)
            ProjAimbotData.Settings.Distance = value
        end
    })

    ProjAimbot:MiniToggle({
        Name = "FOV",
        Flag = "ProjAimbotFOV",
        CallingFunction = function(self, value: boolean)
            ProjAimbotData.Settings.FOV = value

            FovColor:SetVisiblity(value)
            FovSize:SetVisiblity(value)

            if not ProjAimbotData.Data.Circle then
                if ProjAimbot.Enabled then
                    local Circle = Drawing.new("Circle")
                    Circle.Visible = true
                    Circle.Color = ProjAimbotData.Settings.Color
                    Circle.Radius = ProjAimbotData.Settings.Radius
                    Circle.Thickness = 2
                    Circle.Filled = false
                    Circle.Transparency = 0.8
                    ProjAimbotData.Data.Circle = Circle
                end
            else
                if not value then
                    ProjAimbotData.Data.Circle:Destroy()
                    ProjAimbotData.Data.Circle = nil
                end
            end
        end
    })

    ProjAimbot:MiniToggle({
        Name = "Other Projectiles",
        Flag = "ProjAimbotOtherProjectiles",
        Default = true,
        CallingFunction = function(self, value: boolean)
            ProjAimbotData.Settings.Other = value
        end
    })

    ProjAimbot:MiniToggle({
        Name = "Distance Check",
        Flag = "ProjAimbotDistanceCheck",
        CallingFunction = function(self, value: number)
            ProjAimbotData.Settings.DistCheck = value
            Distance:SetVisiblity(value)
        end
    })

    ProjAimbot:MiniToggle({
        Name = "Wall Check",
        Flag = "ProjAimbotWallCheck",
        CallingFunction = function(self, value: boolean)
            ProjAimbotData.Settings.WallCheck = value
        end
    })

    ProjAimbot:TextBox({
        Name = "Blacklisted Projectiles",
        Flag = "ProjAimbotBlacklist",
        Default = "Lowercases, separated by comma",
        CallingFunction = function(self, value: string)
            ProjAimbotData.Settings.Blacklisted = Separate(value)
        end
    })
end)();

(function()
    local ProjectileAura = {
        Settings = {
            Range = 50,
            FireRate = 0.02,
            MaxAngle = 360,
            TargetMode = "Distance",
            WallCheck = true,
            Targets = {
                Players = true,
                Npcs = false
            }
        },
        Data = {
            LastSetTarget = false,
            Delays = {},
            Projectiles = {arrow = true, snowball = true},
            RayParams = RaycastParams.new(),
            Offset = {RelX = 0, RelY = 0, RelZ = 0},
            Switching = false
        }
    }

    pcall(function()
        ProjectileAura.Data.Offset = debug.getupvalue(GameData.Utils.Projectile.enableBeam, 8) or ProjectileAura.Data.Offset
    end)

    ProjectileAura.Data.RayParams.RespectCanCollide = true
    ProjectileAura.Data.RayParams.FilterType = Enum.RaycastFilterType.Include

    local function GetAmmo(Source)
        if not Source.ammoItemTypes then return nil end

        local Inv = GetInventory().items or {}
        for i = 1, #Source.ammoItemTypes do
            local Type = Source.ammoItemTypes[i]
            for j = 1, #Inv do
                if Inv[j].itemType == Type then
                    return Type
                end
            end
        end
        
        return nil
    end
    
    local function GetProjectiles()
        local Found = {}
        local Inventory = GetInventory().items or {}

        for i = 1, #Inventory do
            local Item = Inventory[i]
            local Data = GameData.Utils.ItemMeta[Item.itemType]
            local Source = Data and Data.projectileSource
            if Source then
                local Ammo = GetAmmo(Source)
                if Ammo and ProjectileAura.Data.Projectiles[Ammo] then
                    Found[#Found + 1] = {
                        Item = Item,
                        Ammo = Ammo,
                        Proj = Source.projectileType(Ammo),
                        Meta = Source
                    }
                end
            end
        end

        return next(Found) and Found or {}
    end

    local function OnProjectileFire(Fired, Obj)
        if not Fired then
            ProjectileAura.Data.Delays[Obj.Item.itemType] = tick() + 0.25
        else
            local Sounds = Obj.Meta.launchSound
            if Sounds and Sounds[1] then
                GameData.Utils.Sound:playSound(Sounds[math.random(1, #Sounds)])
            end
        end
    end

    local function UpdateProjectileList(Value: string)
        table.clear(ProjectileAura.Data.Projectiles)

        for _, Name in Value:split(",") do
            Name = Name:lower():gsub("^%s+", ""):gsub("%s+$", "")
            if Name ~= "" then
                ProjectileAura.Data.Projectiles[Name] = true
            end
        end
    end

    local function GetHand(): Instance?
        local CurrentItem = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HandInvItem")
        if CurrentItem and CurrentItem:IsA("ObjectValue") then
            return CurrentItem.Value
        end

        local Inventory = GetInventory()
        return Inventory and Inventory.hand and Inventory.hand.tool
    end

    local function Equip(Tool: Instance): boolean
        if not Tool or GetHand() == Tool then
            return true
        end

        if ProjectileAura.Data.Switching then
            return false
        end

        ProjectileAura.Data.Switching = true
        local Done, Success = false, false

        local Worked = pcall(function()
            GameData.Utils.Remotes:Get("SetInvItem"):CallServerAsync({
                hand = Tool
            }):andThen(function(Result)
                Success = Result ~= false
                Done = true
            end)
        end)

        local Started = tick()
        repeat task.wait() until Done or (tick() - Started) > 0.35
        ProjectileAura.Data.Switching = false

        return Worked and (Success or GetHand() == Tool)
    end

    local Cooldown = 0

    local ProjAura = Windows.Combat:CreateModule({
        Name = "Projectile Aura",
        Flag = "ProjectileAura",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    task.wait()
                    if Bloomware:IsAlive(LocalPlayer) and not Windows.Movement.Modules.LongJump.Enabled then
                        if not CanFastHit then
                            if (workspace:GetServerTimeNow() - (GameData.Utils.SwordController.lastAttack or 0)) < 0.5 then
                                continue
                            end
                        end

                        local Target = GetEntity({
                            TeamCheck = true,
                            MaxRange = ProjectileAura.Settings.Range,
                            MaxAngle = ProjectileAura.Settings.MaxAngle,
                            Visible = ProjectileAura.Settings.WallCheck,
                            Targets = ProjectileAura.Settings.Targets,
                            Mode = ProjectileAura.Settings.TargetMode
                        })

                        if Target.Entity and Bloomware:IsAlive(Target.Entity, true) then
                            local Pos = LocalPlayer.Character.PrimaryPart.Position
                            local Tools = GetProjectiles()

                            if #Tools > 0 then
                                GameData.Data.Target = Target
                                ProjectileAura.Data.LastSetTarget = true

                                for i = 1, #Tools do
                                    local Obj = Tools[i]
                                    local ItemType = Obj.Item.itemType

                                    if (ProjectileAura.Data.Delays[ItemType] or 0) < tick() then
                                        local Map = workspace:FindFirstChild("Map")
                                        ProjectileAura.Data.RayParams.FilterDescendantsInstances = Map and {Map} or {}
                                        local ProjData = GameData.Utils.ProjMeta[Obj.Proj]
                                        if not ProjData then
                                            continue
                                        end

                                        local Root = Target.Data.Root or Target.Entity.PrimaryPart
                                        local Humanoid = Target.Data.Humanoid or Target.Entity:FindFirstChildOfClass("Humanoid")
                                        if not Root or not Humanoid then
                                            continue
                                        end

                                        local LaunchVel = ProjData.launchVelocity or 100
                                        local Gravity = ProjData.gravitationalAcceleration or 196.2
                                        local TargetPos = AimPos(Root, Humanoid)
                                        local TargetVelocity = FlatVel(Root)
                                        local Calc = SolveShot(Pos, LaunchVel, Gravity, TargetPos + (Humanoid.MoveDirection or Vector3.zero), TargetVelocity)

                                        if Calc then
                                            if not Equip(Obj.Item.tool) then
                                                ProjectileAura.Data.Delays[ItemType] = tick() + 0.15
                                                continue
                                            end

                                            local Velocity = FlatVel(Root)
                                            Pos = LocalPlayer.Character.PrimaryPart.Position

                                            local Ping = math.min(LocalPlayer:GetNetworkPing(), 0.5)
                                            TargetPos = AimPos(Root, Humanoid)
                                            if Ping >= 0.067 then
                                                TargetPos += Velocity * Ping
                                            end

                                            Calc = SolveShot(Pos, LaunchVel, Gravity, TargetPos, Velocity)

                                            if not Calc then
                                                continue
                                            end

                                            task.spawn(function()
                                                local Direction = CFrame.lookAt(Pos, Calc).LookVector
                                                local Id = HttpService:GenerateGUID(true)
                                                local Offset = ProjectileAura.Data.Offset
                                                local ShootPosition = (CFrame.new(Pos, Calc) * CFrame.new(Vector3.new(-(Offset.RelX or 0), -(Offset.RelY or 0), -(Offset.RelZ or 0)))).Position

                                                Cooldown = 999999

                                                local Suc, Res = pcall(function()
                                                    return FireProjectileRemote(Obj.Item.tool, Obj.Ammo, Obj.Proj, ShootPosition, Pos, Direction * LaunchVel, Id,
                                                    {drawDurationSeconds = 1, drawDurationSec = 1, shotId = HttpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
                                                end)

                                                OnProjectileFire(Suc and Res, Obj)

                                                Cooldown = tick()
                                            end)

                                            ProjectileAura.Data.Delays[ItemType] = tick() + (Obj.Meta.fireDelaySec or 0)

                                            repeat task.wait() until tick() > Cooldown

                                            if ProjectileAura.Settings.FireRate > 0 then
                                                task.wait(ProjectileAura.Settings.FireRate)
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            if ProjectileAura.Data.LastSetTarget then
                                GameData.Data.Target = nil
                                ProjectileAura.Data.LastSetTarget = false
                            end
                        end
                    end
                    task.wait(0.05)
                until not self.Enabled
            else
                if ProjectileAura.Data.LastSetTarget then
                    GameData.Data.Target = nil
                    ProjectileAura.Data.LastSetTarget = false
                end
            end
        end
    })

    ProjAura:TextBox({
        Name = "Projectiles",
        Flag = "ProjectileAuraProjectiles",
        Default = "arrow, snowball",
        CallingFunction = function(self, value: string)
            UpdateProjectileList(value)
        end
    })

    ProjAura:Slider({
        Name = "Range",
        Flag = "ProjectileAuraRange",
        Min = 1,
        Max = 200,
        Default = 50,
        CallingFunction = function(self, value: number)
            ProjectileAura.Settings.Range = value
        end
    })

    ProjAura:Slider({
        Name = "Fire Rate",
        Flag = "ProjectileAuraFireRate",
        Min = 0,
        Max = 0.5,
        Default = 0.02,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            ProjectileAura.Settings.FireRate = value
        end
    })

    ProjAura:Slider({
        Name = "Max Angle",
        Flag = "ProjectileAuraMaxAngle",
        Min = 1,
        Max = 360,
        Default = 360,
        CallingFunction = function(self, value: number)
            ProjectileAura.Settings.MaxAngle = value
        end
    })

    ProjAura:Dropdown({
        Name = "Targets",
        Flag = "ProjectileAuraTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value: {})
            if value.Players ~= nil or value.Npcs ~= nil then
                ProjectileAura.Settings.Targets = value
            else
                ProjectileAura.Settings.Targets = {
                    Players = table.find(value, "Players") ~= nil,
                    Npcs = table.find(value, "Npcs") ~= nil
                }
            end
        end
    })

    ProjAura:Dropdown({
        Name = "Target Mode",
        Flag = "ProjectileAuraTargetMode",
        Default = "Distance",
        Options = {"Distance", "Angle", "Lowest Health", "Highest Health"},
        CallingFunction = function(self, value: string)
            ProjectileAura.Settings.TargetMode = value
        end
    })    

    ProjAura:MiniToggle({
        Name = "Wall Check",
        Flag = "ProjectileAuraWallCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            ProjectileAura.Settings.WallCheck = value
        end
    })
end)();

(function()
    local LongJump

    local Settings = {
        FireballSpeed = 28,
        HammerSpeed = 60,
        YuziSpeed = 150,
        CameraDirection = false
    }

    local State = {
        Start = nil,
        Direction = nil,
        Boost = 0,
        EndTick = 0,
        Token = 0,
        Locked = false,
        Controls = nil,
        OldWalkSpeed = nil,
        OldJumpPower = nil,
        OldJumpHeight = nil,
        Placed = {}
    }

    local MovementActions = {
        Enum.PlayerActions.CharacterForward,
        Enum.PlayerActions.CharacterBackward,
        Enum.PlayerActions.CharacterLeft,
        Enum.PlayerActions.CharacterRight,
        Enum.PlayerActions.CharacterJump
    }

    local function SinkMovement()
        return Enum.ContextActionResult.Sink
    end

    local function GetCharacterParts()
        if not Bloomware:IsAlive(LocalPlayer) then return nil, nil end
        local Character = LocalPlayer.Character
        return Character.PrimaryPart, Character:FindFirstChildOfClass("Humanoid")
    end

    local function ForceImmediateRestore()
        local Root, Humanoid = GetCharacterParts()

        ContextActionService:UnbindAction("BloomwareLongJumpMovementLock")

        pcall(function()
            if State.Controls then
                State.Controls:Enable()
            else
                require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls():Enable()
            end
        end)

        if Humanoid then
            Humanoid.WalkSpeed = State.OldWalkSpeed or 16
            Humanoid.JumpPower = State.OldJumpPower or 50
            Humanoid.JumpHeight = State.OldJumpHeight or 7.2
            Humanoid:Move(Vector3.zero, false)
        end

        if Root then
            Root.AssemblyLinearVelocity = Vector3.zero
        end

        State.Locked = false
        State.Controls = nil
    end

    local function SetControlsLocked(locked: boolean)
        if State.Locked == locked then return end
        State.Locked = locked

        local Root, Humanoid = GetCharacterParts()

        if locked then
            pcall(function()
                GameData.Utils.Sprint:stopSprinting()
            end)

            ContextActionService:BindActionAtPriority(
                "BloomwareLongJumpMovementLock",
                SinkMovement,
                false,
                3000,
                unpack(MovementActions)
            )

            pcall(function()
                local Controls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                Controls:Disable()
                State.Controls = Controls
            end)

            if Humanoid then
                State.OldWalkSpeed = Humanoid.WalkSpeed
                State.OldJumpPower = Humanoid.JumpPower
                State.OldJumpHeight = Humanoid.JumpHeight
                Humanoid.WalkSpeed = 0
                Humanoid.JumpPower = 0
                Humanoid.JumpHeight = 0
                Humanoid:Move(Vector3.zero, false)
            end

            if Root then
                Root.AssemblyLinearVelocity *= Vector3.new(0, 1, 0)
            end
        else
            ForceImmediateRestore()
        end
    end

    local function FlatUnit(vec: Vector3): Vector3
        local Flat = Vector3.new(vec.X, 0, vec.Z)
        return Flat.Magnitude > 0 and Flat.Unit or Vector3.new(0, 0, -1)
    end

    local function CurrentLookVector(): Vector3
        local Root = GetCharacterParts()
        return (Settings.CameraDirection and CurrentCamera or Root).CFrame.LookVector
    end

    local function HeldTool(): Instance?
        local CurrentItem = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HandInvItem")
        if CurrentItem and CurrentItem:IsA("ObjectValue") then
            return CurrentItem.Value
        end

        local Inventory = GetInventory()
        return Inventory and Inventory.hand and Inventory.hand.tool
    end

    local function ItemFromTool(tool: Instance?)
        if not tool then return nil end

        local Inventory = GetInventory()
        local Items = Inventory and Inventory.items or {}
        for _, Item in Items do
            if Item.tool == tool or Item.itemType == tool.Name then
                return Item
            end
        end

        return nil
    end

    local function GetSafeModifiers(): any
        local ModifierObject = GameData.Utils.Sprint:getMovementStatusModifier()

        if ModifierObject.getModifiers then
            return ModifierObject:getModifiers()
        end

        return ModifierObject.modifiers or {}
    end

    local function GetConstant(ConstantSpeed: number, CurrentMulti: number): (boolean, number)
        local MaxValue = math.max(CurrentMulti, 1)

        if ConstantSpeed > MaxValue then
            local RoundedConstant = math.round(ConstantSpeed)
            local Adjusted = ConstantSpeed - (RoundedConstant * (62 / 1000))

            return false, Adjusted
        end

        return true, CurrentMulti
    end

    local function AddMoveMultiplier(CurrentMulti: number, MoveMultiplier: number): number
        local Delta = MoveMultiplier - 1

        if Delta <= 0 then
            return CurrentMulti
        end

        return CurrentMulti + Delta
    end

    local function ApplyFinalBoost(CurrentMulti: number): number
        local Rounded = math.round(CurrentMulti)

        local BaseBoost = 16 / 100
        local ScaledBoost = Rounded * 2 / 100

        return CurrentMulti + BaseBoost + ScaledBoost
    end

    local function BoostSpeed(): number
        local Multi = 0
        local Increase = true

        local Modifiers = GetSafeModifiers()

        for _, Modifier in next, Modifiers do
            local ConstantSpeed = (Modifier and Modifier.constantSpeedMultiplier) or 0
            Increase, Multi = GetConstant(ConstantSpeed, Multi)
        end

        for _, Modifier in next, Modifiers do
            local MoveSpeed = (Modifier and Modifier.moveSpeedMultiplier) or 0
            Multi = AddMoveMultiplier(Multi, MoveSpeed)
        end

        if Multi > 0 and Increase then
            Multi = ApplyFinalBoost(Multi)
        end

        return (Multi + 1) * ((3 ^ 3) - 7)
    end

    local function ArmBoost(direction: Vector3, boost: number, duration: number)
        State.Direction = FlatUnit(direction)
        State.Boost = boost
        State.EndTick = tick() + duration
    end

    local function FireJumpProjectile(item, position: Vector3?, projectile: string, velocity: number, direction: Vector3)
        if not item or not position then return end

        local Origin = position - direction * 0.1
        local Shoot = CFrame.lookAlong(Origin, Vector3.new(0, -velocity, 0))

        SwitchItem(item.tool)
        task.wait(0.2)

        GameData.Utils.Remotes:Get("ProjectileFire"):CallServerAsync(
            item.tool,
            item.itemType,
            projectile,
            Shoot.Position,
            Origin,
            Shoot.LookVector * velocity,
            HttpService:GenerateGUID(false),
            {
                drawDurationSec = 0,
                drawDurationSeconds = 0,
                shotId = HttpService:GenerateGUID(false)
            },
            workspace:GetServerTimeNow() - 0.325
        )
    end

    local function FinishAttempt(module)
        State.Token += 1
        ForceImmediateRestore()

        if module.Enabled then
            module:SetValue(false)
        end
    end

    local Drivers, Mode = {}, ""

    Drivers.fireball = function(item, position: Vector3?, direction: Vector3)
        Mode = "Fireball"
        FireJumpProjectile(item, position, "fireball", 60, direction)
    end

    Drivers.jade_hammer = function(item, _, direction: Vector3)
        if not item then return end

        Mode = "Jade"

        local Ability = item.itemType .. "_jump"
        while LongJump.Enabled and not GameData.Utils.AbilityController:canUseAbility(Ability) do
            task.wait()
        end

        if LongJump.Enabled and GameData.Utils.AbilityController:canUseAbility(Ability) then
            GameData.Utils.AbilityController:useAbility(Ability)
            ArmBoost(direction, 1.3 * (Settings.HammerSpeed + 10), 2.5)
        end
    end

    Drivers.wood_dao = function(item, position: Vector3?, direction: Vector3)
        if not item or not position then return end

        Mode = "Yuzi"

        while LongJump.Enabled and ((LocalPlayer.Character:GetAttribute("CanDashNext") or 0) > workspace:GetServerTimeNow() or not GameData.Utils.AbilityController:canUseAbility("dash")) do
            task.wait()
        end

        if LongJump.Enabled then
            GameData.Utils.SwordController.lastAttack = workspace:GetServerTimeNow()
            SwitchItem(item.tool, 0.1)
            ReplicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
                direction = direction,
                origin = position,
                weapon = item.itemType
            })
            ArmBoost(direction, math.max(Settings.YuziSpeed - 3, 0), 2.5)
        end
    end

    local DriverAliases = {
        stone_dao = Drivers.wood_dao,
        iron_dao = Drivers.wood_dao,
        diamond_dao = Drivers.wood_dao,
        emerald_dao = Drivers.wood_dao,
        void_axe = Drivers.jade_hammer
    }

    local function GetDriver(name: string)
        return Drivers[name] or DriverAliases[name]
    end

    local function FindDriver()
        local Tool = HeldTool()
        local Driver = Tool and GetDriver(Tool.Name)
        if Driver then
            return Driver, ItemFromTool(Tool)
        end

        for Name, Method in Drivers do
            local Item = GetItem(Name)
            if Item then
                return Method, Item
            end
        end

        for Name, Method in DriverAliases do
            local Item = GetItem(Name)
            if Item then
                return Method, Item
            end
        end

        return nil, nil
    end

    local function StartFailsafe(module, token: number)
        task.delay(3, function()
            if module.Enabled and State.Token == token and State.Boost == 0 then
                FinishAttempt(module)
            end
        end)
    end

    local function WaitForIdle(token: number): boolean
        local Started = tick()

        repeat
            local Root, Humanoid = GetCharacterParts()
            if not LongJump.Enabled or State.Token ~= token or not Root or not Humanoid then
                return false
            end

            pcall(function()
                GameData.Utils.Sprint:stopSprinting()
            end)

            Humanoid.WalkSpeed = 0
            Humanoid.JumpPower = 0
            Humanoid.JumpHeight = 0
            Humanoid:Move(Vector3.zero, false)
            Root.AssemblyLinearVelocity = Vector3.new(0, math.min(Root.AssemblyLinearVelocity.Y, 0), 0)
            task.wait()
        until (tick() - Started) >= ((3 ^ 2 + 3 ^ 2) / 100)

        for _ = 1, 8 do
            local Root, Humanoid = GetCharacterParts()
            if not LongJump.Enabled or State.Token ~= token or not Root or not Humanoid then
                return false
            end

            Humanoid:Move(Vector3.zero, false)
            Root.AssemblyLinearVelocity = Vector3.new(0, Root.AssemblyLinearVelocity.Y, 0)

            local FlatVelocity = Vector3.new(Root.AssemblyLinearVelocity.X, 0, Root.AssemblyLinearVelocity.Z)
            if FlatVelocity.Magnitude <= 0.1 then
                State.Start = Root.Position
                return true
            end

            task.wait()
        end

        local Root = GetCharacterParts()
        if Root then
            State.Start = Root.Position
        end

        return true
    end

    LongJump = Windows.Movement:CreateModule({
        Name = "Long Jump",
        Flag = "LongJump",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if not Bloomware:IsAlive(LocalPlayer) then
                    task.delay(0.1, self.SetValue, self, false)
                    return
                end

                Warning("Long Jump", "Don't move!", 1)

                local Fly = Windows.Movement.Modules.Fly
                if Fly.Enabled then
                    Fly:SetValue(false)
                end

                State.Token += 1
                State.Start = LocalPlayer.Character.PrimaryPart.Position
                State.Direction = nil
                State.Boost = 0
                State.EndTick = 0
                SetControlsLocked(true)

                self:Connection(GameData.Events.Damage.Event:Connect(function(Values)
                    if Values.DamagedPlayer == LocalPlayer then
                        local KnockbackBoost = GameData.Utils.Knockback.calculateKnockbackVelocity(Vector3.one, 1, {
                            vertical = 0,
                            horizontal = 1
                        }).Magnitude * 1.1

                        if KnockbackBoost >= State.Boost and Bloomware:IsAlive(LocalPlayer) then
                            local Root = LocalPlayer.Character.PrimaryPart
                            local Pos = Values.Damager and Values.Damager.PrimaryPart and Values.Damager.PrimaryPart.Position
                            local Vec = Pos and (Root.Position - Pos) or Root.CFrame.LookVector
                            ArmBoost(Vec.Magnitude > 0 and Vec or Root.CFrame.LookVector, math.max(KnockbackBoost, 2.5 * (Mode == "Fireball" and Settings.FireballSpeed or Mode == "Hammer" and Settings.HammerSpeed or Settings.YuziSpeed)), 2.5)
                        end
                    end
                end))

                self:Connection(RunService.PreSimulation:Connect(function(delta: number)
                    local Root, Humanoid = GetCharacterParts()

                    if not self.Enabled then
                        ForceImmediateRestore()
                        return
                    end

                    if Humanoid then
                        Humanoid.WalkSpeed = 0
                        Humanoid.JumpPower = 0
                        Humanoid.JumpHeight = 0
                        Humanoid:Move(Vector3.zero, false)
                    end

                    if Root and Humanoid and isnetworkowner(Root) then
                        if State.Direction and State.EndTick > tick() then
                            Root.AssemblyLinearVelocity = Vector3.new(0, Root.AssemblyLinearVelocity.Y, 0) + State.Direction * (BoostSpeed() + ((State.EndTick - tick()) > 11e-1 and State.Boost or 0))
                            
                            if Humanoid.FloorMaterial == Enum.Material.Air and not State.Start then
                                Root.AssemblyLinearVelocity += Vector3.new(0, delta * (workspace.Gravity - 25), 0)
                            else
                                Root.AssemblyLinearVelocity = Vector3.new(Root.AssemblyLinearVelocity.X, 5, Root.AssemblyLinearVelocity.Z)
                            end
                            
                            State.Start = nil
                        else
                            if State.Start then
                                Root.CFrame = CFrame.lookAlong(State.Start, Root.CFrame.LookVector)
                            end
                            Root.AssemblyLinearVelocity = Vector3.zero
                            if State.Direction then
                                FinishAttempt(self)
                            end
                            State.Boost = 0
                        end
                    else
                        State.Start = nil
                    end
                end))

                local Token = State.Token
                task.spawn(function()
                    if not WaitForIdle(Token) then
                        return
                    end

                    local Driver, Item = FindDriver()
                    if Driver then
                        task.spawn(Driver, Item, State.Start, CurrentLookVector())
                        StartFailsafe(self, Token)
                        return
                    end

                    FinishAttempt(self)
                end)
            else
                FinishAttempt(self)
            end
        end
    })

    LongJump:Slider({
        Name = "Fireball Speed",
        Flag = "LongJumpSpeedFireball",
        Min = 1,
        Max = 28,
        Default = 28,
        CallingFunction = function(self, value: number)
            Settings.FireballSpeed = value
        end
    })

    LongJump:Slider({
        Name = "Yuzi Speed",
        Flag = "LongJumpSpeedYuzi",
        Min = 1,
        Max = 150,
        Default = 150,
        CallingFunction = function(self, value: number)
            Settings.YuziSpeed = value
        end
    })

    LongJump:Slider({
        Name = "Hammer Speed",
        Flag = "LongJumpSpeedHammer",
        Min = 1,
        Max = 60,
        Default = 60,
        CallingFunction = function(self, value: number)
            Settings.HammerSpeed = value
        end
    })

    LongJump:MiniToggle({
        Name = "Camera Direction",
        Flag = "LongJumpCameraDirection",
        CallingFunction = function(self, value: boolean)
            Settings.CameraDirection = value
        end
    })
end)();

(function()
    local Studs = 5
    local HoldingKeybind = false

    local Param = RaycastParams.new()
    Param.FilterType = Enum.RaycastFilterType.Exclude

    local Phase = Windows.Movement:CreateModule({
        Name = "Phase",
        Flag = "Phase",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(RunService.PreSimulation:Connect(function()
                    if Bloomware:IsAlive(LocalPlayer) and isnetworkowner(LocalPlayer.Character.PrimaryPart) and HoldingKeybind then
                        local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart
                        local Humanoid: Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

                        Param.FilterDescendantsInstances = CollectionService:GetTagged("entity")
                        local Ray: RaycastResult? = workspace:Raycast(PrimaryPart.Position, Humanoid.MoveDirection * 3, Param)
                        if Ray then
                            PrimaryPart.CFrame = CFrame.new(PrimaryPart.Position + (Humanoid.MoveDirection * Studs))
                        end
                    end
                end))
            end
        end
    })

    Phase:KeyBind({
        Name = "Phase Bind",
        MobileText = "Use Phase",
        Flag = "PhaseActualBind",
        DestroyMobileButtonOnDisable = true,
        Default = Enum.KeyCode.LeftShift,
        Events = {
            Began = function()
                HoldingKeybind = true
            end,
            Ended = function()
                HoldingKeybind = false
            end
        }
    })

    Phase:Slider({
        Name = "TP Studs",
        Flag = "PhaseStuds",
        Min = 1,
        Max = 10,
        Default = 3,
        CallingFunction = function(self, value: number)
            Studs = value
        end
    })
end)();

(function()
    local Distance: number = 18
    local Delay: number = 0
    local SelectedUpgrades = {}
    local UICheck: boolean = false

    local AutoUpgrade = Windows.Utility:CreateModule({
        Name = "Auto Upgrade",
        Flag = "AutoUpgrade",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    if UICheck and not GameData.Utils.App:isAppOpen(GameData.Utils.AppIds.TEAM_UPGRADE) then
                        task.wait()
                        continue
                    end

                    local Diamonds = GetItem("diamond")
                    local TeamUpgradeShop = GetNearestTaggedItem("TeamUpgradeShopkeeper")

                    if Diamonds and TeamUpgradeShop.Item and Distance >= TeamUpgradeShop.Distance and TeamUpgradeShop.Id then
                        for i,v in SelectedUpgrades do
                            local Id: string, Item = GetUpgradeFromName(i)
                            if Id and Item then
                                local Current = GameData.Utils.TeamUpgradesController.currentUpgrades[Id]
                                local NextUpgrade = 1

                                if Current then
                                    NextUpgrade = (Current + 1)
                                end

                                local NextTier = Item.tiers[NextUpgrade]
                                if NextTier and Diamonds.amount >= NextTier.cost then
                                    GameData.Utils.TeamUpgradesController:requestPurchaseTeamUpgrade(Id)

                                    if Delay ~= 0 then
                                        task.wait(Delay)
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    local Upgrades = {}
    for i,v in GameData.Utils.TeamUpgradeMeta do
        table.insert(Upgrades, v.name)
    end

    AutoUpgrade:Dropdown({
        Name = "Upgrades",
        Flag = "AutoUpgradeUpgrades",
        Default = {"Damage", "Armor"},
        Options = Upgrades,
        MaxLimit = math.huge,
        CallingFunction = function(self, value: {string})
            SelectedUpgrades = value
        end
    })

    AutoUpgrade:Slider({
        Name = "Distance",
        Flag = "AutoUpgradeDistance",
        Min = 1,
        Max = 18,
        Default = 18,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })

    AutoUpgrade:Slider({
        Name = "Delay",
        Flag = "AutoUpgradeDelay",
        Min = 0,
        Max = 5,
        Default = 0,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            Delay = value
        end
    })

    AutoUpgrade:MiniToggle({
        Name = "UI Check",
        Flag = "AutoUpgradeUICheck",
        CallingFunction = function(self, value: boolean)
            UICheck = value
        end
    })
end)();

(function()
    local Distance: number = 18
    local Delay: number = 0
    local UICheck: boolean = false
    local SelectedItems = {}

    local Purchased = {}
    local AutoBuy = Windows.Utility:CreateModule({
        Name = "Auto Buy",
        Flag = "AutoBuy",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    if UICheck and not GameData.Utils.App:isAppOpen(GameData.Utils.AppIds.BEDWARS_ITEM_SHOP) then
                        task.wait()
                        continue
                    end

                    local ItemShop = GetNearestTaggedItem("BedwarsItemShop")
                    if ItemShop.Item and Distance >= ItemShop.Distance and ItemShop.Id then
                        if SelectedItems.Sword then
                            local NextSword = GetNextSword()
                            if NextSword then
                                local Currency = GetItem(NextSword.currency)
                                if Currency and Currency.amount >= NextSword.price and (not Purchased[NextSword.itemType] or (os.clock() - Purchased[NextSword.itemType]) > 5) then
                                    Purchased[NextSword.itemType] = os.clock()
                                    GameData.Utils.Remotes:Get("BedwarsPurchaseItem"):CallServerAsync({
                                        shopItem = NextSword,
                                        shopId = ItemShop.Id
                                    })
                                    
                                    task.wait(0.1 + Delay)
                                end
                            end
                        end

                        if SelectedItems.Armor then
                            local NextArmor = GetNextArmor()
                            if NextArmor then
                                local Currency = GetItem(NextArmor.currency)
                                if Currency and Currency.amount >= NextArmor.price and (not Purchased[NextArmor.itemType] or (os.clock() - Purchased[NextArmor.itemType]) > 5) then
                                    Purchased[NextArmor.itemType] = os.clock()
                                    GameData.Utils.Remotes:Get("BedwarsPurchaseItem"):CallServerAsync({
                                        shopItem = NextArmor,
                                        shopId = ItemShop.Id
                                    })

                                    task.wait(0.1 + Delay)
                                end
                            end
                        end

                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    AutoBuy:Dropdown({
        Name = "Items",
        Flag = "AutoBuyItems",
        Default = {"Sword", "Armor"},
        Options = {"Sword", "Armor"},
        MaxLimit = math.huge,
        CallingFunction = function(self, value: {string})
            SelectedItems = value
        end
    })

    AutoBuy:Slider({
        Name = "Distance",
        Flag = "AutoBuyDistance",
        Min = 1,
        Max = 18,
        Default = 18,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })

    AutoBuy:Slider({
        Name = "Delay",
        Flag = "AutoBuyDelay",
        Min = 0,
        Max = 5,
        Default = 0,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            Delay = value
        end
    })

    AutoBuy:MiniToggle({
        Name = "UI Check",
        Flag = "AutoBuyUICheck",
        CallingFunction = function(self, value: boolean)
            UICheck = value
        end
    })
end)();

(function()
    local Distance: number = 18
    local Delay: number = 0
    local Collected = {}

    local PickupRange = Windows.Utility:CreateModule({
        Name = "Pickup Range",
        Flag = "PickupRange",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    local ItemDrop = GetNearestTaggedItem("ItemDrop", Collected)
                    if ItemDrop.Item and Distance >= ItemDrop.Distance then
                        GameData.Utils.Remotes:Get("PickupItemDrop"):CallServerAsync({
                            itemDrop = ItemDrop.Item
                        })

                        local StoreIndex: number = #Collected + 1
                        table.insert(Collected, StoreIndex, ItemDrop.Item)
                        task.delay(1.2, table.remove, Collected, StoreIndex)

                        if Delay ~= 0 then
                            task.wait(Delay)
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    PickupRange:Slider({
        Name = "Distance",
        Flag = "PickupRangeDistance",
        Min = 1,
        Max = 10,
        Default = 10,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })

    PickupRange:Slider({
        Name = "Delay",
        Flag = "PickupRangeDelay",
        Min = 0,
        Max = 5,
        Default = 0.1,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            Delay = value
        end
    })
end)();

(function()
    local AntiHitData = {
        Settings = {
            Distance = 27,
            Height = 100,
            StayUp = 0.2,
            StayDown = 0.1,
            WaitUntilDamage = false,
            Dynamic = false,
            UpModifier = 0.5,
            DownModifier = 0.5,
            Targets = {
                Players = false,
                Npcs = false
            }
        },
        Data = {
            Target = nil,
            OldPos = nil,
            GoUp = true,
            CanTeleport = false,
            Clone = nil
        }
    }

    local AntiHit = Windows.Combat:CreateModule({
        Name = "Anti Hit",
        Flag = "AntiHit",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat task.wait() until GameData.Utils.Store:getState().Game.matchstate ~= 0

                self:Connection(GameData.Events.Damage.Event:Connect(function(Data)
                    if AntiHitData.Data.Target and Data.Damaged == AntiHitData.Data.Target then
                        AntiHitData.Data.CanTeleport = true
                        task.delay(0.05, function()
                            AntiHitData.Data.CanTeleport = false
                        end)
                    end
                end))

                self:Connection(RunService.PreRender:Connect(function()
                    if AntiHitData.Data.Clone and Bloomware:IsAlive(LocalPlayer) then
                        local RealClone: BasePart = AntiHitData.Data.Clone.Clone
                        local OldRoot: BasePart = AntiHitData.Data.Clone.PrimaryPart
                        RealClone.CFrame = CFrame.lookAlong(Vector3.new(OldRoot.Position.X, RealClone.Position.Y, OldRoot.Position.Z), OldRoot.CFrame.LookVector)
                        RealClone.AssemblyLinearVelocity = Vector3.new(RealClone.AssemblyLinearVelocity.X, OldRoot.AssemblyLinearVelocity.Y + (LocalPlayer.Character.Humanoid.HipHeight * 1.6), RealClone.AssemblyLinearVelocity.Z)
                    end
                end))

                repeat
                    local NearestEntity = GetEntity({
                        TeamCheck = true,
                        MaxRange = AntiHitData.Settings.Distance,
                        Targets = AntiHitData.Settings.Targets
                    })

                    local Fly = Windows.Movement.Modules.Fly
                    local LongJump = Windows.Movement.Modules.LongJump
                    
                    if Fly.Enabled or LongJump.Enabled then
                        task.wait()
                        continue
                    end

                    if Bloomware:IsAlive(LocalPlayer) and NearestEntity.Entity and GameData.Utils.Store:getState().Game.matchState == GameData.Utils.MatchStates.RUNNING then
                        if not AntiHitData.Data.Clone then
                            AntiHitData.Data.Clone = MakeClone()
                        end

                        local PrimaryPart: BasePart = AntiHitData.Data.Clone.PrimaryPart
                        AntiHitData.Data.Target = NearestEntity.Entity
                        repeat 
                            local NewEntity = GetEntity({
                                TeamCheck = true,
                                MaxRange = AntiHitData.Settings.Distance,
                                Targets = AntiHitData.Settings.Targets
                            })

                            if not NewEntity.Entity then
                                break
                            end
                            task.wait() 
                        until AntiHitData.Data.CanTeleport or not AntiHitData.Settings.WaitUntilDamage

                        if self.Enabled and AntiHitData.Data.Clone and Bloomware:IsAlive(LocalPlayer) and isnetworkowner(LocalPlayer.Character.PrimaryPart) then
                            local StayUp: number = AntiHitData.Settings.StayUp
                            local StayDown: number = AntiHitData.Settings.StayDown

                            if not AntiHitData.Settings.WaitUntilDamage and AntiHitData.Settings.Dynamic then
                                local PlayerHealth: number = LocalPlayer.Character.Humanoid.Health or 100
                                local TargetHealth: number = (NearestEntity.Data and NearestEntity.Data.Humanoid and NearestEntity.Data.Humanoid.Health) or 100
                                local Difference: number = PlayerHealth - TargetHealth

                                if math.abs(Difference) <= 5 then
                                    StayUp = AntiHitData.Settings.StayUp
                                    StayDown = AntiHitData.Settings.StayDown
                                else
                                    if Difference > 0 then
                                        StayDown = math.max(0.1, AntiHitData.Settings.StayDown - AntiHitData.Settings.DownModifier)
                                        StayUp = math.max(0.1, AntiHitData.Settings.StayUp - (AntiHitData.Settings.UpModifier * 0.5))
                                    else
                                        StayDown = math.max(0.1, AntiHitData.Settings.StayDown + (AntiHitData.Settings.DownModifier * 0.5))
                                        StayUp = math.max(0.1, AntiHitData.Settings.StayUp + AntiHitData.Settings.UpModifier)
                                    end
                                end
                            end

                            PrimaryPart.CFrame = AntiHitData.Data.Clone.Clone.CFrame + Vector3.new(0, AntiHitData.Settings.Height, 0)
                            task.wait(StayUp)
                            PrimaryPart.Velocity = Vector3.new(0, -1, 0)
                            PrimaryPart.CFrame = AntiHitData.Data.Clone.Clone.CFrame
                            task.wait(StayDown)

                            AntiHitData.Data.GoUp = not AntiHitData.Data.GoUp
                        end
                    else
                        AntiHitData.Data.Target = nil
                        if AntiHitData.Data.Clone then
                            AntiHitData.Data.Clone:Destroy()
                        end

                        AntiHitData.Data.Clone = nil
                    end
                    task.wait()
                until not self.Enabled
            else
                AntiHitData.Data.Target = nil
                local NewCF: CFrame
                if AntiHitData.Data.Clone then
                    NewCF = AntiHitData.Data.Clone.Clone.CFrame
                    AntiHitData.Data.Clone:Destroy()
                end

                AntiHitData.Data.Clone = nil
                if NewCF and Bloomware:IsAlive(LocalPlayer) then
                    LocalPlayer.Character.PrimaryPart.CFrame = NewCF
                end
            end
        end
    })

    AntiHit:Slider({
        Name = "Distance",
        Flag = "AntiHitDistance",
        Min = 1,
        Max = 30,
        Default = 22,
        CallingFunction = function(self, value: number)
            AntiHitData.Settings.Distance = value
        end
    })

    AntiHit:Dropdown({
        Name = "Targets",
        Flag = "AntiHitTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value: {})
            AntiHitData.Settings.Targets = value
        end
    })  

    local Dynamic, Up, Down
    AntiHit:MiniToggle({
        Name = "Damage Wait",
        Flag = "AntiHitDamageWait",
        CallingFunction = function(self, value: boolean)
            AntiHitData.Settings.WaitUntilDamage = value
            Dynamic:SetVisiblity(not value)
            Up:SetVisiblity(Dynamic.Enabled)
            Down:SetVisiblity(Dynamic.Enabled)
        end
    })

    Dynamic = AntiHit:MiniToggle({
        Name = "Dynamic",
        Flag = "AntiHitDynamic",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AntiHitData.Settings.Dynamic = value
            Up:SetVisiblity(value)
            Down:SetVisiblity(value)
        end
    })

    AntiHit:Slider({
        Name = "Height",
        Flag = "AntiHitHeight",
        Min = 1,
        Max = 200,
        Default = 100,
        CallingFunction = function(self, value: number)
            AntiHitData.Settings.Height = value
        end
    })

    AntiHit:Slider({
        Name = "Stay Up",
        Flag = "AntiHitStayUp",
        Min = 0.1,
        Max = 1,
        Default = 0.2,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AntiHitData.Settings.StayUp = value
        end
    })

    AntiHit:Slider({
        Name = "Stay Down",
        Flag = "AntiHitStayDown",
        Min = 0.1,
        Max = 1,
        Default = 0.1,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AntiHitData.Settings.StayDown = value
        end
    })

    Up = AntiHit:Slider({
        Name = "Up Modifier",
        Flag = "AntiHitUpModifier",
        Min = 0,
        Max = 2,
        Default = 0.5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            AntiHitData.Settings.UpModifier = value
        end
    })

    Down = AntiHit:Slider({
        Name = "Down Modifier",
        Flag = "AntiHitDownModifier",
        Min = 0,
        Max = 2,
        Default = 0.5,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            AntiHitData.Settings.DownModifier = value
        end
    })
end)();

(function()
    local StaffDetectorData = {
        Settings = {
            Mode = "Uninject",
            Clan = false,
            YouTuber = false,
            Party = false
        },
        Data = {
            Clans = {"VA", "IPS", "TYP", "gg", "Gdoggs", "L8R", "DV", "ALPH4"},
            Players = {},
            Friends = {},
            Active = {}
        }
    }
    
    local function CheckGroup(Player, ID)
        return pcall(Player.GetRankInGroup, Player, ID)
    end
    
    local function Notify(Player, Reason)
        if StaffDetectorData.Settings.Mode == "Notify" and Bloomware then
            Warning("Staff Detector", string.format("Staff Detected: %s (%s)", Player.Name, Reason), 60)
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Staff Detector",
                Text = string.format("%s\nUser: %s (ID: %d)", Reason, Player.Name, Player.UserId),
                Duration = 60
            })
        end
        
        if StaffDetectorData.Settings.Party and GameData.Utils.Party then
            GameData.Utils.Party:leaveParty()
        end
        
        if StaffDetectorData.Settings.Mode == "Uninject" and Assets.Functions then
            Assets.Functions:Uninject()
        end
    end

    local function GetFriends(ID)
        if StaffDetectorData.Data.Friends[ID] then return StaffDetectorData.Data.Friends[ID] end
        
        local Success, List = pcall(function()
            local Friends = {}
            local Pages = Players:GetFriendsAsync(ID)
            local PageCount = 0
            
            repeat
                local CurrentPage = Pages:GetCurrentPage()
                for _, FriendData in next, CurrentPage do
                    Friends[FriendData.Id] = FriendData.Username
                end
                
                PageCount += 1
                if not Pages.IsFinished and PageCount < 12 then
                    Pages:AdvanceToNextPageAsync()
                end
            until Pages.IsFinished or PageCount >= 12
            
            return Friends
        end)
        
        if Success then
            StaffDetectorData.Data.Friends[ID] = List
            return List
        end

        return {}
    end
    
    local function FindMutual(Friends)
        for ID, Name in next, Friends do
            if StaffDetectorData.Data.Players[ID] then
                return Name
            end
        end
        return nil
    end
    
    local function CheckSpectator(player)
        if not player:GetAttribute("Spectator") or player:GetAttribute("Team") then
            return false
        end
        
        if GameData.Utils.Store and GameData.Utils.Store:getState().Game.customMatch then
            return false
        end
        
        local Friend: string = FindMutual(GetFriends(player.UserId))
        
        if not Friend then
            Notify(player, "Suspicious spectator join pattern")
            return true
        else
            if StaffDetectorData.Settings.Mode == "Notify" and Bloomware then
                Warning("Spectator Detector", string.format("Player %s connected via %s", player.Name, Friend), 15)
            end
        end

        return false
    end
    
    local function GroupRankCheck(player)
        local Success, Rank = CheckGroup(player, 5774246)
        return Success and Rank >= (StaffDetectorData.Settings.YouTuber and 20 or 100)
    end
    
    local function ClanCheck(player)
        local ClanTag = player:GetAttribute("ClanTag")
        if not ClanTag then return false end
        
        for _, BannedClan in next, StaffDetectorData.Data.Clans do
            if ClanTag == BannedClan then
                return true
            end
        end

        return false
    end
    
    local function CheckPlayer(player)
        if player == LocalPlayer then return end
        
        StaffDetectorData.Data.Players[player.UserId] = player.Name
        StaffDetectorData.Data.Active[player.UserId] = StaffDetectorData.Data.Active[player.UserId] or {}

        if GroupRankCheck(player) then
            Notify(player, "Verified staff member")
            return
        end

        local SpectatorCon
        SpectatorCon = player:GetAttributeChangedSignal("Spectator"):Connect(function()
            if CheckSpectator(player) then
                SpectatorCon:Disconnect()
                return
            end
        end)

        table.insert(StaffDetectorData.Data.Active[player.UserId], SpectatorCon)
        if CheckSpectator(player) or not StaffDetectorData.Settings.Clan then 
            return 
        end

        local function SeeClan()
            if ClanCheck(player) then
                Notify(player, string.format("Affiliated with restricted clan: %s", player:GetAttribute("ClanTag")))
                if SpectatorCon then
                    SpectatorCon:Disconnect()
                end
            end
        end
        
        if player:GetAttribute("ClanTag") then
            SeeClan()
        else
            local ClanCon = player:GetAttributeChangedSignal("ClanTag"):Connect(SeeClan)
            table.insert(StaffDetectorData.Data.Active[player.UserId], ClanCon)
        end
    end
    
    local function CleanConnection(player)
        if StaffDetectorData.Data.Active[player.UserId] then
            for _, v in next, StaffDetectorData.Data.Active[player.UserId] do
                if v.Connected then
                    v:Disconnect()
                end
            end
            StaffDetectorData.Data.Active[player.UserId] = nil
        end
        
        StaffDetectorData.Data.Players[player.UserId] = nil
        StaffDetectorData.Data.Friends[player.UserId] = nil
    end

    local StaffDetector = Windows.Utility:CreateModule({
        Name = "Staff Detector",
        Flag = "StaffDetector",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                for _, player in next, Players:GetPlayers() do
                    task.defer(CheckPlayer, player)
                end
                
                self:Connection(Players.PlayerAdded:Connect(CheckPlayer))
                self:Connection(Players.PlayerRemoving:Connect(CleanConnection))
            else
                for _, v in next, StaffDetectorData.Data.Active do
                    for _, conn in next, v do
                        if conn.Connected then
                            conn:Disconnect()
                        end
                    end
                end
                
                table.clear(StaffDetectorData.Data.Active)
                table.clear(StaffDetectorData.Data.Players)
                table.clear(StaffDetectorData.Data.Friends)
            end
        end
    })

    StaffDetector:Dropdown({
        Name = "Mode",
        Flag = "StaffDetectorMode",
        Default = "Uninject",
        Options = {"Uninject", "Notify"},
        CallingFunction = function(self, value: string)
            StaffDetectorData.Settings.Mode = value
        end
    })

    StaffDetector:MiniToggle({
        Name = "Clans",
        Flag = "StaffDetectorClans",
        Default = true,
        CallingFunction = function(self, value: boolean)
            StaffDetectorData.Settings.Clan = value
        end
    })

    StaffDetector:MiniToggle({
        Name = "YouTubers",
        Flag = "StaffDetectorYouTubers",
        Default = true,
        CallingFunction = function(self, value: boolean)
            StaffDetectorData.Settings.YouTuber = value
        end
    })

    StaffDetector:MiniToggle({
        Name = "Leave Party",
        Flag = "StaffDetectorParty",
        Default = true,
        CallingFunction = function(self, value: boolean)
            StaffDetectorData.Settings.Party = value
        end
    })
end)();

(function()
    local Restore = {}
    Windows.Utility:CreateModule({
        Name = "Anti AFK",
        Flag = "AntiAFK",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                for _, v in getconnections(LocalPlayer.Idled) do
                    if v.Enabled then
                        v:Disable()
                        table.insert(Restore, v)
                    end
                end

                for _, v in getconnections(RunService.Heartbeat) do
                    if v.Function and typeof(v.Function) == "function" and (islclosure and islclosure(v.Function) or iscclosure and not iscclosure(v.Function)) then
                        local Constants = debug.getconstants(v.Function)
                        if #Constants > 0 and table.find(Constants, "AfkInfo") then
                            v:Disable()
                            table.insert(Restore, v)
                        end
                    end
                end

                repeat
                    GameData.Utils.Remotes:Get("AfkInfo"):SendToServer({
                        afk = false
                    })
                    task.wait(3)
                until not self.Enabled
            else
                for i,v in Restore do
                    v:Enable()
                end

                table.clear(Restore)
            end
        end
    })
end)();

(function()
    local Delay: number = 0
    local Sent: boolean = false

    local AutoQueue = Windows.Utility:CreateModule({
        Name = "Auto Queue",
        Flag = "AutoQueue",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(GameData.Events.Death.Event:Connect(function(Values)  
                    if not Sent and Values.Final and Values.KilledPlayer and Values.KilledPlayer == LocalPlayer then
                        Sent = true
                        task.delay(Delay, GameData.Utils.QueueController.joinQueue, GameData.Utils.QueueController, GameData.Utils.Store:getState().Game.queueType)
                    end
                end))

                self:Connection(GameData.Events.MatchEnd.Event:Connect(function()
                    if not Sent then
                        Sent = true
                        task.delay(Delay, GameData.Utils.QueueController.joinQueue, GameData.Utils.QueueController, GameData.Utils.Store:getState().Game.queueType)
                    end
                end))
            end
        end
    })

    AutoQueue:Slider({
        Name = "Delay",
        Flag = "AutoQueueDelay",
        Min = 0,
        Max = 4,
        Default = 0,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            Delay = value
        end
    })
end)();

local function GetYLevel()
    local YLevel: number = math.huge
    local BlockStore = GameData.Utils.BlockEngine:getStore()
    for _, v in BlockStore:getAllBlockPositions() do
        local Block = BlockStore:getBlockAt(v + Vector3.new(0, 3, 0))
        if Block and YLevel > v.Y then
            YLevel = v.Y
            return YLevel
        end
    end
    return 0
end

(function()
    local Part: Part
    local LastCF: CFrame
    local Debounce: number = 0

    local AntiVoidData = {
        Loop = 20,
        Add = 8,
        Del = 0.4,
        Times = 3,
        Power = 10,
        Jumps = 7,
        Transparency = 0.5,
        Velo = 150,
        Speed = 0.2,
        DebounceTime = 0.2,
        UseDebounce = false,
        Mode = "Launch",
        Material = "Air",
        Color = Color3.fromRGB(255, 0, 0)
    }

    local AntiVoid = Windows.Utility:CreateModule({
        Name = "Anti Void",
        Flag = "AntiVoid",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                Part = Instance.new("Part", workspace)
                Part.Position = Vector3.new(0, GetYLevel() - 10, 0)
                Part.Size = Vector3.new(100000, 1, 100000)
                Part.Color = AntiVoidData.Color
                Part.Anchored = true
                Part.Transparency = AntiVoidData.Transparency
                Part.Material = Enum.Material[AntiVoidData.Material]
                Part.CanCollide = AntiVoidData.Mode ~= "Launch"
                GameData.Utils.GameQuery:setQueryIgnored(Part)

                local Pos: Vector3 = (Bloomware:IsAlive(LocalPlayer) and LocalPlayer.Character.HumanoidRootPart.Position.Y + 10) or Vector3.zero
                task.spawn(function()
                    repeat
                        Part.Color = AntiVoidData.Color
                        Part.Transparency = AntiVoidData.Transparency
                        Part.Material = Enum.Material[AntiVoidData.Material]
                        Part.CanCollide = AntiVoidData.Mode ~= "Launch"

                        if Bloomware:IsAlive(LocalPlayer) and LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                            Pos = LocalPlayer.Character.HumanoidRootPart.Position.Y
                        end
                        task.wait()
                    until not self.Enabled
                end)

                local Bounce = false
                self:Connection(Part.Touched:Connect(function(Part: Part)
                    if Bloomware:IsAlive(LocalPlayer) and Part.Parent == LocalPlayer.Character and ((os.clock() - Debounce) >= AntiVoidData.DebounceTime or not AntiVoidData.UseDebounce) and not Bounce then
                        Bounce = true
                        local PrimaryPart: BasePart = LocalPlayer.Character.PrimaryPart    
                        if AntiVoidData.Mode == "Launch" then
                            for i = 1, AntiVoidData.Loop do
                                task.wait(AntiVoidData.Del / 10)
                                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, i * (Pos - LocalPlayer.Character.HumanoidRootPart.Position.Y + AntiVoidData.Add), 0)
                            end
                        elseif AntiVoidData.Mode == "Teleport" then
                            local Grav = workspace.Gravity
                            workspace.Gravity = 0

                            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            for _ = 1, AntiVoidData.Times do
                                LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(0, AntiVoidData.Power, 0)
                                task.wait(AntiVoidData.Times / 20)
                            end

                            workspace.Gravity = Grav
                        elseif AntiVoidData.Mode == "Jump" then
                            for _ = 1, AntiVoidData.Jumps do
                                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                task.wait(0.1)
                            end
                        elseif AntiVoidData.Mode == "Velocity" then
                            local Current: Vector3 = PrimaryPart.AssemblyLinearVelocity
                            PrimaryPart.AssemblyLinearVelocity = Vector3.new(Current.X, AntiVoidData.Velo, Current.Z)
                        elseif AntiVoidData.Mode == "Tween" then
                            if LastCF then
                                TweenService:Create(PrimaryPart, TweenInfo.new(AntiVoidData.Speed), {CFrame = LastCF}):Play()
                            end
                        end
                        Bounce = false   
                    end
                end))

                self:Connection(RunService.PreSimulation:Connect(function()
                    if Bloomware:IsAlive(LocalPlayer) then
                        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                            LastCF = LocalPlayer.Character.PrimaryPart.CFrame
                        end
                    end
                end))
            else
                if Part then
                    Part:Destroy()
                end
            end
        end
    })

    local PowerSlider, TweenSpeedSlider, JumpSlider
    local AntiVoidLaunch, AntiVoidTP = {}, {}
    AntiVoid:Dropdown({
        Name = "Mode",
        Flag = "AntiVoidMode",
        Options = {"Launch", "Teleport", "Jump", "Velocity", "Tween", "Walk"},
        Default = "Launch",
        CallingFunction = function(self, value: string)
            AntiVoidData.Mode = value
            PowerSlider:SetVisiblity(value == "Velocity")
            TweenSpeedSlider:SetVisiblity(value == "Tween")
            for _, v in next, AntiVoidLaunch do v:SetVisiblity(value == "Launch") end
            for _, v in next, AntiVoidTP do v:SetVisiblity(value == "Teleport") end
            JumpSlider:SetVisiblity(value == "Jump")
        end
    })

    AntiVoid:Dropdown({
        Name = "Material",
        Flag = "AntiVoidMaterial",
        Options = Materials,
        Default = "Air",
        CallingFunction = function(self, value: string)
            AntiVoidData.Material = value
        end
    })

    local DebounceTimeSlider
    AntiVoid:MiniToggle({
        Name = "Debounce",
        Flag = "AntiVoidDebounce",
        CallingFunction = function(self, value: boolean)
            AntiVoidData.UseDebounce = value
            DebounceTimeSlider:SetVisiblity(false)
        end
    })

    DebounceTimeSlider = AntiVoid:Slider({
        Name = "Debounce",
        Flag = "AntiVoidDebounceTime",
        Min = 0,
        Max = 1,
        Default = 0.2,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            AntiVoidData.DebounceTime = value
        end
    })

    table.insert(AntiVoidLaunch, AntiVoid:Slider({
        Name = "Loop",
        Flag = "AntiVoidLoop",
        Min = 5,
        Max = 4,
        Default = 20,
        CallingFunction = function(self, value: number)
            AntiVoidData.Loop = value
        end
    }))

    table.insert(AntiVoidLaunch, AntiVoid:Slider({
        Name = "Height Add",
        Flag = "AntiVoidAdd",
        Min = 5,
        Max = 15,
        Default = 8,
        CallingFunction = function(self, value: number)
            AntiVoidData.Add = value
        end
    }))

    table.insert(AntiVoidLaunch, AntiVoid:Slider({
        Name = "Delay",
        Flag = "AntiVoidDelay",
        Min = 0.1,
        Max = 0.6,
        Default = 0.4,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AntiVoidData.Del = value
        end
    }))

    table.insert(AntiVoidTP, AntiVoid:Slider({
        Name = "TP Times",
        Flag = "AntiVoidTimes",
        Min = 1,
        Max = 5,
        Default = 3,
        CallingFunction = function(self, value: number)
            AntiVoidData.Times = value
        end
    }))

    table.insert(AntiVoidTP, AntiVoid:Slider({
        Name = "Power",
        Flag = "AntiVoidPower",
        Min = 5,
        Max = 15,
        Default = 10,
        CallingFunction = function(self, value: number)
            AntiVoidData.Power = value
        end
    }))

    JumpSlider = AntiVoid:Slider({
        Name = "Jumps",
        Flag = "AntiVoidJumps",
        Min = 3,
        Max = 15,
        Default = 7,
        CallingFunction = function(self, value: number)
            AntiVoidData.Jumps = value
        end
    })

    PowerSlider = AntiVoid:Slider({
        Name = "Velocity",
        Flag = "AntiVoidVelocityPower",
        Min = 50,
        Max = 400,
        Default = 200,
        CallingFunction = function(self, value: number)
            AntiVoidData.Velo = value
        end
    })

    TweenSpeedSlider = AntiVoid:Slider({
        Name = "Speed",
        Flag = "AntiVoidTweenSpeed",
        Min = 0.05,
        Max = 0.5,
        Default = 0.2,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AntiVoidData.Speed = value
        end
    })

    AntiVoid:Slider({
        Name = "Transparency",
        Flag = "AntiVoidPartTransparency",
        Min = 0,
        Max = 1,
        Default = 0.5,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AntiVoidData.Transparency = value
            if Part then
                Part.Transparency = value
            end
        end
    })

    AntiVoid:ColorSlider({
        Name = "Color",
        Flag = "AntiVoidPartColor",
        Default = Color3.fromRGB(255, 0, 0),
        CallingFunction = function(self, value: Color3)
            AntiVoidData.Color = value
            if Part then
                Part.Color = value
            end
        end
    })
end)();

(function()
    local SelectedKit: string = "Eldertree"
    local ActivationDistance: number = 28
    local ActivationDelay: number = 0
    local CanSwitchItem: boolean = false
    local MaxAngle: number = 360
    local Targets: {[string]: boolean} = {
        Players = false,
        Npcs = false
    }

    local AutoKit = Windows.Utility:CreateModule({
        Name = "Auto Kit",
        Flag = "AutoKit",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    if SelectedKit == "Eldertree" then
                        local NearestOrb = GetNearestTaggedItem("treeOrb")
                        if NearestOrb.Item and ActivationDistance >= NearestOrb.Distance and NearestOrb.Id then
                            if ActivationDelay ~= 0 then
                                task.wait(ActivationDelay)
                            end

                            GameData.Utils.Animation:playAnimation(LocalPlayer, GameData.Utils.ProdAnimations[GameData.Utils.AnimationType.PUNCH])
                            GameData.Utils.ViewmodelController:playAnimation(GameData.Utils.AnimationType.FP_USE_ITEM)
                            if GameData.Utils.Remotes:Get("ConsumeTreeOrb"):CallServer({treeOrbSecret = NearestOrb.Id}) then
                                NearestOrb.Orb:Destroy()
                            end
                        end
                    elseif SelectedKit == "Star Collector Stella" then
                        local NearestStar = GetNearestTaggedItem("stars_ProximityPrompt")
                        if NearestStar.Item and ActivationDistance >= NearestStar.Distance and NearestStar.Id then
                            if ActivationDelay ~= 0 then
                                task.wait(ActivationDelay)
                            end

                            GameData.Utils.Remotes:Get("CollectCollectableEntity"):SendToServer({
                                id = NearestStar.Id,
                                collectableName = NearestStar.Item.Name
                            })
                        end
                    elseif SelectedKit == "Beekeeper Beatrix" then
                        local NearestBee = GetNearestTaggedItem("bee")
                        if NearestBee.Item and ActivationDistance >= NearestBee.Distance and NearestBee.Id then
                            if ActivationDelay ~= 0 then
                                task.wait(ActivationDelay)
                            end

                            GameData.Utils.Animation:playAnimation(LocalPlayer, GameData.Utils.ProdAnimations[GameData.Utils.AnimationType.NET_CATCH])
                            GameData.Utils.Remotes:Get("PickUpBee"):SendToServer({
                                beeId = NearestBee.Id
                            })
                        end
                    elseif SelectedKit == "Kaida" then
                        local NearestEntity = GetEntity({
                            TeamCheck = true,
                            MaxRange  = ActivationDistance,
                            MaxAngle = MaxAngle,
                            Targets = Targets
                        })

                        if NearestEntity.Entity and GameData.Utils.SummonerKitBalance.CLAW_COOLDOWN < (workspace:GetServerTimeNow() - GameData.Utils.ClawHandController.lastAttackTime) then
                            local Claw = GetItem("summoner_claw", true)
                            if Claw and Claw.tool then
                                if CanSwitchItem then
                                    SwitchItem(Claw.tool)
                                end

                                GameData.Utils.ClawHandController.lastAttackTime = workspace:GetServerTimeNow()
                                GameData.Utils.Remotes:Get("SummonerClawAttackRequest"):SendToServer({
                                    position = NearestEntity.Data.Root.Position,
                                    direction = CFrame.lookAt(NearestEntity.Data.Root.Position, CurrentCamera.CFrame.Position).LookVector,
                                    clientTime = workspace:GetServerTimeNow()
                                })
                            end
                        end
                    elseif SelectedKit == "Grim Reaper" then
                        local NearestSoul = GetNearestTaggedItem("GrimSoul")
                        if NearestSoul.Item and ActivationDistance >= NearestSoul.Distance and NearestSoul.Id then
                            if ActivationDelay ~= 0 then
                                task.wait(ActivationDelay)
                            end

                            GameData.Utils.Animation:playAnimation(LocalPlayer, GameData.Utils.ProdAnimations[GameData.Utils.AnimationType.GRIM_REAPER_CONSUME])
                            GameData.Utils.Remotes:Get("ConsumeGrimReaperSoul"):CallServer({
                                secret = NearestSoul.Id
                            })
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    local SwitchItemToggle, TargetsOption, MaxAngleOption
    AutoKit:Dropdown({
        Name = "Kit",
        Flag = "AutoKitSelectedKit",
        Options = {"Eldertree", "Star Collector Stella", "Beekeeper Beatrix", "Kaida", "Grim Reaper"},
        Default = "Eldertree",
        CallingFunction = function(self, value: string)
            SelectedKit = value
            SwitchItemToggle:SetVisiblity(value == "Kaida")
            TargetsOption:SetVisiblity(value == "Kaida")
            MaxAngleOption:SetVisiblity(value == "Kaida")
        end
    })

    TargetsOption = AutoKit:Dropdown({
        Name = "Targets",
        Flag = "AutoKitTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value: {})
            Targets = value
        end
    })

    SwitchItemToggle = AutoKit:MiniToggle({
        Name = "Switch Item",
        Flag = "AutoKitSwitchItem",
        Default = true,
        CallingFunction = function(self, value: boolean)
            CanSwitchItem = value
        end
    })

    MaxAngleOption = AutoKit:Slider({
        Name = "Max Angle",
        Flag = "AutoKitMaxAngle",
        Min = 1,
        Max = 360,
        Default = 360,
        CallingFunction = function(self, value: number)
            MaxAngle = value
        end
    })

    AutoKit:Slider({
        Name = "Distance",
        Flag = "AutoKitActivationDistance",
        Min = 1,
        Max = 32,
        Default = 28,
        CallingFunction = function(self, value: number)
            ActivationDistance = value
        end
    })

    AutoKit:Slider({
        Name = "Delay",
        Flag = "AutoKitActivationDelay",
        Min = 0,
        Max = 5,
        Default = 0,
        CallingFunction = function(self, value: number)
            ActivationDelay = value
        end
    })
end)();

(function()
    local Boost = 50

    local AntiSuffocate = Windows.Utility:CreateModule({
        Name = "Anti Suffocate",
        Flag = "AntiSuffocate",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
					if Bloomware:IsAlive(LocalPlayer) and LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
						local BlockMid = GetBlockPlace(LocalPlayer.Character.HumanoidRootPart.Position)
                        local BlockDown = GetBlockPlace(LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 2, 0))
                        local BlockUp = GetBlockPlace(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
						if BlockMid and BlockDown and BlockUp then
							LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(0, Boost, 0)
						end
					end
                    task.wait()
				until not self.Enabled
            end
        end
    })

    AntiSuffocate:Slider({
        Name = "Boost",
        Flag = "AntiSuffocateBoost",
        Min = 10,
        Max = 100,
        Default = 50,
        CallingFunction = function(self, value: number)
            Boost = value
        end
    })
end)();

(function()
    local AutoToxicData = {
        Kill = false,
        Bed = false,
        Win = false,
        Final = false,
        Custom = false
    }

    local Messages = {
        Kill = {
            "L <PLR>",
            "cope <PLR>",
            "Bloomware > <PLR>",
            "gg ez <PLR>",
            "get better <PLR>",
            "easiest kill ever <PLR>",
            "imagine dying <PLR>",
            "get pwned <PLR>",
            "hop off <PLR> ✌️",
            "did you even try <PLR>?",
            "thanks for the kill <PLR> 😘"
        },
        Bed = {
            "nice bed <TEAM>",
            "<TEAM> has officially lost the game",
            "amusing defense <TEAM>",
            "<TEAM>'s bed got sent into the oblivion",
            "poof, your bed is gone <TEAM>"
        },
        Win = {
            "gg ez | Bloomware on top",
            "easiest game of my life | Bloomware on top",
            "didn't even have to try | Bloomware on top",
            "bot arena cleared | Bloomware on top",
            "has any of you even tried? | Bloomware on top",
            "trillionaire's bypasses have defeated y'all | Bloomware on top"
        }
    }

    local OldMessages = {
        Kill = Messages.Kill,
        Bed = Messages.Bed,
        Win = Messages.Win
    }

    local LastMessage = {
        Kill = nil,
        Bed = nil,
        Win = nil
    }

    local function GetRandomMessage(category: string, replace)
        local Table = Messages[category]
        if #Table == 1 then
            return string.gsub(Table[1], unpack(replace))
        end

        local Message: string
        repeat
            Message = Table[math.random(1, #Table)]
        until Message ~= LastMessage[category] or #Table == 1

        LastMessage[category] = Message
        for i, v in next, replace do
            Message = string.gsub(Message, i, v)
        end

        return Message
    end

    local AutoToxic = Windows.Utility:CreateModule({
        Name = "Auto Toxic",
        Flag = "AutoToxic",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(GameData.Events.Death.Event:Connect(function(Value)
                    if AutoToxicData.Kill and Value.Killer == LocalPlayer.Character and Value.KilledPlayer ~= LocalPlayer.Character and (AutoToxicData.Final and Value.Final or not AutoToxicData.Final) then
                        TextChatService.TextChannels.RBXGeneral:SendAsync(GetRandomMessage("Kill", {["<PLR>"] = Value.KilledPlayer.Name}))
                    end
                end))

                self:Connection(GameData.Events.BedBreak.Event:Connect(function(Value)
                    if AutoToxicData.Bed then
                        TextChatService.TextChannels.RBXGeneral:SendAsync(GetRandomMessage("Bed", {["<TEAM>"] = Value.TeamName}))
                    end
                end))

                self:Connection(GameData.Events.MatchEnd.Event:Connect(function(Value)
                    if AutoToxicData.Win and Value.TeamID == GameData.Utils.Store:getState().Game.myTeam.id then
                        TextChatService.TextChannels.RBXGeneral:SendAsync(GetRandomMessage("Win", {}))
                    end
                end))
            end
        end
    })

    local Final
    AutoToxic:MiniToggle({
        Name = "Kill",
        Flag = "AutoToxicKill",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AutoToxicData.Kill = value
            Final:SetVisiblity(value)
        end
    })

    Final = AutoToxic:MiniToggle({
        Name = "Final Kill",
        Flag = "AutoToxicFinalKill",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AutoToxicData.Final = value
        end
    })

    AutoToxic:MiniToggle({
        Name = "Bed Break",
        Flag = "AutoToxicBedBreak",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AutoToxicData.Bed = value
        end
    })

    AutoToxic:MiniToggle({
        Name = "Win",
        Flag = "AutoToxicWin",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AutoToxicData.Win = value
        end
    })

    local Kill, Bed, Win
    AutoToxic:MiniToggle({
        Name = "Custom",
        Flag = "AutoToxicCustom",
        CallingFunction = function(self, value: boolean)
            AutoToxicData.Custom = value
            Kill:SetVisiblity(value)
            Bed:SetVisiblity(value)
            Win:SetVisiblity(value)

            if not value then
                Messages.Kill = OldMessages.Kill
                Messages.Bed = OldMessages.Bed
                Messages.Win = OldMessages.Win
            end
        end
    })

    Kill = AutoToxic:TextBox({
        Name = "Kill Message",
        Flag = "AutoToxicKillMessage",
        Default = "Lowercases, separated by comma (use <PLR>)",
        CallingFunction = function(self, value: string)
            if AutoToxicData.Custom then
                Messages.Kill = Separate(value)
            end
        end
    })

    Bed = AutoToxic:TextBox({
        Name = "Bed Break Message",
        Flag = "AutoToxicBedBreakMessage",
        Default = "Lowercases, separated by comma (use <TEAM>)",
        CallingFunction = function(self, value: string)
            if AutoToxicData.Custom then
                Messages.Bed = Separate(value)
            end
        end
    })

    Win = AutoToxic:TextBox({
        Name = "Win Message",
        Flag = "AutoToxicWinMessage",
        Default = "Lowercases, separated by comma",
        CallingFunction = function(self, value: string)
            if AutoToxicData.Custom then
                Messages.Win = Separate(value)
            end
        end
    })
end)();

(function()
    local AutoVoidDropData = {
        Settings = {
            Items = {},
            Position = 70,
            Delay = 0.1,
            Owl = false
        },
        Other = {Loop = nil}
    }

    local AutoVoidDrop = Windows.Utility:CreateModule({
        Name = "Auto Void Drop",
        Flag = "AutoVoidDrop",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat task.wait() until GameData.Utils.Store:getState().Game.matchstate ~= 0

                local function VoidDrop()
                    if AutoVoidDropData.Other.Loop then
                        AutoVoidDropData.Other.Loop:Disconnect()
                        AutoVoidDropData.Other.Loop = nil
                    end

                    local YLevel: number = GetYLevel()
                    AutoVoidDropData.Other.Loop = self:Connection(task.spawn(function()
                        repeat
                            if Bloomware:IsAlive(LocalPlayer) and (LocalPlayer.Character:GetAttribute('InflatedBalloons') or 0) <= 0 and LocalPlayer.Character.HumanoidRootPart.Position.Y <= (YLevel - AutoVoidDropData.Settings.Position) then
                                if (AutoVoidDropData.Settings.Owl and not LocalPlayer.Character.HumanoidRootPart:FindFirstChild('OwlLiftForce')) or not AutoVoidDropData.Settings.Owl then
                                    for _, v in AutoVoidDropData.Settings.Items do
                                        local Item = GetItem(v)
                                        if Item then
                                            GameData.Utils.Remotes:Get("DropItem"):CallServerAsync({
                                                item = Item.tool,
                                                amount = Item.amount
                                            })
                                        end
                                    end
                                end
                            end
                            task.wait(AutoVoidDropData.Settings.Delay)
                        until not self.Enabled
                    end))
                end

                self:Connection(LocalPlayer.CharacterAdded:Connect(VoidDrop))
                VoidDrop()
            end
        end
    })

    AutoVoidDrop:TextBox({
        Name = "Items",
        Flag = "AutoVoidDropItems",
        Default = "emerald, diamond, iron",
        CallingFunction = function(self, value: string)
            AutoVoidDropData.Settings.Items = Separate(value)
        end
    })

    AutoVoidDrop:Slider({
        Name = "Position",
        Flag = "AutoVoidDropPosition",
        Min = 30,
        Max = 100,
        Default = 70,
        CallingFunction = function(self, value: number)
            AutoVoidDropData.Settings.Position = value
        end
    })

    AutoVoidDrop:Slider({
        Name = "Delay",
        Flag = "AutoVoidDropDelay",
        Min = 0.1,
        Max = 0.3,
        Default = 0.1,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            AutoVoidDropData.Settings.Delay = value
        end
    })

    AutoVoidDrop:MiniToggle({
        Name = "Owl Check",
        Flag = "AutoVoidDropOwl",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AutoVoidDropData.Settings.Owl = value
        end
    })
end)();

(function()
    local Speed: number = 0.24

    local FastBreak = Windows.Utility:CreateModule({
        Name = "Fast Break",
        Flag = "FastBreak",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    GameData.Utils.BlockBreaker.cooldown = Speed
					task.wait(0.1)
				until not self.Enabled
			else
				GameData.Utils.BlockBreaker.cooldown = 0.3
            end
        end
    })

    FastBreak:Slider({
        Name = "Speed",
        Flag = "FastBreakSpeed",
        Min = 0.01,
        Max = 0.3,
        Default = 0.24,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            Speed = value
        end
    })
end)();

(function()
    local Distance: number = 30

    local FarBreak = Windows.Utility:CreateModule({
        Name = "Far Break",
        Flag = "FarBreak",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat
                    GameData.Utils.BlockBreaker.range = Distance
					task.wait(0.1)
				until not self.Enabled
			else
				GameData.Utils.BlockBreaker.range = 0.3
            end
        end
    })

    FarBreak:Slider({
        Name = "Distance",
        Flag = "FarBreakDistance",
        Min = 1,
        Max = 30,
        Default = 30,
        CallingFunction = function(self, value: number)
            Distance = value
        end
    })
end)();

(function()
    local Old
    Windows.Movement:CreateModule({
        Name = "No Slow",
        Flag = "NoSlow",
        CallingFunction = function(self, enabled: boolean)
            local Modifier = GameData.Utils.Sprint:getMovementStatusModifier()
            if enabled then
                if not Old then
                    Old = Modifier.addModifier
                    Modifier.addModifier = function(self, Tab: {moveSpeedMultiplier: number, blockSprint: boolean})
                        if Tab.moveSpeedMultiplier and 1 > Tab.moveSpeedMultiplier and Tab.blockSprint then
                            Tab.moveSpeedMultiplier = 1
                        end
                        Tab.blockSprint = false
                        return Old(self, Tab)
                    end
                end
            else
                if Old then
                    Modifier.addModifier = Old
                    Old = nil
                end
            end
        end
    })
end)();

(function()
    local Hook
    local Old

    Windows.Utility:CreateModule({
        Name = "Anti Detection",
        Flag = "AntiDetection",
        CallingFunction = function(module, enabled: boolean)
            if enabled then
                if not Hook then
                    Hook = hookmetamethod(game, "__namecall", function(self, ...)
                        if (self.Name == "reportPerformanceMetrics" or self.Name == "AnalyticsReportEvent") and module.Enabled then
                            return
                        end
                        return Hook(self, ...)
                    end)
                end

                Old = GameData.Utils.Remotes.Get
                GameData.Utils.Remotes.Get = function(Bloomware, Item: string, ...)
                    if string.find(Item, "[dD][eE][tT][eE][cC][tT][iI][oO][nN]") then
                        return {SendToServer = function() end}
                    end
                    return Old(Bloomware, Item, ...)
                end
            else
                if Old then
                    GameData.Utils.Remotes.Get = Old
                    Old = nil
                end
            end
        end
    })
end)();

(function()
    local ChestESP
    local ChestESPData = {
        Settings = {
            Items = {"emerald", "speed"},
            Color = Color3.fromRGB(0, 0, 0),
            Trans = 0.5,
            Corner = 6
        },
        Connect = {}
    }

    local ChestESPFolder: Folder = Instance.new("Folder", PlayerGui)
    ChestESPFolder.Name = "[Bloomware] Chest ESP"

    local function MainESP(Object)
        local Chest = Object:FindFirstChild("ChestFolderValue") and Object.ChestFolderValue.Value
        if not Chest then 
            local Start: number = os.clock()
            repeat task.wait() until (Object:FindFirstChild("ChestFolderValue") and Object:FindFirstChild("ChestFolderValue").Value) or (os.clock() - Start) > 120
            Chest = Object:FindFirstChild("ChestFolderValue") and Object.ChestFolderValue.Value
            
            if not Chest then
                return
            end
        end

        local Billboard = Instance.new("BillboardGui", ChestESPFolder)
        Billboard.Name, Billboard.Adornee = "[Bloomware] Chest ESP", Object
        Billboard.StudsOffsetWorldSpace, Billboard.Size = Vector3.new(0, 5, 0), UDim2.fromOffset(35, 35)
        Billboard.AlwaysOnTop, Billboard.ClipsDescendants = true, false

        local Frame = Instance.new("Frame", Billboard)
        Frame.Size = UDim2.fromScale(1, 1)
        Frame.BackgroundColor3, Frame.BackgroundTransparency = ChestESPData.Settings.Color, ChestESPData.Settings.Trans
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, ChestESPData.Settings.Corner)

        local Layout = Instance.new("UIListLayout", Frame)
        Layout.FillDirection, Layout.Padding = Enum.FillDirection.Vertical, UDim.new(0, 5)
        Layout.VerticalAlignment, Layout.HorizontalAlignment = Enum.VerticalAlignment.Center, Enum.HorizontalAlignment.Center
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local Width = Layout.AbsoluteContentSize.X + 5
            if Width < 35 then
                Width = 35
            end
            Billboard.Size = UDim2.fromOffset(Width, Layout.AbsoluteContentSize.Y + 5)
        end)

        local function Update()
            local Objects = Billboard.Adornee:FindFirstChild("ChestFolderValue") and Billboard.Adornee.ChestFolderValue.Value:GetChildren()
            if not Objects then
                Billboard.Enabled = false
                return
            end

            for _, v in Frame:GetChildren() do
                if v:IsA("ImageLabel") then
                    v:Destroy()
                end
            end
            Billboard.Enabled = false

            local Found = {}
            for _, Item in Objects do
                local Name, Match = Item.Name, nil
                for _, v in next, ChestESPData.Settings.Items do
                    if string.find(string.lower(Name), string.lower(v)) then
                        Match = v
                        break
                    end
                end
                
                if not Found[Name] and (Match or table.find(ChestESPData.Settings.Items, Name)) then
                    Found[Name], Billboard.Enabled = true, true
                    local Image = Instance.new("ImageLabel", Frame)
                    Image.Size, Image.BackgroundTransparency, Image.Image = UDim2.fromOffset(27, 27), 1, GameData.Utils.ItemMeta[Name].image
                end
            end
        end

        for _, v in {Chest.ChildAdded, Chest.ChildRemoved} do
            ChestESP:Connection(v:Connect(function(item)
                for _, v in next, ChestESPData.Settings.Items do
                    if string.find(string.lower(item.Name), string.lower(v)) then
                        Update()
                        return
                    end
                end
            end), {ChestESPData.Connect})
        end
        task.spawn(Update)
    end

    ChestESP = Windows.Render:CreateModule({
        Name = "Chest ESP",
        Flag = "ChestESP",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                repeat task.wait() until GameData.Utils.Store:getState().Game.matchstate ~= 0

                table.insert(ChestESPData.Connect, CollectionService:GetInstanceAddedSignal("chest"):Connect(MainESP))
                for _, Chest in CollectionService:GetTagged("chest") do
                    task.spawn(MainESP, Chest)
                end
            else
                for _, v in next, ChestESPData.Connect do
                    pcall(function() v:Disconnect() end)
                end
                ChestESPData.Connect = {}
                
                for _, v in next, ChestESPFolder:GetChildren() do
                    v:Destroy()
                end
            end
        end
    })

    ChestESP:ColorSlider({
        Name = "Color",
        Flag = "ChestESPColor",
        Default = Color3.fromRGB(0, 0, 0),
        CallingFunction = function(self, value: Color3)
            ChestESPData.Settings.Color = value
        end
    })

    ChestESP:TextBox({
        Name = "Items",
        Flag = "ChestESPItems",
        Default = "emerald, speed",
        CallingFunction = function(self, value: string)
            ChestESPData.Settings.Items = Separate(value)
        end
    })

    ChestESP:Slider({
        Name = "Corner",
        Flag = "ChestESPCorner",
        Min = 0,
        Max = 10,
        Default = 6,
        CallingFunction = function(self, value: number)
            ChestESPData.Settings.Corner = value
        end
    })
end)();

(function()
    local Hook = nil
    local NoFall = false
    local Reset = false

    local function Resync()
        if Bloomware:IsAlive(LocalPlayer) then
            LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(math.nan, math.nan, math.nan)
            Warning("Desync", "Resynced", 5)
        end
    end

    local function Buffer(mode)
        if mode == "max_u32" then
            local Floor = math.floor((2 ^ 16) * (2 ^ 16))
            local Abs = math.abs(math.cos(math.pi))
            return Floor - Abs
        elseif mode == "packet_id" then
            local Offset = math.floor(math.sqrt(9))
            return (math.sqrt(9)) * (2 ^ 3) + Offset
        end
        return 0
    end

    local Desync = Windows.Movement:CreateModule({
        Name = "Desync",
        Flag = "Desync",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                Hook = function(packet)
                    if type(packet) ~= "table" and type(packet) ~= "userdata" then return end
                    if not packet.AsArray or packet.AsArray[1] ~= Buffer("packet_id") then
                        return
                    end

                    local data = packet.AsBuffer
                    if not data then return end

                    buffer.writeu32(data, 1, Buffer("max_u32"))

                    if NoFall then
                        buffer.writeu8(data, 25, 7)
                    end

                    packet:SetData(data)
                end

                raknet.add_send_hook(Hook)

                task.wait()

                if GetNearestBed(true, true, true) and Bloomware:IsAlive(LocalPlayer) and Reset then
                    LocalPlayer.Character.Humanoid.Health = 0
                elseif not GetNearestBed(true, true, true) then
                    Warning("Desync | Reset", "No bed found", 10)
                end

            elseif Hook then
                pcall(function()
                    raknet.remove_send_hook(Hook)
                end)
                Hook = nil
            end
        end
    })

    Desync:KeyBind({
        Name = "Resync",
        Flag = "DesyncResync",
        Default = Enum.KeyCode.L,
        Events = {
            Began = function()
                Resync()
            end,
            Ended = function()
                Resync()
            end
        }
    })

    Desync:MiniToggle({
        Name = "No Fall",
        Flag = "DesyncNoFall",
        Default = true,
        CallingFunction = function(self, value: boolean)
            NoFall = value
        end
    })

    Desync:MiniToggle({
        Name = "Reset",
        Flag = "DesyncReset",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Reset = value
        end
    })
end)();

(function()
    local AutoBallonHeight: number = 0
    local Amount: number = 3
    local ShouldSwitchItem: boolean = false

    local AutoBalloon = Windows.Utility:CreateModule({
        Name = "Auto Balloon",
        Flag = "AutoBalloon",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                local YLevel: number = GetYLevel()

                repeat
                    if Bloomware:IsAlive(LocalPlayer) and LocalPlayer.Character.HumanoidRootPart.Position.Y <= (YLevel + AutoBallonHeight) then
                        local Inflated: number = (LocalPlayer.Character:GetAttribute("InflatedBalloons") or 0)
                        if 3 > Inflated then
                            local Balloons = GetItem("balloon")
                            if not Balloons then
                                Balloons = GetItem("anniversary_balloon")
                            end

                            if Balloons then
                                for i = 1, (Amount - Inflated) do
                                    Inflated = (LocalPlayer.Character:GetAttribute("InflatedBalloons") or 0)
                                    if Inflated >= 3 or not (GetItem("balloon") or GetItem("anniversary_balloon")) then
                                        break
                                    end

                                    if ShouldSwitchItem then
                                        SwitchItem(Balloons.tool)
                                    end

                                    GameData.Utils.Remotes:Get("InflateBalloon"):SendToServer()
                                end
                            end
                        end
                    end
                    task.wait()
                until not self.Enabled
            end
        end
    })

    AutoBalloon:Slider({
        Name = "Height",
        Flag = "AutoBalloonActivationHeight",
        Min = 0,
        Max = 100,
        Default = 0,
        CallingFunction = function(self, value: number)
            AutoBallonHeight = value
        end
    })

    AutoBalloon:Slider({
        Name = "Amount",
        Flag = "AutoBalloonUsageAmount",
        Min = 1,
        Max = 3,
        Default = 3,
        CallingFunction = function(self, value: number)
            Amount = value
        end
    })

    AutoBalloon:MiniToggle({
        Name = "Switch Item",
        Flag = "AutoBalloonSwitchItem",
        CallingFunction = function(self, value: boolean)
            ShouldSwitchItem = value
        end
    })
end)();

(function()
    local Mode: string = "Low"
    local AutoSwitch: boolean = false
    local HandCheck: boolean = false
    local Delay = 0

    local function GetPositions(Pos: Vector3): {Vector3}
        local Vectors: {Vector3} = {}

        for y = 0, 6, 3 do
            if y == 6 then
                Vectors[#Vectors + 1] = Pos + Vector3.new(0, y, 0)
            else
                Vectors[#Vectors + 1] = Pos + Vector3.new(0, y, 3)
                Vectors[#Vectors + 1] = Pos + Vector3.new(0, y, -3)
                Vectors[#Vectors + 1] = Pos + Vector3.new(-3, y, 0)
                Vectors[#Vectors + 1] = Pos + Vector3.new(3, y, 0)
            end
        end

        return Vectors
    end

    local function GetAllBlocks(inventory: any): {{Type: string, Tool: any, Health: number}}
        local Blocks: {{Type: string, Tool: any, Health: number}} = {}

        for _, Item in next, inventory do
            local Meta = GameData.Utils.ItemMeta[Item.itemType]
            if Meta.block then
                local Block = {
                    Type = Item.itemType,
                    Tool = Item.tool,
                    Health = Meta.block.health or 0
                }
                Blocks[#Blocks + 1] = Block
            end
        end

        table.sort(Blocks, function(x, y)
            if Mode == "Low" then
                return x.Health < y.Health
            else
                return x.Health > y.Health
            end
        end)

        return Blocks
    end

    local BlockIn = Windows.Utility:CreateModule({
        Name = "Block In",
        Flag = "BlockIn",
        Button = true,
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                local Blocks = GetAllBlocks(GetInventory(LocalPlayer).items)

                if #Blocks == 0 then
                    Warning("Block In", "No blocks found", 5)
                    self:SetValue(false)
                    return
                end

                local HandItem = GetInventory().hand
                if HandCheck then
                    if HandItem and HandItem.tool then
                        local Meta = GameData.Utils.ItemMeta[HandItem.itemType]
                        if not Meta or not Meta.block then
                            Warning("Block In | Hand Check", "Hold the blocks in your hand", 5)
                            return
                        end
                    else
                        Warning("Block In | Hand Check", "Hold the blocks in your hand", 5)
                        return
                    end
                end

                task.spawn(function()
                    for _, Block in next, Blocks do
                        if AutoSwitch then
                            SwitchItem(Block.Tool)
                        end

                        for _, Pos in next, GetPositions(LocalPlayer.Character.HumanoidRootPart.Position) do
                            local IsBlock = GameData.Utils.BlockEngine:getStore():getBlockAt(GameData.Utils.BlockEngine:getBlockPosition(Pos))
                            if not IsBlock then
                                local Item = GameData.Utils.BlockPlacer.new(GameData.Utils.BlockClient, Block.Type)
                                Item:placeBlock(GameData.Utils.BlockEngine:getBlockPosition(Pos))
                                task.wait(Delay)
                            end
                        end
                    end
                end)
            end
        end
    })

    BlockIn:Dropdown({
        Name = "Order",
        Flag = "BlockInORder",
        Options = {"Low", "High"},
        Default = "Low",
        CallingFunction = function(self, value: string)
            Mode = value
        end
    })
    
    BlockIn:MiniToggle({
        Name = "Auto Switch",
        Flag = "BlockInAutoSwitch",
        Default = true,
        CallingFunction = function(self, value: boolean)
            AutoSwitch = value
        end
    })

    BlockIn:MiniToggle({
        Name = "Hand Check",
        Flag = "BlockInHandCheck",
        CallingFunction = function(self, value: boolean)
            HandCheck = value
        end
    })

    BlockIn:Slider({
        Name = "Delay",
        Flag = "BlockInDelay",
        Min = 0,
        Max = 1,
        Default = 0,
        Increment = 0.01,
        CallingFunction = function(self, value: number)
            Delay = value
        end
    })
end)();

(function()
    -- pls stop skidding ts :rage:
    Windows.Utility:CreateModule({
        Name = "Match History",
        Flag = "MatchHistroy",
        Button = true,
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                GameData.Utils.MatchHistroyController:requestMatchHistory(LocalPlayer.Name):andThen(function(Data)
                    if Data then
                        GameData.Utils.App:openApp({
                            app = GameData.Utils.MatchHistroyApp,
                            appId = "MatchHistoryApp",
                        }, Data)
                    end
                end)
            end
        end
    })
end)();

(function()
    local OldGet
    Windows.Utility:CreateModule({
        Name = "Trap Disabler",
        Flag = "TrapDisabler",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                OldGet = GameData.Utils.Remotes.Get
                GameData.Utils.Remotes.Get = function(self, Name: string, ...)
                    if Name == "StepOnSnapTrap" then
                        return {SendToServer = function() end}
                    end

                    return OldGet(self, Name, ...)
                end
            else
                if OldGet then
                    GameData.Utils.Remotes.Get = OldGet
                end
            end
        end
    })
end)();

(function()
    local Distance = 20
    Windows.Utility:CreateModule({
        Name = "Bed Protector",
        Button = true,
        Flag = "BedProtector",
        CallingFunction = function(self, enabled: boolean)
            if not enabled then
                return
            end

            local Bed = GetNearestBed(true, true)
            if not Bed.Bed or Distance < Bed.Distance then
                task.delay(0.1, Warning, "Bed protector", "No bed in range", 5)
                return
            end

            local BedPos = Bed.Bed.Position
            local BackOffset = Bed.Bed.CFrame.LookVector * 3

            local function PlaceBlock(position: Vector3)
                local Block = GetBlocks()
                GameData.Utils.BlockPlacer.new(GameData.Utils.BlockClient, Block.Type)
                    :placeBlock(GameData.Utils.BlockEngine:getBlockPosition(position))
            end

            for _, face in Enum.NormalId:GetEnumItems() do
                if face == Enum.NormalId.Bottom then
                    continue
                end

                for i = 1, 2 do
                    local Pos = BedPos + (Vector3.fromNormalId(face) * (3 * i))
                    PlaceBlock(Pos)
                    PlaceBlock(Pos - BackOffset)

                    if i == 1 then
                        for _, offset in { Vector3.new(0, 3, 0), Vector3.new(0, 0, 3), Vector3.new(0, 0, -3) } do
                            PlaceBlock(Pos + offset)
                            PlaceBlock(Pos - BackOffset + offset)
                        end
                    end
                end
            end
        end
    })
end)();

(function()
    Windows.Utility:CreateModule({
        Name = "Mouse TP",
        Flag = "MouseTP",
        Button = true,
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if Bloomware:IsAlive(LocalPlayer) then 
                    local Mouse: Mouse? = LocalPlayer:GetMouse()
                    if Mouse then
                        local Pearl = GetItem("telepearl")
                        if Pearl then
                            local PlayerPosition: Vector3 = LocalPlayer.Character.PrimaryPart.Position
                            local MousePos: Vector3 = Mouse.Hit.Position

                            local Distance = (Vector3.new(PlayerPosition.X, 0, PlayerPosition.Z) - Vector3.new(MousePos.X, 0, MousePos.Z)).Magnitude
                            MousePos = Vector3.new(MousePos.X, MousePos.Y + (Distance ^ 2) * 0.0035, MousePos.Z)
                            
                            local LaunchVel: number = GameData.Utils.ProjMeta.telepearl.launchVelocity
                            local LookCF: CFrame = CFrame.new(PlayerPosition, MousePos)
                            local LookVec: Vector3 = LookCF.LookVector * LaunchVel

                            SwitchItem(Pearl.tool)
                            GameData.Utils.Remotes:Get("ProjectileFire"):CallServerAsync(
                                Pearl.tool, "telepearl", "telepearl",
                                LookCF.Position,
                                PlayerPosition, LookVec,
                                HttpService:GenerateGUID(true),
                                {drawDurationSec = math.random(1, 3), shotId = HttpService:GenerateGUID(false)},
                                workspace:GetServerTimeNow()
                            )
                        else
                            Warning("Mouse Teleport", "You must have a pearl.", 5)
                        end
                    end
                else
                    Warning("Mouse Teleport", "You are dead.", 5)
                end
                self:SetValue(false)
            end
        end
    })
end)();

(function()
    local index
	for i, v in debug.getconstants(GameData.Utils.SwordController.isClickingTooFast) do
		if v == 'lastSwing' then
			index = i + 1
			break
		end
	end
	local old = debug.getconstant(GameData.Utils.SwordController.isClickingTooFast, index)

    Windows.Combat:CreateModule({
        Name = "No Click Delay",
        Flag = "NoClickDelay",
        CallingFunction = function(self, enabled: boolean)
            debug.setconstant(GameData.Utils.SwordController.isClickingTooFast, index, self.Enabled and 0 or old)
        end
    })
end)();

(function()
    local SilentAuraData = {
        Settings = {
            Smoothness = 15,
            Range = 40,
            TeamCheck = true,
            WallCheck = true,
            TargetPart = "HumanoidRootPart",
            AutoClick = true,
            PerfectHits = true,
            ClickDelay = 0.4,
            Targets = {
                Players = true,
                Npcs = true
            }
        },
        Data = {
            RayParams = RaycastParams.new(),
            LastClick = 0,
            CurrentTarget = nil
        }
    }

    local SilentAura = Windows.Combat:CreateModule({
        Name = "Silent Aura",
        Flag = "SilentAura",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                self:Connection(RunService.PreRender:Connect(function(Delta: number)
                    if not Bloomware:IsAlive(LocalPlayer) then
                        SilentAuraData.Data.CurrentTarget = nil
                        return
                    end

                    if GameData.Utils.Store:getState().Game.matchState ~= GameData.Utils.MatchStates.RUNNING then
                        return
                    end

                    local NearestEntity = GetEntity({
                        TeamCheck = SilentAuraData.Settings.TeamCheck,
                        MaxRange = SilentAuraData.Settings.Range,
                        Mode = "Distance",
                        Targets = SilentAuraData.Settings.Targets,
                        Visible = SilentAuraData.Settings.WallCheck
                    })

                    if NearestEntity.Entity then
                        local Target = NearestEntity.Entity
                        local TargetPart = Target:FindFirstChild(SilentAuraData.Settings.TargetPart) or Target.PrimaryPart
                        if TargetPart then
                            SilentAuraData.Data.CurrentTarget = NearestEntity

                            local TargetCF = CFrame.new(CurrentCamera.CFrame.Position, TargetPart.Position)
                            local LerpAlpha = math.clamp(SilentAuraData.Settings.Smoothness * Delta, 0, 1)
                            CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(TargetCF, LerpAlpha)

                            if SilentAuraData.Settings.AutoClick then
                                local Now = os.clock()
                                if Now - SilentAuraData.Data.LastClick >= (SilentAuraData.Settings.PerfectHits and 1 / 16 * math.random(2, 5) or SilentAuraData.Settings.ClickDelay) then
                                    local Sword = GetSword()
                                    if Sword.Item then
                                        GameData.Utils.SwordController:swingSwordAtMouse()
                                        SilentAuraData.Data.LastClick = Now
                                    end
                                end
                            end
                        end
                    else
                        SilentAuraData.Data.CurrentTarget = nil
                    end
                end))
            else
                SilentAuraData.Data.CurrentTarget = nil
            end
        end
    })

    SilentAura:Slider({
        Name = "Aim Speed",
        Flag = "SilentAuraSpeed",
        Default = 15,
        Min = 1,
        Max = 50,
        CallingFunction = function(self, value: number)
            SilentAuraData.Settings.Smoothness = value
        end
    })

    SilentAura:Slider({
        Name = "Range",
        Flag = "SilentAuraRange",
        Default = 25,
        Min = 5,
        Max = 30,
        CallingFunction = function(self, value: number)
            SilentAuraData.Settings.Range = value
        end
    })

    SilentAura:Slider({
        Name = "Click Speed",
        Flag = "SilentAuraClickSpeed",
        Default = 16,
        Min = 1,
        Max = 40,
        CallingFunction = function(self, value: number)
            SilentAuraData.Settings.ClickDelay = 1 / value * math.random(2, 5)
        end
    })

    SilentAura:Dropdown({
        Name = "Part",
        Flag = "SilentAuraPart",
        Default = "HumanoidRootPart",
        Options = AimParts,
        CallingFunction = function(self, Value: string)
            SilentAuraData.Settings.TargetPart = Value
        end
    })

    SilentAura:Dropdown({
        Name = "Targets",
        Flag = "SilentAuraTargets",
        Default = {"Players", "Npcs"},
        Options = {"Players", "Npcs"},
        MaxLimit = 2,
        MinLimit = 0,
        CallingFunction = function(self, value)
            SilentAuraData.Settings.Targets = value
        end
    })

    SilentAura:MiniToggle({
        Name = "Perfect Hits",
        Default = true,
        Flag = "SilentAuraPerfectHits",
        CallingFunction = function(self, value: boolean)
            SilentAuraData.Settings.PerfectHits = value
        end
    })

    SilentAura:MiniToggle({
        Name = "Auto Click",
        Default = true,
        Flag = "SilentAuraAutoClick",
        CallingFunction = function(self, value: boolean)
            SilentAuraData.Settings.AutoClick = value
        end
    })

    SilentAura:MiniToggle({
        Name = "Team Check",
        Default = true,
        Flag = "SilentAuraTeamCheck",
        CallingFunction = function(self, value: boolean)
            SilentAuraData.Settings.TeamCheck = value
        end
    })

    SilentAura:MiniToggle({
        Name = "Wall Check",
        Default = true,
        Flag = "SilentAuraWallCheck",
        CallingFunction = function(self, value: boolean)
            SilentAuraData.Settings.WallCheck = value
        end
    })
end)();

(function()
    local AutoDodgeData = {
        Settings = {
            Range = 15,
            Delay = 1,
            DodgeOffset = 50
        },
        Data = {
            LastDodgeTime = 0,
            OverlapParams = OverlapParams.new()
        }
    }

    local ArrowNames = {arrow = true, crossbow_arrow = true, headhunter_arrow = true}
    AutoDodgeData.Data.OverlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local function IsEnemyArrow(part): boolean
        local Model = part:FindFirstAncestorWhichIsA("Model")
        if not Model or not ArrowNames[Model.Name] then return false end
        return Model:GetAttribute("ProjectileShooter") ~= LocalPlayer.UserId
    end

    local function Dodge(Root)
        local Pos = Root.Position
        Root.CFrame = CFrame.new(Pos + Vector3.new(0, AutoDodgeData.Settings.DodgeOffset, 0))
        task.wait(0.2)

        local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            HRP.CFrame = CFrame.new(Pos)
        end
        AutoDodgeData.Data.LastDodgeTime = os.clock()
    end

    local AutoDodge = Windows.Combat:CreateModule({
        Name = "Auto Dodge",
        Flag = "AutoDodge",
        CallingFunction = function(self, enabled: boolean)
            if not enabled then return end

            AutoDodgeData.Data.OverlapParams.FilterDescendantsInstances = {LocalPlayer.Character or {}}

            self:Connection(task.spawn(function()
                while task.wait(0.05) do
                    if not self.Enabled then break end
                    if not Bloomware:IsAlive(LocalPlayer) then continue end

                    if GameData.Utils.Store:getState().Game.matchState ~= GameData.Utils.MatchStates.RUNNING then
                        continue
                    end

                    local Root = LocalPlayer.Character.HumanoidRootPart
                    if not Root then continue end
                    if (os.clock() - AutoDodgeData.Data.LastDodgeTime) < AutoDodgeData.Settings.Delay then continue end

                    local nearby = workspace:GetPartBoundsInRadius(Root.Position, AutoDodgeData.Settings.Range, AutoDodgeData.Data.OverlapParams)
                    for _, part in nearby do
                        if IsEnemyArrow(part) then
                            Dodge(Root)
                            break
                        end
                    end
                end
            end))
        end
    })

    AutoDodge:Slider({
        Name = "Range",
        Flag = "AutoDodgeRange",
        Default = 15,
        Min = 5,
        Max = 30,
        CallingFunction = function(self, value: number)
            AutoDodgeData.Settings.Range = value
        end
    })

    AutoDodge:Slider({
        Name = "Delay",
        Flag = "AutoDodgeDelay",
        Default = 1,
        Min = 0,
        Max = 10,
        CallingFunction = function(self, value: number)
            AutoDodgeData.Settings.Delay = value
        end
    })

    AutoDodge:Slider({
        Name = "Dodge Offset",
        Flag = "AutoDodgeDodgeOffset",
        Default = 50,
        Min = 0,
        Max = 500,
        CallingFunction = function(self, value: number)
            AutoDodgeData.Settings.DodgeOffset = value
        end
    })
end)();

(function()
    local TargetStrafeData = {
        Settings = {
            Range = 10,
            StrafeSpeed = 1.2,
            StrafeRadius = 8,
            AutoJump = false,
            JumpDelay = 0.6,
            SmartDodge = true,
            DodgeDistance = 6,
            ReverseInterval = 1.5,
            SprintMultiplier = 1.0,
            Targets = {Players = true, Npcs = true},
            TeamCheck = true,
            Mode = "Distance"
        },
        Data = {
            Angle = 0,
            Direction = 1,
            LastJumpTime = 0,
            LastReverseTime = 0,
            LastDodgeTime = 0,
            RayParams = RaycastParams.new()
        }
    }

    TargetStrafeData.Data.RayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function IsTargetSwinging(target: Model): boolean
        local Hum = target:FindFirstChildWhichIsA("Humanoid")
        if not Hum then return false end
        local Animator = Hum:FindFirstChildWhichIsA("Animator")
        if not Animator then return false end
        for _, track in Animator:GetPlayingAnimationTracks() do
            local name = track.Animation and track.Animation.Name or ""
            if name:lower():find("swing") or name:lower():find("slash") or name:lower():find("attack") or name:lower():find("sword") then
                return true
            end
        end
        return false
    end

    local function GetTargetVelocity(target: Model): Vector3
        local root = target:FindFirstChild("HumanoidRootPart")
        if root then
            return root.AssemblyLinearVelocity
        end
        return Vector3.zero
    end

    local TargetStrafe = Windows.Combat:CreateModule({
        Name = "Target Strafe",
        Flag = "TargetStrafe",
        CallingFunction = function(self, enabled: boolean)
            if enabled then

                TargetStrafeData.Data.Angle = 0
                TargetStrafeData.Data.Direction = 1
                TargetStrafeData.Data.LastReverseTime = os.clock()

                self:Connection(RunService.PreRender:Connect(function(delta)
                    if not Bloomware:IsAlive(LocalPlayer) then return end
                    if GameData.Utils.Store:getState().Game.matchState ~= GameData.Utils.MatchStates.RUNNING then return end

                    local Character = LocalPlayer.Character
                    local Root = Character:FindFirstChild("HumanoidRootPart")
                    local Humanoid = Character:FindFirstChild("Humanoid")
                    if not Root or not Humanoid then return end

                    TargetStrafeData.Data.RayParams.FilterDescendantsInstances = {Character}

                    local NearestEntity = GetEntity({
                        TeamCheck = TargetStrafeData.Settings.TeamCheck,
                        Mode = TargetStrafeData.Settings.Mode,
                        MaxRange = TargetStrafeData.Settings.Range,
                        Targets = TargetStrafeData.Settings.Targets,
                        Visible = false
                    })

                    if not NearestEntity.Entity then return end

                    local TargetRoot = NearestEntity.Data.Root
                    if not TargetRoot then return end

                    local TargetEntity = NearestEntity.Data.Entity
                    local TargetPos = TargetRoot.Position
                    local MyPos = Root.Position
                    local Now = os.clock()

                    if (Now - TargetStrafeData.Data.LastReverseTime) >= TargetStrafeData.Settings.ReverseInterval then
                        TargetStrafeData.Data.Direction = -TargetStrafeData.Data.Direction
                        TargetStrafeData.Data.LastReverseTime = Now
                    end

                    if TargetStrafeData.Settings.SmartDodge and IsTargetSwinging(TargetEntity) then
                        if (Now - TargetStrafeData.Data.LastDodgeTime) > 0.5 then
                            TargetStrafeData.Data.Direction = -TargetStrafeData.Data.Direction
                            TargetStrafeData.Data.LastDodgeTime = Now
                            TargetStrafeData.Data.LastReverseTime = Now

                            if Humanoid.FloorMaterial ~= Enum.Material.Air then
                                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                TargetStrafeData.Data.LastJumpTime = Now
                            end
                        end
                    end

                    local Speed = TargetStrafeData.Settings.StrafeSpeed * TargetStrafeData.Settings.SprintMultiplier
                    TargetStrafeData.Data.Angle += Speed * TargetStrafeData.Data.Direction * delta

                    local Radius = TargetStrafeData.Settings.StrafeRadius
                    local StrafeX = math.cos(TargetStrafeData.Data.Angle) * Radius
                    local StrafeZ = math.sin(TargetStrafeData.Data.Angle) * Radius
                    local DesiredPos = Vector3.new(TargetPos.X + StrafeX, MyPos.Y, TargetPos.Z + StrafeZ)

                    local TargetVel = GetTargetVelocity(TargetEntity)
                    local PredictedCenter = TargetPos + TargetVel * 0.15
                    DesiredPos = Vector3.new(PredictedCenter.X + StrafeX, MyPos.Y, PredictedCenter.Z + StrafeZ)

                    local MoveDir = (DesiredPos - MyPos).Unit
                    local RayResult = workspace:Raycast(MyPos, MoveDir * 3, TargetStrafeData.Data.RayParams)
                    if RayResult then
                        TargetStrafeData.Data.Direction = -TargetStrafeData.Data.Direction
                        TargetStrafeData.Data.LastReverseTime = Now
                    end

                    local LerpAlpha = math.clamp(delta * 10, 0, 1)
                    local NewPos = MyPos:Lerp(DesiredPos, LerpAlpha)

                    local LookDir = (TargetPos - NewPos) * Vector3.new(1, 0, 1)
                    if LookDir.Magnitude > 0.01 then
                        Root.CFrame = CFrame.new(NewPos, NewPos + LookDir)
                    end

                    if TargetStrafeData.Settings.AutoJump and Humanoid.FloorMaterial ~= Enum.Material.Air then
                        if (Now - TargetStrafeData.Data.LastJumpTime) >= TargetStrafeData.Settings.JumpDelay then
                            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            TargetStrafeData.Data.LastJumpTime = Now
                        end
                    end
                end))
            end
        end
    })

    TargetStrafe:Slider({
        Name = "Range",
        Flag = "TargetStrafeRange",
        Default = 10,
        Min = 5,
        Max = 18,
        CallingFunction = function(self, value: number)
            TargetStrafeData.Settings.Range = value
        end
    })

    TargetStrafe:Slider({
        Name = "Strafe Speed",
        Flag = "TargetStrafeSpeed",
        Default = 1.2,
        Min = 0.1,
        Max = 5,
        CallingFunction = function(self, value: number)
            TargetStrafeData.Settings.StrafeSpeed = value
        end
    })

    TargetStrafe:Slider({
        Name = "Strafe Radius",
        Flag = "TargetStrafeRadius",
        Default = 8,
        Min = 3,
        Max = 20,
        CallingFunction = function(self, value: number)
            TargetStrafeData.Settings.StrafeRadius = value
        end
    })

    TargetStrafe:Slider({
        Name = "Jump Delay",
        Flag = "TargetStrafeJumpDelay",
        Default = 0.6,
        Min = 0.1,
        Max = 3,
        CallingFunction = function(self, value: number)
            TargetStrafeData.Settings.JumpDelay = value
        end
    })

    TargetStrafe:Slider({
        Name = "Reverse Interval",
        Flag = "TargetStrafeReverseInterval",
        Default = 1.5,
        Min = 0.3,
        Max = 5,
        CallingFunction = function(self, value: number)
            TargetStrafeData.Settings.ReverseInterval = value
        end
    })

    TargetStrafe:Slider({
        Name = "Sprint Multiplier",
        Flag = "TargetStrafeSprintMultiplier",
        Default = 1.0,
        Min = 0.5,
        Max = 3,
        CallingFunction = function(self, value: number)
            TargetStrafeData.Settings.SprintMultiplier = value
        end
    })

    TargetStrafe:MiniToggle({
        Name = "Auto Jump",
        Flag = "TargetStrafeAutoJump",
        CallingFunction = function(self, value: boolean)
            TargetStrafeData.Settings.AutoJump = value
        end
    })

    TargetStrafe:MiniToggle({
        Name = "Smart Dodge",
        Flag = "TargetStrafeDodge",
        Default = true,
        CallingFunction = function(self, value: boolean)
            TargetStrafeData.Settings.SmartDodge = value
        end
    })

    TargetStrafe:MiniToggle({
        Name = "Team Check",
        Flag = "TargetStrafeTeamCheck",
        Default = true,
        CallingFunction = function(self, value: boolean)
            TargetStrafeData.Settings.TeamCheck = value
        end
    })

    TargetStrafe:Dropdown({
        Name = "Mode",
        Flag = "TargetStrafeMode",
        Default = "Distance",
        Options = {"Distance", "Lowest Health", "Highest Health", "Angle"},
        CallingFunction = function(self, value: string)
            TargetStrafeData.Settings.Mode = value
        end
    })
end)();

(function()
	local OldTime = {
		Multi = 0,
		Fire = 0,
		Strength = 0
	}

    Windows.Combat:CreateModule({
        Name = "Fast Bow",
        Flag = "FastBow",
        CallingFunction = function(self, enabled: boolean)
            for i, v in next, GameData.Utils.ItemMeta do 
				if v.projectileSource then 
					OldTime[i] = self.Enabled and {
						Fire = v.projectileSource.fireDelaySec,
						Multi = v.projectileSource.multiShotChargeTime,
						Strength = v.projectileSource.maxStrengthChargeSec
					} or OldTime[i]
                    pcall(function()
					    v.projectileSource.fireDelaySec = self.Enabled and 0.01 or OldTime[i].Fire
					    v.projectileSource.multiShotChargeTime = self.Enabled and 0.01 or OldTime[i].Multi
					    v.projectileSource.maxStrengthChargeSec = self.Enabled and 0.01 or OldTime[i].Strength
                    end)
                end
			end
        end
    })
end)();

(function()
    local OldGet
    Windows.Combat:CreateModule({
        Name = "Reach",
        Flag = "Reach",
        CallingFunction = function(self, enabled: boolean)
            setmetatable(GameData.Utils.CombatConstant, {
                __newindex = function(self, key, value)
                    if key == "RAYCAST_SWORD_CHARACTER_DISTANCE" then
                        rawset(self, key, enabled and 22 or 14.4)
                    end
                end
            })

            if enabled then
                OldGet = GameData.Utils.Remotes.Get
                GameData.Utils.Remotes.Get = function(self, Name: string, ...)
                    local Get = OldGet(self, Name, ...)

                    if Name == "SwordHit" then
                        return {
                            instance = Get.instance,
                            SendToServer = function(self, Args)
                                Args.validate.selfPosition.value += (math.clamp((Args.validate.targetPosition.value - Args.validate.selfPosition.value).Magnitude - 14.4, 10, 30) * (Args.validate.targetPosition.value - Args.validate.selfPosition.value).Unit)
                                return Get:SendToServer(Args)
                            end
                        }
                    end

                    return Get
                end
            else
                if OldGet then
                    GameData.Utils.Remotes.Get = OldGet
                end
            end
        end
    })
end)();

(function()
    local BeeIcon = GetIcon({itemType = "bee"}, true)

    local Config = {
        BeeColor = Color3.fromRGB(0, 0, 0),
        HiveColor = Color3.fromRGB(0, 0, 0),
        MaxColor = Color3.fromRGB(255, 255, 255),
        BeeSize = 36,
        HiveSize = 80,
        Transparency = 0.5,
        Corner = 6,
        ShowBees = true,
        ShowHives = true,
        Notify = true,
        NotifyMax = true
    }

    local ESPHolder: Folder = Instance.new("Folder", PlayerGui)
    ESPHolder.Name = "[Bloomware] Beekeeper"
    local Tracked = {}
    local MaxNotified = {}
    local PendingAlerts, LastAlert = 0, 0

    local function IsTamed(Obj: Instance): boolean
        if Obj.Name:find("Tamed") then return true end
        if Obj:FindFirstChild("TamedBee") then return true end
        if Obj:GetAttribute("IsTamed") or Obj:GetAttribute("Tamed") then return true end
        for _, Tag in CollectionService:GetTags(Obj) do
            if Tag:lower():find("tamed") then return true end
        end
        return false
    end

    local function MakeLabel(Props): TextLabel
        local Lbl = Instance.new("TextLabel")
        Lbl.BackgroundTransparency = 1
        Lbl.TextColor3 = Color3.new(1, 1, 1)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextStrokeTransparency = 0.5
        Lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        for K, V in Props do Lbl[K] = V end
        return Lbl
    end

    local function CreateBillboard(Adornee: Instance, Offset: number, W: number, H: number): BillboardGui
        local Bb = Instance.new("BillboardGui", ESPHolder)
        Bb.Adornee, Bb.AlwaysOnTop, Bb.ClipsDescendants = Adornee, true, false
        Bb.StudsOffsetWorldSpace = Vector3.new(0, Offset, 0)
        Bb.Size = UDim2.fromOffset(W, H)
        return Bb
    end

    local function TrackBee(Part: BasePart)
        if Tracked[Part] or not Config.ShowBees then return end
        local Mdl = Part.Parent
        if not Mdl or IsTamed(Mdl) then return end

        local Bb = CreateBillboard(Part, 3, Config.BeeSize, Config.BeeSize)
        local Img = Instance.new("ImageLabel", Bb)
        Img.Size, Img.Position, Img.AnchorPoint = UDim2.fromScale(1, 1), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
        Img.BackgroundColor3, Img.BackgroundTransparency = Config.BeeColor, Config.Transparency
        Img.BorderSizePixel, Img.Image = 0, BeeIcon
        Instance.new("UICorner", Img).CornerRadius = UDim.new(0, Config.Corner)

        Tracked[Part] = {Billboard = Bb, Type = "bee", Frame = Img}

        if Config.Notify then
            PendingAlerts += 1
            local Now = tick()
            if Now - LastAlert >= 1 then
                Warning("Beekeeper", PendingAlerts .. " bee(s) detected", 3)
                PendingAlerts, LastAlert = 0, Now
            else
                task.delay(1 - (Now - LastAlert), function()
                    if PendingAlerts > 0 then
                        Warning("Beekeeper", PendingAlerts .. " bee(s) detected", 3)
                        PendingAlerts, LastAlert = 0, tick()
                    end
                end)
            end
        end
    end

    local function TrackHive(Hive: Instance)
        if Tracked[Hive] or not Config.ShowHives then return end
        local Owner = Hive:GetAttribute("PlacedByUserId")
        if Owner ~= LocalPlayer.UserId then return end

        local Lvl = Hive:GetAttribute("Level") or 0
        local Maxed = Lvl >= 10

        local Bb = CreateBillboard(Hive, 4, Config.HiveSize, 34)
        local Frame = Instance.new("Frame", Bb)
        Frame.Name, Frame.Size, Frame.BorderSizePixel = "Frame", UDim2.fromScale(1, 1), 0
        Frame.BackgroundColor3 = Maxed and Config.MaxColor or Config.HiveColor
        Frame.BackgroundTransparency = Config.Transparency
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, Config.Corner)

        local Icon = Instance.new("ImageLabel", Frame)
        Icon.Size, Icon.Position, Icon.AnchorPoint = UDim2.fromOffset(18, 18), UDim2.new(0, 6, 0.5, 0), Vector2.new(0, 0.5)
        Icon.BackgroundTransparency, Icon.Image = 1, BeeIcon

        local LvlLabel = MakeLabel({
            Name = "Level", Text = tostring(Lvl), TextSize = 16,
            Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -34, 0, 0), Parent = Frame
        })

        local MaxLabel = nil
        if Maxed then
            MaxLabel = MakeLabel({
                Name = "MaxTag", Text = "MAX", TextSize = 12,
                TextColor3 = Config.MaxColor,
                Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, -18), Parent = Bb
            })
        end

        Tracked[Hive] = {Billboard = Bb, Type = "hive", Frame = Frame, LvlLabel = LvlLabel, MaxLabel = MaxLabel, Maxed = Maxed}

        if Maxed and not MaxNotified[Hive] and Config.NotifyMax then
            Warning("Beekeeper", "Beehive reached MAX level!", 3)
            MaxNotified[Hive] = true
        end
    end

    local function Untrack(Obj: Instance)
        local Data = Tracked[Obj]
        if not Data then return end
        Data.Billboard:Destroy()
        Tracked[Obj] = nil
    end

    local function RefreshHiveLevel(Hive: Instance)
        local Data = Tracked[Hive]
        if not Data or Data.Type ~= "hive" then return end
        local Lvl = Hive:GetAttribute("Level") or 0
        local Maxed = Lvl >= 10

        Data.LvlLabel.Text = tostring(Lvl)
        Data.Frame.BackgroundColor3 = Maxed and Config.MaxColor or Config.HiveColor
        Data.Maxed = Maxed

        if Maxed and not Data.MaxLabel then
            Data.MaxLabel = MakeLabel({
                Name = "MaxTag", Text = "MAX", TextSize = 12,
                TextColor3 = Config.MaxColor,
                Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, -18), Parent = Data.Billboard
            })
            if not MaxNotified[Hive] and Config.NotifyMax then
                Warning("Beekeeper", "Beehive reached MAX level!", 3)
                MaxNotified[Hive] = true
            end
        elseif not Maxed and Data.MaxLabel then
            Data.MaxLabel:Destroy()
            Data.MaxLabel = nil
            MaxNotified[Hive] = nil
        end
    end

    local function ScanDescendant(Obj: Instance)
        if Obj:IsA("Model") and Obj:FindFirstChild("PrimaryPart") or Obj:IsA("Model") and Obj.PrimaryPart then
            local Tags = CollectionService:GetTags(Obj)
            if table.find(Tags, "bee") and not IsTamed(Obj) and Obj.PrimaryPart then
                TrackBee(Obj.PrimaryPart)
            end
            if table.find(Tags, "beehive") then
                TrackHive(Obj)
            end
        end
        if CollectionService:HasTag(Obj, "bee") and Obj:IsA("Model") and Obj.PrimaryPart then
            if not IsTamed(Obj) then TrackBee(Obj.PrimaryPart) end
        end
        if CollectionService:HasTag(Obj, "beehive") then
            TrackHive(Obj)
        end
    end

    local Beekeeper = Windows.Render:CreateModule({
        Name = "Beekeeper ESP",
        Flag = "BeekeeperESP",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                for _, Obj in workspace:GetDescendants() do
                    task.spawn(ScanDescendant, Obj)
                end

                self:Connection(workspace.DescendantAdded:Connect(function(Obj)
                    task.defer(ScanDescendant, Obj)
                end))

                self:Connection(workspace.DescendantRemoving:Connect(function(Obj)
                    if Obj:IsA("Model") and Obj.PrimaryPart then Untrack(Obj.PrimaryPart) end
                    Untrack(Obj)
                end))

                self:Connection(CollectionService:GetInstanceAddedSignal("bee"):Connect(function(Obj)
                    if Obj:IsA("Model") and Obj.PrimaryPart and not IsTamed(Obj) then
                        task.defer(TrackBee, Obj.PrimaryPart)
                    end
                end))

                self:Connection(CollectionService:GetInstanceRemovedSignal("bee"):Connect(function(Obj)
                    if Obj:IsA("Model") and Obj.PrimaryPart then Untrack(Obj.PrimaryPart) end
                end))

                self:Connection(CollectionService:GetInstanceAddedSignal("beehive"):Connect(function(Obj)
                    task.defer(TrackHive, Obj)
                end))

                self:Connection(CollectionService:GetInstanceRemovedSignal("beehive"):Connect(function(Obj)
                    Untrack(Obj)
                end))

                self:Connection(RunService.RenderStepped:Connect(function()
                    for Obj, Data in Tracked do
                        if not Obj or not Obj.Parent then
                            Untrack(Obj)
                        elseif Data.Type == "hive" then
                            RefreshHiveLevel(Data.Billboard.Adornee)
                        end
                    end
                end))
            else
                ESPHolder:ClearAllChildren()
                table.clear(Tracked)
                table.clear(MaxNotified)
                PendingAlerts, LastAlert = 0, 0
            end
        end
    })

    Beekeeper:MiniToggle({
        Name = "Show Bees",
        Flag = "BeeESPShowBees",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Config.ShowBees = value
            if not value then
                for Obj, Data in Tracked do
                    if Data.Type == "bee" then Untrack(Obj) end
                end
            end
        end
    })

    Beekeeper:MiniToggle({
        Name = "Show Hives",
        Flag = "BeeESPShowHives",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Config.ShowHives = value
            if not value then
                for Obj, Data in Tracked do
                    if Data.Type == "hive" then Untrack(Obj) end
                end
            end
        end
    })

    Beekeeper:MiniToggle({
        Name = "Notifications",
        Flag = "BeeESPNotify",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Config.Notify = value
        end
    })

    Beekeeper:MiniToggle({
        Name = "Max LVL Notify",
        Flag = "BeeESPNotifyMax",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Config.NotifyMax = value
        end
    })

    Beekeeper:ColorSlider({
        Name = "Bee Color",
        Flag = "BeeESPBeeColor",
        Default = Color3.fromRGB(0, 0, 0),
        CallingFunction = function(self, value: Color3)
            Config.BeeColor = value
            for _, Data in Tracked do
                if Data.Type == "bee" and Data.Frame then
                    Data.Frame.BackgroundColor3 = value
                end
            end
        end
    })

    Beekeeper:ColorSlider({
        Name = "Hive Color",
        Flag = "BeeESPHiveColor",
        Default = Color3.fromRGB(0, 0, 0),
        CallingFunction = function(self, value: Color3)
            Config.HiveColor = value
            for _, Data in Tracked do
                if Data.Type == "hive" and Data.Frame and not Data.Maxed then
                    Data.Frame.BackgroundColor3 = value
                end
            end
        end
    })

    Beekeeper:ColorSlider({
        Name = "Max LVL Color",
        Flag = "BeeESPMaxColor",
        Default = Color3.fromRGB(255, 255, 255),
        CallingFunction = function(self, value: Color3)
            Config.MaxColor = value
            for _, Data in Tracked do
                if Data.Type == "hive" and Data.Maxed then
                    if Data.Frame then Data.Frame.BackgroundColor3 = value end
                    if Data.MaxLabel then Data.MaxLabel.TextColor3 = value end
                end
            end
        end
    })

    Beekeeper:Slider({
        Name = "Transparency",
        Flag = "BeeESPTransparency",
        Default = 50,
        Min = 0,
        Max = 100,
        CallingFunction = function(self, value: number)
            Config.Transparency = value / 100
            for _, Data in Tracked do
                local Target = Data.Frame
                if Target then Target.BackgroundTransparency = Config.Transparency end
            end
        end
    })

    Beekeeper:Slider({
        Name = "Corner Radius",
        Flag = "BeeESPCorner",
        Default = 6,
        Min = 0,
        Max = 16,
        CallingFunction = function(self, value: number)
            Config.Corner = value
            for _, Data in Tracked do
                local Corner = Data.Frame and Data.Frame:FindFirstChildOfClass("UICorner")
                if Corner then Corner.CornerRadius = UDim.new(0, value) end
            end
        end
    })

    Beekeeper:Slider({
        Name = "Bee Size",
        Flag = "BeeESPBeeSize",
        Default = 36,
        Min = 16,
        Max = 64,
        CallingFunction = function(self, value: number)
            Config.BeeSize = value
            for _, Data in Tracked do
                if Data.Type == "bee" and Data.Billboard then
                    Data.Billboard.Size = UDim2.fromOffset(value, value)
                end
            end
        end
    })
end)();

(function()
	local Me = Players.LocalPlayer

	local Skins = {
		Nightmare = {asset = "cannon_nightmare_victorious", sfx = "CANNON_FIRE_VICTORIOUS_NIGHTMARE"},
		Diamond = {asset = "cannon_diamond_victorious", sfx = "CANNON_FIRE_VICTORIOUS_DIAMOND"},
		Emerald = {asset = "cannon_emerald_victorious", sfx = "CANNON_FIRE_VICTORIOUS_EMERALD"}
	}

	local ActiveSkin = "Nightmare"
	local TAG = "DANIELWHITETHEPASTER"
	local Binds = {}
	local Active = false
	local OrigFire, OrigLaunch, SfxPatched = nil, nil, false

	local HandOff = CFrame.new()
	local WorldOff = CFrame.new(0, -0.75, 0)

	local function GetVisuals(Root)
		local Parts, Decals = {}, {}
		for _, Obj in Root:GetDescendants() do
			if Obj:IsA("BasePart") then Parts[#Parts + 1] = Obj
			elseif Obj:IsA("Decal") or Obj:IsA("Texture") then Decals[#Decals + 1] = Obj end
		end
		return Parts, Decals
	end

	local function HideOrig(Root)
		local Parts, Decals = GetVisuals(Root)
		for _, P in Parts do P.Transparency, P.LocalTransparencyModifier = 1, 1 end
		for _, D in Decals do D.Transparency = 1 end
	end

	local function ShowOrig(Root)
		local Parts, Decals = GetVisuals(Root)
		for _, P in Parts do P.Transparency, P.LocalTransparencyModifier = 0, 0 end
		for _, D in Decals do D.Transparency = 0 end
	end

	local function GetTemplate()
		return ReplicatedStorage.Assets.Blocks:FindFirstChild(Skins[ActiveSkin].asset)
	end

	local function GetAnchor(Container)
		local H = Container:FindFirstChild("Handle")
		if H and H:IsA("BasePart") then return H end
		for _, D in Container:GetDescendants() do
			if D:IsA("BasePart") then return D end
		end
		return nil
	end

	local function WeldAll(Model)
		local Root = Model.PrimaryPart
		if not Root then return end
		for _, D in Model:GetDescendants() do
			if D:IsA("BasePart") and D ~= Root then
				local W = Instance.new("WeldConstraint")
				W.Part0, W.Part1 = Root, D
				W.Parent = Root
			end
		end
	end

	local function NoPhysics(Model)
		for _, D in Model:GetDescendants() do
			if D:IsA("BasePart") then
				D.CanCollide, D.CanTouch, D.CanQuery, D.Massless, D.Anchored = false, false, false, true, false
			end
		end
	end

	local function SetPrimary(Model)
		if Model.PrimaryPart then return true end
		for _, D in Model:GetDescendants() do
			if D:IsA("BasePart") then
				local Ok = pcall(function() Model.PrimaryPart = D end)
				if Ok then return true end
			end
		end
		return false
	end

	local function Apply(Target, Offset)
		if not Target or CollectionService:HasTag(Target, TAG) then return end
		CollectionService:AddTag(Target, TAG)

		local Anchor = GetAnchor(Target)
		if not Anchor then CollectionService:RemoveTag(Target, TAG); return end

		local Tmpl = GetTemplate()
		if not Tmpl then CollectionService:RemoveTag(Target, TAG); return end

		HideOrig(Target)

		local Skin = Tmpl:Clone()
		Skin.Name = "_cskin"

		if Skin:IsA("Model") then
			if not SetPrimary(Skin) then
				Skin:Destroy()
				CollectionService:RemoveTag(Target, TAG)
				return
			end
			NoPhysics(Skin)
			Skin.Parent = Target
			pcall(Skin.PivotTo, Skin, Anchor.CFrame * Offset)
			WeldAll(Skin)

			local Bridge = Instance.new("WeldConstraint")
			Bridge.Part0, Bridge.Part1 = Anchor, Skin.PrimaryPart
			Bridge.Parent = Skin
		else
			Skin.Parent = Target
		end
	end

	local function Remove(Target)
		if not Target then return end
		local Sk = Target:FindFirstChild("_cskin")
		if Sk then Sk:Destroy() end
		ShowOrig(Target)
		pcall(CollectionService.RemoveTag, CollectionService, Target, TAG)
	end

	local function Listen(Parent, Check, Offset, Now)
		if Now then
			for _, Ch in Parent:GetChildren() do
				if Check(Ch) then Apply(Ch, Offset) end
			end
		end
		local C = Parent.ChildAdded:Connect(function(Ch)
			if not Active then return end
			task.defer(function()
				if Check(Ch) then Apply(Ch, Offset) end
			end)
		end)
		Binds[#Binds + 1] = C
		return C
	end

	local function IsCannon(Obj) return Obj.Name == "cannon" end
	local function IsCannonTool(Obj) return Obj:IsA("Tool") and Obj.Name == "cannon" end

	local function WatchCam()
		local Cam = workspace.CurrentCamera
		if not Cam then return end

		local function HookVm(Vm)
			Listen(Vm, IsCannon, HandOff, true)
		end

		local Existing = Cam:FindFirstChild("Viewmodel")
		if Existing then HookVm(Existing) end

		Binds[#Binds + 1] = Cam.ChildAdded:Connect(function(Ch)
			if Ch.Name == "Viewmodel" then task.defer(HookVm, Ch) end
		end)
	end

	local function WatchEquip(Char)
		local C = Char.ChildAdded:Connect(function(Tool)
			if not (Active and IsCannonTool(Tool)) then return end
			task.defer(function()
				local Handle = GetAnchor(Tool)
				if not Handle then return end

				local Old = Tool:FindFirstChild("_cskin")
				if Old then Old:Destroy() end

				local Tmpl = GetTemplate()
				if not Tmpl then return end

				local Skin = Tmpl:Clone()
				Skin.Name = "_cskin"
				Skin.Parent = Tool

				if Skin:IsA("Model") then
					SetPrimary(Skin)
					NoPhysics(Skin)
					pcall(Skin.PivotTo, Skin, Handle.CFrame * HandOff)
					WeldAll(Skin)
					local W = Instance.new("WeldConstraint")
					W.Part0, W.Part1 = Handle, Skin.PrimaryPart
					W.Parent = Skin
				end

				local Elapsed = 0
				local Hb
				Hb = RunService.Heartbeat:Connect(function(Dt)
					if not Tool.Parent then Hb:Disconnect() return end
					HideOrig(Tool)
					if Skin and Skin.Parent and Skin:IsA("Model") and Skin.PrimaryPart then
						pcall(Skin.PivotTo, Skin, Handle.CFrame * HandOff)
					end
					Elapsed += Dt
					if Elapsed > 2 then Hb:Disconnect() end
				end)
				Binds[#Binds + 1] = Hb
			end)
		end)
		Binds[#Binds + 1] = C

		for _, Ch in Char:GetChildren() do
			if IsCannonTool(Ch) then C:Fire(Ch) end
		end

		for _, Ch in Char:GetChildren() do
			if IsCannonTool(Ch) then
				task.defer(function()
					Apply(Ch, HandOff)
				end)
			end
		end
	end

	local function WatchWorld()
		local Worlds = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Worlds")
		if not Worlds then return end

		local function HookFolder(Folder)
			Listen(Folder, IsCannon, WorldOff, true)

			local C = Folder.ChildAdded:Connect(function(Ch)
				if not (Active and IsCannon(Ch)) then return end
				task.defer(function()
					task.wait()
					local Sk = Ch:FindFirstChild("_cskin")
					if not (Sk and Sk:IsA("Model") and Sk.PrimaryPart) then return end
					local Anchor = GetAnchor(Ch)
					if not Anchor then return end
					for _, W in Sk:GetChildren() do
						if W:IsA("WeldConstraint") and W.Part0 == Anchor then W:Destroy() end
					end
					Sk:PivotTo(Anchor.CFrame * WorldOff)
					local Bridge = Instance.new("WeldConstraint")
					Bridge.Part0, Bridge.Part1 = Anchor, Sk.PrimaryPart
					Bridge.Parent = Sk
				end)
			end)
			Binds[#Binds + 1] = C
		end

		for _, World in Worlds:GetChildren() do
			local B = World:FindFirstChild("Blocks")
			if B then HookFolder(B) end
		end

		Binds[#Binds + 1] = Worlds.ChildAdded:Connect(function(World)
			task.defer(function()
				local B = World:FindFirstChild("Blocks")
				if B then HookFolder(B) end
			end)
		end)
	end

	local function PurgeSfx()
		for _, S in workspace.SoundPool:GetChildren() do
			if S:IsA("Sound") and S.SoundId == "rbxassetid://7121064180" then S:Destroy() end
		end
	end

	local function PlaySfx()
		local Data = Skins[ActiveSkin]
		if Data then GameData.Utils.Sound:playSound(GameData.Utils.GameSound[Data.sfx]) end
	end

	local function PatchSfx()
		if SfxPatched then return end
		SfxPatched = true
		local Ctrl = GameData.Utils.Cannon

		OrigFire = Ctrl.fireCannon
		OrigLaunch = Ctrl.launchSelf

		Ctrl.fireCannon = function(...)
			PurgeSfx()
			PlaySfx()
			return OrigFire(...)
		end

		Ctrl.launchSelf = function(...)
			PurgeSfx()
			PlaySfx()
			return OrigLaunch(...)
		end
	end

	local function UnpatchSfx()
		if not SfxPatched then return end
		local Ctrl = GameData.Utils.Cannon
		Ctrl.fireCannon = OrigFire
		Ctrl.launchSelf = OrigLaunch
		OrigFire, OrigLaunch = nil, nil
		SfxPatched = false
	end

	local function OnSpawn(Char)
		task.wait(0.2)
		if not Active then return end
		Listen(Me.Backpack, IsCannonTool, HandOff, true)
		Listen(Char, IsCannonTool, HandOff, true)
		WatchEquip(Char)
	end

	local function Teardown()
		Active = false
		for _, C in Binds do pcall(C.Disconnect, C) end
		table.clear(Binds)

		for _, Obj in CollectionService:GetTagged(TAG) do
			Remove(Obj)
		end

		local Worlds = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Worlds")
		if Worlds then
			for _, World in Worlds:GetChildren() do
				local B = World:FindFirstChild("Blocks")
				if B then
					for _, Ch in B:GetChildren() do
						if Ch.Name == "cannon" then Remove(Ch) end
					end
				end
			end
		end

		UnpatchSfx()
	end

	local CannonReskin = Windows.Render:CreateModule({
		Name = "Cannon Reskin",
		Flag = "CannonReskin",
		CallingFunction = function(self, enabled: boolean)
			if enabled then
				Active = true
				WatchCam()
				WatchWorld()
				PatchSfx()
				if Me.Character then OnSpawn(Me.Character) end
				Binds[#Binds + 1] = Me.CharacterAdded:Connect(OnSpawn)
			else
				Teardown()
			end
		end
	})

	CannonReskin:Dropdown({
		Name = "Skin",
		Flag = "CannonReskinSkin",
		Options = {"Nightmare", "Diamond", "Emerald"},
		Default = {"Nightmare"},
		CallingFunction = function(self, value: {})
			ActiveSkin = value
		end
	})
end)();


(function()
    local Sword
    local Parts
    local Size1 = 6.8
    local Size2 = 8

    local ExpandedParts = {}

    local function ExpandPlayer(Character)
        local HRP = Character:FindFirstChild("HumanoidRootPart")
        if not HRP or ExpandedParts[Character] or not Parts then return end

        local Box = Instance.new("Part")
        Box.Size = Vector3.new(Size2, Size2, Size2)
        Box.Transparency = 1
        Box.CanCollide = false
        Box.CanQuery = true
        Box.Massless = true
        Box.Name = "HB"

        local Weld = Instance.new("WeldConstraint")
        Weld.Part0 = HRP
        Weld.Part1 = Box
        Weld.Parent = Box

        Box.CFrame = HRP.CFrame
        Box.Parent = Character
        ExpandedParts[Character] = Box
    end

    local function Cleanup()
        for _, Part in next, ExpandedParts do
            if Part and Part.Parent then
                Part:Destroy()
            end
        end
        table.clear(ExpandedParts)
    end

    local OldRegion = debug.getconstant(GameData.Utils.SwordController.swingSwordInRegion, 6)
    local OldAttack = debug.getconstant(GameData.Utils.SwordController.attackEntity, 58)

    local Radius
    for i, v in debug.getconstants(GameData.Utils.SwordController.getTargetInRegion) do
        if v == 3.8 then
            Radius = i
            break
        end
    end
    local OldRadius = Radius and debug.getconstant(GameData.Utils.SwordController.getTargetInRegion, Radius)

    local function Reach()
        debug.setconstant(GameData.Utils.SwordController.swingSwordInRegion, 6, Size1)

        if Radius then
            debug.setconstant(GameData.Utils.SwordController.getTargetInRegion, Radius, Size1)
        end

        debug.setconstant(GameData.Utils.SwordController.attackEntity, 58, "damage")
    end

    local function Reset()
        debug.setconstant(GameData.Utils.SwordController.swingSwordInRegion, 6, OldRegion)

        if Radius then
            debug.setconstant(GameData.Utils.SwordController.getTargetInRegion, Radius, OldRadius)
        end

        debug.setconstant(GameData.Utils.SwordController.attackEntity, 58, OldAttack)
    end

    local Applied = false
    local Hitboxes = Windows.Combat:CreateModule({
        Name = "Hitboxes",
        Flag = "Hitboxes",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                if Sword then
                    Reach()
                end

                for _, Player in Players:GetPlayers() do
                    if Player ~= LocalPlayer and Player.Character then
                        ExpandPlayer(Player.Character)
                    end
                end

                self:Connection(Players.PlayerAdded:Connect(function(Player)
                    if Player ~= LocalPlayer then
                        self:Connection(Player.CharacterAdded:Connect(function(Char)
                            task.wait(0.1)
                            ExpandPlayer(Char)
                        end))
                    end
                end))

                for _, Player in Players:GetPlayers() do
                    if Player ~= LocalPlayer then
                        self:Connection(Player.CharacterAdded:Connect(function(Char)
                            task.wait(0.1)
                            ExpandPlayer(Char)
                        end))
                    end
                end
            else
                if Applied then
                    Reset()
                    Applied = false
                end

                Cleanup()
            end
        end
    })

    local SwordSize, PartsSize
    Hitboxes:MiniToggle({
        Name = "Sword",
        Flag = "HitboxesSword",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Sword = value
            SwordSize:SetVisiblity(value)
        end
    })

    SwordSize = Hitboxes:Slider({
        Name = "Sword Size",
        Flag = "HitboxesSwordSize",
        Min = 3.8,
        Max = 6.8,
        Default = 6.8,
        Increment = 0.1,
        CallingFunction = function(self, value: number)
            Size1 = value
        end
    })

    Hitboxes:MiniToggle({
        Name = "Parts",
        Flag = "HitboxesParts",
        Default = true,
        CallingFunction = function(self, value: boolean)
            Parts = value
            PartsSize:SetVisiblity(value)
        end
    })

    PartsSize = Hitboxes:Slider({
        Name = "Parts Size",
        Flag = "HitboxesPartsSize",
        Min = 2,
        Max = 15,
        Default = 8,
        CallingFunction = function(self, value: number)
            Size2 = value
        end
    })
end)();

(function()
    local KeepSprintEnabled = false
    local NamecallHooked = false

    Windows.Movement:CreateModule({
        Name = "Keep Sprint",
        Flag = "KeepSprint",
        CallingFunction = function(self, enabled: boolean)
            KeepSprintEnabled = enabled

            if not NamecallHooked then
                NamecallHooked = true
                local Old; Old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if KeepSprintEnabled and method == "blockSprint" then
                        setnamecallmethod("blockSprinting")
                    end
                    return Old(self, ...)
                end))
            end
            GameData.Utils.Sprint.stopSprinting()
        end
    })
end)();

(function()
	local Enabled
	local Cache = {}
	local Storage = Instance.new("Folder")
	Storage.Parent = workspace

	local function Render(Target)
		if not Enabled or Cache[Target] then return end
		local Group = Instance.new("Folder")
		Cache[Target] = Group

		local Parts = {}
		for _, Object in Target:GetChildren() do
			if Object:IsA("BasePart") and Object.Name ~= "Blanket" then
				Parts[#Parts + 1] = Object
			end
		end

		table.sort(Parts, function(First, Second)
			return First.Name > Second.Name
		end)

		for Index = 1, #Parts do
			local Part = Parts[Index]
			local IsLeg = Part.Name == "Legs"
			local Adornment = Instance.new("BoxHandleAdornment")

            Adornment.Size = Part.Size + (IsLeg and Vector3.new(0, -1, 0) or Vector3.new(0, 0.3, 0))
			Adornment.Color3 = IsLeg and Color3.fromRGB(100, 65, 35) or Part.Color
			Adornment.ZIndex = IsLeg and 0 or 2
			Adornment.Adornee = Part
			Adornment.Visible = true
            Adornment.AlwaysOnTop = true

			if IsLeg then
				Adornment.CFrame = CFrame.new(0, -0.5, 0)
			end

			Adornment.Parent = Group
		end

		Group.Parent = Storage
	end

	local function Clear(Target)
		local Group = Cache[Target]
		if not Group then return end
		Group:Destroy()
		Cache[Target] = nil
	end

	local function Wipe()
		Storage:ClearAllChildren()
		table.clear(Cache)
	end

	Windows.Render:CreateModule({
		Name = "Bed ESP",
		Flag = "BedESP",
		CallingFunction = function(self, enabled: boolean)
			Enabled = enabled
			if not Enabled then
				Wipe()
				return
			end

            for _, Bed in CollectionService.GetTagged(CollectionService, "bed") do
				Render(Bed)
			end

			self:Connection(CollectionService.GetInstanceAddedSignal(CollectionService, "bed"):Connect(function(Bed)
				task.delay(0.5, Render, Bed)
			end))

			self:Connection(CollectionService.GetInstanceRemovedSignal(CollectionService, "bed"):Connect(function(Bed)
				Clear(Bed)
			end))
		end
	})
end)();

(function()
    local GeneratorData = {
        Settings = {
            Diamonds = true,
            Emeralds = true,
            TeamGens = true,
            OwnTeam = false,
            EnemyTeams = true
        },
        Data = {
            Visuals = {},
            Container = Instance.new("Folder"),
            UpdateClock = 0
        }
    }

    GeneratorData.Data.Container.Name = "GeneratorESPHolder"
    GeneratorData.Data.Container.Parent = workspace.CurrentCamera

    local TeamPalette = {
        [1] = {Label = "Blue", Hue = Color3.fromRGB(0, 145, 255)},
        [2] = {Label = "Orange", Hue = Color3.fromRGB(255, 150, 0)},
        [3] = {Label = "Pink", Hue = Color3.fromRGB(255, 0, 210)},
        [4] = {Label = "Yellow", Hue = Color3.fromRGB(255, 250, 0)},
        [5] = {Label = "Green", Hue = Color3.fromRGB(0, 255, 100)},
        [6] = {Label = "Red", Hue = Color3.fromRGB(255, 40, 40)},
        [7] = {Label = "Purple", Hue = Color3.fromRGB(160, 50, 255)},
        [8] = {Label = "Cyan", Hue = Color3.fromRGB(0, 255, 255)},
        [9] = {Label = "White", Hue = Color3.fromRGB(245, 245, 245)},
        [10] = {Label = "Black", Hue = Color3.fromRGB(40, 40, 40)}
    }

    local GenDefinitions = {
        diamond = {
            Match = "diamond",
            Icon = "diamond",
            Tag = "Diamond",
            Tint = Color3.fromRGB(85, 200, 255),
        },
        emerald = {
            Match = "emerald",
            Icon = "emerald",
            Tag = "Emerald",
            Tint = Color3.fromRGB(0, 255, 100),
        }
    }

    local TeamLookup = {
        {Name = "blue", Index = "0", Value = 1},
        {Name = "orange", Index = "1", Value = 2},
        {Name = "pink", Index = "2", Value = 3},
        {Name = "yellow", Index = "3", Value = 4}
    }

    local function GetMyTeam(): number?
        local TeamAttr = LocalPlayer:GetAttribute("Team")
        if not TeamAttr then return nil end

        local Mapped = tostring(TeamAttr):lower()
        for _, Info in TeamLookup do
            if Mapped:find(Info.Name) or Mapped == Info.Index then
                return Info.Value
            end
        end

        return nil
    end

    local function GetGenId(Id: string): (string?, boolean, number?)
        if not Id then return nil, false, nil end

        local Sep = Id:find("_")
        if Sep and Id:sub(Sep + 1) == "generator" then
            local Prefix = Id:sub(1, Sep - 1)
            local AsNum = tonumber(Prefix)
            if AsNum then return "teamgen", true, AsNum end
        end

        local Lower = Id:lower()
        for Key, Def in GenDefinitions do
            if Lower:find(Def.Match) then
                return Key, false, nil
            end
        end

        return nil, false, nil
    end

    local function CanShow(GenType: string, TeamId: number?): boolean
        if GenType == "diamond" then return GeneratorData.Settings.Diamonds end
        if GenType == "emerald" then return GeneratorData.Settings.Emeralds end

        if GenType == "teamgen" then
            if not GeneratorData.Settings.TeamGens then return false end

            local MyTeam = GetMyTeam()
            if not MyTeam or not TeamId then return true end

            return TeamId == MyTeam and GeneratorData.Settings.OwnTeam or TeamId ~= MyTeam and GeneratorData.Settings.EnemyTeams
        end

        return false
    end

    local function GetItemIcon(ItemType: string): string?
        local Result = GetIcon({itemType = ItemType}, true)
        return (Result and Result ~= "") and Result or nil
    end

    local function GetTimer(Adornee: Instance): number
        local Tree = Adornee:FindFirstChild("RoactTree")
        if not Tree then return 0 end

        local App = Tree:FindFirstChild("TeamOreGeneratorApp")
        if not App then return 0 end

        local Global = App:FindFirstChild("GlobalOreGenerator")
        if not Global then return 0 end

        local CountdownNode = Global:FindFirstChild("Countdown")
        if not CountdownNode then return 0 end

        local Label = CountdownNode:FindFirstChild("Text") or (CountdownNode:IsA("TextLabel") and CountdownNode)
        if not Label or not Label:IsA("TextLabel") then return 0 end

        local Raw = Label.Text
        local Extracted = nil
        local Open = Raw:find("%[")
        if Open then
            local Close = Raw:find("%]", Open + 1)
            if Close then Extracted = Raw:sub(Open + 1, Close - 1) end
        end

        if not Extracted then
            local S, E = Raw:find("%d+")
            if S then Extracted = Raw:sub(S, E) end
        end

        return tonumber(Extracted) or 0
    end

    local RomanMap = {[0] = "0", [1] = "I", [2] = "II", [3] = "III", [4] = "IV"}

    local function GetTier(Adornee: Instance): string
        local Tree = Adornee:FindFirstChild("RoactTree")
        local App = Tree and Tree:FindFirstChild("TeamOreGeneratorApp")
        if not App then return "0" end

        local Paths = {
            {"GlobalOreGenerator", "Countdown"},
            {"GlobalOreGenerator"},
            {"TeamGenMain"}
        }

        for _, Path in Paths do
            local Current = App
            for _, Step in Path do
                Current = Current:FindFirstChild(Step)
                if not Current then break end
            end

            if not Current then continue end
            for _, Child in Current:GetChildren() do
                if not Child:IsA("TextLabel") then continue end

                local Txt = Child.Text
                local TierPos = Txt:find("Tier")

                if TierPos then
                    local After = Txt:sub(TierPos + 4):gsub("^%s+", "")
                    local Val = tonumber(After:match("%d+"))
                    if Val then return RomanMap[Val] or tostring(Val) end
                end

                local IsRoman = #Txt > 0 and not Txt:find("[^IVX]")
                if IsRoman then return Txt end
            end
        end
        return "0"
    end

    local function GetDropCount(Origin: Vector3, ResourceName: string): number
        local Total = 0

        for _, Drop in CollectionService:GetTagged("ItemDrop") do
            local Handle = Drop:FindFirstChild("Handle")
            if Handle and Drop.Name:lower():find(ResourceName) and (Handle.Position - Origin).Magnitude <= 10 then
                Total += Drop:GetAttribute("Amount") or 1
            end
        end

        return Total
    end

    local function GetTimerTint(Seconds: number, BaseColor: Color3): Color3
        if Seconds <= 5 then return Color3.fromRGB(255, 0, 0) end
        if Seconds <= 10 then return Color3.fromRGB(255, 145, 0) end
        return BaseColor
    end

    local function MakeCorner(Parent: Instance, Radius: number)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, Radius)
        Corner.Parent = Parent
        return Corner
    end

    local function MakeStroke(Parent: Instance, Col: Color3, Thick: number)
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Col
        Stroke.Thickness = Thick
        Stroke.Transparency = 0.5
        Stroke.Parent = Parent
        return Stroke
    end

    local function MakeLabel(Props: {[string]: any}): TextLabel
        local Lbl = Instance.new("TextLabel")
        Lbl.BackgroundTransparency = 1
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextStrokeTransparency = 0.5
        Lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        for Key, Val in Props do
            (Lbl :: any)[Key] = Val
        end
        return Lbl
    end

    local function CreateBoard(Adornee: Instance, GenType: string, Pos: Vector3, TeamId: number?, IsTeam: boolean)
        if GeneratorData.Data.Visuals[Adornee] then return end

        local DisplayTint = IsTeam and (TeamId and TeamPalette[TeamId] and TeamPalette[TeamId].Hue or Color3.fromRGB(200, 200, 200)) or GenDefinitions[GenType].Tint

        local Board = Instance.new("BillboardGui")
        Board.Name = "GenESP_" .. GenType
        Board.Adornee = Adornee
        Board.AlwaysOnTop = true
        Board.ClipsDescendants = false
        Board.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
        Board.Size = IsTeam and UDim2.fromOffset(175, 34) or UDim2.fromOffset(88, 30)
        Board.Parent = GeneratorData.Data.Container

        local Backdrop = Instance.new("Frame")
        Backdrop.Size = UDim2.fromScale(1, 1)
        Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Backdrop.BackgroundTransparency = 0.5
        Backdrop.BorderSizePixel = 0
        Backdrop.Parent = Board
        MakeCorner(Backdrop, 6)
        MakeStroke(Backdrop, DisplayTint, 1)

        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new(Color3.fromRGB(69, 69, 78), Color3.fromRGB(0, 0, 0))
        Gradient.Rotation = 90
        Gradient.Parent = Backdrop

        local Entry: {[string]: any} = {
            Board = Board,
            GenType = GenType,
            Pos = Pos,
            TeamId = TeamId,
            IsTeam = IsTeam
        }

        if IsTeam then
            Entry.TierLabel = MakeLabel({
                Name = "Tier", Parent = Backdrop,
                Size = UDim2.new(0, 22, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                Text = "0", TextColor3 = Color3.fromRGB(255, 255, 100),
                TextSize = 14
            })

            local Resources = {
                {Key = "Iron", IconId = "iron", Tint = Color3.fromRGB(255, 255, 255), X = 30},
                {Key = "Diamond", IconId = "diamond", Tint = Color3.fromRGB(0, 225, 255), X = 80},
                {Key = "Emerald", IconId = "emerald", Tint = Color3.fromRGB(0, 255, 80), X = 130}
            }

            for _, Res in Resources do
                local Img = GetItemIcon(Res.IconId)
                if Img then
                    local Icon = Instance.new("ImageLabel")
                    Icon.Size = UDim2.fromOffset(16, 16)
                    Icon.Position = UDim2.new(0, Res.X, 0.5, -8)
                    Icon.BackgroundTransparency = 1
                    Icon.Image = Img
                    Icon.Parent = Backdrop
                end

                Entry[Res.Key .. "Label"] = MakeLabel({
                    Name = Res.Key, Parent = Backdrop,
                    Size = UDim2.new(0, 24, 1, 0),
                    Position = UDim2.new(0, Res.X + 18, 0, 0),
                    Text = "0", TextColor3 = Res.Tint,
                    TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })
            end
        else
            local Img = GetItemIcon(GenDefinitions[GenType].Icon)
            if Img then
                local Icon = Instance.new("ImageLabel")
                Icon.Size = UDim2.fromOffset(18, 18)
                Icon.Position = UDim2.new(0, 5, 0.5, -9)
                Icon.BackgroundTransparency = 1
                Icon.Image = Img
                Icon.Parent = Backdrop
            end

            Entry.TimerLabel = MakeLabel({
                Name = "Timer", Parent = Backdrop,
                Size = UDim2.new(0, 30, 1, 0),
                Position = UDim2.new(0.5, -2, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                Text = "00", TextColor3 = DisplayTint,
                TextSize = 16
            })

            Entry.AmountLabel = MakeLabel({
                Name = "Amount", Parent = Backdrop,
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -22, 0, 0),
                Text = "0", TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 13
            })
        end

        GeneratorData.Data.Visuals[Adornee] = Entry
    end

    local function UpdateOne(Adornee: Instance)
        local Ref = GeneratorData.Data.Visuals[Adornee]
        if not Ref then return end

        if Ref.IsTeam then
            Ref.TierLabel.Text = GetTier(Adornee)
            Ref.IronLabel.Text = tostring(GetDropCount(Ref.Pos, "iron"))
            Ref.DiamondLabel.Text = tostring(GetDropCount(Ref.Pos, "diamond"))
            Ref.EmeraldLabel.Text = tostring(GetDropCount(Ref.Pos, "emerald"))
        else
            local Seconds = GetTimer(Adornee)
            Ref.TimerLabel.Text = string.format("%02d", Seconds)
            Ref.TimerLabel.TextColor3 = GetTimerTint(Seconds, GenDefinitions[Ref.GenType].Tint)
            Ref.AmountLabel.Text = tostring(GetDropCount(Ref.Pos, Ref.GenType))
        end
    end

    local function ClearAll()
        GeneratorData.Data.Container:ClearAllChildren()
        table.clear(GeneratorData.Data.Visuals)
    end

    local function FindGens()
        for _, Obj in workspace:GetDescendants() do
            if Obj.Name == "GeneratorAdornee" then
                local Id = Obj:GetAttribute("Id")
                if not Id then continue end
                local GenType, IsTeam, TeamId = GetGenId(Id)
                if GenType and CanShow(GenType, TeamId) then
                    CreateBoard(Obj, GenType, Obj:GetPivot().Position, TeamId, IsTeam)
                end
            end
        end
    end

    local function FullRefresh()
        ClearAll()
        FindGens()
    end

    local GeneratorESP = Windows.Render:CreateModule({
        Name = "Generator ESP",
        Flag = "GeneratorESP",
        CallingFunction = function(self, enabled: boolean)
            if enabled then
                FindGens()

                self:Connection(workspace.DescendantAdded:Connect(function(Obj)
                    if Obj.Name ~= "GeneratorAdornee" then return end

                    task.wait(0.2)
                    local Id = Obj:GetAttribute("Id")
                    if not Id then return end

                    local GenType, IsTeam, TeamId = GetGenId(Id)
                    if GenType and CanShow(GenType, TeamId) then
                        CreateBoard(Obj, GenType, Obj:GetPivot().Position, TeamId, IsTeam)
                    end
                end))

                self:Connection(workspace.DescendantRemoving:Connect(function(Obj)
                    local Ref = GeneratorData.Data.Visuals[Obj]
                    if Ref then
                        Ref.Board:Destroy()
                        GeneratorData.Data.Visuals[Obj] = nil
                    end
                end))

                self:Connection(RunService.Heartbeat:Connect(function(Delta)
                    GeneratorData.Data.UpdateClock += Delta
                    if GeneratorData.Data.UpdateClock < 0.2 then return end
                    GeneratorData.Data.UpdateClock = 0

                    for Adornee, Ref in GeneratorData.Data.Visuals do
                        if Adornee and Adornee.Parent then
                            UpdateOne(Adornee)
                        else
                            Ref.Board:Destroy()
                            GeneratorData.Data.Visuals[Adornee] = nil
                        end
                    end
                end))
            else
                ClearAll()
            end
        end
    })

    GeneratorESP:MiniToggle({
        Name = "Diamonds",
        Flag = "GeneratorESPDiamonds",
        Default = true,
        CallingFunction = function(self, value: boolean)
            GeneratorData.Settings.Diamonds = value
            FullRefresh()
        end
    })

    GeneratorESP:MiniToggle({
        Name = "Emeralds",
        Flag = "GeneratorESPEmeralds",
        Default = true,
        CallingFunction = function(self, value: boolean)
            GeneratorData.Settings.Emeralds = value
            FullRefresh()
        end
    })

    GeneratorESP:MiniToggle({
        Name = "Team Generators",
        Flag = "GeneratorESPTeamGens",
        Default = true,
        CallingFunction = function(self, value: boolean)
            GeneratorData.Settings.TeamGens = value
            FullRefresh()
        end
    })

    GeneratorESP:MiniToggle({
        Name = "Own Team",
        Flag = "GeneratorESPOwnTeam",
        Default = false,
        CallingFunction = function(self, value: boolean)
            GeneratorData.Settings.OwnTeam = value
            FullRefresh()
        end
    })

    GeneratorESP:MiniToggle({
        Name = "Enemy Teams",
        Flag = "GeneratorESPEnemyTeams",
        Default = true,
        CallingFunction = function(self, value: boolean)
            GeneratorData.Settings.EnemyTeams = value
            FullRefresh()
        end
    })
end)();
