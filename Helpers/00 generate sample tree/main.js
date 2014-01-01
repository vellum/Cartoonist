function makeSequence()
{
	var a = {
		"type" : "sequence",
		"nodes" : [],
		"image" : null,  // only read if this is a child of joint
		"caption" : null // only read if this is a child of joint
	}; 
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
	return a;
}

function makeJoint()
{
	var a = {
		"type" : "joint",
	    "selected" : 0,
	    "children" : []
	};
	return a;
}

function addSequenceToJoint(seq, joint)
{
	joint.children.push(seq);
}

function addNodeToSequence(node, seq)
{
	seq.nodes.push(node);
}

function addJointToSequence(joint, seq)
{
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
			// this is what we're looking for
			
			//var joint0 = makeBranchWith(3, 5, 'joint');
			// addJointToSequence(joint0, root);
			 
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

/////////////////////////////////

var count = 0;
var root;
function init()
{
	// make a root node sequence of 3 frames
	root = makeSequenceWith(2, 'r');

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
	console.log(count);
}

function render()
{
	var $main = $('#main');
	$main.empty();
	
	renderSequenceIntoDiv(root, $main);
	//i'm wasting your time
}

function renderSequenceIntoDiv( seq, $div )
{
	var $sequence = $('<div class="sequence"><heading>sequence</heading></div>');
	for (var i = 0; i < seq.nodes.length; i++)
	{
		var node = seq.nodes[i];
		var $node = $('<div class="node"><heading>' + node.type + '</heading></div>');
		
		if (node.type.toUpperCase() == 'FRAME')
		{
			$node.append('<div class="caption">' + node.caption + '</div>');
		} else if ( node.type.toUpperCase() == 'JOINT' ) {

			renderSequenceIntoDiv(node.children[node.selected], $node);
		}
		$sequence.append($node);
	}
	$div.append($sequence);
}