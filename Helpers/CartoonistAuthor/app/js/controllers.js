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
        $scope.shouldShowJointButtons = false;
        $scope.shouldShowSequenceButtons = false;

        $scope.hover = function(node) {
            return node.shouldShowEditButton = !node.shouldShowEditButton;
        };

        $scope.sequenceHover = function(node) {
            return node.shouldShowSequenceButtons = !node.shouldShowSequenceButtons;
        };

        $scope.jointHover = function(node) {
            return node.shouldShowJointButtons = !node.shouldShowJointButtons;
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

        $scope.removeSequence = function(sequence){
            console.log('removesequencefrom joint');
            var joint = idlookup[sequence.parentid];
            if (joint.children.length>2){
                removeNodeFromParent(sequence);
            }
        };

        $scope.addJointClicked = function(){
            console.log(('add joint clicked'));

            // find the last sequence in the selected tree path
            var found = $scope.findLastSequenceInNode($scope.root);
            var joint = makeBranchWith(2, 2, 'empty');
            addJointToSequence(joint, found);
        };

        $scope.findLastSequenceInNode = function(node){
            switch (node.type){
                case 'sequence':
                    var last = node.nodes[node.nodes.length-1];
                    if (last.type=='joint')
                        return $scope.findLastSequenceInNode(last);
                    return node;
                    break;

                case 'joint':
                    var sequence = node.children[node.selected];
                    return $scope.findLastSequenceInNode(sequence);
                    break;

                // this should never happen
                case 'frame':
                    var parent = idlookup[node.parentid];
                    return $scope.findLastSequenceInNode(parent);
                    break;

                // this should never happen
                default:
                    return null;
            }
        };

        $scope.addNewBranchToJoint = function(joint){
            var newsequence = makeSequenceWith(1, "empty");
            addSequenceToJoint(newsequence, joint);
        };

    });
