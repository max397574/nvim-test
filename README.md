# Run Neovim tests inside Neovim

<video src="https://user-images.githubusercontent.com/7904185/154276369-38596790-a62e-4e63-bf95-442cd67cc5d6.mp4" width="100%"></video>

          
* Add virtual text for test results
* Add virtual lines for failed test output immediately above the test.

## Commands

`RunTest`: Run the test in the buffer the cursor is inside. Works for `it` and `describe` blocks.

`RunTestClear`: Clear test result decorations in buffer

## TODO

* Generalise for any busted testsuite
