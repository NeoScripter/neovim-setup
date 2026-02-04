-- Color Converter for Neovim
-- Converts CSS colors under cursor: CSS -> HSL -> OKHSL -> CSS
-- Usage: Add to your init.lua or create a plugin

local M = {}

-- Helper function to parse hex colors
local function hex_to_rgb(hex)
	hex = hex:gsub("#", "")
	if #hex == 3 then
		hex = hex:gsub("(%x)", "%1%1")
	end
	local r = tonumber(hex:sub(1, 2), 16) / 255
	local g = tonumber(hex:sub(3, 4), 16) / 255
	local b = tonumber(hex:sub(5, 6), 16) / 255
	return r, g, b
end

-- Helper function to parse rgb/rgba
local function parse_rgb(str)
	local r, g, b, a = str:match("rgba?%((%d+%.?%d*)%s*,%s*(%d+%.?%d*)%s*,%s*(%d+%.?%d*)%s*,?%s*(%d*%.?%d*)%)?")
	if not r then
		r, g, b, a = str:match("rgba?%((%d+%.?%d*)%%?%s+(%d+%.?%d*)%%?%s+(%d+%.?%d*)%%?%s*/%s*(%d*%.?%d*)%)?")
	end
	if r then
		r = tonumber(r) / 255
		g = tonumber(g) / 255
		b = tonumber(b) / 255
		return r, g, b, a and tonumber(a)
	end
	return nil
end

-- Convert RGB to HSL
local function rgb_to_hsl(r, g, b)
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, l = 0, 0, (max + min) / 2

	if max ~= min then
		local d = max - min
		s = l > 0.5 and d / (2 - max - min) or d / (max + min)

		if max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h * 360, s * 100, l * 100
end

-- Convert HSL to RGB
local function hsl_to_rgb(h, s, l)
	h = h / 360
	s = s / 100
	l = l / 100

	local r, g, b

	if s == 0 then
		r, g, b = l, l, l
	else
		local function hue_to_rgb(p, q, t)
			if t < 0 then
				t = t + 1
			end
			if t > 1 then
				t = t - 1
			end
			if t < 1 / 6 then
				return p + (q - p) * 6 * t
			end
			if t < 1 / 2 then
				return q
			end
			if t < 2 / 3 then
				return p + (q - p) * (2 / 3 - t) * 6
			end
			return p
		end

		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue_to_rgb(p, q, h + 1 / 3)
		g = hue_to_rgb(p, q, h)
		b = hue_to_rgb(p, q, h - 1 / 3)
	end

	return r, g, b
end

-- Convert RGB to linear RGB (for OKLAB conversion)
local function rgb_to_linear(c)
	if c <= 0.04045 then
		return c / 12.92
	else
		return math.pow((c + 0.055) / 1.055, 2.4)
	end
end

-- Convert linear RGB to RGB
local function linear_to_rgb(c)
	if c <= 0.0031308 then
		return c * 12.92
	else
		return 1.055 * math.pow(c, 1 / 2.4) - 0.055
	end
end

-- Convert linear RGB to OKLAB
local function linear_rgb_to_oklab(r, g, b)
	local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

	l = math.pow(l, 1 / 3)
	m = math.pow(m, 1 / 3)
	s = math.pow(s, 1 / 3)

	return 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
		1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
		0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
end

-- Convert OKLAB to linear RGB
local function oklab_to_linear_rgb(L, a, b)
	local l = L + 0.3963377774 * a + 0.2158037573 * b
	local m = L - 0.1055613458 * a - 0.0638541728 * b
	local s = L - 0.0894841775 * a - 1.2914855480 * b

	l = l * l * l
	m = m * m * m
	s = s * s * s

	return 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
		-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
		-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
end

-- Convert RGB to OKLCH
local function rgb_to_oklch(r, g, b)
	local lr = rgb_to_linear(r)
	local lg = rgb_to_linear(g)
	local lb = rgb_to_linear(b)

	local L, a, b_lab = linear_rgb_to_oklab(lr, lg, lb)

	local C = math.sqrt(a * a + b_lab * b_lab)
	local h = math.atan2(b_lab, a) * 180 / math.pi
	if h < 0 then
		h = h + 360
	end

	return L, C, h
end

-- Convert OKLCH to RGB
local function oklch_to_rgb(L, C, h)
	h = h * math.pi / 180
	local a = C * math.cos(h)
	local b = C * math.sin(h)

	local lr, lg, lb = oklab_to_linear_rgb(L, a, b)

	return linear_to_rgb(lr), linear_to_rgb(lg), linear_to_rgb(lb)
end

-- Parse HSL/HSLA string
local function parse_hsl(str)
	local h, s, l, a = str:match("hsla?%((%d+%.?%d*)%s*,?%s*(%d+%.?%d*)%%?%s*,?%s*(%d+%.?%d*)%%?%s*,?%s*(%d*%.?%d*)%)?")
	if not h then
		h, s, l, a = str:match("hsla?%((%d+%.?%d*)%s+(%d+%.?%d*)%%?%s+(%d+%.?%d*)%%?%s*/%s*(%d*%.?%d*)%)?")
	end
	if h then
		return tonumber(h), tonumber(s), tonumber(l), a and tonumber(a)
	end
	return nil
