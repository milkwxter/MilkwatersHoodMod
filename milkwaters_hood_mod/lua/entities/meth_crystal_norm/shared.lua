AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Drugs - Meth Bag"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

if SERVER then
	-- called when you spawn it
	function ENT:Initialize()
		-- initialize model
		self:SetModel("models/meth/meth_bags/brown_sky.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		self:SetUseType( SIMPLE_USE )
		
		-- enable physics
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
	end

	-- called when someone presses "E" on it
	function ENT:Use(activator)
		if activator:IsPlayer() then
			-- max out health
			activator:SetHealth(activator:GetMaxHealth())
			
			-- effects
			local effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			util.Effect("meth_boom_norm", effectData)
			self:EmitSound("lighter_smoke.wav")
			
			-- remove self
			self:Remove()
		end
	end
end