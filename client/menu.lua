ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function isPlayerWearingBag()
    local playerPed = PlayerPedId()
    local bagDrawableId = GetPedDrawableVariation(playerPed, 5)

    for k,v in pairs(Config.Items) do 
        if bagDrawableId == v.bagModel then
            return true
        else
            return false
        end
    end
end

RegisterNetEvent('esx_bag:useBag')
AddEventHandler('esx_bag:useBag', function(bagModel)
    local playerPed = PlayerPedId()
    if not isPlayerWearingBag() then
        TriggerEvent('skinchanger:change', "bags_1", bagModel)
        TriggerEvent('skinchanger:change', "bags_2", 0)
        TriggerEvent('skinchanger:getSkin', function(skin)
            if skin ~= nil then
                TriggerServerEvent('esx_skin:save', skin)
            end
        end)
    else
        TriggerEvent('skinchanger:change', "bags_1", 0)
        TriggerEvent('skinchanger:change', "bags_2", 0)
        TriggerEvent('skinchanger:getSkin', function(skin)
            if skin ~= nil then
                TriggerServerEvent('esx_skin:save', skin)
            end
        end)
    end
end)



local openBag = false 
menuBag = RageUI.CreateMenu("Sac à dos", " ")
menuDepo = RageUI.CreateSubMenu(menuBag, "Déposer", " ")
menuRetirer = RageUI.CreateSubMenu(menuBag, "Retirer", " ")
menuBag.Closed = function()
    openBag = false  
end

local selectedQuantities = {}
local selectedQuantities2 = {}
function openMenuBag()
    if openBag then 
        openBag = false 
        RageUI.Visible(menuBag, false)
        return
    else
        openBag = true
        RageUI.Visible(menuBag, true)
        CreateThread(function()
            while openBag do 
                RageUI.IsVisible(menuBag, function()
                    RageUI.Separator("↓ Mon sac ↓")
                    RageUI.Line()
                    RageUI.Button("Déposer", nil, {}, true, {
                        onSelected = function()
                            getInventoryPlayer()
                        end
                    }, menuDepo)
                    RageUI.Button("Retirer", nil, {}, true, {
                        onSelected = function()
                            getSacPlayer()
                        end
                    }, menuRetirer)
                    RageUI.Button("Poser au sol", nil, {}, true, {
                        onSelected = function()
                            TriggerEvent('skinchanger:getSkin', function(skin)
                                if skin ~= nil then
                                    TriggerServerEvent("PoserAuSolSac", GetEntityCoords(PlayerPedId()), skin.bags_1)
                                end
                            end)
                            TriggerEvent('skinchanger:change', "bags_1", 0)
                            TriggerEvent('skinchanger:change', "bags_2", 0)
                            Wait(3000)
                        end
                    })
                    RageUI.Button("Replier le sac", nil, {}, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback("getSacPlayer", function(result) 
                                if #result > 0 then 
                                    ESX.ShowNotification("Vous devez retirer le contenu de votre sac avant de pouvoir le ranger.")
                                else
                                    TriggerEvent('skinchanger:change', "bags_1", 0)
                                    TriggerEvent('skinchanger:change', "bags_2", 0)
                                    TriggerEvent('skinchanger:getSkin', function(skin)
                                        if skin ~= nil then
                                            TriggerServerEvent('esx_skin:save', skin)
                                        end
                                    end)
                                    TriggerServerEvent('addBagItem')
                                end
                            end)
                        end
                    })
                end)
                RageUI.IsVisible(menuRetirer, function()
                    if loadSacPlayer then 
                        for k,v in pairs(SacPlayer) do 
                            if selectedQuantities[v.name] == nil then
                                selectedQuantities[v.name] = 1
                            end
                            local quantities = {}
                            for i = 1, v.quantity do
                                table.insert(quantities, tostring(i))
                            end
                            RageUI.List(("[~b~x%s~s~] - %s"):format(v.quantity, v.label), quantities, selectedQuantities[v.name], nil, {}, true, {
                                onListChange = function(Index, Items)
                                    selectedQuantities[v.name] = Index
                                end,
                                onSelected = function()
                                    TriggerServerEvent("retirerBag", selectedQuantities[v.name], v.name, v.label)
                                    Wait(50)                                        
                                    selectedQuantities = {}
                                    getSacPlayer()
                                end
                            })
                        end
                    else
                        RageUI.Separator(" ")
                        RageUI.Separator("Vous n'avez rien dans le sac")
                        RageUI.Separator(" ")
                    end
                end)
                RageUI.IsVisible(menuDepo, function()
                    if loadInventoryPlayer then 
                        for k,v in pairs(inventoryPlayer) do 
                            if selectedQuantities2[v.name] == nil then
                                selectedQuantities2[v.name] = 1
                            end
                            local quantities = {}
                            for i = 1, v.count do
                                table.insert(quantities, tostring(i))
                            end
                            RageUI.List("[~b~x"..v.count.."~s~] - "..v.label, quantities, selectedQuantities2[v.name], nil, {}, true, {
                                onListChange = function(Index, Items)
                                    selectedQuantities2[v.name] = Index
                                end,
                                onSelected = function()
                                    TriggerServerEvent("deposerItemBag", selectedQuantities2[v.name], v.name, v.label)
                                    Wait(50)
                                    selectedQuantities2 = {}
                                    getInventoryPlayer()
                                end
                            })
                        end
                    else
                        RageUI.Separator(" ")
                        RageUI.Separator("Vous n'avez rien sur vous")
                        RageUI.Separator(" ")
                    end
                end)
                Wait(0)
            end
        end)
    end
