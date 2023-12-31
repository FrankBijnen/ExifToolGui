
Important:

Geocode.maps.co started requiring an api-key. If it is not supplied you will get a response code 401. (Unautorized)
ExifToolGUI 6.2.8 adds the option to specify this api-key in preferences. Earlier versions will throw an Access violation.

If you want to keep using GeoCode:
- Register yourself
- Obtain your api-key
- Fill out the api-key in preferences
- Set the throttle value to 1000 ms or higher for a free account.

Starting with Version 6.2.5 GeoCoding has been revised.

In a nutshell:
- 2 Geocoding providers are now supported. https://geocode.maps.co/ and https://www.overpass-api.de/
- It was already possible to find the GPS coordinates of a location, now it is also possible to find the location of GPS coordinates. AKA Reverse GeoCoding
- The Coordinates and Place found can be saved using Exiftool in selected files. Provided the file format is supported of course.

Changes in ExiftoolGui.

In Preferences a tab is added called 'GeoCoding'. Here you can:

- Enable/Disable GeoCoding. 
  Notes: To enable GeoCoding you also need to enable 'Internet access'.
         If an error occurs with a request to the provider, you will get a dialog that allows you to disable the GeoCode requests. This checkbox Re-enables GeoCoding.
         Why this dialog? Suppose you want to GeoCode 100 files and you get an error with the 1st? Then you can cancel the remaining 99 requests.

- Enable/Disable the dialogs that have been added, when searching for Locations or Coordinates.

- For both providers, you can change the URL (normally not needed) and a 'throttle'. Throttling has been added to prevent overloading the providers.
  For example GeoCode.maps.co states that 1 requests per second is the max. Hence a default throttle value of 1000 ms.
  Normally there will be no need to change the default settings.

- Setup you api-key for GeoCode.

Search for the coordinates of a location.
   In the 'Find' edit box on the OSM map tab, you can enter:
   - Coordinates E.g.: 51.5534, 5.691287 (Lat and Lon values with decimal point, separated with a comma) 
   - If the program determines that the Coordinates are not valid, it assumes you are searching for a location. 
     You can enter the name of a City, optionally followed by a comma and a country.  
     In the dialog you can choose the provider, and optionally correct the input.
     When you select Overpass you have more options.
     - You can select the preferred language. This wil only affect the output shown, it does not affect the search.
     - Search only within the bounds displayed.
     - By default Overpass will only find a City when it is correctly and completely typed. With correct casing and international Characters.
       You can opt to search case insensitive, and or only partial. But it will slow down the search.
     - If no country is specified, the default for Overpass is to search within the Bounds of the map displayed.
   
   Examples.
   GeoCode.map.co will find cities and countries specified like:
   
   Muenchen
   Munchen
   M�nchen
   Munich
   
   M�nchen, Deutschland
   M�nchen, Duitsland
   M�nchen, Germany
   
   Den Bosch
   's-Hertogenbosch
   
   Overpass.api wil only find cities typed exactly correct, Countries/regions are allowed 'fuzzy'
   
   M�nchen
   M�nchen, Deutschland 
   M�nchen, Deu
   
   's-Hertogenbosch, Nederland
   's-Hertogenbosch, Ned
   
   The default provider for searching cities is 'https://geocode.maps.co/'. Searching is faster and yields better results. The disadvantage of only 2 requests per second is no issue in my opinion.

Search for the location of coordinates. Reverse geocoding.
   Reverse geocoding is performed in these 3 functions.
   - When you press 'Geotag files' a dialog is shown with the selected coordinates and the location.
     Use the button 'Setup Geo' to configure the lookup of the location. See setting up Geo.
     You can choose to update the selected file with the selected coordinates and or found location.

     Note: The selected files all get the same coordinates and or location. 
           The updated files are shown in the filelist, when set to 'Location Info'.

   - A new menu-item 'Modify/Update City, Province, Country from GPS coordinates'.
     The differences with 'Geotag files' are:
     - The selected files should already have GPS info.  
     - It will perform a lookup for every file and fill the location info. See also caching.

   - When you Ctrl/Click on the map, or press 'Get Location' the City/Province/Country Code are shown on the map.

   Setting up Geo.

   - Choose the provider.
     If Overpass selected you can choose your preferred language.

   - Map the fields Country, City and Province. Location can not be mapped, but you can update it manually. 

     - Country. Select only the Code, or the Name. Example: NL or Netherlands. DE or Germany.
     - Province. Map this to an Admin_level 6 to 3 for Overpass, or county, state for GeoCode.
     - City. Map this to an Admin_level 10 to 7 for Overpass, or village, municipality, town, city for GeoCode.

     The default values for City and Province is the smallest entity that has a value.

     The available fields from Geocode.maps.co are the OSM fields for address. https://wiki.openstreetmap.org/wiki/Key:addr:*
     More info on admin levels: https://wiki.openstreetmap.org/wiki/Key:admin_level

   The default provider for reverse geocoding is 'Overpass'. It allows more than 2 requests/second. You can change the language.

   Caching.

   The lookups for a location (Reverse GeoCoding) are cached. The cache is not written to disk, so every start of ExifToolGui you have an empty cache.
   Also the cache is cleared when you setup the Geo params.
   Caching is done on rounded Lat and Lon values to 4 decimals.
   The reason for Caching is to reduce the number of needless calls to the provider.

   Logging.

   All Rest requests (calls to the GeoCode provider) are logged and visible in the log window. You can copy the executed Command and paste it in a browser to replay.

Frank
