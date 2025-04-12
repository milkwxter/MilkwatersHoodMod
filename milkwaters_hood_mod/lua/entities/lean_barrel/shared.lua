AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Drugs - Codeine Barrel"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

-- my variables
ENT.Lean_Syrup = 0
ENT.Lean_Sprite = 0

if SERVER then
	-- function to make it easy to send networked vars to client
	function ENT:SendLeanVarsToClient()
		self:SetNWInt("Lean_Syrup", self.Lean_Syrup)
		self:SetNWInt("Lean_Sprite", self.Lean_Sprite)
	end
	
	-- called when you spawn it
	function ENT:Initialize()
		-- network the variables, needed for the client to see the 3d2d text
		self:SendLeanVarsToClient()
		
		-- initialize model
		self:SetModel("models/lean/codeine_barrel.mdl")
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
	
	-- called when a entity collides with the pot
    function ENT:StartTouch(ent)
		-- take the materials or give lean
        if IsValid(ent) then
			-- add materials
            if ent:GetClass() == "lean_syrup" and self.Lean_Syrup < 900 then
				-- add it
				self.Lean_Syrup = self.Lean_Syrup + 90
				
				-- small check
				if self.Lean_Syrup > 900 then self.Lean_Syrup = 900 end
				
				-- other stuff
				self:EmitSound("pot_splash.wav")
				ent:Remove()
			elseif ent:GetClass() == "lean_sprite" and self.Lean_Sprite < 900 then
				-- add it
				self.Lean_Sprite = self.Lean_Sprite + 90
				
				-- small check
				if self.Lean_Sprite > 900 then self.Lean_Sprite = 900 end
				
				-- other stuff
				self:EmitSound("pot_splash.wav")
				ent:Remove()
			end
			
			-- give lean
			if self.Lean_Syrup >= 90 and self.Lean_Sprite >= 90 and ent:GetClass() == "lean_cup" then
				-- remove old cup
				ent:Remove()
				
				-- spawn a new lean on top
				local lean = ents.Create("lean_cup_full")
				lean:SetPos(self:GetPos() + Vector(0, 0, 25))
				lean:Spawn()
				
				-- make vars go down
				self.Lean_Syrup = self.Lean_Syrup - 90
				self.Lean_Sprite = self.Lean_Sprite - 90
			end
        end
		
		-- network the variables, needed for the client to see the 3d2d text
		self:SendLeanVarsToClient()
    end
end

if CLIENT then
	-- called every tick as well
	function ENT:Draw()
		-- do the basics
		self:DrawModel()
		
		-- networked variables
		local syrup = self:GetNWInt("Lean_Syrup", 0)
		local sprite = self:GetNWInt("Lean_Sprite", 0)
		
		-- add bodygroup lean if there is enough ingredients
		if syrup >= 90 and sprite >= 90 then
			self:SetBodyGroups( "01" )
		else
			self:SetBodyGroups( "00" )
		end
		
		-- setup where the text appears
		local pos = self:GetPos() + Vector(0, 0, 40)
		local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

		-- draw the main text
		cam.Start3D2D(pos, ang, 0.2)
			draw.SimpleTextOutlined(
				"Codeine Barrel",
				"DermaLarge",
				0, 0,
				Color(192, 28, 238),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				2,
				Color(0, 0, 0, 255)
			)
		cam.End3D2D()
		
		-- draw the alt text
		cam.Start3D2D(pos - Vector(0, 0, 5), ang, 0.1)
			draw.SimpleTextOutlined(
				"Cough Syrup: " .. syrup .. "/900 mL" .. " | Sprite: " .. sprite .. "/900 mL",
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