-- Remember the last manually selected scaling profile and reapply it on
-- file load. Images are skipped: they always use the NEAREST default set
-- by the [image] auto-profile in mpv.conf.

local state_path = mp.find_config_file("profile-state")
if not state_path then
    local conf = mp.find_config_file("mpv.conf")
    state_path = conf and conf:match("^(.*)/[^/]*$") .. "/profile-state"
            or "profile-state"
end

local image_exts = {
    png = true, jpg = true, jpeg = true, jpe = true, gif = true, webp = true,
    avif = true, bmp = true, tiff = true, tif = true, svg = true, svgz = true,
    heic = true, heif = true, jxl = true, qoi = true, pnm = true, ppm = true,
    pgm = true, pbm = true, xbm = true, xpm = true, pcx = true, tga = true,
    vnd = true, ras = true, mng = true,
}

local function read_state()
    local f = io.open(state_path, "r")
    if not f then return nil end
    local name = f:read("*l")
    f:close()
    if name then name = name:match("^%s*(.-)%s*$") end
    return (name and name ~= "") and name or nil
end

local function write_state(name)
    local f = io.open(state_path, "w")
    if not f then return end
    f:write(name, "\n")
    f:close()
end

local function is_image()
    local fn = mp.get_property("filename") or ""
    local ext = fn:match("%.([^.]+)$")
    return ext and image_exts[ext:lower()] or false
end

mp.register_event("file-loaded", function()
    if is_image() then return end
    local saved = read_state()
    if saved then
        mp.commandv("apply-profile", saved)
    end
end)

mp.register_script_message("apply", function(name)
    if not name or name == "" then return end
    mp.commandv("apply-profile", name)
    write_state(name)
    mp.osd_message("profile: " .. name, 1)
end)
