AddCSLuaFile()

TOOL.Category = "DarkRP"
TOOL.Name = "Airdrop Spawnpoint Tools"
TOOL.Command = nil

if CLIENT then
	language.Add("tool.airdrop_spawner.name", "DarkRP - Airdrop Spawnpoint")
	language.Add("tool.airdrop_spawner.desc", "LeftClick: Creates a new Airdrop spawnpoint.")
	language.Add("tool.airdrop_spawner.0", "LeftClick: Creates a new Airdrop spawnpoint.")
	
	function TOOL.BuildCPanel( CPanel )

		CPanel:AddControl( "Header", { Description = "#tool.ballsocket.help" } )

		CPanel:Button("Remove all spawnpoints", "airdrop_clear_spawnpoints")
	end
end

if SERVER then
	util.AddNetworkString("RequestAirdropSpawnName")
	util.AddNetworkString("ReceiveAirdropSpawnName")
	
	-- clear spawn points command
    concommand.Add("airdrop_clear_spawnpoints", function(ply, cmd, args)
        if not ply:IsAdmin() then
            ply:ChatPrint("You must be an admin to clear spawnpoints!")
            return
        end

        -- Clear the file by overwriting with an empty table
        file.Write("airdrop_spawnpoints.txt", util.TableToJSON({}))

        ply:ChatPrint("Spawnpoints file has been cleared!")
    end)

	function TOOL:LeftClick(trace)
		if not trace.Hit then return false end

		local ply = self:GetOwner()

		-- admin checker
		if not ply:IsAdmin() then
			ply:ChatPrint("You must be an admin to use this tool!")
			return false
		end

		ply:ChatPrint("Hello")

		-- send client the menu to select name
		net.Start("RequestAirdropSpawnName")
		net.Send(ply)

		-- save the temp position for later
		ply.TempSpawnPoint = trace.HitPos

		return true
	end

	net.Receive("ReceiveAirdropSpawnName", function(len, ply)
		local spawnpointName = net.ReadString()
		local pos = ply.TempSpawnPoint

		if not pos or spawnpointName == "" then
			ply:ChatPrint("Invalid spawnpoint data!")
			return
		end

		-- Load existing spawnpoints
		local spawnpoints = {}
		if file.Exists("airdrop_spawnpoints.txt", "DATA") then
			spawnpoints = util.JSONToTable(file.Read("airdrop_spawnpoints.txt", "DATA"))
		end

		-- Add the new spawnpoint
		table.insert(spawnpoints, {name = spawnpointName, position = pos})
		file.Write("airdrop_spawnpoints.txt", util.TableToJSON(spawnpoints))

		ply:ChatPrint("Spawnpoint '" .. spawnpointName .. "' saved at " .. tostring(pos))

		ply.TempSpawnPoint = nil -- Clear the temporary position
	end)
end

if CLIENT then
	net.Receive("RequestAirdropSpawnName", function()
		local ply = LocalPlayer()
		ply:ChatPrint("Hello2")
		
		local frame = vgui.Create("DFrame")
		frame:SetTitle("Enter Spawnpoint Name")
		frame:SetSize(300, 100)
		frame:Center()
		frame:MakePopup()

		local textEntry = vgui.Create("DTextEntry", frame)
		textEntry:SetSize(280, 20)
		textEntry:SetPos(10, 40)
		textEntry:SetPlaceholderText("Spawnpoint Name")

		local confirmButton = vgui.Create("DButton", frame)
		confirmButton:SetSize(280, 20)
		confirmButton:SetPos(10, 70)
		confirmButton:SetText("Confirm")
		confirmButton.DoClick = function()
			local spawnpointName = textEntry:GetValue()
			if spawnpointName ~= "" then
				net.Start("ReceiveAirdropSpawnName")
				net.WriteString(spawnpointName)
				net.SendToServer()
				frame:Close()
			else
				frame:SetTitle("Name cannot be empty!")
			end
		end
	end)
end