--- md-glow.yazi - Markdown previewer powered by glow.
---
--- This implementation intentionally sticks to APIs available across Yazi 26.x:
--- Command:arg(), ya.preview_widget(), ya.preview_code(), and ya.emit().
--- It avoids newer cache/preload file APIs so the plugin works on 26.1+.

local M = {}

local PLUGIN = "md-glow"
local MIN_WIDTH = 20
local DEFAULT_WIDTH = 80
local SCROLL_SPEED = 5

local function plugin_style()
	local override = os.getenv("YAZI_MARKDOWN_VIEWER_STYLE")
	if override and override ~= "" then
		return override
	end

	return (os.getenv("HOME") or "") .. "/.config/yazi/plugins/" .. PLUGIN .. ".yazi/assets/vscode.json"
end

local function file_path(file)
	if file.path then
		return tostring(file.path)
	end

	return tostring(file.url)
end

local function preview_text(job, text)
	local widget = ui.Text.parse(text):area(job.area)

	if ya.preview_widget then
		return ya.preview_widget(job, widget)
	end

	return ya.preview_widgets(job, { widget })
end

local function fallback(job)
	if ya.preview_code then
		return ya.preview_code({
			area = job.area,
			file = job.file,
			mime = "text/plain",
			skip = job.skip,
		})
	end

	local ok, code = pcall(require, "code")
	if ok and type(code.peek) == "function" then
		local called, result = pcall(function()
			return code:peek(job)
		end)
		if called then
			return result
		end

		called, result = pcall(function()
			return code.peek(job)
		end)
		if called then
			return result
		end
	end

	return preview_text(job, "Markdown preview failed: unable to run glow.\n")
end

local function emit_peek(job, skip, upper_bound)
	local payload = {
		math.max(0, skip),
		only_if = job.file.url,
		upper_bound = upper_bound or nil,
	}

	if ya.emit then
		return ya.emit("peek", payload)
	end

	return ya.mgr_emit("peek", payload)
end

local function preview_width(job)
	local width = job.area and job.area.w or DEFAULT_WIDTH
	if width < MIN_WIDTH then
		return DEFAULT_WIDTH
	end

	return width
end

local function spawn_glow(job)
	return Command("glow")
		:arg({
			"--style",
			plugin_style(),
			"--width",
			tostring(preview_width(job)),
			"--",
			file_path(job.file),
		})
		:env("CLICOLOR_FORCE", "1")
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()
end

function M:peek(job)
	local child = spawn_glow(job)
	if not child then
		return fallback(job)
	end

	local limit = math.max(1, job.area.h)
	local seen, lines = 0, {}

	repeat
		local line, event = child:read_line()
		if event == 1 then
			child:start_kill()
			return fallback(job)
		elseif event ~= 0 then
			break
		end

		seen = seen + 1
		if seen > job.skip then
			lines[#lines + 1] = line
		end
	until seen >= job.skip + limit

	child:start_kill()

	if job.skip > 0 and seen < job.skip + limit then
		return emit_peek(job, seen - limit, true)
	end

	local rendered = table.concat(lines):gsub("\t", string.rep(" ", rt.preview.tab_size))
	return preview_text(job, rendered)
end

-- Keep preloader rules harmless on all Yazi 26.x versions. Rendering happens in peek().
function M:preload(_)
	return true
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end

	return emit_peek(job, cx.active.preview.skip + job.units * SCROLL_SPEED)
end

return M
