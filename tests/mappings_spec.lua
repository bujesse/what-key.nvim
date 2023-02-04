vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('AutoTest', { clear = true }),
  pattern = 'mappings.lua',
  callback = function()
    require('neotest').run.run('tests/mappings_spec.lua')
  end,
})

local function find_map(maps, lhs)
  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return map
    end
  end
end

local assert = require('luassert')

describe('mappings', function()
  local module = require('what-key.mappings')

  describe('get_next_key', function()
    it('returns first single characters', function()
      assert.are.equal('g', module.get_next_key('ga'))
    end)

    it('returns tags', function()
      assert.are.equal('<C-a>', module.get_next_key('<C-a>'))
    end)

    it('returns multiple tags', function()
      assert.are.equal('<C-W>', module.get_next_key('<C-W><C-J>'))
    end)
  end)

  describe('create_mapping', function()
    local test_key = '<C-J>'

    before_each(function()
      vim.cmd('silent! unmap ' .. test_key)
    end)

    it('updates state of user_mappings', function()
      vim.keymap.set('n', test_key, '<nop>')
      local user_mappings = module.create_mapping('n')
      assert.is_not_nil(user_mappings[test_key])
      assert.are.equal('user', user_mappings[test_key].mapped_by)
    end)

    it('updates state by mode', function()
      vim.keymap.set('n', test_key, '<nop>')
      local user_mappings = module.create_mapping('v')
      assert.is_nil(user_mappings[test_key])
    end)
  end)

  describe('split_keymap', function()
    it('splits mappings', function()
      assert.are.same({ 'g', 's' }, module.split_keymap('gs'))
    end)

    it('splits angle bracket mappings', function()
      assert.are.same({ '<C-W>', '<C-J>', '<C-W>' }, module.split_keymap('<C-W><C-J><C-W>'))
    end)

    it('returns empty table for empty string', function()
      assert.are.same({}, module.split_keymap(''))
    end)

    it('handles spaces', function()
      assert.are.same({ ' ', 'a' }, module.split_keymap(' a'))
      assert.are.same({ ' ', ' ' }, module.split_keymap('  '))
    end)

    it('handles special', function()
      assert.are.same({ '%' }, module.split_keymap('%'))
      assert.are.same({ '[' }, module.split_keymap('['))
      assert.are.same({ '-' }, module.split_keymap('-'))
    end)
  end)

  describe('get_nested_mapping', function()
    it('gets nested map', function()
      local test_map = {
        g = {
          mappings = {
            s = {
              target_reached = true,
              mappings = {},
            },
          },
        },
      }

      local keys = { 'g', 's' }
      assert.is_true(module.get_nested_mapping(test_map, keys).target_reached)
    end)

    it('handles none', function()
      local test_map = {
        target_reached = true,
        g = {
          mappings = {
            s = {
              mappings = {},
            },
          },
        },
      }

      local keys = {}
      assert.is_true(module.get_nested_mapping(test_map, keys).target_reached)
    end)

    it('handles single', function()
      local test_map = {
        g = {
          target_reached = true,
          mappings = {
            s = {
              mappings = {},
            },
          },
        },
      }

      local keys = { 'g' }
      assert.is_true(module.get_nested_mapping(test_map, keys).target_reached)
    end)

    it('handles initializing new key', function()
      local test_map = {
        g = {
          mappings = {
            foo = {
              mappings = {},
            },
          },
        },
      }

      local keys = { 'g', 's' }
      local expected = require('what-key.possible_keys').init_key('user')
      local actual = module.get_nested_mapping(test_map, keys)
      assert.are.same(expected, actual)
    end)
  end)

  describe('get_mapping_for_prefix', function()
    it('works with single prefix', function()
      vim.keymap.set('n', 'g', 'foo')
      local mapping = module.create_mapping('n')
      local result = module.get_mapping_for_prefix(mapping, 'g')

      assert.are.same('foo', result.rhs)
    end)

    it('works with multiple prefix', function()
      vim.keymap.set('n', 'gsa', 'foo')
      local mapping = module.create_mapping('n')
      local result = module.get_mapping_for_prefix(mapping, 'gsa')

      assert.are.same('foo', result.rhs)
    end)

    it('works with middle prefix', function()
      vim.keymap.set('n', 'gsa', 'foo')
      local mapping = module.create_mapping('n')
      local result = module.get_mapping_for_prefix(mapping, 'gs')

      assert.is_nil(result.rhs)
    end)
  end)
end)
