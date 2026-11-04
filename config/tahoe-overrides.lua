-- Loaded after user looknfeel.lua so Tahoe keeps its larger continuous corners.
local state = os.getenv("HOME") .. "/.local/state/omarchy/current/theme.name"
local file = io.open(state, "r")
local theme = file and (file:read("*l") or "") or ""
if file then file:close() end

if theme == "tahoe-dark" then
  hl.config({
    decoration = {
      -- Matches the `P` table in theme/tahoe-dark/hyprland.lua; keep both in step.
      -- On Hyprland 0.55+ 1.0 is a triangular chamfer, 2.0 is a true circle.
      rounding = 18,
      rounding_power = 2.0,
    },
  })
end
