--- mdglow.yazi — glow 기반 Markdown 프리뷰어 (yazi 26.5.6 전용)
--- glow 출력을 한 번만 렌더링해 디스크에 캐시하고, 스크롤 시엔 캐시를 읽어
--- 파싱·스크롤만 수행한다. preload로 커서 주변 파일을 백그라운드에서 미리
--- 렌더링해 첫 표시 지연을 없앤다.

local M = {}

local PLUGIN = "mdglow"

-- preload(투기적 사전 렌더링)로 처리할 최대 파일 크기 (1MiB).
-- 이보다 큰 파일은 hover 시 peek이 on-demand로만 렌더링한다.
local PRELOAD_MAX = 1 << 20

-- VSCode 풍 커스텀 테마 경로. ya pkg는 assets/ 디렉터리만 추가 자산으로 배포한다.
local STYLE = os.getenv("YAZI_MARKDOWN_VIEWER_STYLE")
	or ((os.getenv("HOME") or "") .. "/.config/yazi/plugins/" .. PLUGIN .. ".yazi/assets/vscode.json")

-- skip과 무관한 캐시 경로 (폭을 접미사로 붙여 리사이즈 시 갱신).
-- peek/preload가 동일한 경로를 써야 캐시가 공유된다.
local function cache_url(job)
	local base = ya.file_cache({ file = job.file, skip = 0 })
	if not base then
		return nil
	end
	return Url(tostring(base) .. "-mdglow-" .. job.area.w)
end

-- 캐시 파일 전체를 문자열로 읽는다
local function read_cache(url)
	local fd = fs.access():read(true):open(url)
	if not fd then
		return nil
	end
	local parts = {}
	while true do
		local chunk = fd:read(1 << 20)
		if not chunk then
			ya.drop(fd)
			return nil
		elseif #chunk == 0 then
			break
		end
		parts[#parts + 1] = chunk
	end
	local rendered = table.concat(parts)
	ya.drop(fd)
	return rendered
end

-- glow로 마크다운을 렌더링한 ANSI 문자열을 반환 (실패 시 nil)
local function render(job)
	local output = Command("glow")
		:arg({
			"--style",
			STYLE,
			"--width",
			tostring(job.area.w),
			"--",
			tostring(job.file.path),
		})
		:env("CLICOLOR_FORCE", "1")
		:stdout(Command.PIPED)
		:stderr(Command.NULL)
		:output()

	if not output or not output.status.success or output.stdout == "" then
		return nil
	end
	return (output.stdout:gsub("\t", string.rep(" ", rt.preview.tab_size)))
end

function M:peek(job)
	local cache = cache_url(job)
	if not cache then
		return require("code"):peek(job)
	end

	local rendered
	if fs.cha(cache) then
		rendered = read_cache(cache)
	end
	if not rendered then
		rendered = render(job)
		if not rendered then
			return require("code"):peek(job)
		end
		fs.write(cache, rendered)
	end

	-- 마지막 줄 아래로 스크롤되지 않도록 상한 처리
	local _, total = rendered:gsub("\n", "")
	local max_skip = math.max(0, total - job.area.h + 1)
	if job.skip > max_skip then
		return ya.emit("peek", { max_skip, only_if = job.file.url, upper_bound = true })
	end

	ya.preview_widget(job, ui.Text.parse(rendered):area(job.area):scroll(0, job.skip))
end

-- 백그라운드 워커에서 호출됨. 커서 주변 .md 파일을 미리 렌더링해 캐시에 저장.
-- 사용자가 hover하면 peek은 캐시만 읽으므로 첫 표시가 즉각적이다.
function M:preload(job)
	-- 큰 파일은 투기적으로 미리 렌더링하지 않는다(자원 낭비 방지).
	-- 실제로 hover하면 peek이 그때 on-demand로 처리한다.
	local cha = job.file.cha
	if cha and cha.len > PRELOAD_MAX then
		return true
	end

	local cache = cache_url(job)
	if not cache or fs.cha(cache) then
		return true -- 캐시 불가 파일이거나 이미 캐시됨
	end
	local rendered = render(job)
	if rendered then
		fs.write(cache, rendered)
	end
	return true -- glow 실패는 peek의 code 폴백이 처리
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end
	-- 휠 한 칸당 스크롤할 줄 수 (값을 키우면 더 빨라짐)
	local speed = 5
	ya.emit("peek", {
		math.max(0, cx.active.preview.skip + job.units * speed),
		only_if = job.file.url,
	})
end

return M
