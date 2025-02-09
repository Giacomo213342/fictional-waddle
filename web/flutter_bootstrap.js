{{flutter_js}}
{{flutter_build_config}}

const searchParams = new URLSearchParams(window.location.search);
const action = searchParams.get('action');

// bug : Flutter does not pass the --base-href flag over to the CanvasKit location
const baseURI = document.head.baseURI;

// handle OAuth2.0 redirects
if(action == 'oauth2redirect') {
    const bc = new BroadcastChannel('oauth2redirect');
    // broadcast the location.href to main tab
    bc.postMessage(window.location.href);
    window.document.body.innerText = 'OAuth2.0 redirect received. You can close this tab.';
} else {
    _flutter.loader.load({
        config: {
            canvasKitBaseUrl: baseURI + 'canvaskit'
        }
    });
}
