var idlookup = [];

function uniqueid(){
    // always start with a letter (for DOM friendlyness)
    var idstr=String.fromCharCode(Math.floor((Math.random()*25)+65));
    do {                
        // between numbers and characters (48 is 0 and 90 is Z (42-48 = 90)
        var ascicode=Math.floor((Math.random()*42)+48);
        if (ascicode<58 || ascicode>64){
            // exclude all chars between : (58) and @ (64)
            idstr+=String.fromCharCode(ascicode);    
        }                
    } while (idstr.length<32);

    return (idstr);
}

function brand(a)
{
	a.id = uniqueid();
	idlookup[a.id] = a;
}

function makeSequence()
{
	var a = {
		"type" : "sequence",
		"nodes" : [],
		"image" : null,  // only read if this is a child of joint
		"caption" : null // only read if this is a child of joint
	}; 
	brand(a);
	return a;
}

function makeNode(caption)
{
	count++;
	var a = {
        "type" : "frame",
        "celltype" : "wireframe",
        "image" : null,
        "caption": caption
	};
	brand(a);
	return a;
}

function makeJoint()
{
	var a = {
		"type" : "joint",
	    "selected" : 0,
	    "children" : []
	};
	brand(a);
	return a;
}

function addSequenceToJoint(seq, joint)
{
	seq.parentid = joint.id;
	joint.children.push(seq);
}

function addNodeToSequence(node, seq)
{
	node.parentid = seq.id;
	seq.nodes.push(node);
}

function addNodeToSequenceAtIndex(node, seq, index)
{
	node.parentid = seq.id;
	seq.nodes.splice(index, 0, node);
	return;
	
	if (index > seq.nodes.length-1){
		seq.nodes.push(node);
	} else {
	}
}

function addJointToSequence(joint, seq)
{
	joint.parentid = seq.id;
	addNodeToSequence(joint, seq);
}

function makeSequenceWith(numFrames, baseLabel)
{
	var a = makeSequence();
	a.caption = baseLabel;
	for ( var i = 0; i < numFrames; i++ )
	{
		var b = makeNode( baseLabel + ' / f' + i );
		addNodeToSequence(b, a);
	}
	brand(a);
	return a;
}

function makeBranchWith(numBranches, numFrames, baseLabel)
{
	var a = makeJoint();
	for ( var i = 0; i < numBranches; i++ )
	{
		var b = makeSequenceWith(numFrames, baseLabel + '_' + i);
		addSequenceToJoint(b, a);
	}
	brand(a);
	return a;
}

function makeAndAddBranchesToEnd(node, numBranches, numFrames)
{
	if (node.type == 'sequence')
	{
		// get the last node
		var last = node.nodes[node.nodes.length-1];
		
		// check if it's a joint
		if (last.type == 'sequence')
		{
			makeAndAddBranchesToEnd(last, numBranches, numFrames);
			return;
		} 
		else if (last.type == 'joint')
		{
			for ( var i = 0; i < last.children.length; i++ )
			{
				// each child is a sequence so recurse
				makeAndAddBranchesToEnd(last.children[i], numBranches, numFrames);
			}
			return;
		} 
		else if ( last.type == 'frame')
		{
			var joint = makeBranchWith(3, 3, last.caption);
			addJointToSequence(joint, node);
		}
	} 
	else if ( node.type == 'joint') 
	{
		for ( var i = 0; i < node.children.length; i++ )
		{
			// each child is a sequence so recurse
			makeAndAddBranchesToEnd(node.children[i], numBranches, numFrames);
		}
	}
}

function removeNodeFromParent(node)
{
	if ( node.parentid == null || node.parentid == undefined ) {
		console.log('parentid undefined');
		return;
	}
	var parentnode = idlookup[node.parentid];
	if ( parentnode == null || parentnode == undefined ) {
		console.log('parentnode not found in lookup');
		return;
	}
	var type = parentnode.type.toUpperCase();
	if ( type == 'JOINT' )
	{
		var ind = parentnode.children.indexOf(node);
		if ( ind > -1 )
		{
			parentnode.children.splice(ind, 1);
			console.log('removed node from joint');
		}
		if (parentnode.children.length==0)
		{
			console.log('parent now empty, so remove parent');
			removeNodeFromParent(parentnode);
		}
	} 
	else if ( type == 'SEQUENCE' ) 
	{
		var ind = parentnode.nodes.indexOf(node);
		if ( ind > -1 )
		{
			parentnode.nodes.splice(ind, 1);
			console.log('removed node from sequence');
		}
	}
}

