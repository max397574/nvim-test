local api = vim.api

local ns = api.nvim_create_namespace('nvim_test')


local function get_test_lnum(lnum)
  local test
  local test_lnum
  for i = lnum, 1, -1 do
    test = vim.fn.getline(i):match("^%s*it%s*%(%s*['\"](.*)['\"']%s*,")
    if test then
      test_lnum = i
      break
    end
    test = vim.fn.getline(i):match("^%s*describe%s*%(%s*['\"](.*)['\"']%s*,")
    if test then
      test_lnum = i
      break
    end
  end

  return test, test_lnum
end

local function apply_decor(bufnr, lnum, code, stdout)
  local virt_text, virt_lines
  if code > 0 then
    virt_text = {'FAILED', 'ErrorMsg' }
    virt_lines = {}
    local collect = false
    for _, l in ipairs(vim.split(stdout, '\n')) do
      if not collect and l:match('%[ RUN') then
        collect = true
      end
      if collect and l ~= '' then
        virt_lines[#virt_lines+1] = {{l, 'ErrorMsg'}}
      end
    end

  else
    virt_text = {'PASSED', 'MoreMsg' }
  end
  api.nvim_buf_set_extmark(bufnr, ns, lnum-1, -1, {
    id = lnum,
    virt_text = {virt_text},
    virt_lines = virt_lines,
    virt_lines_above = true
  })
end

local function run_nvim_test()
  local name = api.nvim_buf_get_name(0)
  if not name:match('^.*/test/functional/.*$') then
    print('Buffer is not an nvim functional test file')
    return
  end
  local lnum = vim.fn.line('.')
  local test, test_lnum = get_test_lnum(lnum)
  if test then
    local cbuf = api.nvim_get_current_buf()
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local stdout_data = ''

    vim.loop.spawn('make', {
      args = {
        'functionaltest',
        'TEST_FILE='..name,
        'TEST_FILTER='..test
      },
      stdio = { nil, stdout, stderr },
    },
      function(code)
        if stdout then stdout:read_stop() end
        if stderr then stderr:read_stop() end

        if stdout and not stdout:is_closing() then stdout:close() end
        if stderr and not stderr:is_closing() then stderr:close() end

        vim.schedule(function()
          apply_decor(cbuf, test_lnum, code, stdout_data)
        end)
      end
    )

    stdout:read_start(function(_, data)
      if data then
        stdout_data = stdout_data..data
      end
    end)

    stderr:read_start(function(_, data)
      if data then
        stdout_data = stdout_data..data
      end
    end)
  else
    print('Could not find test')
  end
end

vim.api.nvim_add_user_command('RunTest', run_nvim_test, {
  force=true,
  nargs='*' -- shouldn't need this. Must be a bug.
})

vim.api.nvim_add_user_command('RunTestClear', function()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.cmd'redraw'
end, {
  force=true,
  nargs='*' -- shouldn't need this. Must be a bug.
})
