{{flutter_js}}
{{flutter_build_config}}

const searchParams = new URLSearchParams(window.location.search);

// bug : Flutter does not pass the --base-href flag over to the CanvasKit location
const baseURI = document.head.baseURI;

// handle OAuth2.0 redirects
if (window.location.hash.startsWith('#state') || searchParams.has("loginToken")) {
    const bc = new BroadcastChannel('oauth2redirect');
    // broadcast the location.href to main tab
    bc.postMessage(window.location.href);
    window.document.querySelector("#status-text").innerText = 'OAuth2.0 redirect received. You can close this tab.';
} else {
    _flutter.loader.load({
        config: {
            canvasKitBaseUrl: baseURI + 'canvaskit'
        }
    });
}