function insertNewFrameInSequenceAt(seq, index)
{
	console.log('insert new frame at ' + index);
	var node = makeNode('empty');
	addNodeToSequenceAtIndex(node, seq, index);
	render();
}
/////////////////////////////////

var count = 0;
var root = {"type":"sequence","nodes":[{"type":"frame","celltype":"wireframe","image":null,"caption":"Cover","id":"W9CCTJ738QCRRRT6FEUQEIAF9Q6YITO0","parentid":"F9GGN0J63TNCWLDTV565L0MT40F6FROH"},{"type":"frame","celltype":"wireframe","image":null,"caption":"Instructions","id":"LV69H2YEIM3V8M56G5TSE3UX2X8KJDCD","parentid":"F9GGN0J63TNCWLDTV565L0MT40F6FROH"},{"type":"frame","celltype":"wireframe","image":null,"caption":"Scene","id":"MAC3TG3MRXMDWETXJLADPJJ3CAQL5XTE","parentid":"F9GGN0J63TNCWLDTV565L0MT40F6FROH"},{"type":"frame","celltype":"wireframe","image":null,"caption":"Scene","id":"VSW9GGWSCH21FTF39D0EJSUKO7AF5SX0","parentid":"F9GGN0J63TNCWLDTV565L0MT40F6FROH"},{"type":"joint","selected":"2","children":[{"type":"sequence","nodes":[{"type":"frame","celltype":"wireframe","image":null,"caption":"Look","id":"WK0DOPPUDIQIMK08A11ETSLMF9YRW97A","parentid":"C6NX1IH0VASE6J1155IN9S56MC7TYMV9"}],"image":null,"caption":"empty_0","id":"M67U1JSLJT3JPVF3W47EBQXS83RPIYTW","parentid":"K2YBS1V07T1HMFH3N5TPY6E4GJXEENJU"},{"type":"sequence","nodes":[{"type":"frame","celltype":"wireframe","image":null,"caption":"Say something","id":"ID07PBU1LSL1GV80QR8W8P2AFN038VH2","parentid":"G19OY064CB0PC52GVUDFCJ2WC2AO06UY"}],"image":null,"caption":"empty_1","id":"Y7GSL0LVRLKC4UOX3UIV7KJNDCDQPKV5","parentid":"K2YBS1V07T1HMFH3N5TPY6E4GJXEENJU"},{"type":"sequence","nodes":[{"type":"frame","celltype":"wireframe","image":null,"caption":"Say some other thing","id":"PLA1HHJX8010L56E9HBY9CNLTDXXJ1DQ","parentid":"AP10QNWJUIXLPPL4EKCS50E7RDO2QECC"}],"image":null,"caption":"empty_2","id":"JX0U59WINUKQXYUNTYYGRYHFM4UO5JK3","parentid":"K2YBS1V07T1HMFH3N5TPY6E4GJXEENJU"}],"id":"W7CJTTLKP5GJGGNW6NSULDPXSXOU13QP","parentid":"F9GGN0J63TNCWLDTV565L0MT40F6FROH"}],"image":null,"caption":"root","id":"F9GGN0J63TNCWLDTV565L0MT40F6FROH"};
var idcount = 0;
function init()
{
	if ( root == null || root == undefined )
	{
		root = makeSequenceWith(0, 'root');
	}
	
	$('#clippie').click(function(){
		clipboard();
	});

	/*
	// put a joint with 3 branches of 3 frames
	var joint0 = makeBranchWith(3, 3, 'j');
	addJointToSequence(joint0, root);

	for (var i = 0; i < 4; i++)
	{
		makeAndAddBranchesToEnd(root);
	}

	var json = JSON.stringify(root);
	//console.log(json);
	//console.log(root);
	console.clear();
	console.log(count);
	*/
	

}

