GoogleApiHelper = (function () {
    var _config = {};
    _config.OAUTHURL = 'https://accounts.google.com/o/oauth2/auth?';
    _config.VALIDURL = 'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=';
    _config.SCOPE = 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email';
    _config.CLIENTID = '';
    _config.REDIRECT = '';
    _config.TYPE = 'code';

    return {
        setConfig: function (config) { 
            _config = $.extend(_config, config);
        },
        getConfig: function () {
            return _config;
        },
        Open: function () {
            var _urlToOpen = _config.OAUTHURL + 'scope=' + _config.SCOPE + '&client_id=' + _config.CLIENTID + '&redirect_uri=' + _config.REDIRECT + '&response_type=' + _config.TYPE;
            window.location.href = _urlToOpen;
        }
    };
})();

