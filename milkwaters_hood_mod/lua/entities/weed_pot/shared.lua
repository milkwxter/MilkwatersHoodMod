AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Drugs - Weed Pot"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

-- my variables
ENT.PlantStage = 0
ENT.GrowthTime = 0
ENT.WaterAmount = 0

if SERVER then
	-- called when you spawn it
	function ENT:Initialize()
		-- network the variables, needed for the client to see the 3d2d text
		self:SetNWInt("PlantStage", self.PlantStage)
		self:SetNWInt("WaterAmount", self.WaterAmount)
		self:SetNWBool("GrowthTime", self.GrowthTime)
	
		-- initialize model
		self:SetModel("models/weed/weed_plant_empty/weed_plant_empty.mdl")
		if self.PlantStage == 1 then
			self:SetModel("models/weed/weed_plant_small01/weed_plant_small01.mdl")
		elseif self.PlantStage == 2 then
			self:SetModel("models/weed/weed_plant_medium01/weed_plant_medium01.mdl")
		elseif self.PlantStage == 3 then
			self:SetModel("models/weed/weed_plant_large01/weed_plant_large01.mdl")
		end
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end

	-- called when someone presses "E" on it
	function ENT:Use(activator)
		if self.PlantStage >= 3 then
			self.PlantStage = 0
			self:GrowStage()
			self:ProduceWeed()
		end
	end

	-- called every tick
	function ENT:Think()
		-- set next think time
		self:NextThink(CurTime() + 1)
		
		-- stop after growth 8
		if self.PlantStage >= 3 then return end
		
		-- wait for water
		if self.WaterAmount > 0 then
			-- increment variables
			self.GrowthTime = self.GrowthTime + 1
			self.WaterAmount = self.WaterAmount - 1
			
			-- if we need to grow a stage
			if self.GrowthTime >= 60 then
				self.PlantStage = self.PlantStage + 1
				self.GrowthTime = 0
				self:GrowStage()
			end
			-- if there is too much water
			if self.WaterAmount > 300 then
				self.WaterAmount = 300
			end
		end
		
		-- update networked variables
		self:SetNWInt("PlantStage", self.PlantStage)
		self:SetNWInt("WaterAmount", self.WaterAmount)
		self:SetNWBool("GrowthTime", self.GrowthTime)
		
		return true
	end

	-- custom function, called when someone uses it at the right time
	function ENT:ProduceWeed()
		local weed = ents.Create("weed_brick")
		weed:SetPos(self:GetPos() + Vector(0, 0, 50))
		weed:Spawn()
		
		-- enable physics
        local phys = weed:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
	end
	
	-- custom function, called when we need to update the model
	function ENT:GrowStage()
		if self.PlantStage == 0 then
			self:SetModel("models/weed/weed_plant_empty/weed_plant_empty.mdl")
		elseif self.PlantStage == 1 then
			self:SetModel("models/weed/weed_plant_small01/weed_plant_small01.mdl")
		elseif self.PlantStage == 2 then
			self:SetModel("models/weed/weed_plant_medium01/weed_plant_medium01.mdl")
		elseif self.PlantStage == 3 then
			self:SetModel("models/weed/weed_plant_large01/weed_plant_large01.mdl")
		end
		
		-- effects
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos())
		util.Effect("weed_boom", effectData)
		self:EmitSound("weed_rustle.wav")
	end
end

if CLIENT then
	-- called every tick as well
	function ENT:Draw()
		-- do the basics
		self:DrawModel()
		
		-- networked variables
		local stage = self:GetNWInt("PlantStage", 0)
		local water = self:GetNWInt("WaterAmount", 0)
		local growth = self:GetNWInt("GrowthTime", 0)

		-- setup where the text appears
		local pos = self:GetPos() + Vector(0, 0, 50)
		if stage == 2 then
			pos = pos + Vector(0, 0, 20)
		elseif stage == 3 then
			pos = pos + Vector(0, 0, 60)
		end
		local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

		-- draw the main text
		cam.Start3D2D(pos, ang, 0.2)
			draw.SimpleTextOutlined(
				"Stage: " .. stage .. " | Water: " .. water .. "/300",
				"DermaLarge",
				0, 0,
				Color(34, 139, 34),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				2,
				Color(0, 0, 0, 255)
			)
		cam.End3D2D()
		
		-- if there is no water, draw this text
		if water <= 0 then
			cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
				draw.SimpleTextOutlined(
					"Waiting for water...",
					"DermaLarge",
					0, 0,
					Color(34, 139, 34),
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
					2,
					Color(0, 0, 0, 255)
				)
			cam.End3D2D()
		-- if there is water, display some cool info
		else
			-- if we are still growing
			if stage <= 2 then
				cam.Start3D2D(pos - Vector(0, 0, 5), ang, 0.1)
					draw.SimpleTextOutlined(
						"Currently growing...",
						"DermaLarge",
						0, 0,
						Color(34, 139, 34),
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
						2,
						Color(0, 0, 0, 255)
					)
				cam.End3D2D()
				cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
					draw.SimpleTextOutlined(
						"Time remaining: " .. 60 - growth,
						"DermaLarge",
						0, 0,
						Color(34, 139, 34),
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
						2,
						Color(0, 0, 0, 255)
					)
				cam.End3D2D()
			-- if harvest is possible
			elseif stage >= 3 then
				cam.Start3D2D(pos - Vector(0, 0, 5), ang, 0.1)
					draw.SimpleTextOutlined(
						"Ready for harvest!",
						"DermaLarge",
						0, 0,
						Color(0, 255, 0),
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
						2,
						Color(0, 0, 0, 255)
					)
				cam.End3D2D()
			end
		end
	end
end
