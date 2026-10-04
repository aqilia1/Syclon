-- URL Dasar GitHub milikmu (Ganti Username dan Repo kamu)
local baseUrl = "https://raw.githubusercontent.com/Aqilia1/Syclon/main/scripts/"

-- 1. Daftar Map yang Didukung beserta nama file script-nya
local MapScripts = {
    -- [PlaceID] = "NamaFileScript.lua"
    [91653709055687] = "StealAndCookFood.lua",  -- Blox Fruits First Sea
    [104050046639813] = "RideAFishlua",  -- Blox Fruits Second Sea
    [7449423635] = "blox_fruits.lua",  -- Blox Fruits Third Sea
    [4520749081] = "king_legacy.lua",  -- King Legacy
    [13772394367] = "blade_ball.lua",  -- Blade Ball
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
