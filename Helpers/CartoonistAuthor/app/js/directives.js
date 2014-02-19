'use strict';

/* Directives */

angular.module('theApp.directives', []).
    directive('appVersion', ['version', function(version) {
        return function(scope, elm, attrs) {
            elm.text(version);
        };
    }]).
    directive('errSrc', function(){
      return {
          link: function(scope, element, attrs) {
              element.bind('error', function() {
                  element.attr('src', attrs.errSrc);
              })}
      };

    });



/*
* app.directive('errSrc', function() {
 return {
 ;
 }
 }
 });
* */