function printjson(){
	var json = JSON.stringify(root);
	console.log(json);
}
function clipboard() {
  window.prompt("Copy to clipboard: Ctrl+C, Enter", JSON.stringify(root));
}
function render()
{
	var $main = $('#main');
	$main.empty();
	renderSequenceIntoDiv(root, $main);
}

function renderSequenceIntoDiv( seq, $div )
{
	var $sequence = $('<div class="sequence"></div>');
	var $hs = $('<div class="heading">sequence</div>');
	if ( seq.id != undefined ){
		var $dl = $('<span data-id="' + seq.id + '" class="delete">[remove]</span>');
		$dl.click(function(){
			var extractedid = $(this).attr('data-id');
			var resultnode = idlookup[extractedid];
			removeNodeFromParent(resultnode);
			render();
		});
		$hs.append($dl);
	} 
	$sequence.append($hs);
	
	var $addie = $('<div class="add node">[add frame]</div>');
	$addie.click(function(){
		insertNewFrameInSequenceAt(seq, 0);
	});
	$sequence.append($addie);
	var shouldPresentAddButton = true;
	
	for (var i = 0; i < seq.nodes.length; i++)
	{
		var node = seq.nodes[i];
		var $node = $('<div class="node"></div>');
		var $heading = $('<div class="heading">' + node.type + '</div>');
		$node.append($heading);
		
		var $del = $('<span data-id="' + node.id + '" class="delete">[remove]</span>');
		$heading.append($del);
		$del.click(function(){
			var extractedid = $(this).attr('data-id');
			var resultnode = idlookup[extractedid];
			removeNodeFromParent(resultnode);
			render();
		});
		
		if (node.type.toUpperCase() == 'FRAME')
		{
			var $framediv = $('<div class="captiontext" data-id="' + node.id + '">' + node.caption + '</div>');
			var $cap = $('<div class="caption"></div>');
			$cap.append($framediv);
			$node.append($cap);
			var localnode = node;
			$framediv.editable({
			    type: 'text',
			    title: '',
			    success: function(response, newValue) {
					var extractedid = $(this).attr('data-id');
					var resultnode = idlookup[extractedid];
					resultnode.caption = newValue;
					render();
			    }
			});
			
		} else if ( node.type.toUpperCase() == 'JOINT' ) {
			idcount++;
			var $select = $('<select id="select_' + idcount + '"></select>');
			for ( var j = 0; j < node.children.length; j++ )
			{
				var childseq = node.children[j];
				var textie = childseq.nodes[0].caption;
				if ( j != node.selected )
				{
					$select.append($('<option id="' + j + '">' + textie + '</option>'));
				} else {
					$select.append($('<option id="' + j + '" selected>' + textie + '</option>'));
				}
			}
			$select.change(function(){
				console.log( $(this).attr('id') );
				var thisid = $(this).attr('id');
				var $selectedoption = $('#' + thisid + ' option:selected');
				//console.log($selectedoption.attr('id'));
				node.selected = $selectedoption.attr('id');
				render();
			});
			$node.append($select);
			renderSequenceIntoDiv(node.children[node.selected], $node);
		}
		$sequence.append($node);
		
		if ( i == seq.nodes.length-1 && node.type.toUpperCase() == 'JOINT' )
		{
			shouldPresentAddButton = false;
		}
		if ( shouldPresentAddButton )
		{
			var $addie = $('<div data-id="' + node.id + '" class="add node">[add frame]</div>');
			$sequence.append($addie);
			$addie.click(function(){

				var id = $(this).attr('data-id');
				var resultnode = idlookup[id];
				var parentnode = idlookup[resultnode.parentid];
				var ind = parentnode.nodes.indexOf(resultnode);
				insertNewFrameInSequenceAt(parentnode, ind+1);
			});
			$sequence.append($addie);
		}
	}
	if (shouldPresentAddButton)
	{
		var $addie = $('<div class="add node">[add joint]</div>');
		$sequence.append($addie);
		$addie.click(function(){
			var joint = makeBranchWith(3, 1, 'empty');
			addJointToSequence(joint, seq);
			render();
		});
		$sequence.append($addie);
	}
	$div.append($sequence);
}