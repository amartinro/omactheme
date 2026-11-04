-- Tahoe Dark · compositor chrome and motion.
--
-- All tunables live in the `P` table below; everything after it only consumes
-- those values, so a change never has to be chased through the file.
-- Reload after editing:  hyprctl reload config-only
--
-- Color format (Hyprland 0.50+ non-legacy parser):
--   solid      "rgba(rrggbbaa)"   or   "rgb(rrggbb)"
--   gradient   { colors = { "rgba(...)", "rgba(...)" }, angle = <degrees> }
-- Anything else (bare hex, space-separated stops) is rejected as invalid.

local P = {
  -- ── Gaps ──────────────────────────────────────────────────────────────
  -- Empty space, in pixels. `gaps_in` between neighbours, `gaps_out` at the
  -- screen edge.
  gaps_in = 4,
  gaps_out = 7,

  -- ── Window border ─────────────────────────────────────────────────────
  -- `border_size` is the thickness in pixels, identical on all four sides of
  -- the focused window. The inactive hairline stays neutral so the accent rim
  -- is the only thing carrying focus.
  border_size = 1,
  border_active = { colors = { "rgba(ffc46bff)", "rgba(ff9f0acc)" }, angle = 90 },
  border_inactive = "rgba(ffffff0d)",

  -- ── Corners ───────────────────────────────────────────────────────────
  -- `corner_radius` in pixels. `corner_power` shapes the curve (Hyprland 0.55+
  -- scale): 1.0 is a triangular chamfer, 2.0 is a true circle, 4.0 a squircle.
  -- 2.0 matches the compositor default and reads as the smooth macOS-style arc.
  corner_radius = 18,
  corner_power = 2.0,

  -- ── Opacity ───────────────────────────────────────────────────────────
  active_opacity = 1.0,
  inactive_opacity = 0.965,
  fullscreen_opacity = 1.0,

  -- ── Drop shadow ───────────────────────────────────────────────────────
  -- The frame's soft edge. `tinted = false` keeps the neutral black drop
  -- shadow; `true` paints it with the accent so the focused window also gets a
  -- faint halo. Geometry is shared by both. `range` = reach in px, `power` =
  -- falloff steepness (higher = tighter), `offset` = {x, y} push, `scale` =
  -- shrink of the shadow versus the window.
  shadow = {
    tinted = false,
    tint = "rgba(ff9f0a59)",
    neutral = "rgba(00000078)",
    color_inactive = "rgba(00000042)",
    range = 34,
    power = 3,
    offset = { 0, 8 },
    scale = 0.97,
  },

  -- ── Glass blur ────────────────────────────────────────────────────────
  -- A light diffusion: shapes stay legible behind menus rather than collapsing
  -- into a dense frosted wash.
  blur = {
    enabled = true,
    size = 7,
    passes = 2,
    noise = 0.012,
    contrast = 0.98,
    brightness = 0.96,
    vibrancy = 0.12,
    vibrancy_darkness = 0.08,
    popups = true,
    popups_ignorealpha = 0.16,
    new_optimizations = true,
    xray = false,
  },

  -- ── Title bar (hyprbars) ──────────────────────────────────────────────
  -- One color for tiled and floating windows: the same charcoal on both, so
  -- flipping float state does not repaint the bar.
  -- `part_of_window = true` + `precedence_over_border = true` keep the bar
  -- inside the frame, so the accent rim closes over its top edge too.
  titlebar = {
    enabled = true,
    color = "rgba(25272eee)",
    height = 38,
    blur = true,
    text = "rgba(f2f3f7e6)",
    title = true,
    text_size = 13,
    text_weight = "medium",
    text_font = "Sans",
    text_align = "center",
    buttons_alignment = "left",
    part_of_window = true,
    precedence_over_border = true,
    padding = 12,
    button_padding = 7,
    icon_on_hover = true,
    inactive_button_color = "rgba(777982ff)",
  },

  -- Traffic-light button diameter in pixels.
  button_size = 13,

  -- ── Layer blur ────────────────────────────────────────────────────────
  -- Alpha thresholds for the Omarchy shell bar and the local dock.
  layer_ignore_alpha = 0.12,
  dock_ignore_alpha = 0.08,
}

