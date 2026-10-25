--!nonstrict

-- The host decides which devices exist and how to read them. It provides a
-- `peripheral-battery` command that prints a JSON array of
-- { name, icon, level, charging } objects. The widget hides itself when the
-- command is missing or reports no devices. Click to refresh.

local COMMAND = "peripheral-battery"
local REFRESH_MS = 60000
local TIMEOUT_MS = 45000
local LOW_LEVEL = 20

local devices = {}
local pending = false

local function levelText(device)
  if type(device.level) == "number" then
    return `{math.floor(device.level)}%`
  end
  return "?"
end

local function render()
  if #devices == 0 then
    barWidget.setVisible(false)
    barWidget.clearTooltip()
    return
  end

  local container = barWidget.isVertical() and ui.column or ui.row
  local items = {}
  local tooltip = {}

  for index, device in ipairs(devices) do
    local low = type(device.level) == "number" and device.level <= LOW_LEVEL and not device.charging
    local color = low and "error" or nil
    local parts = {
      ui.glyph({ name = tostring(device.icon or "battery"), color = color }),
      ui.label({ text = levelText(device), color = color }),
    }
    if device.charging then
      table.insert(parts, ui.glyph({ name = "bolt", size = 12 }))
    end
    table.insert(items, container({ key = `device-{index}`, gap = 4, align = "center" }, parts))
    table.insert(tooltip, {
      key = tostring(device.name or device.icon or "Device"),
      value = levelText(device) .. (device.charging and " (charging)" or ""),
    })
  end

  barWidget.setVisible(true)
  barWidget.render(container({ gap = 10, align = "center" }, items))
  barWidget.setTooltip(tooltip)
end

local function refresh()
  if pending then
    return
  end
  if not noctalia.commandExists(COMMAND) then
    devices = {}
    render()
    return
  end

  pending = true
  local started = noctalia.runAsync({ COMMAND }, function(result)
    pending = false
    local parsed = nil
    if result.exitCode == 0 then
      local ok, value = pcall(noctalia.json.decode, result.stdout)
      if ok and type(value) == "table" then
        parsed = value
      end
    end
    if parsed == nil then
      noctalia.log(`{COMMAND} failed (exit {result.exitCode}): {result.stderr}`)
    end
    devices = parsed or {}
    render()
  end, TIMEOUT_MS)
  if not started then
    pending = false
  end
end

noctalia.setUpdateInterval(REFRESH_MS)
render()
refresh()

function update()
  refresh()
end

function onClick()
  refresh()
end
