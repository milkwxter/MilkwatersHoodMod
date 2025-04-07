SWEP.PrintName = "Watering Hose"
SWEP.Author = "Milkwater"
SWEP.Instructions = "Use this hose to water your plants. Don't get caught out there!"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.IconOverride = "weapons/firehose.png"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true
SWEP.ViewModel = "models/firehose/c_firehose.mdl"
SWEP.WorldModel = "models/firehose/w_firehose.mdl"
SWEP.ViewModelFOV = 80

function SWEP:Initialize()
    self:SetHoldType("ar2")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.08)

    -- create water effects
    local ply = self:GetOwner()
    local forward = ply:GetAimVector()
    local pos = ply:GetShootPos() + forward * 10
	
    local tr = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + forward * 100,
        filter = ply
    })
	
	local effectdata = EffectData()
    effectdata:SetOrigin(tr.HitPos)
    effectdata:SetNormal(forward * -1)
    effectdata:SetMagnitude(1)
    effectdata:SetScale(2)
    effectdata:SetRadius(10)
    util.Effect("watersplash", effectdata)

    if IsValid(tr.Entity) and tr.Entity:GetClass() == "weed_pot" then
		tr.Entity.IsWatered = true
		tr.Entity.WaterAmount = tr.Entity.WaterAmount + 5
		
		local stage = tr.Entity:GetNWInt("PlantStage", 0)
		local water = tr.Entity:GetNWInt("WaterAmount", 0)
		local growth = tr.Entity:GetNWInt("GrowthTime", 0)
		--print("Stage: " .. stage .. " | Water level: " .. water .. " | growth amount: " .. growth)
	end
end
