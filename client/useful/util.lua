players = {} -- global players table

RegisterNetEvent("Z:playerUpdate")
AddEventHandler("Z:playerUpdate", function(mPlayers)
	players = mPlayers
end)

function GetPlayers()
	local players = {}
	
	for i = 0, 255 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end
	return players
end


function GetPlayersInRadius(radius)
	local plist = GetPlayers()
	local pamount = 0
	local localx,localy,localz = table.unpack(GetEntityCoords(PlayerPedId(), true))	
	for _,player in pairs(plist) do
		local pedx,pedy,pedz = table.unpack(GetEntityCoords(GetPlayerPed(player), true))
		if #(vector3(localx, localy, localz) - vector3(pedx,pedy,pedz)) < (radius or 300) then
			pamount=pamount+1
		end
	end
	return pamount
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
end

function table.tostring( tbl )
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, table.val_to_str( v ) )
		done[ k ] = true
	end

	for k, v in pairs( tbl ) do
		if not done[ k ] then
		 	table.insert( result,
			table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
		end
	end
	return "{" .. table.concat( result, "," ) .. "}"
end
