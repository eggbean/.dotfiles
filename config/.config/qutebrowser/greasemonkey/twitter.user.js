// ==UserScript==
// @name         Twitter Go Back with H key
// @namespace    https://gist.github.com/eggbean/ba4daf82f132421c69dbd2c2e0b3e061/raw/twitter_go_back.user.js
// @version      1.0
// @description  Makes the unused H key a browser back button for better H,J,K,L keyboard navigation
// @author       https://github.com/eggbean
// @match        https://twitter.com/*
// @icon         https://twitter.com/favicon.ico
// @grant        none
// ==/UserScript==

(function() {
    var gKeyPressed = false;
    addEventListener("keydown", function(e){
        if (document.activeElement.tagName != 'INPUT' && document.activeElement.tagName != 'TEXTAREA' && document.activeElement.contentEditable != 'true') {
            switch (e.keyCode) {
                case 71: //"g"
                    gKeyPressed = true;
                    break;
                case 72: //"h"
                    if (e.keyCode === 72 && gKeyPressed === false) {
                        history.back();
                    }
                    break;
                default:
                    gKeyPressed = false;
                    break;
            }
        }
    });
})();
