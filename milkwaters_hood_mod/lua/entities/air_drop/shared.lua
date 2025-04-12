AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Air Drop - Crate"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

-- my variables
ENT.AirDropHealth = 500
ENT.alreadyProduced = false

if SERVER then
	-- called when you spawn it
	function ENT:Initialize()
		-- network the variables, needed for the client to see the 3d2d text
		self:SetNWInt("AirDropHealth", self.AirDropHealth)
	
		-- initialize model
		self:SetModel("models/props_junk/wood_crate002a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		-- enable physics
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
			phys:SetMass( 500 )
        end
	end

	-- called every tick
	function ENT:Think()
		-- set next think time
		self:NextThink(CurTime() + 1)
		
		-- update networked variables
		self:SetNWInt("AirDropHealth", self.AirDropHealth)
		
		return true
	end
	
	-- called when the entity takes damage
	function ENT:OnTakeDamage(dmg)
		-- update health
		self.AirDropHealth = self.AirDropHealth - dmg:GetDamage()
		self:SetNWInt("AirDropHealth", self.AirDropHealth)

		-- check for the killing shot
		if self.AirDropHealth <= 0 and not self.alreadyProduced then
			self.alreadyProduced = true 

			-- become red
			self:SetColor(Color(255, 0, 0))

			-- spawn money
			self:ProduceCash()
			
			-- delete ourselves
			self:Remove()
		end
	end

	-- custom function, called when someone shoots the register to death
	function ENT:ProduceCash()
		local cash = ents.Create("money_pile")
		cash:SetPos(self:GetPos() + Vector(0, 0, 50))
		cash:Spawn()
		
		-- effects
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos())
		util.Effect("money_drop", effectData)
		self:EmitSound("register_kaching.wav")
	end
end

if CLIENT then
	-- called every tick as well
	function ENT:Draw()
		-- do the basics
		self:DrawModel()
		
		-- networked variables
		local health = self:GetNWInt("AirDropHealth", 0)

		-- setup where the text appears
		local pos = self:GetPos() + Vector(0, 0, 40)
		local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

		-- draw the main text
		cam.Start3D2D(pos, ang, 0.2)
			draw.SimpleTextOutlined(
				"Air Drop",
				"DermaLarge",
				0, 0,
				Color(255, 255, 255),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				2,
				Color(0, 0, 0, 255)
			)
		cam.End3D2D()
		
		-- draw the other text
		cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
			draw.SimpleTextOutlined(
				"Health: " .. math.floor(health) .. "/500",
				"DermaLarge",
				0, 0,
				Color(255, 255, 255),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				2,
				Color(0, 0, 0, 255)
			)
		cam.End3D2D()
	end
end
