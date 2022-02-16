# Run Neovim tests inside Neovim

<video src="https://raw.githubusercontent.com/lewis6991/media/main/nvim-test-demo.mp4" width="100%"></video>

* Add virtual text for test results
* Add virtual lines for failed test output immediately above the test.

## Commands

`RunTest`: Run the test in the buffer the cursor is inside. Works for `it` and `describe` blocks.

`RunTestClear`: Clear test result decorations in buffer

## TODO

* Generalise for any busted testsuite
