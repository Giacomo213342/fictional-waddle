{{flutter_js}}
{{flutter_build_config}}

// bug : Flutter does not pass the --base-href flag over to the CanvasKit location
const baseURI = document.head.baseURI;

_flutter.loader.load({
    config: {
        canvasKitBaseUrl: baseURI + 'canvaskit'
    }
});