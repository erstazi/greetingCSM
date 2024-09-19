-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
--   greeting     CSM for automatic greetings when a new player joins
--
--   2024-09-18   erstazi (on the Linux-Forks.de server)
--
--   Licence:     MIT
--
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

local mod_name = minetest.get_current_modname()
local mod_storage = minetest.get_mod_storage()
local greeting_setting = mod_storage:get_string("greeting")
local next = mod_storage:get_string("next")
local next = mod_storage:get_string("debug")
local player_color = mod_storage:get_string("color")
if greeting_setting == nil then
  mod_storage:set_string("greeting","1")
end
if next == nil then
  mod_storage:set_string("next","0")
end
if debug == nil then
  mod_storage:set_string("debug","0")
end
if player_color == nil then
  mod_storage:set_string("color","#FFFFFF")
end

local vc_version = "$Id: init.lua,v 1.0 2024-09-18 13:45:25 minetest Exp $"

local vc_v = vc_version:split(" ",false,5,false)

local register_on_send = minetest.register_on_sending_chat_message or minetest.register_on_sending_chat_messages
local register_on_receive = minetest.register_on_receiving_chat_message or minetest.register_on_receiving_chat_messages

greeting = {}
greeting.version = vc_v[3]
greeting.date = vc_v[4]
greeting.default_lang = "en"
greeting.modname = "GreetingCSM"
greeting.delay = 20
greeting.debug = true
-- greeting.MY_COLOR = "#CCFFFF"
greeting.data = {
  ["en"] = "Welcome to Linux-Forks! Please, read the rules at https://li-fo.de/rules ! If you would like a free apartment with free food (take as you need) then type /phw ",
  ["de"] = "Willkommen bei Linux-Forks! Bitte lesen Sie die Regeln unter https://li-fo.de/rules-de ! Wenn Sie eine freie Wohnung mit kostenlosem Essen wünschen, dann verwenden Sie den Befehl: /phw ",
  ["es"] = "¡Bienvenido a Linux-Forks! Por favor, lee las reglas en https://li-fo.de/rules-es antes de continuar. Si deseas un apartamento gratuito con comida gratis (toma lo que necesites), escribe /phw ",
  ["ru"] = "Добро пожаловать на Linux-Forks! Пожалуйста, прочтите правила на https://li-fo.de/rules-ru ! Если вы хотите бесплатное жилье с бесплатной едой (берите сколько вам нужно), то введите /phw ",
  ["hu"] = "Üdvözöllek a Linux-Forks szerveren! Kérlek, olvasd el a szabályokat itt: https://li-fo.de/rules ! Ha szeretnél egy ingyenes lakást ingyenes élelmiszerrel (vegyél annyit, amennyit szükségesnek találsz), akkor írd be a /phw parancsot !",
}
greeting.print = function(text)
  minetest.display_chat_message(greeting.modname .. ": " .. text)
end

greeting.split = function(parameter)
  local cmd = {}
  for word in string.gmatch(parameter, "[%w%-%:%.2f%_]+") do
    table.insert(cmd, word)
  end
  return cmd
end

greeting.send_greeting = function(username, message, override)
  local now = minetest.get_us_time()
  local ref = mod_storage:get_string("next")
  local debug = mod_storage:get_string("debug")
  local greeting_setting = mod_storage:get_string("greeting")
  local player_color = mod_storage:get_string("color")
  local diff = ref - now
  ref = tonumber(ref) or 0
  if now > ref or override == true then
    minetest.send_chat_message(minetest.get_color_escape_sequence(player_color) .. username .. ": " .. message)
    local wait_to_next = tostring(now + tonumber(greeting.delay) * 1000000)
    mod_storage:set_string("next", wait_to_next)
    if tonumber(debug) == 1 then
      greeting.print("Greeting - Wait: " .. wait_to_next)
    end
  else
    if tonumber(debug) == 1 then
      greeting.print("Cannot greet. Use override. Wait: " .. tostring(ref) .. " | Now: " .. tostring(now) .. " | Diff: " .. tostring(diff) )
    else
      greeting.print("Cannot greet. Use override.")
    end
  end
end

greeting.check_if_greeting_can_be_done = function(message)
  local status = mod_storage:get_string("greeting")
  local debug = mod_storage:get_string("debug")
  if status == "1" then
    local msg = minetest.strip_colors(message)
    local sp1 = msg:find("*** xban: New player", 1, true)
    local sp2 = msg:find("joined the game", 1, true)
    local welcomeGreeting = msg:find("Welcome to Linux-Forks!", 1, true)

    if welcomeGreeting then
      local now = minetest.get_us_time()
      local wait_to_next = tostring(now + greeting.delay * 1000000)
      mod_storage:set_string("next", wait_to_next)
      if tonumber(debug) == 1 then
        greeting.print("Greeting for new player has already done. - Wait: " .. wait_to_next)
      else
        greeting.print("Greeting for new player has already done. ")
      end
    end
    -- minetest.after(1, ddfdfdfd)

    if sp1 and sp2 then
      local username = string.match(msg, "*** xban: New player (%S+) joined the game")
      local randomDelay = math.random(1, 5)
      minetest.after(randomDelay, function()
        greeting.send_greeting(username, greeting.data[greeting.default_lang], false)
      end)
    end
  end
end

local server_info = minetest.get_server_info()
local server_id = server_info.address .. ':' .. server_info.port
local full_version = "CSM greeting version "..greeting.version.." from "..greeting.date

greeting.print(full_version)

local function log(level, message)
  minetest.log(level, ("[%s] %s"):format(mod_name, message))
end

local function safe(func)
  -- wrap a function w/ logic to avoid crashing the game
  local f = function(...)
    local status, out = pcall(func, ...)
    if status then
      return out
    else
      log("warning", "Error (func):  " .. out)
      return nil
    end
  end
  return f