end


local openBagSol = false
menuBagSol = RageUI.CreateMenu(" ", " ")
menuDepoBagSol = RageUI.CreateSubMenu(menuBagSol, " ", " ")
menuRetirerSol = RageUI.CreateSubMenu(menuBagSol, " ", " ")
menuBagSol.Closed = function()
    openBagSol = false
end

function openMenuBagSol(id)
    if openBagSol then 
        openBagSol = false 
        RageUI.Visible(menuBagSol, false)
        return  
    else
        openBagSol = true
        RageUI.Visible(menuBagSol, true)
        CreateThread(function()
            while openBagSol do 
                RageUI.IsVisible(menuBagSol, function()
                    RageUI.Button("Retirer du sac", nil, {}, true, {
                        onSelected = function()
                            getSacSolPlayer(id)
                        end
                    }, menuRetirerSol)
                    RageUI.Button("Déposer dans le sac", nil, {}, true, {
                        onSelected = function()
                            getInventoryPlayer()
                        end
                    }, menuDepoBagSol)
                end)


                RageUI.IsVisible(menuRetirerSol, function()
                    if loadSacSolPlayer then 
                        for k,v in pairs(SacSolPlayer) do 
                            if selectedQuantities[v.name] == nil then
                                selectedQuantities[v.name] = 1
                            end
                            local quantities = {}
                            for i = 1, v.quantity do
                                table.insert(quantities, tostring(i))
                            end
                            RageUI.List(("[~b~x%s~s~] - %s"):format(v.quantity, v.label), quantities, selectedQuantities[v.name], nil, {}, true, {
                                onListChange = function(Index, Items)
                                    selectedQuantities[v.name] = Index
                                end,
                                onSelected = function()
                                    TriggerServerEvent("retirerBag", selectedQuantities[v.name], v.name, v.label)
                                    Wait(50)                                        
                                    selectedQuantities = {}
                                    getSacSolPlayer(id)
                                end
                            })
                        end
                    else
                        RageUI.Separator(" ")
                        RageUI.Separator("Vous n'avez rien dans le sac")
                        RageUI.Separator(" ")
                    end
                end)


                RageUI.IsVisible(menuDepoBagSol, function()
                    if loadInventoryPlayer then 
                        for k,v in pairs(inventoryPlayer) do 
                            if selectedQuantities2[v.name] == nil then
                                selectedQuantities2[v.name] = 1
                            end
                            local quantities = {}
                            for i = 1, v.count do
                                table.insert(quantities, tostring(i))
                            end
                            RageUI.List("[~b~x"..v.count.."~s~] - "..v.label, quantities, selectedQuantities2[v.name], nil, {}, true, {
                                onListChange = function(Index, Items)
                                    selectedQuantities2[v.name] = Index
                                end,
                                onSelected = function()
                                    TriggerServerEvent("deposerItemBag", selectedQuantities2[v.name], v.name, v.label)
                                    Wait(50)
                                    selectedQuantities2 = {}
                                    getInventoryPlayer()
                                end
                            })
                        end
                    else
                        RageUI.Separator(" ")
                        RageUI.Separator("Vous n'avez rien sur vous")
                        RageUI.Separator(" ")
                    end
                end)
                Wait(0)
            end
        end)
    end
end


Keys.Register('F2', "sac", 'Ouvrir le sac', function()
    if isPlayerWearingBag() then
        if openBag == false then
            openMenuBag()
        end
    else
        ESX.ShowNotification("Vous devez porter un sac pour utiliser ce menu.")
    end
end)
