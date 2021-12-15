-- CONFIG --

-- Zombies have a 1 in 150 chance to spawn with guns
-- It will choose a gun in this list when it happens
-- Weapon list here: https://www.se7ensins.com/forums/threads/weapon-and-explosion-hashes-list.1045035/

local walks = {
	{"default", "very_drunk"},
	{"murfree", "very_drunk"},
	{"default", "dehydrated_unarmed"},
}

-- zombie spawn amounts in specific zones, default = 15

zombieZones = {
	BayouNwa = 50,
	bigvalley = 50,
	BluewaterMarsh = 50,
	ChollaSprings = 50,
	Cumberland = 50,
	DiezCoronas = 50,
	GaptoothRidge = 50,
	greatPlains = 50,
	GrizzliesEast = 50,
	GrizzliesWest = 50,
	GuarmaD = 50,
	Heartlands = 50,
	HennigansStead = 50,
	Perdido = 50,
	PuntaOrgullo = 50,
	RioBravo = 50,
	roanoke = 50,
	scarlettMeadows = 50,
	TallTrees = 50,
}

local pedModels = {
	{ model = 'CS_MrAdler',                    outfit = 1 },
	{	model = 'CS_ODProstitute',               outfit = 0 },
	{ model = 'CS_SwampFreak',                 outfit = 0 },
	{ model = 'CS_Vampire',                    outfit = 0 },
	{ model = 'CS_ChelonianMaster',            outfit = 0 },
	{ model = 'RE_Voice_Females_01',           outfit = 0 },
	{ model = 'RE_SavageAftermath_Males_01',   outfit = 0 },
	{ model = 'RE_SavageAftermath_Males_01',   outfit = 1 },
	{ model = 'RE_SavageAftermath_Males_01',   outfit = 2 },
	{ model = 'RE_SavageWarning_Males_01',     outfit = 3 },
	{ model = 'RE_SavageWarning_Males_01',     outfit = 4 },
	{ model = 'RE_SavageWarning_Males_01',     outfit = 5 },
	{ model = 'RE_SavageWarning_Males_01',     outfit = 6 },
	{ model = 'RE_SavageAftermath_Males_01',   outfit = 3 },
	{ model = 'RE_SavageAftermath_Males_01',   outfit = 4 },
	{ model = 'RE_SavageAftermath_Females_01', outfit = 0 },
	{ model = 'RE_SavageAftermath_Females_01', outfit = 1 },
	{ model = 'RE_CorpseCart_Males_01', 			 outfit = 0 },
	{ model = 'RE_CorpseCart_Males_01', 			 outfit = 1 },
	{ model = 'RE_CorpseCart_Males_01', 			 outfit = 2 },
	{ model = 'RE_LostFriend_Males_01', 			 outfit = 0 },
	{ model = 'RE_LostFriend_Males_01', 			 outfit = 1 },
	{ model = 'RE_LostFriend_Males_01', 			 outfit = 2 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 0 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 1 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 2 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 3 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 4 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 5 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 6 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 7 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 8 },
	{ model = 'A_F_M_ArmCholeraCorpse_01', 		 outfit = 9 },
}

lastTimePlayerShot = 0

Citizen.CreateThread(function()
	while true do
		Wait(1)
		if IsPedShooting(PlayerPedId()) then
			lastTimePlayerShot = GetGameTimer()
		end
	end
end)

function calculateZombieAmount()
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
	local pedAmount = (zombieZones[ Citizen.InvokeNative(0x43AD8FC02B429D33, x,y,z) ] or 10)
	if type(zombiepedAmount) ~= "number" then
		zombiepedAmount = 15
	end
	zombiepedAmount = math.round((pedAmount/GetPlayersInRadius(500))*1.2)
	if lastTimePlayerShot > GetGameTimer()-5000 then
		zombiepedAmount = math.round(zombiepedAmount*1.6)
	end
	return zombiepedAmount
end

function calculateZombieHealth()
	if GetClockHours() < 5 or GetClockHours() > 22 then
		return math.random(300,500)
	else
		return math.random(180,300)
	end
end

function WillThisPedBeaBoss()
	if math.random(0,100) > 98 then
		return true
	else
		return false
	end
end




-- CODE --

zombies = {}

peddeletionqueue = {}