end

-- Parse OKLCH string
local function parse_oklch(str)
	local l, c, h, a = str:match("oklch%((%d+%.?%d*)%%?%s+(%d+%.?%d*)%s+(%d+%.?%d*)%s*/%s*(%d*%.?%d*)%)?")
	if not l then
		l, c, h, a = str:match("oklch%((%d+%.?%d*)%%?%s*,?%s*(%d+%.?%d*)%s*,?%s*(%d+%.?%d*)%s*,?%s*(%d*%.?%d*)%)?")
	end
	if l then
		-- OKLCH L is 0-1, but often written as percentage
		local L = tonumber(l)
		if str:match("oklch%(" .. l .. "%%") then
			L = L / 100
		end
		return L, tonumber(c), tonumber(h), a and tonumber(a)
	end
	return nil
end

-- Get color string under cursor
local function get_color_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	-- Try to find color patterns
	local patterns = {
		"#%x%x%x%x%x%x",
		"#%x%x%x",
		"rgba?%([^)]+%)",
		"hsla?%([^)]+%)",
		"oklch%([^)]+%)",
	}

	for _, pattern in ipairs(patterns) do
		for match in line:gmatch(pattern) do
			local start_pos = line:find(match, 1, true)
			local end_pos = start_pos + #match - 1
			if col >= start_pos and col <= end_pos then
				return match, start_pos, end_pos
			end
		end
	end

	return nil
end

-- Format color as HSL
local function to_hsl_string(r, g, b, alpha)
	local h, s, l = rgb_to_hsl(r, g, b)
	h = math.floor(h + 0.5)
	s = math.floor(s + 0.5)
	l = math.floor(l + 0.5)

	if alpha then
		return string.format("hsla(%d, %d%%, %d%%, %g)", h, s, l, alpha)
	else
		return string.format("hsl(%d, %d%%, %d%%)", h, s, l)
	end
end

-- Format color as OKLCH
local function to_oklch_string(r, g, b, alpha)
	local L, C, h = rgb_to_oklch(r, g, b)
	L = math.floor(L * 100 + 0.5) / 100
	C = math.floor(C * 1000 + 0.5) / 1000
	h = math.floor(h + 0.5)

	if alpha then
		return string.format("oklch(%.2f %g %d / %g)", L, C, h, alpha)
	else
		return string.format("oklch(%.2f %g %d)", L, C, h)
	end
end

-- Format color as hex
local function to_hex_string(r, g, b)
	local function clamp(v)
		return math.max(0, math.min(1, v))
	end

	r = math.floor(clamp(r) * 255 + 0.5)
	g = math.floor(clamp(g) * 255 + 0.5)
	b = math.floor(clamp(b) * 255 + 0.5)

	return string.format("#%02x%02x%02x", r, g, b)
end

-- Main conversion function
function M.convert_color()
	local color, start_pos, end_pos = get_color_under_cursor()

	if not color then
		-- Not a color, exit silently
		return
	end

	local r, g, b, alpha
	local new_color

	-- Check if it's OKLCH
	local L, C, h, a = parse_oklch(color)
	if L then
		-- OKLCH -> Hex
		r, g, b = oklch_to_rgb(L, C, h)
		new_color = to_hex_string(r, g, b)
	else
		-- Check if it's HSL
		local h_hsl, s, l, a_hsl = parse_hsl(color)
		if h_hsl then
			-- HSL -> OKLCH
			r, g, b = hsl_to_rgb(h_hsl, s, l)
			new_color = to_oklch_string(r, g, b, a_hsl)
		else
			-- Check if it's hex
			if color:match("^#%x+$") then
				r, g, b = hex_to_rgb(color)
				new_color = to_hsl_string(r, g, b)
			else
				-- Check if it's rgb/rgba
				r, g, b, alpha = parse_rgb(color)
				if r then
					new_color = to_hsl_string(r, g, b, alpha)
				else
					-- Unknown format, exit silently
					return
				end
			end
		end
	end

	-- Replace the color in the line
	local line = vim.api.nvim_get_current_line()
	local new_line = line:sub(1, start_pos - 1) .. new_color .. line:sub(end_pos + 1)
	vim.api.nvim_set_current_line(new_line)

	-- Adjust cursor position to stay within the new color string
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_win_set_cursor(0, { cursor_row, start_pos - 1 })
end

-- Setup function to create command and keybinding
-- function M.setup(opts)
-- 	opts = opts or {}

-- 	-- Create user command
-- 	vim.api.nvim_create_user_command("ConvertColor", M.convert_color, {})

-- 	-- Create default keybinding if specified
-- 	if opts.keybind then
-- 		vim.keymap.set("n", opts.keybind, M.convert_color, {
-- 			desc = "Convert color format under cursor",
-- 			silent = true,
-- 		})
-- 	end
-- end

return M
