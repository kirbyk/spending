$(function () {
    $('#container').highcharts({
        title: {
            text: category_name,
            x: -20 //center
        },
        subtitle: {
            text: 'Weekly vs Average',
            x: -20
        },
        xAxis: {
            categories: ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5']
        },
        yAxis: {
            title: {
                text: 'Dollars'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        tooltip: {
            valuePrefix: '$'
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        series: [{
            name: 'Average',
            data: average_data
        }, {
            name: category_name,
            data: category_data
        }]
    });
});
