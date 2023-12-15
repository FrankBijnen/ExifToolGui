Notes on using 4K (HighDpi) monitors.

Issue #199 tries to improve 4K support.
The problem with 4K monitors is that they typically have a higher DPI than 96, the DPI ExifToolGui is designed for.
The result could be that items look too small, or not correctly positioned, or even be unreadable.

Previous versions of Delphi used scaling to overcome that. The problem with scaling is that items could be blurry.
Recent Delphi versions support the Windows HighDpi Api. (E.g. Via Manifest or API SetProcessDpiAwareness, SetProcessDpiAwarenessContext)

As of version 6.2.7 this solution is implemented in ExiftoolGui:

- Scaling is turned off by default, but can be re-enabled with the command line parameter /Scale.

- DPI Awareness.

  Below Window 8.1
  - No calls are made to set DPI Awareness.
  
  Windows 8.1 or higher
  - SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_SYSTEM_DPI_AWARE)
    see: https://learn.microsoft.com/en-us/windows/win32/api/shellscalingapi/ne-shellscalingapi-process_dpi_awareness

  Windows 10 1703 or higher
  - SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_SYSTEM_AWARE)
    see: https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context

Notes:
- Microsoft states that is recommended to use a Manifest instead of the API's, but then it would not be easy to switch at runtime.
- The API's have to be called very early, and only once, at startup.
- You can override the settings in the shortcut. Properties/Compatibility/Change high DPI settings.
- To help troubleshoot any problems the following command line parameters are introduced to override the default behaviour:

  /Scale                     Turn on Scaling for all forms. 

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
- The preferences are read too late. A window handle is already created.

The problem that I face is that I dont own a 4K monitor, so it's very hard to test. I can only test a lower DPI.
Anyone with such a monitor willing to help? Create an issue on Github with your testresults. https://github.com/FrankBijnen/ExifToolGui/issues

Frank
