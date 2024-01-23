Notes on using 4K (HighDpi) monitors.

History:
Initially Issue #199 tried to improve 4K support.
- The defaults where /HighDpi=SystemAware and no scaling.

More testing resulted in Issue #216, and changing the defaults to:
- /HighDPI=PerMonitorAwareV2 (Windows 10, or higher), /HighDpi=PerMonitorAware (Windows 8.1 or higher).
- Scaling turned on by default. But can be disabled by /DontScale
This should solve all problems previously encountered with scaling and resizing. The Command line parameters should not be needed anymore.

Additionally an option was added to resize the windows to its default sizes, without affecting other settings. You can access it by:
- Hovering over the ExifToolGui in the taskbar, click on the small button under preview. You must have Aero enabled.
- Right click on the tray icon. You must have enabled 'When minimized move to tray' in Preferences/Shell integration.

Background:
The problem with 4K monitors is that they typically have a higher DPI than 96, the DPI ExifToolGui is designed for.
The result could be that items look too small, or not correctly positioned, or even be unreadable.

Previous versions of Delphi used scaling to overcome that.
The problem with scaling, without using the SetProcessDpiAwareness(Context) API, is that items can be blurry.
Recent Delphi versions support the Windows HighDpi Api. (E.g. Via Manifest or API SetProcessDpiAwareness, SetProcessDpiAwarenessContext)

Solution:
As of version 6.2.9 this is implemented in ExiftoolGui:

- Scaling is turned on by default, but can be disabled with the command line parameter /DontScale.

- DPI Awareness.

  Windows 10 1703 or higher
  - SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
    see: https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context

  Windows 8.1 or higher
  - SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_PER_MONITOR_DPI_AWARE)
    see: https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/ne-shellscalingapi-process_dpi_awareness
  
  Below Window 8.1
  - No calls are made to set DPI Awareness.

A Tray icon is added to the Windows Taskbar, that shows the current ExifToolGui version, and enables you to reset the window sizes to their default values.

Notes:
- Microsoft states that it is recommended to use a Manifest instead of the API's, but then it would not be easy to switch at runtime.
- The API's have to be called very early, and only once, at startup.
- It should not be necessary, but you can override the settings in the shortcut. Properties/Compatibility/Change high DPI settings.
- To help troubleshoot any problems the following command line parameters are introduced to override the default behaviour:

  /DontScale                 Turn off Scaling for all forms. 

  Valid for Windows 10 1703 or higher:
  /HighDPI=UnAware           SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_UNAWARE)
  /HighDPI=SystemAware       SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_SYSTEM_AWARE)
  /HighDPI=PerMonitorAware   SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE)
  /HighDPI=PerMonitorAwareV2 SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
  /HighDPI=UnAwareGDIScaled  SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED)

  Valid for Windows 8.1 or higher:
  /HighDPI=UnAware           SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_DPI_UNAWARE)
  /HighDPI=SystemAware       SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_SYSTEM_DPI_AWARE)
  /HighDPI=PerMonitorAware   SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_PER_MONITOR_DPI_AWARE)

The reasons for using command line parameters instead of adding options in preferences:
- They are hopefully only temporary. The long term solution is to use the manifest.
- The preferences are read to late. A window handle is already created.

The problem that I face is that I dont own a 4K monitor, so it's very hard to test. I can only test a lower DPI.
Anyone with such a monitor willing to help? Create an issue on Github with your testresults. https://github.com/FrankBijnen/ExifToolGui/issues

Frank
