google.load("visualization", "1.1", {packages:["corechart", "bar", "line"]});
var drawChart = function(id, config) {
    var div = document.getElementById(id)
    div.style.width = config['style']['width']
    div.style.height = config['style']['height']
    var chart = new config['type'](div);
    chart.draw(config['data'], config['options']);
}
