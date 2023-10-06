ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function getInventoryPlayer()
    loadInventoryPlayer = false 
    inventoryPlayer = {}
    ESX.TriggerServerCallback("getInventoryPlayer", function(result) 
        if #result > 0 then 
            for k,v in pairs(result) do 
                table.insert(inventoryPlayer, v)
            end
            loadInventoryPlayer = true
        end
    end)
end

function getSacPlayer()
    loadSacPlayer = false 
    SacPlayer = {}
    ESX.TriggerServerCallback("getSacPlayer", function(result) 
        if #result > 0 then 
            for k,v in pairs(result) do
                print(json.encode(v))
                table.insert(SacPlayer, v)
            end
            loadSacPlayer = true
        end
    end)
end


function getSacSolPlayer(id)
    loadSacSolPlayer = false 
    SacSolPlayer = {}
    ESX.TriggerServerCallback("getSacSolPlayer", function(result) 
        if #result > 0 then 
            for k,v in pairs(result) do 
                table.insert(SacSolPlayer, v)
            end
            loadSacSolPlayer = true
        end
    end, id)
end


RegisterNetEvent("refreshBagOnFloor")
AddEventHandler("refreshBagOnFloor", function(bagModel)
    refreshSac(bagModel)
end)

local sacOnFloor = {}
function getSacOnSol()
    loadSacOnFloor = false
    ESX.TriggerServerCallback("getSacOnFloor", function(result) 
        for k,v in pairs(result) do 
            if v.onfloor then 
                table.insert(sacOnFloor, v)
            else
                table.remove(sacOnFloor, k)
            end
        end
        loadSacOnFloor = true
    end)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = ((1 / GetDistanceBetweenCoords(px, py, pz, x, y, z)) * 2) * (1 / GetGameplayCamFov()) * 100
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


function refreshSac(bagModel)
    print(bagModel)
    CreateThread(function()
        getSacOnSol()
        while not loadSacOnFloor do 
            Wait(10)
        end
        if loadSacOnFloor then 
            for k,v in pairs(sacOnFloor) do 
                local dest = v.coords 
                local model = GetHashKey("prop_cs_heist_bag_02")
                backpackProp = CreateObject(model, dest.x, dest.y, dest.z-1, true, false, true)
                FreezeEntityPosition(backpackProp, true)
            end
        end
        while true do 
            local interval = 500
            local posPlayer = GetEntityCoords(PlayerPedId())
            if loadSacOnFloor then 
                for k,v in pairs(sacOnFloor) do 
                    if v.onfloor then 
                        local dest = v.coords 
                        local dist = Vdist(posPlayer, dest.x, dest.y, dest.z)
                        if dist <= 10 then
                            interval = 0
                            DrawText3D(dest.x, dest.y, dest.z + 0.2, "X pour ouvrir le sac")
                            DrawText3D(dest.x, dest.y, dest.z, "E pour porter le sac")        
                            if IsControlJustReleased(0, 51) then
                                TriggerEvent('skinchanger:change', "bags_1", bagModel)
                                TriggerEvent('skinchanger:change', "bags_2", 0)
                                TriggerEvent('skinchanger:getSkin', function(skin)
                                    if skin ~= nil then
                                        TriggerServerEvent('esx_skin:save', skin)
                                        TriggerServerEvent('takeBagOnFloor', v.id) 
                                    end
                                end)
                                DeleteEntity(backpackProp)
                                Wait(100)
                                refreshSac(bagModel)
                                Wait(3000)
                                -- Animation récupération Sac
                            elseif IsControlJustReleased(0, 73) then 
                                if not openBagSol then 
                                    openMenuBagSol(v.id)
                                end
                            end
                        end
                    end
                end
            end
            Wait(interval)
        end
    end)
end

CreateThread(function()
    TriggerServerEvent("deletreAllBag")
end)

