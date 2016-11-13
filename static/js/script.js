$(function() {
    $('button').click(function() {
        var restaurant = $('#restaurant').val();
        var distance = $('#distance').val();
        alert(distance);
        $.ajax({
            url: '/',
            data: $('form').serialize(),
            type: 'POST',
            success: function(data) {
                $('#Name').text(data['name']);
                $('#Rating').text(data['rating'])
                $('#Desc').text(data['desc'])
                console.log(data);
            },
            error: function(error) {
                console.log(error);
            }
        });
    });
});