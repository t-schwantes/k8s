var http = require('http'),
    httpProxy = require('http-proxy');

var proxy6006 = httpProxy.createProxyServer({});
var proxy6007 = httpProxy.createProxyServer({});
var proxy6008 = httpProxy.createProxyServer({});

var server6006 = http.createServer(function(req, res) {
    items = req.url.split('/');
    req.url = '/' + items.splice(4).join('/');
    proxy6006.web(req, res, { target: 'http://localhost:6006' },
        function(e) { console.log(e); });
});
var server6007 = http.createServer(function(req, res) {
    items = req.url.split('/');
    req.url = '/' + items.splice(4).join('/');
    proxy6007.web(req, res, { target: 'http://localhost:6007' },
        function(e) { console.log(e); });
});
var server6008 = http.createServer(function(req, res) {
    items = req.url.split('/');
    req.url = '/' + items.splice(4).join('/');
    proxy6008.web(req, res, { target: 'http://localhost:6008' },
        function(e) { console.log(e); });
});

server6006.listen(6116);
server6007.listen(6117);
server6008.listen(6118);
