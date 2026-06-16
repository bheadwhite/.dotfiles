-- taskloop.nvim — editor front-end for the TASK-LOOP v2 daemon.
-- You never type `###` or `#NN`: this writes the grammar for you, and tails any
-- dispatched job in a split. Protocol: ~/.claude/TASKLOOP.md.
--   TASKS.md  (you write task blocks; daemon stamps the [#NN] id)
--   STATUS.md (daemon renders; you read)
--   REVIEW.md (you write verdicts `#NN gg | <note> | ?q`)
local M = {}
local uv = vim.uv or vim.loop

-- claude_dir: where the daemon + helper scripts are symlinked (default $CLAUDE_DIR,
-- else ~/.claude). Override via setup({ claude_dir = "…" }) to adopt the loop on a
-- machine that keeps the agent config elsewhere.
local cfg = {
  prefix = "<C-A-",                                            -- chord prefix
  tail = "split",                                              -- "split" | "float"
  claude_dir = vim.env.CLAUDE_DIR or (vim.fn.expand("~/.claude")),
}

-- Absolute path to a symlinked helper script under the configured claude_dir.
local function claude_helper(name) return cfg.claude_dir .. "/" .. name end

-- ---- locate the repo / board ----------------------------------------------
local function root()
  local found = vim.fs.find("TASKS.md", { upward = true, path = vim.fn.expand("%:p:h") })[1]
  if found then return vim.fs.dirname(found) end
  local git = vim.fs.find(".git", { upward = true, path = vim.fn.expand("%:p:h") })[1]
  return git and vim.fs.dirname(git) or vim.fn.getcwd()
end
local function p(rel) return root() .. "/" .. rel end

local function append(file, text)
  local fd = io.open(file, "a")
  if not fd then vim.notify("taskloop: cannot write " .. file, vim.log.levels.ERROR); return end
  fd:write(text); fd:close()
end

local function read_lines(file)
  local fd = io.open(file, "r"); if not fd then return {} end
  local out = {}; for l in fd:lines() do out[#out + 1] = l end; fd:close(); return out
end

-- ---- clipboard image -> file ----------------------------------------------
-- Unique asset basename. os.time() alone collides for pastes within the same
-- second (the 2nd would overwrite the 1st), so append a monotonic counter.
local img_seq = 0
local function unique_name(prefix)
  img_seq = img_seq + 1
  return prefix .. "-" .. os.time() .. "-" .. img_seq
end

-- Pull the *bytes* of the clipboard image onto disk via the clip2png helper.
-- Returns the repo-relative path under .task-assets/, or nil if no image bytes.
local function save_clip_image(name)
  vim.fn.mkdir(p(".task-assets"), "p")
  local rel = ".task-assets/" .. name .. ".png"
  local helper = claude_helper("taskloop-clip2png.sh")
  vim.fn.system({ "bash", helper, p(rel) })
  if vim.v.shell_error ~= 0 or vim.fn.filereadable(p(rel)) == 0 then return nil end
  return rel
end

-- Many screenshot tools (CleanShot) and Finder "Copy" put a *path or file:// URL*
-- on the clipboard as text rather than image bytes. If the clipboard text points
-- at a readable image file, return that absolute path; otherwise nil.
local function clipboard_image_path(clip)
  if not clip or clip == "" then return nil end
  local s = clip:gsub("^%s+", ""):gsub("%s+$", "")
  s = s:gsub("^['\"]", ""):gsub("['\"]$", "")            -- strip one layer of quotes
  s = s:gsub("^file://", ""):gsub("%%20", " ")           -- de-URL a file:// path
  if not s:lower():match("%.png$") and not s:lower():match("%.jpe?g$")
     and not s:lower():match("%.gif$") and not s:lower():match("%.webp$") then
    return nil
  end
  return vim.fn.filereadable(s) == 1 and s or nil
end

-- Copy an on-disk image into .task-assets/, preserving its extension.
-- Returns the repo-relative path, or nil on failure.
local function copy_into_assets(src, name)
  vim.fn.mkdir(p(".task-assets"), "p")
  local ext = (src:match("%.([%w]+)$") or "png"):lower()
  local rel = ".task-assets/" .. name .. "." .. ext
  vim.fn.system({ "cp", src, p(rel) })
  if vim.v.shell_error ~= 0 or vim.fn.filereadable(p(rel)) == 0 then return nil end
  return rel
end

-- Resolve a clipboard screenshot to a file under .task-assets/ by either route:
-- a path/URL pointing at an image file (copied in), or raw image bytes (extracted).
-- Returns the repo-relative path, or nil if the clipboard holds no image at all.
local function grab_clipboard_image(name)
  local src = clipboard_image_path(vim.fn.getreg("+"))
  if src then
    local rel = copy_into_assets(src, name)
    if rel then return rel end
  end
  return save_clip_image(name)
end

-- Insert text at the cursor in the current buffer (works in normal & insert mode).
local function put_at_cursor(text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { text })
  vim.api.nvim_win_set_cursor(0, { row, col + #text })
end

-- ---- image placeholders ----------------------------------------------------
-- Inside a composer buffer, an attached image shows as a tidy `[image #N]` token
-- (like the Claude input box) while its real path is held aside; on :w the token
-- expands to `[img: <rel>]` so the worker can still open it. `buf_images[buf]` is
-- the per-buffer list of saved paths, indexed by N.
local buf_images = {}

local function add_image(buf, rel)
  local list = buf_images[buf] or {}
  list[#list + 1] = rel
  buf_images[buf] = list
  return #list
end

-- Replace every `[image #N]` in `lines` with its `[img: <rel>]` reference.
local function expand_images(buf, lines)
  local list = buf_images[buf] or {}
  for i, l in ipairs(lines) do
    lines[i] = l:gsub("%[image #(%d+)%]", function(n)
      local rel = list[tonumber(n)]
      return rel and ("[img: " .. rel .. "]") or nil   -- leave unknown tokens as-is
    end)
  end
  return lines
end

-- Mark a buffer as a composer so attachments use the [image #N] placeholder, and
-- forget its image list when it goes away.
local function mark_composer(buf)
  vim.b[buf].taskloop_composer = true
  vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
    buffer = buf, callback = function() buf_images[buf] = nil end,
  })
end

-- Drop a reference to a just-saved image at the cursor: a `[image #N]` placeholder
-- in a composer, or the concrete `[img: <rel>]` anywhere else (no expansion there).
local function insert_attachment(rel)
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].taskloop_composer then
    local n = add_image(buf, rel)
    put_at_cursor("[image #" .. n .. "]")
    vim.notify("taskloop: 🖼 attached as [image #" .. n .. "]")
  else
    put_at_cursor("[img: " .. rel .. "]")
    vim.notify("taskloop: 🖼 attached " .. rel)
  end
end

-- Buffer-local <prefix>p in a composer scratch buffer: grab the clipboard image
-- onto disk and drop a placeholder at the cursor.
local function enable_image_paste(buf, name_prefix)
  vim.keymap.set({ "n", "i" }, cfg.prefix .. "p>", function()
    local rel = grab_clipboard_image(unique_name(name_prefix))
    if not rel then
      vim.notify("taskloop: no image on the clipboard", vim.log.levels.WARN); return
    end
    insert_attachment(rel)
  end, { buffer = buf, desc = "taskloop: attach clipboard image at cursor" })
end

-- ---- find the id of the task under the cursor (or via prompt) --------------
-- Looks upward from the cursor for a `### ... [#NN]` heading in the current buffer.
local function id_under_cursor()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  for i = row, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ""
    local id = line:match("###.*%[#(%d+)%]")
    if id then return id end
    local sid = line:match("^#(%d+)%s")          -- a STATUS.md `### #NN` or REVIEW line
    if sid then return sid end
    local hid = line:match("«.-».-#(%d+)") or line:match("#(%d+)%s*«")
    if hid then return hid end
  end
  return nil
end

local function need_id(cb)
  local id = id_under_cursor()
  if id then cb(id); return end
  vim.ui.input({ prompt = "task id (#): " }, function(v)
    if v and v:match("%d+") then cb(v:match("(%d+)")) end
  end)
end

-- Resolve a task's title by id from STATUS.md (`#NN «title»`), falling back to
-- the TASKS.md `### title [#NN]` heading. Used to label the feedback composer so
-- it's unmistakable which task a note targets. Returns nil if not found.
local function title_for_id(id)
  for _, l in ipairs(read_lines(p("STATUS.md"))) do
    local i, t = l:match("#(%d+)%s+«(.-)»")
    if not i then i, t = l:match("#(%d+).-«(.-)»") end
    if i == id and t and t ~= "" then return t end
  end
  for _, l in ipairs(read_lines(p("TASKS.md"))) do
    local h, i = l:match("^###%s+(.-)%s*%[#(%d+)%]")
    if i == id and h and h ~= "" then return (h:gsub("%s+$", "")) end
  end
  return nil
end

-- ---- new task --------------------------------------------------------------
-- Scratch buffer: line 1 = title (you may add {issue}/{mr}); rest = body. :w appends.
function M.new_task()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "", "", "# ^ line 1 = title (+ optional {issue}/{mr}); below = body. "
      .. "Cmd+V attaches a screenshot. :w to queue, :q to cancel.",
  })
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].buftype = "acwrite"
  vim.api.nvim_buf_set_name(buf, "taskloop://new-" .. os.time())
  mark_composer(buf)
  enable_image_paste(buf, "new")
  vim.cmd("botright split"); vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_height(0, 8); vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.cmd("startinsert")
  vim.api.nvim_create_autocmd("BufWriteCmd", { buffer = buf, callback = function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local body = {}
    for _, l in ipairs(lines) do
      if not l:match("^# %^ line 1") then body[#body + 1] = l end
    end
    -- Title is line 1 and must be text — an image pasted there would otherwise
    -- become the task title. Lift any image placeholder off the title line and
    -- push it into the body so the screenshot is kept, not lost.
    if body[1] then
      local moved = {}
      body[1] = body[1]:gsub("%[image #%d+%]", function(m) moved[#moved + 1] = m; return "" end)
      body[1] = body[1]:gsub("^%s+", ""):gsub("%s+$", "")
      for i = #moved, 1, -1 do table.insert(body, 2, moved[i]) end
    end
    expand_images(buf, body)
    while #body > 0 and body[#body] == "" do body[#body] = nil end
    local title = (body[1] or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if title == "" then
      vim.notify("taskloop: line 1 must be a text title — type one above the image",
        vim.log.levels.WARN); return
    end
    local block = "\n### " .. title .. "\n" .. table.concat({ unpack(body, 2) }, "\n") .. "\n"
    append(p("TASKS.md"), block)
    vim.bo[buf].modified = false
    vim.notify("taskloop: queued «" .. title .. "» (id stamps in a moment)")
    vim.cmd("close")
  end })
end

-- ---- feedback / accept (write verdicts to REVIEW.md) -----------------------
-- Multi-line note composer: a scratch split; :w submits the typed lines, :q cancels.
-- `header` describes what the note targets (e.g. "rework #12 «Fix the modal»").
-- It's shown three ways so you can't mistake which task you're writing about: a
-- winbar banner, a leading in-buffer line, and the buffer name.
local function compose(header, on_done, img_prefix)
  local target = "# ✍ " .. header
  local hint = "# type your note (multi-line ok) · Cmd+V attaches a screenshot · :w submit · :q cancel"
  local strip = { [target] = true, [hint] = true }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "", target, hint })
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].buftype = "acwrite"
  vim.api.nvim_buf_set_name(buf, "taskloop://" .. (img_prefix or "note") .. "-" .. os.time())
  mark_composer(buf)
  enable_image_paste(buf, img_prefix or "note")
  vim.cmd("botright split"); vim.api.nvim_win_set_buf(0, buf); vim.api.nvim_win_set_height(0, 10)
  vim.wo.winbar = "%#Title#  ✍ " .. header:gsub("%%", "%%%%") .. "  %*"
  vim.api.nvim_win_set_cursor(0, { 1, 0 }); vim.cmd("startinsert")
  vim.api.nvim_create_autocmd("BufWriteCmd", { buffer = buf, callback = function()
    local body = {}
    for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      if not strip[l] then body[#body + 1] = l end
    end
    while #body > 0 and body[#body]:match("^%s*$") do body[#body] = nil end
    while #body > 0 and body[1]:match("^%s*$") do table.remove(body, 1) end
    vim.bo[buf].modified = false
    if #body == 0 then vim.notify("taskloop: empty note", vim.log.levels.WARN); vim.cmd("close"); return end
    expand_images(buf, body)
    on_done(body)
    vim.cmd("close")
  end })
end

function M.feedback()
  need_id(function(id)
    local title = title_for_id(id)
    local header = "rework #" .. id .. (title and (" «" .. title .. "»") or "")
    compose(header, function(body)
      if #body == 1 then
        append(p("REVIEW.md"), "#" .. id .. " " .. body[1] .. "\n")
      else
        append(p("REVIEW.md"), "#" .. id .. " <<\n" .. table.concat(body, "\n") .. "\n>>\n")
      end
      vim.notify(("taskloop: rework queued for #%s (%d line%s)"):format(id, #body, #body > 1 and "s" or ""))
    end, "T" .. id)
  end)
end

-- ---- image feedback: paste a clipboard screenshot as a rework note ---------
-- Saves the clipboard image to .task-assets/T<id>-<ts>.png and writes a REVIEW
-- verdict referencing it; the worker opens the image when it reworks the task.
local function attach_image(id)
  local rel = save_clip_image(unique_name("T" .. id))
  if not rel then
    vim.notify("taskloop: no image on the clipboard", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "#" .. id .. " note with image (optional): " }, function(note)
    note = (note or ""):gsub("%s+$", "")
    local line = "#" .. id .. " " .. (note ~= "" and (note .. " ") or "") .. "[img: " .. rel .. "]"
    append(p("REVIEW.md"), line .. "\n")
    vim.notify("taskloop: 🖼 image feedback queued for #" .. id)
  end)
end

function M.image_feedback()
  need_id(attach_image)
end
M._attach_image = attach_image

-- ---- smart paste (Cmd+V) ---------------------------------------------------
-- wezterm sends Cmd+V here as <C-F16> whenever nvim is the foreground process.
-- Text on the clipboard pastes exactly as a normal paste would; a screenshot
-- (a path to an image file, or raw image bytes) is saved to .task-assets/ and
-- dropped at the cursor as a tidy [image #N] placeholder in a composer — the one
-- thing terminal paste can never do for you.
function M.smart_paste()
  local clip = vim.fn.getreg("+")
  -- A clipboard path/URL pointing at an image file (CleanShot, Finder) is an
  -- image, not text — attach it rather than pasting the path string.
  local src = clipboard_image_path(clip)
  if src then
    local rel = copy_into_assets(src, unique_name("paste"))
    if rel then insert_attachment(rel); return end
  end
  -- Otherwise real text → ordinary paste.
  if clip ~= "" then
    vim.api.nvim_paste(clip, true, -1)
    return
  end
  -- Empty text register → maybe raw image bytes on the clipboard.
  local rel = save_clip_image(unique_name("paste"))
  if rel then
    insert_attachment(rel)
  else
    vim.notify("taskloop: clipboard is empty", vim.log.levels.WARN)
  end
end

function M.accept()
  need_id(function(id)
    append(p("REVIEW.md"), "#" .. id .. " gg\n")
    -- user-side: also remove the block from TASKS.md so it stops cluttering your list
    local file = p("TASKS.md"); local lines = read_lines(file)
    local out, skipping = {}, false
    for _, l in ipairs(lines) do
      if l:match("^###.*%[#" .. id .. "%]") then skipping = true
      elseif skipping and l:match("^### ") then skipping = false end
      if not skipping then out[#out + 1] = l end
    end
    local fd = io.open(file, "w"); if fd then fd:write(table.concat(out, "\n")); fd:close() end
    vim.notify("taskloop: accepted #" .. id .. " ✓")
  end)
end

-- ---- tail a dispatched job's log -------------------------------------------
-- stream-json log rendered readable by a tiny python filter, in a split/float.
local RENDER = table.concat({
  "import sys,json",
  "for ln in sys.stdin:",
  "  ln=ln.strip()",
  "  if not ln: continue",
  "  try: o=json.loads(ln)",
  "  except Exception: print(ln); sys.stdout.flush(); continue",
  "  t=o.get('type')",
  "  if t=='assistant':",
  "    for b in o.get('message',{}).get('content',[]):",
  "      if b.get('type')=='text' and b.get('text','').strip(): print(b['text'])",
  "      elif b.get('type')=='tool_use': print('  \\u2192 '+b.get('name','tool')+' '+json.dumps(b.get('input',{}))[:120])",
  "  elif t=='result': print('\\u2713 '+str(o.get('subtype',''))+' '+(o.get('result','') or '')[:200])",
  "  sys.stdout.flush()",
}, "\n")

function M.tail()
  need_id(function(id)
    local log = p(".taskloop/T" .. id .. ".log")
    if vim.fn.filereadable(log) == 0 then
      vim.notify("taskloop: no log yet for #" .. id .. " (not dispatched?)", vim.log.levels.WARN); return
    end
    if cfg.tail == "float" then
      local w, h = math.floor(vim.o.columns * 0.6), math.floor(vim.o.lines * 0.6)
      local b = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_open_win(b, true, { relative = "editor", width = w, height = h,
        row = math.floor((vim.o.lines - h) / 2), col = math.floor((vim.o.columns - w) / 2),
        border = "rounded", title = " tail #" .. id .. " " })
    else
      -- `vnew`, not `vsplit`: the terminal gets its own empty buffer (a plain split
      -- would termopen over the buffer you came from, e.g. STATUS.md, and show the
      -- terminal in both windows). Vertical so the log tails beside STATUS.md.
      vim.cmd("botright vnew")
      vim.api.nvim_win_set_width(0, math.max(80, math.floor(vim.o.columns * 0.4)))
    end
    vim.bo.bufhidden = "wipe"
    local cmd = string.format("tail -n +1 -F %s | python3 -c %s",
      vim.fn.shellescape(log), vim.fn.shellescape(RENDER))
    vim.fn.termopen({ "bash", "-lc", cmd })
    vim.cmd("normal! G")
  end)
end

-- ---- cancel / restart a running worker -------------------------------------
-- A thrashing worker can outlive a slow or dead daemon, so we don't only ask
-- nicely. To stop one we: (1) make sure the daemon is up, (2) SIGKILL the worker's
-- process group directly from its lock file for an immediate stop, and (3) drop
-- `.cancel` so the daemon parks the task and frees the slot cleanly on its tick.
-- Restart layers a re-queue on top: a fresh REVIEW note resumes the parked task,
-- so the daemon re-dispatches it with full thread context.

local function request_cancel(tid)
  local fd = io.open(p(".taskloop/.cancel"), "w")
  if not fd then vim.notify("taskloop: couldn't write .cancel", vim.log.levels.ERROR); return false end
  fd:write(tid or ""); fd:close(); return true
end

-- Ensure the daemon is running for this repo (idempotent — restarts a dead one).
local function ensure_daemon()
  local helper = claude_helper("taskloop-ensure.sh")
  if vim.fn.filereadable(helper) == 1 then vim.fn.system({ "bash", helper, root() }) end
end

-- Live worker PID for a task, from its lock file (`.taskloop/workers/T<id>` = "tid pid start").
local function worker_pid(tid)
  local line = read_lines(p(".taskloop/workers/T" .. tid))[1]
  return line and tonumber(line:match("^%S+%s+(%d+)")) or nil
end

-- Stop a worker now: kill its process group (workers use start_new_session, so
-- pgid == pid and the leader's group is its own — never the daemon's), then flag
-- `.cancel` so the daemon parks the task and clears the lock. Returns true if a
-- live worker PID was found and signalled.
local function stop_worker(tid)
  ensure_daemon()
  local pid = worker_pid(tid)
  if pid then
    -- negative pid = whole process group; bare pid as a fallback for the leader.
    vim.fn.system(("kill -KILL -%d 2>/dev/null; kill -KILL %d 2>/dev/null"):format(pid, pid))
  end
  request_cancel(tid)
  return pid ~= nil
end

-- Kill the worker for the task under the cursor and park it. The freed slot lets
-- queued/head-of-line-blocked tasks proceed. (No id under cursor → prompts.)
function M.cancel()
  need_id(function(id)
    local killed = stop_worker(id)
    vim.notify(("taskloop: ✖ #%s %s — task parked, slot freed for queued tasks. "
      .. "hyper+r restarts it, or add a REVIEW note to resume."):format(
        id, killed and "worker killed" or "no live worker (flagged anyway)"))
  end)
end

-- Kill the worker for the task under the cursor AND re-queue it. Use when a task
-- is *thrashing* — spinning without converging toward the timeout.
local restart_seq = 0
function M.restart()
  need_id(function(id)
    local killed = stop_worker(id)
    vim.ui.input({ prompt = "#" .. id .. " restart note (optional): " }, function(note)
      note = (note or ""):gsub("^%s+", ""):gsub("%s+$", "")
      if note == "" then
        note = "restart — previous attempt failed/stalled; start fresh with the simplest approach"
      end
      -- The daemon fires each note-hash ONCE, so an identical (default) note on a
      -- repeat restart is deduped → "nothing happens". Stamp every restart unique.
      restart_seq = restart_seq + 1
      note = note .. " (restart " .. os.date("%H:%M:%S") .. "." .. restart_seq .. ")"
      append(p("REVIEW.md"), "#" .. id .. " " .. note .. "\n")
      vim.notify(("taskloop: ↻ restarting #%s (%s + re-queued)"):format(
        id, killed and "worker killed" or "flagged"))
    end)
  end)
end

-- ---- prune consumed verdicts from REVIEW.md --------------------------------
function M.prune()
  local helper = claude_helper("taskloop-prune.py")
  local out = vim.fn.system({ "python3", helper, root() })
  local n = tonumber(out:match("pruned (%d+)")) or 0
  -- reload REVIEW.md if it's open in a buffer
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(b):match("REVIEW%.md$") then
      vim.api.nvim_buf_call(b, function() vim.cmd("silent! checktime") end)
    end
  end
  vim.notify(n > 0 and ("taskloop: pruned " .. n .. " consumed verdict line(s)")
                    or "taskloop: nothing to prune", vim.log.levels.INFO)
end

-- ---- status view + picker --------------------------------------------------
-- Make a STATUS buffer non-editable AND live: poll `checktime` ~1s so it reloads
-- as the daemon rewrites it, without you touching it. A timer beats fs_event here
-- because the daemon writes via tmp+rename, which inode-based watchers miss.
local function make_status_live(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].taskloop_live then return end
  vim.b[buf].taskloop_live = true
  vim.bo[buf].autoread = true
  vim.bo[buf].readonly = true       -- you CAN'T edit it
  vim.bo[buf].modifiable = false    -- and edits are hard-blocked, not just warned
  local timer = uv.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(function()
    if not (vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)) then
      timer:stop(); if not timer:is_closing() then timer:close() end; return
    end
    vim.cmd("silent! checktime " .. buf)
  end))
  vim.api.nvim_create_autocmd({ "BufWipeout", "BufUnload" }, { buffer = buf, callback = function()
    if not timer:is_closing() then timer:stop(); timer:close() end
  end })
end

function M.status()
  vim.cmd("botright vsplit " .. vim.fn.fnameescape(p("STATUS.md")))
  make_status_live(vim.api.nvim_get_current_buf())
end

function M.picker()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then return M.status() end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  -- parse STATUS.md into entries: {id, status, title}
  local entries, cur = {}, nil
  for _, l in ipairs(read_lines(p("STATUS.md"))) do
    local emoji = l:match("^## (.+)")
    if emoji then cur = emoji end
    local id, title = l:match("#(%d+)%s+«(.-)»")
    if not id then id, title = l:match("#(%d+).-«(.-)»") end
    if id then entries[#entries + 1] = { id = id, title = title or "", group = cur or "" } end
  end
  pickers.new({}, {
    prompt_title = "Task Loop",
    finder = finders.new_table({ results = entries, entry_maker = function(e)
      return { value = e, display = ("#%-3s %s  %s"):format(e.id, e.group:sub(1, 12), e.title),
               ordinal = e.id .. " " .. e.title }
    end }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnr, map)
      local function id_of() return state.get_selected_entry().value.id end
      actions.select_default:replace(function() actions.close(bufnr); M._tail_id(id_of()) end)
      map({ "i", "n" }, "<C-f>", function() actions.close(bufnr)
        vim.ui.input({ prompt = "rework note: " }, function(note)
          if note and note ~= "" then append(p("REVIEW.md"), "#" .. id_of() .. " " .. note .. "\n") end
        end) end)
      map({ "i", "n" }, "<C-a>", function() local id = id_of(); actions.close(bufnr)
        append(p("REVIEW.md"), "#" .. id .. " gg\n"); vim.notify("accepted #" .. id) end)
      map({ "i", "n" }, "<C-p>", function() local id = id_of(); actions.close(bufnr)
        vim.schedule(function() M._attach_image(id) end) end)
      return true
    end,
  }):find()
end
function M._tail_id(id)  -- tail by explicit id (from picker)
  vim.schedule(function()
    local log = p(".taskloop/T" .. id .. ".log")
    -- `new` (not `split`) so the terminal opens in its own empty buffer rather
    -- than hijacking the buffer the picker returned you to.
    vim.cmd("botright new"); vim.api.nvim_win_set_height(0, 16)
    vim.bo.bufhidden = "wipe"
    vim.fn.termopen({ "bash", "-lc", string.format("tail -n +1 -F %s | python3 -c %s",
      vim.fn.shellescape(log), vim.fn.shellescape(RENDER)) })
    vim.cmd("normal! G")
  end)
end

-- ---- blocked watcher: notify when a task lands in ⛔ -----------------------
local function start_watch()
  local logf = p(".taskloop/loop.log")
  if vim.fn.filereadable(logf) == 0 then return end
  local last = vim.fn.getfsize(logf)
  local timer = uv.new_timer()
  timer:start(3000, 3000, vim.schedule_wrap(function()
    local sz = vim.fn.getfsize(logf)
    if sz > last then
      local fd = io.open(logf, "r")
      if fd then fd:seek("set", last)
        for l in fd:lines() do
          local ids = l:match("BLOCKED %- needs you: (.+)")
          if ids then vim.notify("Task Loop ⛔ blocked: " .. ids, vim.log.levels.WARN, { title = "taskloop" }) end
        end
        fd:close()
      end
    end
    last = sz
  end))
end

-- ---- setup -----------------------------------------------------------------
function M.setup(opts)
  cfg = vim.tbl_extend("force", cfg, opts or {})
  local pre = cfg.prefix
  local function mapk(suffix, fn, desc)
    vim.keymap.set("n", pre .. suffix .. ">", fn, { desc = "taskloop: " .. desc })
  end
  -- prefix like "<C-A-" so "<C-A-" .. "t" .. ">" => "<C-A-t>"
  mapk("t", M.picker,   "tasks picker")
  mapk("n", M.new_task, "new task")
  mapk("f", M.feedback, "feedback/rework under cursor")
  mapk("p", M.image_feedback, "paste-image feedback under cursor")
  mapk("a", M.accept,   "accept under cursor")
  mapk(",", M.tail,     "tail job under cursor (vsplit)")
  mapk("s", M.status,   "open STATUS.md")
  mapk("u", M.prune,    "prune consumed verdicts from REVIEW.md")
  mapk("c", M.cancel,   "kill worker under cursor (frees slot for queued tasks)")
  mapk("r", M.restart,  "restart task under cursor (kill worker + re-queue)")
  -- Cmd+V: wezterm forwards it as <C-F16> when nvim is foreground (see
  -- wezterm/config/nvim.lua → smart_paste). Normal/insert get the smart paste;
  -- cmdline and terminal fall back to a plain clipboard paste so nothing regresses.
  vim.keymap.set({ "n", "i" }, "<C-F16>", M.smart_paste,
    { desc = "taskloop: smart paste (text, or attach clipboard image)" })
  vim.keymap.set("c", "<C-F16>", "<C-r>+", { desc = "taskloop: paste clipboard at cmdline" })
  vim.keymap.set("t", "<C-F16>", function()
    local job = vim.b.terminal_job_id
    if job then vim.fn.chansend(job, vim.fn.getreg("+")) end
  end, { desc = "taskloop: paste clipboard into terminal" })
  vim.api.nvim_create_user_command("Tasks", M.picker, {})
  vim.api.nvim_create_user_command("TaskNew", M.new_task, {})
  vim.api.nvim_create_user_command("TaskPrune", M.prune, {})
  vim.api.nvim_create_user_command("TaskCancel", M.cancel, {})
  vim.api.nvim_create_user_command("TaskRestart", M.restart, {})
  -- Make the daemon-owned STATUS.md non-editable however it's opened (not just via
  -- hyper+s) — but only the one that sits next to a TASKS.md (the task-loop board),
  -- so unrelated files named STATUS.md elsewhere aren't affected.
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
    pattern = "STATUS.md",
    callback = function(ev)
      local name = vim.api.nvim_buf_get_name(ev.buf)
      local dir = name ~= "" and vim.fs.dirname(name) or nil
      if dir and vim.fn.filereadable(dir .. "/TASKS.md") == 1 then
        make_status_live(ev.buf)   -- readonly + live auto-refresh
      end
    end,
  })
  pcall(start_watch)
end

return M
