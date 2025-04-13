AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Robbery - Chop Shop"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

-- my custom variables
ENT.CurrentVehicle = nil
ENT.CurrentVehicleName = nil
ENT.CurrentVehiclePrice = nil

if SERVER then
	-- network strings
	util.AddNetworkString("SimpleChopShop.OpenMenu")
	util.AddNetworkString("SimpleChopShop.Destroy")
	util.AddNetworkString("SimpleChopShop.Release")
	
	function ENT:SendChopShopVarsToClient()
		self:SetNWEntity( "ChopShop_CurrentCar", self.CurrentVehicle )
	end
	
	-- called when you spawn it
	function ENT:Initialize()
		-- initialize model
		self:SetModel("models/craphead_scripts/chop_shop/ch_compactor_open.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		-- enable physics
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
	end
	
	function ENT:StartTouch(ent)
		-- check if a wheel touched the chop shop
        if IsValid(ent) and ent:GetClass() == "gmod_sent_vehicle_fphysics_wheel" then
			-- if a wheel touched us, get his parent and set a variable
			local nearbyEntities = ents.FindInSphere(self:GetPos(), 100)
			for _, nearbyEnt in pairs(nearbyEntities) do
				if nearbyEnt:GetClass() == "prop_vehicle_prisoner_pod" then
					print("[CHOP SHOP] Detected a vehicle!")
					print("[CHOP SHOP] Vehicle Name: ", nearbyEnt:GetParent().VehicleName)
					self.CurrentVehicle = nearbyEnt:GetParent()
					break
				end
			end
		end
		
		-- check if we got a vehicle from that info
		if self.CurrentVehicle then
			self.CurrentVehicleName = self.CurrentVehicle.VehicleName
			self.CurrentVehiclePrice = 100
			
			-- network some stuff
			self:SendChopShopVarsToClient()
		end
    end
	
	hook.Add("PlayerLeaveVehicle", "CheckChopShopVehicle", function(player, vehicle)
		if IsValid(vehicle) then
			print("This vehicle has been left: ", vehicle)
			
			-- Find nearby entities using ents.FindInSphere
			local nearbyEntities = ents.FindInSphere(vehicle:GetPos(), 100)
			local nearestChopShop = nil

			for _, ent in ipairs(nearbyEntities) do
				if IsValid(ent) and ent:GetClass() == "chop_shop" then
					print("We found a chop shop! ", ent.CurrentVehicle)
					nearestChopShop = ent
					break
				end
			end

			-- Compare the vehicle to the chop shop's currentVehicle value
			if IsValid(nearestChopShop) and nearestChopShop.CurrentVehicle == vehicle:GetParent() then
				print("This vehicle matches the chop shop's currentVehicle!")
				-- Perform additional logic here if needed
				player:SetPos(nearestChopShop:GetPos() + nearestChopShop:GetForward() * 50 + nearestChopShop:GetUp() * -50 + nearestChopShop:GetRight() * -150)
				player:SetEyeAngles( Vector( 90, 0, 0 ):Angle() )
				nearestChopShop:SetModel("models/craphead_scripts/chop_shop/ch_compactor.mdl")
			end
		end
	end)
	
	-- when someone presses "E" on this entity
	function ENT:AcceptInput(inputName, activator, caller)
		if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and self.CurrentVehicle ~= nil then
			net.Start("SimpleChopShop.OpenMenu")
			net.WriteEntity( self )
			net.WriteUInt( self.CurrentVehiclePrice, 15 )
			net.Send(activator)
		end
	end
	
	net.Receive("SimpleChopShop.Destroy", function(len, ply)
		-- read the chop shop we are using
		local chopShop = net.ReadEntity()
		
		-- check if car exists
		if chopShop.CurrentVehicle == nil then return end
		
		-- clean the animations
		chopShop:ResetSequenceInfo()
		
		-- destroy it
		chopShop.CurrentVehicle:Remove()
		chopShop.CurrentVehicle = nil
		chopShop.CurrentVehicleName = nil
		chopShop.CurrentVehiclePrice = nil
		
		-- start the compress animation
		chopShop:ResetSequence("compress")
		local animDuration = chopShop:SequenceDuration(chopShop:LookupSequence("compress"))
		
		-- simple timer
		timer.Simple(animDuration, function()
			-- start the uncompress animation
			chopShop:ResetSequence("uncompress")
			animDuration = chopShop:SequenceDuration(chopShop:LookupSequence("uncompress"))
			
			-- effects
			local effectData = EffectData()
			effectData:SetOrigin(chopShop:GetPos())
			util.Effect("money_drop", effectData)
			chopShop:EmitSound("register_kaching.wav")
			
			-- effects
			chopShop:EmitSound("ambient/materials/clang1.wav")
			
			-- simple timer
			timer.Simple(animDuration, function()
				-- open door
				chopShop:SetModel("models/craphead_scripts/chop_shop/ch_compactor_open.mdl")
				
				-- spawn valuable scrap
				local scrap = ents.Create("chop_shop_scrap")
				scrap:SetPos(chopShop:GetPos() + Vector(0, 0, 20))
				scrap:Spawn()
				
				-- enable physics
				local phys = scrap:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
				end
				
				-- effects
				chopShop:EmitSound("ambient/materials/clang1.wav")
			end)
		end)
	end)
end

if CLIENT then
    function ENT:Draw()
		-- draw the model
        self:DrawModel()

        -- Render interface on the custom screen
        local pos = self:GetPos() + self:GetForward() * 85 + self:GetUp() * 10 + self:GetRight() * -81
        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Forward(), -90)
		ang:RotateAroundAxis(ang:Up(), 90)

		-- main text
        cam.Start3D2D(pos, ang, 0.1)
			-- draw a background
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(0, 0, 512, 300)

			-- draw the text
            draw.SimpleText("Chop Shop Interface", "CloseCaption_Bold", 256, 50, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
		
		-- if a car is inside the chop shop, show this
		if carInShop then
			cam.Start3D2D(pos - Vector(0, 0, 10), ang, 0.1)
				-- show the price
				draw.SimpleText("Press [E] to open menu!", "CloseCaption_Bold", 256, 50, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
    end
	
	-- recieve a message from the server to open the menu
	net.Receive("SimpleChopShop.OpenMenu", function()
		-- read vars
		local chopShop = net.ReadEntity()
		local carPrice = net.ReadUInt( 15 )
		
		-- color variables
		local bgColor = Color(106, 226, 222)
		local whiteColor = Color(255, 255, 255)
		local blackColor = Color(0, 0, 0)

		-- main frame
		local frame = vgui.Create("DFrame")
		frame:SetTitle("Chop Shop Interface")
		frame:SetSize(600, 400)
		frame:Center()
		frame:MakePopup()
		frame.Paint = function(self, w, h)
			surface.SetDrawColor(whiteColor)
			surface.SetMaterial(Material("vgui/bank_screen.png"))
			surface.DrawTexturedRect(0, 0, w, h)
		end

		-- label that tells you how expensive the car is
		local priceLabel = vgui.Create("DLabel", frame)
		priceLabel:SetSize(200, 30)
		priceLabel:SetPos(200, 150)
		priceLabel:SetTextColor(blackColor)
		priceLabel:SetText("Car Price: $" .. carPrice)

		-- destroy button
		local destroyButton = vgui.Create("DButton", frame)
		destroyButton:SetText("DESTROY FOR $$$")
		destroyButton:SetSize(150, 50)
		destroyButton:SetPos(125, 250)
		destroyButton:SetTextColor(blackColor)
		destroyButton.DoClick = function()
			-- send back to server
			net.Start("SimpleChopShop.Destroy")
			net.WriteEntity( chopShop )
			net.SendToServer()
			frame:Close()
		end

		-- release car button
		local releaseButton = vgui.Create("DButton", frame)
		releaseButton:SetText("RELEASE CAR")
		releaseButton:SetSize(150, 50)
		releaseButton:SetPos(325, 250)
		releaseButton:SetTextColor(blackColor)
		releaseButton.DoClick = function()
			-- send back to server
			net.Start("SimpleChopShop.Release")
			net.SendToServer()
			frame:Close()
		end
	end)
end