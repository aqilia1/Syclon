-- URL Dasar GitHub milikmu (Ganti Username dan Repo kamu)
local baseUrl = "https://raw.githubusercontent.com/aqilia1/Syclon/refs/heads/main/"

-- 1. Daftar Map yang Didukung beserta nama file script-nya
local MapScripts = {
    -- [PlaceID] = "NamaFileScript.lua"
    [91653709055687] = "StealAndCookFood.lua",  -- Blox Fruits First Sea
    [104050046639813] = "RideAFish.lua",  -- Blox Fruits Second Sea
    [113132840606249] = "hamstersmash.lua",  -- Blox Fruits Third Sea
    [122969114308489] = "findanimalbones.lua",  -- King Legacy
    [132122109102323] = "Ride A Dragon",  -- Blade Ball
}

-- 2. Dapatkan PlaceId map saat ini
local currentPlaceId = game.PlaceId

-- 3. Cek apakah map saat ini ada di daftar
if MapScripts[currentPlaceId] then
    local fileName = MapScripts[currentPlaceId]
    local scriptUrl = baseUrl .. fileName
    
    -- Notifikasi Map Didukung
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script Supported!",
        Text = "Memuat script: " .. fileName,
        Duration = 5
    })
    
    -- Eksekusi script spesifik untuk map tersebut
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    
    if not success then
        warn("[ERROR] Gagal memuat script:", err)
    end

else
    -- Notifikasi Map Tidak Didukung
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script Not Supported",
        Text = "Map ini (ID: " .. currentPlaceId .. ") belum didukung!",
        Duration = 5
    })
    
    warn("[INFO] PlaceId " .. currentPlaceId .. " tidak ada di daftar MapScripts.")
end
