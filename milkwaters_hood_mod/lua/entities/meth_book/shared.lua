AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Drugs - Meth Helper"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

if SERVER then
	-- called when you spawn it
	function ENT:Initialize()
		-- initialize model
		self:SetModel("models/books/binder_meth.mdl")
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
			activator:ChatPrint("METH HELPER:\nBuy a pot and a stove. Then some matches, acid, and sudafed.\nPlace the pot on the stove and add your ingredients.")
			activator:ChatPrint("Press [E] to begin cooking. (You need 25 of each ingredient!)\nMeth is ready at 100%, perfect at 110%, and burns away at 111%!")
		end
	end
end