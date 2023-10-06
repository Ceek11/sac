ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("getInventoryPlayer", function(source, cb)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then 
        return 
    end 

    local inventoryData = {}
    for k, v in pairs(xPlayer.getInventory()) do 
        if v.count > 0 then 
            table.insert(inventoryData, v)
        end
    end

    cb(inventoryData)
end)


RegisterNetEvent("deposerItemBag")
AddEventHandler("deposerItemBag", function(quantity, name, label)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    local tableItem = {}
    table.insert(tableItem, {name = name, label = label, quantity = quantity})
    MySQL.Async.fetchAll("SELECT item FROM owned_bag WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier,
    }, function(result)
        if result[1] then
            local itemData = json.decode(result[1].item) 
            local isNameUnique = true 
            
            for i = 1, #itemData do
                local itemName = itemData[i].name
                if name == itemName then 
                    itemData[i].quantity = itemData[i].quantity + quantity
                    isNameUnique = false
                    break 
                end
            end
            if isNameUnique then
                table.insert(itemData, {name = name, label = label, quantity = quantity})
            end
            local updatedItemJSON = json.encode(itemData)
            MySQL.Async.execute("UPDATE owned_bag SET item = @item WHERE identifier = @identifier", {
                ["@item"] = updatedItemJSON,
                ["@identifier"] = xPlayer.identifier, 
            })
        else
            MySQL.Async.execute("INSERT INTO owned_bag (identifier, item) VALUES (@identifier, @item)", {
                ["@identifier"] = xPlayer.identifier, 
                ["@item"] = json.encode(tableItem),
            })
        end
        xPlayer.removeInventoryItem(name, quantity)
    end)
end)


ESX.RegisterServerCallback("getSacPlayer", function(source, cb)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    local sacBdd = {}
    if not xPlayer then return end
    MySQL.Async.fetchAll("SELECT item FROM owned_bag WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier, 
    }, function(result)
        local itemData = json.decode(result[1].item)
        for i = 1, #itemData do
            local itemName = itemData[i].name
            local quantity = itemData[i].quantity
            local label = itemData[i].label
            table.insert(sacBdd, {name = itemName, quantity = quantity, label = label})
        end
        cb(sacBdd)
    end)
end)


ESX.RegisterServerCallback("getSacSolPlayer", function(source, cb, id)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    local sacBdd = {}
    if not xPlayer then return end
    MySQL.Async.fetchAll("SELECT item FROM owned_bag WHERE id = @id", {
        ["@id"] = id, 
    }, function(result)
        local itemData = json.decode(result[1].item)
        for i = 1, #itemData do
            local itemName = itemData[i].name
            local quantity = itemData[i].quantity
            local label = itemData[i].label
            table.insert(sacBdd, {name = itemName, quantity = quantity, label = label})
        end
        cb(sacBdd)
    end)
end)

RegisterNetEvent("retirerBag")
AddEventHandler("retirerBag", function(quantity, name, label)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    local newQuantity = 0
    MySQL.Async.fetchAll("SELECT id, item FROM owned_bag WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier,
    }, function(result)
        if result[1] then
            local itemData = json.decode(result[1].item) 
            local isNameUnique = true 

            for i = 1, #itemData do
                local itemName = itemData[i].name
                if name == itemName then 
                    itemData[i].quantity = itemData[i].quantity - quantity
                    newQuantity = itemData[i].quantity
                    break 
                end
            end
            
            if newQuantity > 0 then 
                local updatedItemJSON = json.encode(itemData)
                MySQL.Async.execute("UPDATE owned_bag SET item = @item WHERE identifier = @identifier", {
                    ["@item"] = updatedItemJSON,
                    ["@identifier"] = xPlayer.identifier, 
                })
            else
                for i = #itemData, 1, -1 do
                    if itemData[i].quantity <= 0 then
                        table.remove(itemData, i)
                    end
                end

                local updatedItemJSON = json.encode(itemData)
                MySQL.Async.execute("UPDATE owned_bag SET item = @item WHERE identifier = @identifier", {
                    ["@item"] = updatedItemJSON,
                    ["@identifier"] = xPlayer.identifier, 
                })
            end

            xPlayer.addInventoryItem(name, quantity)
        end
    end)
end)



RegisterNetEvent("PoserAuSolSac")
AddEventHandler("PoserAuSolSac", function(coords, clotheSac)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    MySQL.Async.fetchAll("SELECT * FROM owned_bag WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier
    }, function(result) 
        if result and #result > 0 then
            for k,v in pairs(result) do
                clotheSac = v.clotheSac
            end
            MySQL.Async.execute("UPDATE owned_bag SET coords = @coords, onfloor = @onfloor WHERE identifier = @identifier", {
                ["@identifier"] = xPlayer.identifier,
                ["@coords"] = json.encode(coords),
                ["@onfloor"] = 1
            })
        else
            MySQL.Async.execute("INSERT INTO owned_bag (identifier, coords, onfloor, clotheSac) VALUES (@identifier, @coords, @onfloor, @clotheSac)", {
                ["@identifier"] = xPlayer.identifier,
                ["@coords"] = json.encode(coords),
                ["@onfloor"] = 1, 
                ["@clotheSac"] = clotheSac,
            })
        end
    end)
    xPlayer.removeInventoryItem("bag", 1)
    TriggerClientEvent("refreshBagOnFloor", -1, clotheSac)
end)

ESX.RegisterServerCallback("getSacOnFloor", function(source, cb)
    local sacOnFloor = {}
    MySQL.Async.fetchAll("SELECT coords, onfloor, id FROM owned_bag", function(result)
        for k,v in pairs(result) do
            table.insert(sacOnFloor, {
                id = v.id,
                onfloor = v.onfloor,
                coords = json.decode(v.coords),
            })
        end
        cb(sacOnFloor)
    end)
end)


RegisterNetEvent("deletreAllBag")
AddEventHandler("deletreAllBag", function()
    MySQL.Async.fetchAll("SELECT onfloor FROM owned_bag", function(result)
        for k,v in pairs(result) do
            if v.onfloor then 
                MySQL.Async.execute("DELETE FROM owned_bag")
            end
        end
    end)
end)

RegisterNetEvent("takeBagOnFloor")
AddEventHandler("takeBagOnFloor", function(id)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    MySQL.Async.execute("UPDATE owned_bag SET onfloor = @onfloor, coords = @coords  WHERE id = @id", {
        ["@id"] = id,
        ["@onfloor"] = 0,
        ["@coords"] = nil
    })
    xPlayer.addInventoryItem("bag", 1)
end)

RegisterNetEvent("addBagItem")
AddEventHandler("addBagItem", function(id)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if not xPlayer then return end
    xPlayer.addInventoryItem("bag", 1)
    TriggerClientEvent("esx:showNotification", _src, "Vous venez de récupérer le sac dans votre inventaire")
end)


ESX.RegisterUsableItem('bag', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bagModel = nil
    for i = 1, #Config.Items do
        if Config.Items[i].name == "bag" then
            bagModel = Config.Items[i].bagModel
            break
        end
    end
    if bagModel ~= nil then
        xPlayer.removeInventoryItem('bag', 1)
        TriggerClientEvent('esx_bag:useBag', source, bagModel)
    end
end)
