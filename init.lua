local armor_intalled = minetest.global_exists("armor")
clothes = {}
local num_faces = 0
local num_skins = 0
local num_hairs = 0
local num_pants = 0
local num_shirts = 0
local num_head_gears = 0
local textures = minetest.get_dir_list(minetest.get_modpath("clothes") .. "/textures")
for _, texture in pairs(textures) do
	if texture:find("skin_%d*.png") then
		num_skins = num_skins + 1
	elseif texture:find("clothes_face_%d*.png") then
		num_faces = num_faces + 1
	elseif texture:find("clothes_hair_%d*.png") then
		num_hairs = num_hairs + 1
	elseif texture:find("clothes_head_gear_%d*.png") then
		num_head_gears = num_head_gears + 1
	elseif texture:find("clothes_pants_%d*.png") then
		num_pants = num_pants + 1
	elseif texture:find("clothes_shirt_%d*.png") then
		num_shirts = num_shirts + 1
	end
end
local current_tab_indexes = {} -- IN: player name OUT: current tab index
local tabs = {
	"skin",
	"face",
	"hair",
	"head gear",
	"pants",
	"shirt",
}
local clothes_file_name = minetest.get_worldpath() .. "/clothes.lua"
function show_clothes_config(player)
	local player_name = player:get_player_name()
	local current_tab_index = current_tab_indexes[player_name]
	local formspec = "size[9,8]bgcolor[#ffffff50;false]tabheader[0,0;tabs;"
	for _, tab in pairs(tabs) do
		formspec = formspec .. tab .. ","
	end
	formspec = formspec:sub(0, formspec:len() - 1) -- remove trailing comma
	formspec = formspec .. ";" .. current_tab_index .. ";true;false]"
	local current_tab = tabs[current_tab_index]
	if current_tab == "skin" then
		for i = 1, num_skins do
			local column = (i - 1) % 9
			local row = math.floor((i - 1) / 9)
			if i == clothes[player_name].skin then
				formspec = formspec .. "box[" .. (column - 0.1) .. "," .. (row - 0.1) .. ";1,1.1;white]"
			end
			formspec = formspec
				.. "image_button[" .. column .. "," .. row .. ";1,1;clothes_skin_" .. i .. "_preview.png;" .. i .. ";;false;false;]"
		end
	elseif current_tab == "face" then
		for i = 1, num_faces do
			local column = (i - 1) % 9
			local row = math.floor((i - 1) / 9)
			if i == clothes[player_name].face then
				formspec = formspec .. "box[" .. (column - 0.1) .. "," .. (row - 0.1) .. ";1,1.1;white]"
			end
			formspec = formspec
				.. "image_button[" .. column .. "," .. row .. ";1,1;clothes_face_" .. i .. ".png;" .. i .. ";;false;false;]"
		end
	elseif current_tab == "hair" then

		for i = 1, num_hairs do
			local column = (i - 1) % 9
			local row = math.floor((i - 1) / 9)
			if i == clothes[player_name].hair then
				formspec = formspec .. "box[" .. (column - 0.1) .. "," .. (row - 0.1) .. ";1,1.1;white]"
			end
			formspec = formspec
				.. "image_button[" .. column .. "," .. row .. ";1,1;clothes_hair_" .. i .. "_preview.png;" .. i .. ";;false;false;]"
		end
	elseif current_tab == "head gear" then
		for i = 1, num_head_gears do
			local column = (i - 1) % 9
			local row = math.floor((i - 1) / 9)
			if i == clothes[player_name].head_gear then
				formspec = formspec .. "box[" .. (column - 0.1) .. "," .. (row - 0.1) .. ";1,1.1;white]"
			end
			formspec = formspec
				.. "image_button[" .. column .. "," .. row .. ";1,1;clothes_head_gear_" .. i .. "_preview.png;" .. i .. ";;false;false;]"
		end
	elseif current_tab == "pants" then
		for i = 1, num_pants do
			local column = (i - 1) % 9 * 0.5
			local row = math.floor((i - 1) / 9) * 2
			if i == clothes[player_name].pants then
				formspec = formspec .. "box[" .. (column - 0.1) .. "," .. (row - 0.1) .. ";0.5,2.1;white]"
			end
			formspec = formspec
				.. "image_button[" .. column .. "," .. row .. ";0.5,2;clothes_pants_" .. i .. "_preview.png;" .. i .. ";;false;false;]"
		end
	elseif current_tab == "shirt" then
		for i = 1, num_shirts do
			local column = (i - 1) % 9
			local row = math.floor((i - 1) / 9) * 2
			if i == clothes[player_name].shirt then
				formspec = formspec .. "box[" .. (column - 0.1) .. "," .. (row - 0.1) .. ";1,2.1;white]"
			end
			formspec = formspec
				.. "image_button[" .. column .. "," .. row .. ";1,2;clothes_shirt_" .. i .. "_preview.png;" .. i .. ";;false;false;]"
		end
	end
	minetest.show_formspec(player_name, "clothes:config", formspec)
