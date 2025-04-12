AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money - ATM"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

if SERVER then
	-- add network string for colored messages and menu stuff
	util.AddNetworkString("SimpleATM.Notify")
	util.AddNetworkString("SimpleATM.OpenMenu")
	util.AddNetworkString("SimpleATM.Withdraw")
	util.AddNetworkString("SimpleATM.Deposit")
	
	-- called when you spawn it
	function ENT:Initialize()
		-- initialize model
		self:SetModel("models/atm/ATM1.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		-- enable physics
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
			phys:SetMass( 500 )
        end
	end
	
	-- server side notification, for colored messages
	local function Notify(ply, msg)
		net.Start("SimpleATM.Notify")
		net.WriteString(msg)
		net.Send(ply)
	end
	
	-- when someone presses "E" on this entity
	function ENT:AcceptInput(inputName, activator, caller)
		if inputName == "Use" and IsValid(activator) and activator:IsPlayer() then
			-- get clients money amount and send it to the client
			local query = sql.QueryRow("SELECT balance FROM player_atm_accounts WHERE steamid = '" .. activator:SteamID() .. "'")
			local clientBalance
			if query and query.balance then
				clientBalance = tonumber(query.balance)
			else
				clientBalance = 0
			end
			net.Start("SimpleATM.OpenMenu")
			net.WriteUInt(clientBalance, 20) -- max value of 1,048,575, never negative
			net.Send(activator)
		end
	end
	
	net.Receive("SimpleATM.Withdraw", function(len, ply)
		-- save clients current balance
		local query = sql.QueryRow("SELECT balance FROM player_atm_accounts WHERE steamid = '" .. ply:SteamID() .. "'")
		local savingsBalance
		if query and query.balance then
			savingsBalance = tonumber(query.balance)
		else
			savingsBalance = 0
		end
		
		local amountToWithdraw = net.ReadUInt(20)
		
		-- if they cant afford the withdraw, return early
		if savingsBalance < amountToWithdraw then
			Notify(ply, "You can't afford to withdraw that much!")
			EmitSound( "garrysmod/ui_click.wav", ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			return
		end
		
		-- otherwise, add money to their wallet and remove it from the database
		ply:addMoney(amountToWithdraw)
		local query = sql.QueryRow("SELECT balance FROM player_atm_accounts WHERE steamid = '" .. ply:SteamID() .. "'")
		if query and query.balance then
			local currentBalance = tonumber(query.balance)

			-- Update the player's balance
			sql.Query("UPDATE player_atm_accounts SET balance = " .. (currentBalance - amountToWithdraw) .. " WHERE steamid = '" .. ply:SteamID() .. "'")
			print("[SimpleATM] Decreased savings balance by $" .. amountToWithdraw .. " for SteamID: " .. ply:SteamID())
			
			-- play a sound
			EmitSound( "garrysmod/save_load1.wav", ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			
			-- notify them
			Notify(ply, "Withdrew $" .. amountToWithdraw .. " successfully!")
			
			-- update the clients menu
			net.Start("SimpleATM.OpenMenu")
			net.WriteUInt(currentBalance - amountToWithdraw, 20) -- max value of 1,048,575, never negative
			net.Send(ply)
		else
			Notify(ply, "Somehow you don't exist in the ATM database! Please notify the server owner!")
			EmitSound( "garrysmod/ui_click.wav", ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			return
		end
	end)
	
	net.Receive("SimpleATM.Deposit", function(len, ply)
		-- read how much they want to deposit
		local amountToDeposit = net.ReadUInt(20)
		
		-- if they cant afford the deposit, return early
		if amountToDeposit > ply:getDarkRPVar("money") then
			Notify(ply, "You can't afford to deposit that much!")
			EmitSound( "garrysmod/ui_click.wav", ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			return
		end
		
		-- otherwise, remove money from their wallet and add it to database
		ply:addMoney(-amountToDeposit)
		local query = sql.QueryRow("SELECT balance FROM player_atm_accounts WHERE steamid = '" .. ply:SteamID() .. "'")
		if query and query.balance then
			local currentBalance = tonumber(query.balance)
			
			if (currentBalance + amountToDeposit) >= 1048575 then
				Notify(ply, "You have way too much money! The ATM can only hold a maximum of $1,048,575.")
				EmitSound( "garrysmod/ui_click.wav", ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
				return
			end

			-- Update the player's balance
			sql.Query("UPDATE player_atm_accounts SET balance = " .. (currentBalance + amountToDeposit) .. " WHERE steamid = '" .. ply:SteamID() .. "'")
			print("[SimpleATM] Increased savings balance by $" .. amountToDeposit .. " for SteamID: " .. ply:SteamID())
			
			-- play a sound
			EmitSound( "garrysmod/save_load1.wav", ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			
			-- notify them
			Notify(ply, "Deposited $" .. amountToDeposit .. " successfully!")
			
			-- update the clients menu
			net.Start("SimpleATM.OpenMenu")
			net.WriteUInt(currentBalance + amountToDeposit, 20) -- max value of 1,048,575, never negative
			net.Send(ply)
		else
			Notify(ply, "Somehow you don't exist in the ATM database! Please notify the server owner!")
			EmitSound( "garrysmod/ui_click.wav", ply:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			return
		end
	end)
end

if CLIENT then
	-- draw model and floating text for the clients
    function ENT:Draw()
        self:DrawModel()
        local pos = self:GetPos() + Vector(0, 0, 50)
        local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

        cam.Start3D2D(pos, ang, 0.3)
        draw.SimpleText("ATM", "Trebuchet24", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
		cam.Start3D2D(pos - Vector(0, 0, 5), ang, 0.1)
        draw.SimpleText("Withdraw or deposit cash!", "Trebuchet24", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
	
	-- colored chat message
	local function Notify(msg)
		chat.AddText(Color(44, 153, 0), "Simple ATM | ", Color(255, 255, 255), msg)
	end
	
	-- recieve a message to color from the server
	net.Receive("SimpleATM.Notify", function()
		Notify(net.ReadString())
	end)
	
	-- recieve a message from the server to open the menu
	net.Receive("SimpleATM.OpenMenu", function()
		-- money variables
		local walletBalance = LocalPlayer():getDarkRPVar("money")
		local savingsBalance = net.ReadUInt(20)
		
		-- color variables
		local bgColor = Color(106, 226, 222)
		local whiteColor = Color(255, 255, 255)
		local blackColor = Color(0, 0, 0)

		-- main frame
		local frame = vgui.Create("DFrame")
		frame:SetTitle("ATM Interface")
		frame:SetSize(600, 400)
		frame:Center()
		frame:MakePopup()
		frame.Paint = function(self, w, h)
			surface.SetDrawColor(whiteColor)
			surface.SetMaterial(Material("vgui/bank_screen.png"))
			surface.DrawTexturedRect(0, 0, w, h)
		end

		-- wallet and savings labels
		local walletLabel = vgui.Create("DLabel", frame)
		walletLabel:SetText("Wallet: $" .. walletBalance)
		walletLabel:SetFont("Trebuchet24")
		walletLabel:SetTextColor(blackColor)
		walletLabel:SizeToContents()
		walletLabel:SetPos(20, 40)
		
		local savingsLabel = vgui.Create("DLabel", frame)
		savingsLabel:SetText("Savings: $" .. savingsBalance)
		savingsLabel:SetFont("Trebuchet24")
		savingsLabel:SetTextColor(blackColor)
		savingsLabel:SizeToContents()
		savingsLabel:SetPos(20, 80)

		-- Input Field for Entering Amount
		local amountEntry = vgui.Create("DTextEntry", frame)
		amountEntry:SetSize(200, 30)
		amountEntry:SetPos(200, 150)
		amountEntry:SetText("0")

		-- Withdraw Button
		local withdrawButton = vgui.Create("DButton", frame)
		withdrawButton:SetText("WITHDRAW")
		withdrawButton:SetSize(150, 50)
		withdrawButton:SetPos(125, 250)
		withdrawButton:SetTextColor(blackColor)
		withdrawButton.DoClick = function()
			local amount = tonumber(amountEntry:GetValue())
			if amount and amount > 0 then
				-- send amount to withdraw to server
				net.Start("SimpleATM.Withdraw")
				net.WriteUInt(amount, 20)
				net.SendToServer()
				frame:Close()
			end
		end

		-- Deposit Button
		local depositButton = vgui.Create("DButton", frame)
		depositButton:SetText("DEPOSIT")
		depositButton:SetSize(150, 50)
		depositButton:SetPos(325, 250)
		depositButton:SetTextColor(blackColor)
		depositButton.DoClick = function()
			local amount = tonumber(amountEntry:GetValue())
			if amount and amount > 0 then
				-- send amount to deposit to server
				net.Start("SimpleATM.Deposit")
				net.WriteUInt(amount, 20)
				net.SendToServer()
				frame:Close()
			end
		end
	end)
end