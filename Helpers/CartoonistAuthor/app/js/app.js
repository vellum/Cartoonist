'use strict';

// Declare app level module which depends on filters, and services
angular.module('theApp', [
  'theApp.controllers',
  'theApp.directives',
  'theApp.services'
]);

/*.run(function($rootScope){
    $rootScope.$on("$routeChangeStart", function (event, next, current) {
        if (sessionStorage.restorestate == "true") {
            $rootScope.$broadcast('restorestate'); //let everything know we need to restore state
            sessionStorage.restorestate = false;
        }
    });

    //let everthing know that we need to save state now.
    window.onbeforeunload = function (event) {
        $rootScope.$broadcast('savestate');
    };
});
*/

/*.
config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/view1', {templateUrl: 'partials/partial1.html', controller: 'MyCtrl1'});
  $routeProvider.when('/view2', {templateUrl: 'partials/partial2.html', controller: 'MyCtrl2'});
  $routeProvider.otherwise({redirectTo: '/view1'});
}]);
*/