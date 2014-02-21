'use strict';

/* Controllers */
angular.module('theApp.controllers', ['ui.bootstrap']).
    controller('PanelCollectionCtrl', function($scope, DataProviderService) {

        $scope.dataProvider = DataProviderService;
        $scope.root = DataProviderService.model;
        $scope.shouldShowEditButton = false;
        $scope.shouldShowEditPanel = false;
        $scope.shouldShowExtendedOptions = false;
        $scope.availableCellTypes = ['caption','nocaption', 'wireframe'];
        $scope.errorImage = 'img/img404.png';
        $scope.shouldShowJointButtons = false;
        $scope.shouldShowSequenceButtons = false;
        $scope.shouldShowAddButtons = false;
        $scope.isCollapsed = true;

        $scope.handleTreeChanges = function(){
            //console.log('handle tree changes');
            DataProviderService.SaveState();
        };

        $scope.hover = function(node) {
            node.shouldShowEditButton = !node.shouldShowEditButton;
            if (!node.shouldShowEditButton)
                node.shouldShowExtendedOptions = false;
        };

        $scope.sequenceHover = function(node) {
            return node.shouldShowSequenceButtons = !node.shouldShowSequenceButtons;
        };

        $scope.connectionHover = function(node) {
            node.shouldShowAddButtons = !node.shouldShowAddButtons;
            if (!node.shouldShowAddButtons) {
            }
        };

        $scope.jointHover = function(node) {
            return node.shouldShowJointButtons = !node.shouldShowJointButtons;
        };

        $scope.editClicked = function(node) {
            node.shouldShowEditPanel = !node.shouldShowEditPanel;
        };

        $scope.editDone = function(node) {
            node.shouldShowEditPanel = false;
            $scope.handleTreeChanges();
        };

        $scope.dotdotdotClicked = function(node) {
            return node.shouldShowExtendedOptions = !node.shouldShowExtendedOptions;
        };

        $scope.removeClicked = function(node) {

            // ToDo: prevent deletion of root node (very first)
            var parent = idlookup[node.parentid];
            if (parent){
                // if no grandparent, this is root
                if (parent.parentid==null||parent.parentid==undefined){
                    // this is the last and first node, so refuse to remove
                    if (parent.nodes.length==1) return;
                }
            }
            removeNodeFromParent(node);
            $scope.handleTreeChanges();
            return true;
        };

        $scope.addPanelAtFirstSibling = function(node, index){
            var parent = idlookup[node.parentid];
            insertNewFrameInSequenceAt(parent, 0);
            $scope.handleTreeChanges();
        };

        $scope.addPanelAfter = function(node, index){
            var parent = idlookup[node.parentid];
            insertNewFrameInSequenceAt(parent, index+1);
            $scope.handleTreeChanges();
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
            $scope.handleTreeChanges();
        };

        $scope.addJointClicked = function(){
            console.log(('add joint clicked'));

            // find the last sequence in the selected tree path
            var found = $scope.findLastSequenceInNode($scope.root);
            var joint = makeBranchWith(2, 2, 'empty');
            addJointToSequence(joint, found);
            $scope.handleTreeChanges();
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
            $scope.handleTreeChanges();
        };

    });