end

if register_on_receive then
  register_on_receive(function(message)
    greeting.check_if_greeting_can_be_done(message)
  end)
else
  log('warning', 'can\'t find minetest.register_on_receiving_chat_message')
end

minetest.register_chatcommand('setgreet', {
  params = '[(function)]',
  description = 'enable or disable greeting new players',
  func = function(param)
    local debug = mod_storage:get_string("debug")
    local player_color = mod_storage:get_string("color")
    local paramsTable = {}
    for paramItem in string.gmatch(param, "%S+") do
      table.insert(paramsTable, paramItem)
    end

    if paramsTable[1] == nil or paramsTable[1] == "help" then
      greeting.print("setgreet [0|1|on|off|enable|disable|reset|debug|color|status|help]")
    else
      if paramsTable[1] == "status" then
        local greeting_setting = mod_storage:get_string("greeting")
        if greeting_setting == "0" then
          greeting_setting_text = "off"
        else
          greeting_setting_text = "on"
        end
        greeting.print(greeting_setting_text)
      end

      if paramsTable[1] == "1" or paramsTable[1] == "on" or paramsTable[1] == "enable" then
        mod_storage:set_string("greeting","1")
        mod_storage:set_string("next","0")
        greeting.print("Greeting new players is enabled")
      end

      if paramsTable[1] == "0" or paramsTable[1] == "off" or paramsTable[1] == "disable" then
        mod_storage:set_string("greeting","0")
        mod_storage:set_string("next","0")
        greeting.print("Greeting new players is disabled ")
      end

      if paramsTable[1] == "reset" then
        mod_storage:set_string("next","0")
        greeting.print("Greeting wait time has been reset ")
      end

      if paramsTable[1] == "debug" then
        greeting.print(tostring(debug))
        if tonumber(debug) == 1 then
          mod_storage:set_string("debug","0")
          greeting.print("Greeting debug has been disabled ")
        else
          mod_storage:set_string("debug","1")
          greeting.print("Greeting debug has been enabled ")
        end
      end

      if paramsTable[1] == "color" then
        if paramsTable[2] == nil then
          if player_color == nil or player_color == "#FFFFFF" then
            greeting.print("To set your text color, run: .setgreet color #FFFFFF ")
          else
            greeting.print("Your color is " .. player_color .. ". To set your text color, run: .setgreet color " .. player_color)
          end
        else
          local new_color = paramsTable[2]
          if new_color:len() == 7 then
            mod_storage:set_string("color", paramsTable[2])
            greeting.print("Your color is " .. new_color .. ".")
          elseif new_color:len() == 6 then
            mod_storage:set_string("color", "#" .. paramsTable[2])
            greeting.print("Your color is #" .. new_color .. ".")
          else
            greeting.print("Please, set your color with a hex color like #FFFFFF.")
          end
        end
      end
    end
  end,
})

minetest.register_chatcommand("intro", {
  params = "<playernamename>",
  description = "say greeting to player",
  func = safe(function(params)
    local paramsTable = {}
    for param in string.gmatch(params, "%S+") do
      table.insert(paramsTable, param)
    end
    if #paramsTable == 1 then
      local username = params
      greeting.send_greeting(username, greeting.data[greeting.default_lang], false)
    elseif #paramsTable == 2 then
      local lang = paramsTable[1]
      local username = paramsTable[2]
      if greeting.data[lang] ~= nil then
        greeting.send_greeting(username, greeting.data[lang], false)
      else
        greeting.print("The language " .. lang .. " is not available ")
      end
    elseif #paramsTable == 3 then
      local lang = paramsTable[1]
      local username = paramsTable[2]
      local override = paramsTable[3]
      if override == "true" or override == "override" then
        if greeting.data[lang] ~= nil then
          greeting.send_greeting(username, greeting.data[lang], true)
        else
          greeting.print("The language " .. lang .. " is not available ")
        end
      else
        greeting.print("For greeting, the override needs to be set to true ")
      end
    else
      greeting.print("Please use command as: .intro username or .intro en username or .intro en username override ")
    end
  end),
})

minetest.register_chatcommand("intro-en", {
  params = "<playernamename>",
  description = "say greeting to player",
  func = safe(function(username)
    greeting.send_greeting(username, greeting.data["en"], true)
  end),
})

minetest.register_chatcommand("intro-de", {
  params = "<playernamename>",
  description = "say FL intro to player",
  func = safe(function(param)
    local username = param
    greeting.send_greeting(username, greeting.data["de"], true)
  end),
})

minetest.register_chatcommand("intro-es", {
  params = "<playernamename>",
  description = "say FL intro to player",
  func = safe(function(param)
    local username = param
    greeting.send_greeting(username, greeting.data["es"], true)
  end),
})

minetest.register_chatcommand("intro-ru", {
  params = "<playernamename>",
  description = "say FL intro to player",
  func = safe(function(param)
    local username = param
    greeting.send_greeting(username, greeting.data["ru"], true)
  end),
})

minetest.register_chatcommand("intro-hu", {
  params = "<playernamename>",
  description = "say FL intro to player",
  func = safe(function(param)
    local username = param
    greeting.send_greeting(username, greeting.data["hu"], true)
  end),
})


--[[
minetest.register_chatcommand("intro-en", {
  params = "<playernamename>",
  description = "say FL intro to player",
  func = safe(function(param)
    local username = param
    local message = "Welcome to Linux-Forks! Please, read the rules at https://li-fo.de/rules ! If you would like a free apartment with free food (take as you need) then type /phw "
    minetest.send_chat_message(minetest.get_color_escape_sequence(player_color) .. username .. ": " .. message)
  end),
})
]]
