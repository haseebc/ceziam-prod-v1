//= require rails-ujs
//= require jquery
//= require bootstrap
//= require_tree .

$(document).ready(function(){
    $( "a.scroll" ).click(function( event ) {
        event.preventDefault();
        $("html, body").animate({ scrollTop: $($(this).attr("href")).offset().top }, 500);
    });
});

console.log('Hello from application.js')