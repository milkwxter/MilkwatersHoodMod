if SERVER then
	-- net messages
	util.AddNetworkString("SendATMData")
	
	-- if the table doesnt exist, then make it
	if not sql.TableExists("player_atm_accounts") then
		sql.Query("CREATE TABLE player_atm_accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, steamid TEXT, balance INTEGER)")
		print("Created player_atm_accounts table for SQL! This should only happen once.")
	end
	
	-- every time a player spawns for the first time, we do this
	hook.Add("PlayerInitialSpawn", "CheckPlayerATM", function(ply)
		local steamID = ply:SteamID()
		
		local query = sql.QueryRow("SELECT * FROM player_atm_accounts WHERE steamid = '" .. steamID .. "'")
    
		-- if player is not in database, initialize them with 0 dollars
		if not query then
			sql.Query("INSERT INTO player_atm_accounts (steamid, balance) VALUES ('" .. steamID .. "', 0)")
			print("[SimpleATMs] Added new player to the ATM database: " .. steamID)
		end
	end)
end