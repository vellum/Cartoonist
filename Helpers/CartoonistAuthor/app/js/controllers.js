'use strict';

/* Controllers */
var controllers = angular.module('theApp.controllers', ['ui.bootstrap']);

// PanelCollectionControl
controllers.controller('PanelCollectionCtrl', function($scope, $timeout, DataProviderService) {

    // boilerplate
    $scope.dataProvider = DataProviderService;
    $scope.root = DataProviderService.model;
    $scope.userInterfaceState = [];
    $scope.availableCellTypes = ['caption','nocaption', 'wireframe'];
    $scope.errorImage = 'img/img404.png';
    $scope.pasteBoardSequence = null;
    $scope.shouldShowTitleEditPanel = false;

    // ui-bootstrap wants its state values at the scope level
    $scope.isCollapsed = true;
    $scope.isFirstCollapsed = true;

    // ui state management
    // lookup state by node id
    $scope.stateForNode = function(node){
        var state = $scope.userInterfaceState[node.id];
        if (state==undefined||state==null){
            var newState = {
                shouldShowEditButton : false,
                shouldShowEditPanel : false,
                shouldShowExtendedOptions : false,
                shouldShowJointButtons : false,
                shouldShowSequenceButtons : false,
                shouldShowAddButtons : false,
                shouldShowAddButtonsFirst : false
            };
            $scope.userInterfaceState[node.id] = newState;
            state = newState;
        }
        return state;
    };

    $scope.propertyOnNode = function(property, node){
        var state = $scope.stateForNode(node);
        var value = state[property];
        return value;
    };

    $scope.setPropertyOnNode = function(property, value, node){
        var state = $scope.stateForNode(node);
        state[property] = value;
    };

    $scope.enter = function(node) {
        var state = $scope.stateForNode(node);
        state.shouldShowEditButton = true;
    };

    $scope.leave = function(node) {
        var state = $scope.stateForNode(node);
        state.shouldShowEditButton = false;
        state.shouldShowExtendedOptions = false;
    };

    $scope.sequenceHover = function(node) {
        var state = $scope.stateForNode(node);
        return state.shouldShowSequenceButtons = !state.shouldShowSequenceButtons;
    };

    $scope.connectionHover = function(node) {
        var state = $scope.stateForNode(node);
        state.shouldShowAddButtons = !state.shouldShowAddButtons;
    };

    $scope.jointHover = function(node) {
        var state = $scope.stateForNode(node);
        return state.shouldShowJointButtons = !state.shouldShowJointButtons;
    };

    $scope.editClicked = function(node) {
        var state = $scope.stateForNode(node);
        state.shouldShowEditPanel = !state.shouldShowEditPanel;
    };

    $scope.editDone = function(node) {
        var state = $scope.stateForNode(node);
        state.shouldShowEditPanel = false;
        $scope.handleTreeChanges();
    };

    $scope.dotdotdotClicked = function(node) {
        var state = $scope.stateForNode(node);
        return state.shouldShowExtendedOptions = !state.shouldShowExtendedOptions;
    };


    $scope.storyTitleClicked = function(){
        $scope.shouldShowTitleEditPanel = true;
        var el = document.getElementById('roottitle');
        $timeout(function() {
            el.focus();
        }, 100);
        console.log(el);
    };

    $scope.storyTitleEditDoneClicked = function(){
        $scope.shouldShowTitleEditPanel = false;
        $scope.handleTreeChanges();
    };

    //////

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

    $scope.removeClickedButPreserveChildren = function(node) {
        var joint = node;
        var sequencetopreserve = joint.children[joint.selected];
        var parentsequence = idlookup[joint.parentid];

        // remove joint from parent sequence
        removeNodeFromParent(joint);

        // transplant panels and nested joints, if any
        for (var i = 0; i < sequencetopreserve.nodes.length; i++){
            var item = sequencetopreserve.nodes[i];
            addNodeToSequence(item, parentsequence);
        }

        $scope.handleTreeChanges();
    };

    // utilities
    $scope.isLastInSequence = function(node, index){
        var parent = idlookup[node.parentid];
        if (parent==null||parent==undefined) return false;
        if (parent.type != 'sequence') return false;
        if (parent.nodes.length-1==index) return true;
        return false;
    };

    $scope.handleTreeChanges = function(){
        //console.log('handle tree changes');
        DataProviderService.SaveState();
    };

    // tree management
    // ToDo: refactor this into a library
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

    $scope.copyPanelsInSequenceToPasteboard = function(seq){
        console.log('copy');
        if (seq.type!='sequence'){
            return;
        }
        console.log('copy');
        var arrDuplicatePanels = [];
        for (var i = 0; i<seq.nodes.length; i++) {
            var original = seq.nodes[i];

            // only copy panels, no joints
            if (original.type=='frame'){
                var dupe = makeNode();
                dupe.type = original.type;
                dupe.celltype = original.celltype;
                dupe.caption = original.caption;
                dupe.image = original.image;
                arrDuplicatePanels.push(dupe);
            }
        }
        console.log(arrDuplicatePanels);
        $scope.pasteBoardSequence = arrDuplicatePanels;
    };

    $scope.applyPasteboardSequenceAt = function(node, index){

        var parent = idlookup[node.parentid];
        if (parent==null||parent==undefined) {
            return;
        }
        if (parent.type!='sequence'){
            return;
        }

        // step 1:
        // split nodes into two lists
        // remember that beginning is an alias to sequence's node array
        var beginning = parent.nodes;
        var end = [];
        console.log(parent);

        // move nodes from beginning to end
        for (var i = index+1; i < beginning.length; i++){
            var transplant = beginning[i];
            end.push(transplant);
        }
        beginning.splice(index+1, end.length);

        // step 2:
        // copy pasteboard into the sequence
        var pasteboard = $scope.pasteBoardSequence;
        for ( var i = 0; i < pasteboard.length; i++ ){
            var item = pasteboard[i];
            addNodeToSequence(item, parent);
        }

        // step 3:
        // copy spliced nodes back into the sequence
        for ( var i = 0; i < end.length; i++ ){
            var item = end[i];
            addNodeToSequence(item, parent);
        }
        $scope.pasteBoardSequence = null;
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

    $scope.addJointAt = function(node, index){
        //console.log('addjoint at index' + index + node);
        //console.log(node);
        console.log($scope.root);

        var parent = idlookup[node.parentid];
        console.log(parent);
        if (parent.type!='sequence') {
            //    return;
        }

        // let's make a joint with 2 sequences
        var joint = makeJoint();
        var sequenceA = makeSequence(); sequenceA.caption = 'Choice A';
        var sequenceB = makeSequenceWith(2, 'Choice B');

        // transplant displaced nodes in the current sequence
        // to the new joint
        var transplantlist = [];
        for (var i = index+1; i < parent.nodes.length; i++){
            var transplant = parent.nodes[i];
            transplantlist.push(transplant);
            addNodeToSequence(transplant, sequenceA);
        }

        // cleanup
        parent.nodes.splice(index+1, transplantlist.length);

        // make sure there is at least one nodes in the new sequence
        for (var i = sequenceA.nodes.length; i < 2; i++){
            var a = makeNode('placeholder');
            addNodeToSequence(a, sequenceA);
        }

        // add new sequences to the new joint
        addSequenceToJoint(sequenceA, joint);
        addSequenceToJoint(sequenceB, joint);

        // insert new joint into the original sequence
        addJointToSequence(joint, parent);

        $scope.handleTreeChanges();
    };

    $scope.$on('SELECTED_MODEL_UPDATED', function(event, data){
        $scope.root = $scope.dataProvider.model;
    });

});

// StorySelector
controllers.controller('StoryPickerCtrl', function($scope, DataProviderService){
    $scope.dataProvider = DataProviderService;

    $scope.selectIndex = function(index){
        $scope.dataProvider.SelectIndex(index);
    };

    $scope.empty = function(){
        console.log('empty');
        $scope.dataProvider.NewEmpty();
    };

    $scope.generate = function(){
        console.log('generate');
        $scope.dataProvider.NewGenerated();
    };

    $scope.dupe = function(){
        console.log('duplicate');
        $scope.dataProvider.NewDuplicate();
    };

    $scope.removeStoryAtIndex =  function(index){
        $scope.dataProvider.RemoveStoryAtIndex(index);
    };

});
