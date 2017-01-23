var fs = require('fs');
var page = require('webpage').create();
var system = require('system');

var args = system.args;

var scriptDir = args[0].replace(/googlecharts-convert\.js$/, '')
var config = fs.read(args[1])
var pageContent = fs.read(scriptDir + 'template.html')
pageContent = pageContent.replace(/\$\{CONFIG}/g, config);

var path = args[1] + '.html';
fs.write(path, pageContent, 'w');

page.viewportSize = {
    width: 1024,
    height: 768
};

page.open(args[1] + '.html', function () {
    window.setTimeout(function () {
        phantom.exit();
    }, 30000);
});

page.onConsoleMessage = function (msg) {
    if (msg === 'chart.ready') {
        page.render(args[2]);
        phantom.exit();
    }
}
