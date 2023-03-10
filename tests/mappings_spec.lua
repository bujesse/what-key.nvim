local assert = require('luassert')

describe('mappings', function()
  local module = require('what-key.mappings')
  local Keys = require('what-key.keys')

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

  describe('create_mapping_for_mode', function()
    local test_key = '<C-J>'

    before_each(function()
      vim.cmd('silent! unmap ' .. test_key)
    end)

    it('updates state of user_mappings', function()
      vim.keymap.set('n', test_key, '<nop>')
      local mode_mappings = vim.api.nvim_get_keymap('n')
      local user_mappings = module.create_mapping(mode_mappings, Keys.USER_MAP)
      assert.is_not_nil(user_mappings[test_key])
      assert.are.equal(Keys.USER_MAP, user_mappings[test_key].mapped)
    end)

    it('updates state by mode', function()
      vim.keymap.set('n', test_key, '<nop>')
      local mode_mappings = vim.api.nvim_get_keymap('v')
      local user_mappings = module.create_mapping(mode_mappings, Keys.USER_MAP)
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
  end)
end)
