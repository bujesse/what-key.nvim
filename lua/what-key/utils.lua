local M = {}

-- filter(function, table)
-- e.g: filter(is_even, {1,2,3,4}) -> {2,4}
function M.filter_tbl(func, tbl)
  local newtbl = {}
  for k, v in pairs(tbl) do
    if func(k, v) then
      newtbl[k] = v
    end
  end
  return newtbl
end

function M.get_sorted_keys(tbl)
  local sorted_keys = {}
  -- populate the table that holds the keys
  for k in pairs(tbl) do
    table.insert(sorted_keys, k)
  end
  -- sort the keys
  table.sort(sorted_keys)
  return sorted_keys
end

return M
