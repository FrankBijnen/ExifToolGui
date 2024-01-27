# ExifToolGui. Create or update a translation 
<h4>Preparation</h4>

<li>Download and install the Better Translation Manager.</li>

https://bitbucket.org/anders_melander/better-translation-manager/downloads/amTranslationManagerInstall-2.0.8628.33873.exe

<li>Create a new directory for translation.</li>

It should contain:
- The 32 Bits executable. (Has to do with naming, works best when it's the same name as the .Drc file) <br>
- ExifToolGui.Drc
- ExifToolGui_xx.xlat Where xx is the language code you want to translate. If your language is not listed, take any language and rename the file to the language code of your choice.

<li>Open the .xlat file in the Better Translation Manager, and start translation</li>
- Regularly save.
- When you want to test. Click on Build. That should create a translation DLL. ExifToolGui.xxx
  If the language matches your Windows language, it will automatically be slected when you start ExifToolGui.
  You can also use a command line parameter /LANG=xxx to override the default.




Frank
