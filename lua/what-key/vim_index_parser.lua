

local function file_exists(file)
  local f = io.open(file, 'rb')
  if f then
    f:close()
  end
  return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local function lines_from(file)
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

local function parse_vim_index(file)
  local lines = lines_from(file)
  local result = vim.defaulttable()
  for _, v in pairs(lines) do
    local inside_bar = string.match(v, '^|.*|')
    if inside_bar == nil then
      goto continue
    end

    inside_bar = string.gsub(inside_bar, '|', '')
    local help_str = inside_bar
    -- print(help_str)

    local mode = string.match(inside_bar, '%a_')
    if mode ~= nil then
      mode = string.sub(mode, 1, 1)
    else
      mode = 'n'
    end
    -- print(mode)

    local first_t = string.find(v, '%s')
    local keys = vim.trim(v:sub(first_t, #v))
    -- local word_finder = vim.regex([[  \|\t\|\(\}\)\s]])
    local word_finder = vim.regex([[  \|\t\|\(\}\)\s\|$]])
    local found = word_finder:match_str(keys)
    local desc = vim.trim(keys:sub(found + 2, #v))
    -- print(desc)

    keys = keys:sub(1, found + 1)
    if string.match(keys, 'CTRL%-SHIFT') then
      -- Don't support CTRL-SHIFT for now
      keys = keys:gsub('%-SHIFT', '')
    end

    if string.match(keys, 'CTRL') then
      keys = keys:gsub('CTRL', '<C')
      keys = keys:gsub('([%-][^<])', '%1>')
      keys = keys:gsub('-<(%u[%l]*)>', '-%1>') -- Handle <C-Tab> or <C-Space> etc
    end
    keys = keys:gsub('%s', '')
    -- print(keys)

    table.insert(result[mode], {
      lhs = keys,
      help_str = help_str,
      desc = desc,
    })

    ::continue::
  end

  return result
end

local function parse_vim_index_to_json()
  local in_file = 'vim_index.txt'
  if not file_exists(in_file) then
    error(in_file .. ' not found')
    return
  end

  local out_file = 'vim_index.json'
  if not file_exists(out_file) then
    error(out_file .. ' not found')
    return
  end

  local vim_index = parse_vim_index(in_file)
  local json_vim_index = vim.json.encode(vim_index)

  local out_file_io = io.open(out_file, 'w')
  out_file_io:write(json_vim_index)
  out_file_io:close()
end


parse_vim_index_to_json()