Citizen.CreateThread(function()
	AddRelationshipGroup("zombeez")
	SetRelationshipBetweenGroups(5, GetHashKey("zombeez"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("zombeez"))
	DecorRegister("zombie", 2)
	DecorRegister("IsBoss", 3)

	SetAiMeleeWeaponDamageModifier(2.0)

	while true do
		Wait(100)
		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
		zombiepedAmount = calculateZombieAmount()

		if not isPlayerInSafezone and not IsPlayerDead(PlayerId()) and #zombies < zombiepedAmount then

			undead = pedModels[math.random(1, #pedModels)]
			model = GetHashKey(undead.model)
			RequestModel(model)
			while not HasModelLoaded(model) or not HasCollisionForModelLoaded(model) do
				Wait(1)
			end

			repeat
				Wait(100)

				newX = x + math.random(-50, 50)
				newY = y + math.random(-50, 50)
				for i = -400,10,400 do
					RequestCollisionAtCoord(newX, newY, i)
					Wait(1)
				end
				_,newZ = GetGroundZAndNormalFor_3dCoord(newX, newY, z + 999)

--				for _, player in pairs(players) do -- i have literally no idea what this code does tbh
--					Wait(10)
					playerX, playerY = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
					if newX > playerX - 35 and newX < playerX + 35 or newY > playerY - 35 and newY < playerY + 35 then
						canSpawn = false
					else
						canSpawn = true
					end
--				end
			until canSpawn

			ped = CreatePed(model, newX, newY, newZ, 0.0, true, false)
			DecorSetBool(ped, "zombie", true)
			SetPedOutfitPreset(ped, undead.outfit)
			if WillThisPedBeaBoss() then
				local th = math.random(3000,18000)
				SetPedMaxHealth(ped, th)
				SetEntityHealth(ped, th)
				SetPedSeeingRange(ped, 40.0)
				DecorSetInt(ped, "IsBoss", 1)
			else
				local th = calculateZombieHealth()
				SetPedMaxHealth(ped, th)
				SetEntityHealth(ped, th)
				SetPedSeeingRange(ped, 20.0)
			end
			SetPedAccuracy(ped, 25)
			SetPedHearingRange(ped, 65.0)

			SetPedFleeAttributes(ped, 0, 0)
			SetPedCombatAttributes(ped, 46, true)
			SetPedCombatMovement(ped, 3)
			SetPedAsCop(ped, true)
			SetPedCombatRange(ped,1)
			SetPedRelationshipGroupHash(ped, GetHashKey("zombeez"))
			DisablePedPainAudio(ped, true)
			SetPedIsDrunk(ped, true)
			SetPedIsDrunk(ped, true)
			walk = walks[math.random(1, #walks)]
			Citizen.InvokeNative(0x923583741DC87BCE, ped, walk[1])
			Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, walk[2])
			StopPedSpeaking(ped,true)

			TaskWanderStandard(ped, 1.0, 10)

			if not NetworkGetEntityIsNetworked(ped) then
				NetworkRegisterEntityAsNetworked(ped)
			end

			table.insert(zombies, ped)
		end

		for i, ped in pairs(zombies) do
			Wait(100)
			if DoesEntityExist(ped) == false or not NetworkHasControlOfEntity(ped) then
				table.remove(zombies, i)
			end
			local pedX, pedY, pedZ = table.unpack(GetEntityCoords(ped, true))
			if IsPedDeadOrDying(ped, true) then
				local pedX, pedY, pedZ = table.unpack(GetEntityCoords(ped, false))
				local distancebetweenpedandplayer = #(vector3(pedX,pedY,pedZ) - vector3(x,y,z))
				-- Set ped as no longer needed for despawning
				if distancebetweenpedandplayer < 200.0 then
					table.insert(peddeletionqueue, ped)
					table.remove(zombies, i)
			else
				playerX, playerY = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
				if GetPedArmour(ped) <= 90 then
					SetPedArmour(ped, GetPedArmour(ped)+5)
				end
				SetPedAccuracy(ped, 25)
				SetPedSeeingRange(ped, 20.0)
				SetPedHearingRange(ped, 65.0)

				SetPedFleeAttributes(ped, 0, 0)
				SetPedCombatAttributes(ped, 46, true)
				SetPedCombatMovement(ped, 3)
				SetPedAsCop(ped, true)
				SetPedRelationshipGroupHash(ped, GetHashKey("zombeez"))
				DisablePedPainAudio(ped, true)
				if #(vector3(pedX, pedY, 0.0) - vector3(playerX, playerY, 0.0)) > 135.0 then
					-- Set ped as no longer needed for despawning
					local model = GetEntityModel(ped)
					DeleteEntity(ped)
					SetModelAsNoLongerNeeded(model)
					--table.remove(zombies, i) -- the first check takes care of this
					end
				end
			end
		end
	end
end)

-- ped assignment
Citizen.CreateThread(function()
	while true do
		Wait(1000)
		local handle, ped = FindFirstPed()
		local finished = false -- FindNextPed will turn the first variable to false when it fails to find another ped in the index
		repeat
			Wait(20)
			if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) and DecorGetBool(ped, "zombie") == true and NetworkHasControlOfEntity(ped) then
				local ownedByMe = false
				for i,zombie in pairs(zombies) do
					if ped == zombie then
						ownedByMe = true
					end
				end

				if NetworkHasControlOfEntity(ped) and not ownedByMe then
					table.insert(zombies, ped)
					print("\nFound homeless zombie "..ped..", lets give him a home :heart:!\n")
				end
			end
			finished, ped = FindNextPed(handle) -- first param returns true while entities are found
		until not finished
		EndFindPed(handle)
	end
end)



-- -- boss light
-- Citizen.CreateThread(function()
-- 	while true do
-- 		Wait(1)
-- 		for i,ped in pairs(zombies) do
-- 			if DecorGetInt(ped, "IsBoss") == 1 then
-- 				pedX, pedY, pedZ = table.unpack(GetEntityCoords(ped, true))
-- 				DrawLightWithRangeAndShadow(pedX, pedY, pedZ + 0.4, 255, 0, 0, 4.0, 50.0, 5.0)
-- 			end
-- 		end
-- 	end
-- end)


Citizen.CreateThread(function()
	while true do
		Wait(math.random(5000,15000))
		for i, ped in pairs(peddeletionqueue) do
			local model = GetEntityModel(ped)
			DeleteEntity(ped)
			print("ZombYEET")
			SetModelAsNoLongerNeeded(model)
			table.remove(peddeletionqueue,i)
		end
	end
end)


RegisterNetEvent("Z:cleanup")
AddEventHandler("Z:cleanup", function()
	for i, ped in pairs(zombies) do
		-- Set ped as no longer needed for despawning
		local model = GetEntityModel(ped)
		SetModelAsNoLongerNeeded(model)
		SetEntityAsNoLongerNeeded(ped)

		table.remove(zombies, i)
	end
end)
