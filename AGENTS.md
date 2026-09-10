# Visual tests

- Before starting any test or demo that opens windows or uses mouse/keyboard focus, show the desktop countdown with `Build/visual-test-notice.ps1`.
- Default to 10 seconds (5 seconds is also allowed). The notice must be centered on the monitor containing the mouse pointer.
- Wait for the notice to finish before launching the visual test. Do not continue if the notice fails or is closed early.
- Run visual test programs sequentially so they do not steal focus from one another.
- The `test-editing.ps1`, `test-virtual-loading.ps1` and `test-dataset-loading.ps1` launchers already show the notice. Do not add a second notice when using them.
- For a manual launch, dot-source `Build/visual-test-notice.ps1` and call `Show-GridVisualTestNotice -TestName 'DemoName'` immediately before launching the application.
- Compiler runs and headless tests do not need a desktop notice.
