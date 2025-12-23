--      ██████╗  █████╗ ███████╗████████╗███████╗██╗
--      ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██║
--      ██████╔╝███████║███████╗   ██║   █████╗  ██║
--      ██╔═══╝ ██╔══██║╚════██║   ██║   ██╔══╝  ██║
--      ██║     ██║  ██║███████║   ██║   ███████╗███████╗
--      ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local gears = require("gears")

local pastel = {}


-- ===================================================================
-- Pastel setup
-- ===================================================================


pastel.initialize = function()
   -- Import components
   require("components.exit-screen")
   require("components.volume-adjust")

   -- Import panels
   local top_panel = require("components.pastel.top-panel")

   -- Set up each screen (add tags & panels)
   awful.screen.connect_for_each_screen(function(s)
      for i = 1, 9 do
         awful.tag.add(i, {
            icon = gears.filesystem.get_configuration_dir() .. "/icons/tags/pastel/" .. i .. ".png",
            icon_only = true,
            layout = awful.layout.suit.tile,
            screen = s,
            selected = i == 1
         })
      end

      -- Add the top panel to every screen
      top_panel.create(s)
   end)
end

return pastel
