local M = {}

function M.setup(options)
  require('what-key.colors').setup()
  require('what-key.mappings').get_or_create_full_mapping()
end

return M
