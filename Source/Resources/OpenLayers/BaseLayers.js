/**
 * BaseLayers.js. Classes for BaseLayers
 *
 * Taken (and adapted) from http://www.openstreetmap.org/openlayers/OpenStreetMap.js
 */
OpenLayers.Layer.OSM.Mapnik = OpenLayers.Class(OpenLayers.Layer.OSM, {
    initialize: function(name, options) {
        var url = [
            "https://a.tile.openstreetmap.org/${z}/${x}/${y}.png",
            "https://b.tile.openstreetmap.org/${z}/${x}/${y}.png",
            "https://c.tile.openstreetmap.org/${z}/${x}/${y}.png"
        ];
        options = OpenLayers.Util.extend({
            numZoomLevels: 20,
            maxZoom: 20,
            attribution: "&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors",
            buffer: 1,
            transitionEffect: "resize"
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.OSM.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.OSM.Mapnik"
});

OpenLayers.Layer.XYZ.OpenTopoMap = OpenLayers.Class(OpenLayers.Layer.XYZ, {
    initialize: function(name, options) {
        var url = [
            "https://a.tile.opentopomap.org/${z}/${x}/${y}.png",
            "https://b.tile.opentopomap.org/${z}/${x}/${y}.png",
            "https://c.tile.opentopomap.org/${z}/${x}/${y}.png"
        ];
        options = OpenLayers.Util.extend({
            numZoomLevels: 18,
            maxZoom: 18,
            sphericalMercator: true,
            attribution: "Map data: &copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors, <a href='http://viewfinderpanoramas.org'>SRTM</a> | Map style: &copy; <a href='https://opentopomap.org'>OpenTopoMap</a> (<a href='https://creativecommons.org/licenses/by-sa/3.0/'>CC-BY-SA</a>)",
            buffer: 0,
            transitionEffect: "resize"
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.OSM.prototype.initialize.apply(this, newArguments);
    },

    CLASS_NAME: "OpenLayers.Layer.XYZ.OpenTopoMap"
});

OpenLayers.Layer.XYZ.MapTiler = OpenLayers.Class(OpenLayers.Layer.XYZ, {
    initialize: function(name, resource, style, key, options) {
        var url = [
           "https://api.maptiler.com/" + resource + "/" + style + "/${z}/${x}/${y}.jpg?key=" + key
        ];
        options = OpenLayers.Util.extend({
            numZoomLevels: 20,
            maxZoom: 20,
            sphericalMercator: true,
            attribution: "<a href='https://www.maptiler.com/copyright/' target='_blank'>&copy; MapTiler</a><a href='https://www.openstreetmap.org/copyright' target='_blank'>&copy;&nbsp;OpenStreetMap contributors</a>",
            buffer: 0,
            transitionEffect: "resize"
        }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.OSM.prototype.initialize.apply(this, newArguments);
    },
    CLASS_NAME: "OpenLayers.Layer.XYZ.MapTiler"
});
