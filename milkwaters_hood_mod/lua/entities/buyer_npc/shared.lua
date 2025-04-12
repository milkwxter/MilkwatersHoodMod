AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "General - Buyer NPC"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

if SERVER then
	-- add network string for colored messages
	util.AddNetworkString("SimpleBuyer.Notify")
	
	-- list of drugs he buys
	local buyList = {
		{name = "Weed Brick", class = "weed_brick", price = 300},
		{name = "Stolen Cash", class = "money_pile", price = 150},
		{name = "Meth Bag", class = "meth_crystal_norm", price = 750},
		{name = "Blue Sky", class = "meth_crystal_pure", price = 1100},
		{name = "Lean Cup", class = "lean_cup_full", price = 90},
	}
	
	-- initialize entity
	function ENT:Initialize()
		self:SetModel("models/Humans/Group02/male_07.mdl")
		self:SetHullType(0)
		self:SetHullSizeNormal()
		self:SetNPCState(NPC_STATE_SCRIPT)
		self:SetSolid(SOLID_BBOX)
		self:SetUseType(SIMPLE_USE)
		self:SetMoveType(MOVETYPE_NONE)
	end
	
	-- server side notification, for colored messages
	local function Notify(ply, msg)
		net.Start("SimpleBuyer.Notify")
		net.WriteString(msg)
		net.Send(ply)
	end
	
	-- when someone presses "E" on this entity
	function ENT:AcceptInput(inputName, activator, caller)
		if inputName == "Use" and IsValid(caller) and caller:IsPlayer() then
			self:BuyFromPlayer(caller)
		end
	end
	
	-- this handles buying a players stuff
	function ENT:BuyFromPlayer(ply)
		-- get pocket items as an array
		local pocketItems = ply:getPocketItems()
		local itemsSold = 0
		
		-- iterate through the array
		if #pocketItems > 0 then
			-- for each item in pocket, do this
			for key, value in ipairs(pocketItems) do
				for itemKey, itemValue in ipairs(buyList) do
					if value.class == itemValue.class then
						Notify(ply, "You sold '" .. itemValue.name .. "' and got paid $" .. itemValue.price .. "!")
						ply:removePocketItem(key)
						ply:addMoney(itemValue.price)
						itemsSold = itemsSold + 1
					end
				end
			end
			if itemsSold != 0 then
				-- at the end, play a fun sound and throw money
				EmitSound( "garrysmod/save_load1.wav", self:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
				local effectData = EffectData()
				effectData:SetOrigin(self:GetPos())
				util.Effect("money_drop", effectData)
			else
				-- if the player had zero buyable items
				Notify(ply, "Your pocket had no illegal items! No deal.")
				EmitSound( "vo/npc/male01/excuseme01.wav", self:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			end
		else
			-- if the player had zero pocket items
			Notify(ply, "Your pocket had no illegal items! No deal.")
			EmitSound( "vo/npc/male01/excuseme01.wav", self:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
		end
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        local pos = self:GetPos() + Vector(0, 0, 80)
        local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

        cam.Start3D2D(pos, ang, 0.2)
        draw.SimpleText("Illegal Buyer NPC", "Trebuchet24", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
		cam.Start3D2D(pos - Vector(0, 0, 5), ang, 0.1)
        draw.SimpleText("Sell illegal goods here!", "Trebuchet18", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
	
	local function Notify(msg)
		chat.AddText(Color(10, 80, 110), "Simple Buyer NPC | ", Color(255, 255, 255), msg)
	end

	net.Receive("SimpleBuyer.Notify", function()
		Notify(net.ReadString())
	end)
end
