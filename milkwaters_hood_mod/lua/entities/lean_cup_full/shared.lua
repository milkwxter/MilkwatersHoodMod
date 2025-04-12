AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Drugs - Lean Cup"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

ENT.SubCategory = "Drugs"

if SERVER then
	-- called when you spawn it
	function ENT:Initialize()
		-- initialize model
		self:SetModel("models/lean/codeine_cup.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		self:SetUseType( SIMPLE_USE )
		
		-- enable physics
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
		
		-- change body group because there is one
		self:SetBodyGroups( "01" )
	end

	-- called when someone presses "E" on it
	function ENT:Use(activator)
		if activator:IsPlayer() then
			-- max out health
			activator:SetHealth(activator:GetMaxHealth())
			
			-- effects
			activator:EmitSound("drinking.wav")
			
			-- remove self
			self:Remove()
		end
	end
end

if CLIENT then
	-- called every tick as well
	function ENT:Draw()
		-- do the basics
		self:DrawModel()
		
		-- setup where the text appears
		local pos = self:GetPos() + Vector(0, 0, 20)
		local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

		-- draw the main text
		cam.Start3D2D(pos, ang, 0.2)
			draw.SimpleTextOutlined(
				"Lean Cup",
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
				"Gives super jumps!",
				"DermaLarge",
				0, 0,
				Color(192, 28, 238),
				TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
				2,
				Color(0, 0, 0, 255)
			)
		cam.End3D2D()
	end
end
