'use strict';

/* Controllers */
angular.module('theApp.controllers', []).
    controller('PanelCollectionCtrl', function($scope) {

        $scope.root = makeSampleTree();

        $scope.shouldShowEditButton = false;
        $scope.shouldShowEditPanel = false;
        $scope.shouldShowExtendedOptions = false;
        $scope.availableCellTypes = ['caption','nocaption', 'wireframe'];
        $scope.errorImage = 'img/img404.png';

        $scope.hover = function(node) {
            return node.shouldShowEditButton = !node.shouldShowEditButton;
        };

        $scope.editClicked = function(node) {
          return node.shouldShowEditPanel = !node.shouldShowEditPanel;
        };

        $scope.editDone = function(node) {
          return node.shouldShowEditPanel = false;
        };

        $scope.dotdotdotClicked = function(node) {
          return node.shouldShowExtendedOptions = !node.shouldShowExtendedOptions;
        };

        $scope.removeClicked = function(node) {

            // ToDo: prevent deletion of root node (very first)

            removeNodeFromParent(node);
            return true;
        };

        $scope.addPanelAtFirstSibling = function(node, index){
            var parent = idlookup[node.parentid];
            insertNewFrameInSequenceAt(parent, 0);
        };

        $scope.addPanelAfter = function(node, index){
            var parent = idlookup[node.parentid];
            insertNewFrameInSequenceAt(parent, index+1);
        };

        $scope.isIndexSelected = function(node, index){
          return node.selected==index;
        };

        $scope.selectedClicked = function(node, index){
            node.selected = index;
        };

    });
