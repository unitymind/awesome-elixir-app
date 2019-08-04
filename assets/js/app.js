// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'jquery'
import 'popper.js'
import 'bootstrap'
import 'phoenix_html'

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import $ from 'jquery';
window.jQuery = $;
window.$ = $;

$(document).ready(function(e) {
    $(".js-scroll-to").click(function(e) {

        // Get the href dynamically
        let destination = $(this).attr('href');

        // Prevent href=“#” link from changing the URL hash (optional)
        // e.preventDefault();

        // Animate scroll to destination
        $('html, body').animate({
            scrollTop: parseInt($(destination).offset().top) - 125
        }, 500);
    });
});