hl.config({
  general = {
    gaps_in = P.gaps_in,
    gaps_out = P.gaps_out,
    border_size = P.border_size,
    resize_on_border = true,
    col = {
      active_border = P.border_active,
      inactive_border = P.border_inactive,
    },
  },
  decoration = {
    rounding = P.corner_radius,
    rounding_power = P.corner_power,
    active_opacity = P.active_opacity,
    inactive_opacity = P.inactive_opacity,
    fullscreen_opacity = P.fullscreen_opacity,
    shadow = {
      enabled = true,
      range = P.shadow.range,
      render_power = P.shadow.power,
      color = P.shadow.tinted and P.shadow.tint or P.shadow.neutral,
      color_inactive = P.shadow.color_inactive,
      offset = P.shadow.offset,
      scale = P.shadow.scale,
    },
    blur = {
      enabled = P.blur.enabled,
      size = P.blur.size,
      passes = P.blur.passes,
      noise = P.blur.noise,
      contrast = P.blur.contrast,
      brightness = P.blur.brightness,
      vibrancy = P.blur.vibrancy,
      vibrancy_darkness = P.blur.vibrancy_darkness,
      popups = P.blur.popups,
      popups_ignorealpha = P.blur.popups_ignorealpha,
      new_optimizations = P.blur.new_optimizations,
      xray = P.blur.xray,
    },
  },
  group = {
    col = {
      border_active = P.border_active,
      border_inactive = P.border_inactive,
    },
  },
  plugin = {
    hyprbars = {
      enabled = P.titlebar.enabled,
      bar_color = P.titlebar.color,
      bar_height = P.titlebar.height,
      bar_blur = P.titlebar.blur,
      col = { text = P.titlebar.text },
      bar_title_enabled = P.titlebar.title,
      bar_text_size = P.titlebar.text_size,
      bar_text_weight = P.titlebar.text_weight,
      bar_text_font = P.titlebar.text_font,
      bar_text_align = P.titlebar.text_align,
      bar_buttons_alignment = P.titlebar.buttons_alignment,
      bar_part_of_window = P.titlebar.part_of_window,
      bar_precedence_over_border = P.titlebar.precedence_over_border,
      bar_padding = P.titlebar.padding,
      bar_button_padding = P.titlebar.button_padding,
      icon_on_hover = P.titlebar.icon_on_hover,
      inactive_button_color = P.titlebar.inactive_button_color,
      on_double_click = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
    },
  },
})

hl.curve("tahoeEase", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("tahoeSpring", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
-- Hyprland measures this value in deciseconds, so lower means faster.
-- These durations are roughly 25% shorter than the original Tahoe profile.
hl.animation({ leaf = "windows", enabled = true, speed = 4.2, bezier = "tahoeEase" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.3, bezier = "tahoeSpring", style = "popin 95%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.8, bezier = "tahoeEase", style = "popin 97%" })
hl.animation({ leaf = "fade", enabled = true, speed = 4.5, bezier = "tahoeEase" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4.2, bezier = "tahoeEase" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4.0, bezier = "tahoeEase" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.9, bezier = "tahoeEase", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.6, bezier = "tahoeEase", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3.2, bezier = "tahoeEase", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.3, bezier = "tahoeEase", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.3, bezier = "tahoeEase", style = "slidevert" })

hl.layer_rule({ match = { namespace = ".*omarchy.*" }, blur = true, blur_popups = true, ignore_alpha = P.layer_ignore_alpha })
hl.layer_rule({ match = { namespace = "local-dock" }, blur = true, blur_popups = true, ignore_alpha = P.dock_ignore_alpha })

-- Fullscreen content should have no visible frame or titlebar.
hl.window_rule({ match = { fullscreen = true }, border_size = 0, rounding = 0 })

-- macOS-style elevation: the tiled plane stays flat and only the floating
-- layer casts the drop shadow, so a floated window reads as lifted above the
-- rest. Declare the flat base first; the later rule wins for floaters.
hl.window_rule({ match = { class = ".*" }, no_shadow = true })
hl.window_rule({ match = { float = true }, no_shadow = false })

-- hyprbars renders buttons left-to-right in declaration order when aligned
-- left, so declare them in the macOS traffic-light order: red (close),
-- yellow (float), green (maximize).
pcall(function()
  hl.plugin.hyprbars.add_button({
    bg_color = "rgb(E06E68)", fg_color = "rgb(791D19)", size = P.button_size, icon = "×",
    action = [[hyprctl dispatch 'hl.dsp.window.close()']],
  })
  hl.plugin.hyprbars.add_button({
    bg_color = "rgb(DCA84A)", fg_color = "rgb(765B10)", size = P.button_size, icon = "−",
    action = [[tahoe-window float-toggle]],
  })
  hl.plugin.hyprbars.add_button({
    bg_color = "rgb(3CB44E)", fg_color = "rgb(163C1D)", size = P.button_size, icon = "+",
    action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
  })
end)

-- Keep the floating window exactly where it was tiled so the titlebar and
-- traffic lights stay fully visible instead of sliding under the top bar.
-- This file loads after the default bindings, so it can replace SUPER+T.
if o and o.bind and hl and hl.unbind then
  hl.unbind("SUPER + T")
  o.bind("SUPER + T", "Toggle window floating/tiling", "tahoe-window float-toggle")
end
