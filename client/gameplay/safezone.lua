Zone = nil
local grace = 0
isPlayerInSafezone = false

CreateThread(function()
  while true do
    Wait(1000)
    if grace > 0 then
      grace = grace - 1
    end
  end
end)

CreateThread(function()
  while true do
    Wait(20)
    for k,v in pairs(_RDConfig.SafeZones) do
      local pCoords = GetEntityCoords(PlayerPedId(), true)
      local pdist = #(pCoords - vector3(v.x, v.y, v.z))
      if pdist < 180 then
        local handle, ped = FindFirstPed()
        local finished = false
        repeat
          local pCoords = GetEntityCoords(PlayerPedId(), true)
          v.zd = #(vector3(0.0, 0.0, pCoords.z) - vector3(0.0, 0.0, v.z))
          if not IsPedAPlayer(ped) and not Citizen.InvokeNative(0x9A100F1CF4546629, ped) and #(pCoords - vector3(v.x,v.y,v.z)) < v.radius-math.pi and v.zd < v.radius then
            SetEntityAsMissionEntity(ped, true, true)
            SetEntityHealth(ped, 0.0)
            SetEntityAsNoLongerNeeded(ped)
          end
          Wait(1)
          finished, ped = FindNextPed(handle)
        until not finished
        EndFindPed(handle)
      end
    end
  end
end)

CreateThread(function()
  while true do
    Wait(0)
    local pCoords = GetEntityCoords(PlayerPedId(), true)
    for k,v in pairs(_RDConfig.SafeZones) do
      v.distance = #(pCoords - vector3(v.x, v.y, v.z))

      if v.distance < v.radius - math.pi then
        NetworkSetFriendlyFireOption(false)
        DisableControlAction(0,  0x60c81cde,  true)
        DisableControlAction(0,  0xc904196d,  true)
        DisableControlAction(0,  0xD0C1FEFF,  true)
        DisableControlAction(0,  0xADEAF48C,  true)
        DisableControlAction(0,  0x018C47CF,  true)
        DisableControlAction(0,  0x91C9A817,  true)
        DisableControlAction(0,  0xBE1F4699,  true)
        DisableControlAction(0,  0x67ED272E,  true)
        DisableControlAction(0,  0x78ed2132,  true)
        DisableControlAction(0,  0x162afeb8,  true)
        DisableControlAction(0,  0x0283c582,  true)
        DisableControlAction(0,  0x07ce1e61,  true)
        DisableControlAction(0,  0xb2f377e8,  true)
        Zone = v
        grace = 10
        isPlayerInSafezone = true
        break
      elseif v.distance > v.radius - math.pi then
        NetworkSetFriendlyFireOption(true)

        isPlayerInSafezone = false
      elseif IsEntityDead(PlayerPedId()) then
        NetworkSetFriendlyFireOption(true)
        grace = 0
        isPlayerInSafezone = false
      elseif grace > 0 and not isPlayerInSafezone then
        NetworkSetFriendlyFireOption(false)
      elseif grace == 0 and not isPlayerInSafezone then
        NetworkSetFriendlyFireOption(true)
      end
      ZoneKey = k
      Zone = nil
    end
  end
end)

CreateThread(function()
  while true do
    if Zone ~= nil then
      ShowUi()
      while isPlayerInSafezone do
        Wait(0)
      end
      HideUi()
    end
    Wait(250)
  end
end)

function ShowUi()
    SendNUIMessage({
      action = 'show',
      key = ZoneKey
    })
end

function HideUi()
  SendNUIMessage({
    action = 'hide'
  })
end
