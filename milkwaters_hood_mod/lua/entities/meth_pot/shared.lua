AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Drugs - Meth Cooking Pot"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

-- my variables
ENT.Meth_Matchsticks = 0
ENT.Meth_HydrochloricAcid = 0
ENT.Meth_Sudafed = 0
ENT.Meth_Cooking = false
ENT.Meth_CookTime = 0
ENT.Meth_CookingSound = nil
local timeTillCooked = 120
local timeTillPerfect = timeTillCooked + 12
local timeTillBurnt = timeTillPerfect + 1
local hasProducedNormalParticles = false

if SERVER then
	-- function to make it easy to send networked vars to client
	function ENT:SendMethVarsToClient()
		self:SetNWInt("Meth_Matchsticks", self.Meth_Matchsticks)
		self:SetNWInt("Meth_HydrochloricAcid", self.Meth_HydrochloricAcid)
		self:SetNWInt("Meth_Sudafed", self.Meth_Sudafed)
		self:SetNWBool("Meth_Cooking", self.Meth_Cooking)
		self:SetNWBool("Meth_CookTime", self.Meth_CookTime)
	end

	-- called when you spawn it
	function ENT:Initialize()
		-- network the variables, needed for the client to see the 3d2d text
		self:SendMethVarsToClient()
	
		-- initialize model
		self:SetModel("models/props_c17/metalpot001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		-- enable physics
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
	end
	
	-- called when someone presses "E" on it
	function ENT:Use(activator)
		-- if product is ready
		if self.Meth_Cooking and self.Meth_CookTime >= timeTillCooked then
			-- spawn a meth crystal
			if self.Meth_CookTime == timeTillPerfect then
				local meth = ents.Create("meth_crystal_pure")
				meth:SetPos(self:GetPos() + Vector(0, 0, 50))
				meth:Spawn()
			else
				local meth = ents.Create("meth_crystal_norm")
				meth:SetPos(self:GetPos() + Vector(0, 0, 50))
				meth:Spawn()
			end
		
			-- stop cooking
			self.Meth_Cooking = false
			self.Meth_CookTime = 0
			self:StopLoopingSound(self.Meth_CookingSound)
			
			-- network the variables, needed for the client to see the 3d2d text
			self:SendMethVarsToClient()
			
			-- return early
			return
		end
		-- if product is not ready but we are cooking
		if self.Meth_Cooking then
			self.Meth_CookingSound = self:StartLoopingSound("loop_boiling.wav")
			return
		end
		-- if we are low on materials
		if self.Meth_HydrochloricAcid < 25 then
			return
		end
		if self.Meth_Matchsticks < 25 then
			return
		end
		if self.Meth_Sudafed < 25 then
			return
		end
		
		-- otherwise, start the cook
		self.Meth_Cooking = true
		self.Meth_Sudafed = self.Meth_Sudafed - 25
		self.Meth_Matchsticks = self.Meth_Matchsticks - 25
		self.Meth_HydrochloricAcid = self.Meth_HydrochloricAcid - 25
		
		-- network the variables, needed for the client to see the 3d2d text
		self:SendMethVarsToClient()
	end
	
	-- called every tick
	function ENT:Think()
		-- set next think time
		self:NextThink(CurTime() + 1)
		
		-- burn at 132 seconds
		if self.Meth_Cooking and self.Meth_CookTime >= timeTillBurnt then
			-- stop cooking
			self.Meth_Cooking = false
			self.Meth_CookTime = 0
			self:StopLoopingSound(self.Meth_CookingSound)
		-- only cook while its ON and while the timer is less than 120
		elseif self.Meth_Cooking and self.Meth_CookTime < timeTillBurnt then
			self.Meth_CookTime = self.Meth_CookTime + 1
			-- effects
			local effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			util.Effect("meth_smoke", effectData)
		end
		
		-- special effects
		print(math.floor(100 / timeTillCooked * self.Meth_CookTime))
		if math.floor(100 / timeTillCooked * self.Meth_CookTime) == 100 and hasProducedNormalParticles == false then
			local effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			util.Effect("meth_boom_norm", effectData)
			self:EmitSound("crystallize.wav")
			hasProducedNormalParticles = true
		elseif math.floor(100 / timeTillCooked * self.Meth_CookTime) == 110 then
			local effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			util.Effect("meth_boom_blue", effectData)
			self:EmitSound("crystallize.wav")
		end
		
		-- network the variables, needed for the client to see the 3d2d text
		self:SendMethVarsToClient()
		
		return true
	end
	
	-- called when a entity collides with the pot
    function ENT:StartTouch(ent)
		-- ignore collision while cooking
		if self.Meth_Cooking then
			return
		end
	
		-- if not cooking, take the materials
        if IsValid(ent) then
            if ent:GetClass() == "meth_acid" then
				self.Meth_HydrochloricAcid = self.Meth_HydrochloricAcid + 200
				self:EmitSound("pot_splash.wav")
				ent:Remove()
			elseif ent:GetClass() == "meth_matches" then
				self.Meth_Matchsticks = self.Meth_Matchsticks + 34
				self:EmitSound("pot_splash.wav")
				ent:Remove()
			elseif ent:GetClass() == "meth_sudo" then
				self.Meth_Sudafed = self.Meth_Sudafed + 50
				self:EmitSound("pot_splash.wav")
				ent:Remove()
			end
        end
		
		-- network the variables, needed for the client to see the 3d2d text
		self:SendMethVarsToClient()
    end
end

if CLIENT then
	-- called every tick as well
	function ENT:Draw()
		-- do the basics
		self:DrawModel()
		
		-- networked variables
		local matchsticks = self:GetNWInt("Meth_Matchsticks", 0)
		local acid = self:GetNWInt("Meth_HydrochloricAcid", 0)
		local sudafed = self:GetNWInt("Meth_Sudafed", 0)
		local isCooking = self:GetNWBool("Meth_Cooking", false)
		local cookTime = self:GetNWInt("Meth_CookTime", 0)

		-- setup where the text appears
		local pos = self:GetPos() + Vector(0, 0, 30)
		local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

		-- draw the main text
		cam.Start3D2D(pos, ang, 0.2)
			draw.SimpleTextOutlined(
				"Meth Cooking Pot",
				"DermaLarge",
				0, 0,
				Color(135, 206, 250),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				2,
				Color(0, 0, 0, 255)
			)
		cam.End3D2D()
		
		-- draw the alt text
		if not isCooking then
			cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
				draw.SimpleTextOutlined(
					"Matches: " .. matchsticks .. " | Acid: " .. acid .. " | Sudafed: " .. sudafed,
					"DermaLarge",
					0, 0,
					Color(135, 206, 250),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
					2,
					Color(0, 0, 0, 255)
				)
			cam.End3D2D()
		else
			cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
				draw.SimpleTextOutlined(
					"Cook in progress!",
					"DermaLarge",
					0, 0,
					Color(135, 206, 250),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
					2,
					Color(0, 0, 0, 255)
				)
			cam.End3D2D()
			if cookTime == timeTillPerfect then
				cam.Start3D2D(pos - Vector(0, 0, 15), ang, 0.1)
					draw.SimpleTextOutlined(
						"PERFECT!!! " .. math.floor(100 / timeTillCooked * cookTime) .. "%",
						"DermaLarge",
						0, 0,
						Color(0, 255, 255),
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
						2,
						Color(0, 0, 0, 255)
					)
				cam.End3D2D()
			else
				cam.Start3D2D(pos - Vector(0, 0, 15), ang, 0.1)
					draw.SimpleTextOutlined(
						"Progess: " .. math.floor(100 / timeTillCooked * cookTime) .. "%",
						"DermaLarge",
						0, 0,
						Color(135, 206, 250),
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
						2,
						Color(0, 0, 0, 255)
					)
				cam.End3D2D()
			end
		end
	end
end