end
function int_to_bin(int)
	return string.char(int)
end
function bin_to_int(bin)
	return bin:byte(0,1)
end
function init_clothes()
	local clothes_file = io.open(clothes_file_name, "r")
	if clothes_file then
		local data = clothes_file:read('*all')
		if data then
			clothes = minetest.deserialize(data)
		end
		io.close(clothes_file)
	end
	if armor_intalled then
		armor.get_player_skin = function(self, player_name)
			return compile_clothes(clothes[player_name])
		end
	end
end
init_clothes()
function save_clothes()
	local clothes_file = io.open(clothes_file_name,'w')
	clothes_file:write(minetest.serialize(clothes))
	io.close(clothes_file)
end
function compile_clothes(clothes)
	return "[combine:128x64:0,0=clothes_skin_" .. clothes.skin .. ".png:16,16=clothes_face_" .. clothes.face .. ".png:0,32=clothes_pants_" .. clothes.pants .. ".png:32,32=clothes_shirt_" .. clothes.shirt .. ".png:64,0=clothes_head_gear_" .. clothes.head_gear .. ".png:0,0=clothes_hair_" .. clothes.hair .. ".png"
end
function update_player_clothes(player)
	local player_props = player:get_properties()
	if armor_intalled then
		local player_name = player:get_player_name()
		armor.textures[player_name].skin = compile_clothes(clothes[player_name])
		armor:update_player_visuals(player)
	else
		player_props.textures[1] = compile_clothes(clothes[player:get_player_name()])
		player:set_properties(player_props)
	end
end

local unknown_inventory_engine = false

function add_clothes_button_to_formspec(player)
	if not unknown_inventory_engine then
		return
	end
	local formspec = player:get_inventory_formspec()
	formspec = formspec .. "image_button[-1.1,-1.1;1,1;clothes_icon.png;clothes;;true;true;clothes_icon.png]"
	player:set_inventory_formspec(formspec)
end

if rawget(
	_G,
	"unified_inventory"
) then
	unified_inventory.register_button(
		"clothes:configure",
		{
			type = "image",
			image = "clothes_icon.png",
			tooltip = "Configure clothes",
			hide_lite=true,
			action = show_clothes_config,
			condition = function(player)
				return true
			end,
		}
	)
else
	unknown_inventory_engine = true
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	if not clothes[player_name] then
		clothes[player_name] = {
			skin = 1,
			face = 1,
			hair = 1,
			pants = 1,
			shirt = 1,
			head_gear = 1
		}
	end
	current_tab_indexes[player_name] = 1
	minetest.after(0.01, function()
		update_player_clothes(player)
		add_clothes_button_to_formspec(player)
	end)
end)
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if fields.clothes then -- player pressed our button
		show_clothes_config(player)
		return true
	elseif formname == "clothes:config" then -- our form
		for str, _ in pairs(fields) do
			if fields.tabs then
				current_tab_indexes[player:get_player_name()] = tonumber(fields.tabs)
				show_clothes_config(player)
			elseif str == "quit" then
				add_clothes_button_to_formspec(player)
				save_clothes() -- save clothes to hard drive
			else
				local current_tab_index = current_tab_indexes[player:get_player_name()]
				local current_tab = tabs[current_tab_index]
				if current_tab == "skin" then
					clothes[player:get_player_name()].skin = tonumber(str)
				elseif current_tab == "face" then
					clothes[player:get_player_name()].face = tonumber(str)
				elseif current_tab == "hair" then
					clothes[player:get_player_name()].hair = tonumber(str)
				elseif current_tab == "head gear" then
					clothes[player:get_player_name()].head_gear = tonumber(str)
				elseif current_tab == "pants" then
					clothes[player:get_player_name()].pants = tonumber(str)
				elseif current_tab == "shirt" then
					clothes[player:get_player_name()].shirt = tonumber(str)
				end
				update_player_clothes(player)
				show_clothes_config(player)
			end
		end
	else -- deal with creative_inventory setting the formspec on every single message
		minetest.after(0.01, function()
			add_clothes_button_to_formspec(player)
		end)
		return false -- continue processing in creative inventory
	end
end)
