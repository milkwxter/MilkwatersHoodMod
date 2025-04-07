AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Robbery - Cash Register"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

-- my variables
ENT.CashRegisterHealth = 50
ENT.CashRegisterRespawn = 0
ENT.alreadyProduced = false

if SERVER then
	-- called when you spawn it
	function ENT:Initialize()
		-- network the variables, needed for the client to see the 3d2d text
		self:SetNWInt("CashRegisterHealth", self.CashRegisterHealth)
		self:SetNWInt("CashRegisterRespawn", self.CashRegisterRespawn)
	
		-- initialize model
		self:SetModel("models/cash_register/cashregister01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end

	-- called every tick
	function ENT:Think()
		-- set next think time
		self:NextThink(CurTime() + 1)
		
		-- update respawn if broken
		if self.CashRegisterHealth <= 0 then
			self.CashRegisterRespawn = self.CashRegisterRespawn + 1
		end
		
		-- respawn self if timer is up
		if self.CashRegisterRespawn >= 60 then
			-- update our variables back to defaults
			self.CashRegisterRespawn = 0
			self.CashRegisterHealth = 50
			self.alreadyProduced = false
			
			-- clean ourselves up
			self:SetColor(Color(255, 255, 255))
			self:RemoveAllDecals()
			self:EmitSound("garrysmod/save_load1.wav")
		end
		
		-- update networked variables
		self:SetNWInt("CashRegisterHealth", self.CashRegisterHealth)
		self:SetNWInt("CashRegisterRespawn", self.CashRegisterRespawn)
		
		return true
	end
	
	-- called when the entity takes damage
	function ENT:OnTakeDamage(dmg)
		-- update health
		self.CashRegisterHealth = self.CashRegisterHealth - dmg:GetDamage()
		self:SetNWInt("CashRegisterHealth", self.CashRegisterHealth)

		-- check for the killing shot
		if self.CashRegisterHealth <= 0 and not self.alreadyProduced then
			self.alreadyProduced = true 

			-- become red
			self:SetColor(Color(255, 0, 0))

			-- spawn money
			self:ProduceCash()
		end
	end

	-- custom function, called when someone shoots the register to death
	function ENT:ProduceCash()
		local cash = ents.Create("money_pile")
		cash:SetPos(self:GetPos() + Vector(0, 0, 50))
		cash:Spawn()
		
		-- enable physics
        local phys = cash:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
		
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
		local health = self:GetNWInt("CashRegisterHealth", 0)
		local respawnTimer = self:GetNWInt("CashRegisterRespawn", 0)

		-- setup where the text appears
		local pos = self:GetPos() + Vector(0, 0, 40)
		local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

		-- draw the main text
		cam.Start3D2D(pos, ang, 0.2)
			draw.SimpleTextOutlined(
				"Cash Register",
				"DermaLarge",
				0, 0,
				Color(255, 255, 255),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				2,
				Color(0, 0, 0, 255)
			)
		cam.End3D2D()
		
		-- draw the other text
		if health > 0 then
			cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
				draw.SimpleTextOutlined(
					"Health: " .. health .. "/50",
					"DermaLarge",
					0, 0,
					Color(255, 255, 255),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
					2,
					Color(0, 0, 0, 255)
				)
			cam.End3D2D()
		else
			cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
				draw.SimpleTextOutlined(
					"Respawns in: " .. 60 - respawnTimer .. " seconds",
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
end
