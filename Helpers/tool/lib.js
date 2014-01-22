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
			var joint = makeBranchWith(3, 2, last.caption);
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
		console.log('parent is joint');
		var ind = parentnode.children.indexOf(node);
		console.log('child is child nmr ' + ind);
		if ( ind > -1 )
		{
			parentnode.children.splice(ind, 1);
			console.log('removed node from joint');
			console.log('new length is ' + parentnode.children.length);
			if (parentnode.selected>parentnode.children.length-1)
			{
				parentnode.selected = 0;
				console.log('new selection is zero');
			}
		}
		if (parentnode.children.length==0)
		{
			console.log('parent now empty, so remove parent');
			removeNodeFromParent(parentnode);
		}
	} 
	else if ( type == 'SEQUENCE' ) 
	{
		console.log('parent is sequence');
		
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

function parseAndIndex(node)
{
	if ( idlookup[node.id]== undefined )
	{
		idlookup[node.id] = node;
	}
	var type = node.type.toUpperCase();
	if ( type == 'JOINT' )
	{
		console.log('parsing joint');
		for ( var i = 0; i < node.children.length; i++ )
		{
			var c = node.children[i];
			if ( idlookup[c.parentid] == undefined )
			{
				idlookup[c.parentid] = node;
			}
			idlookup[c.id] = c;
			parseAndIndex(c);
		}
	} 
	else if ( type == 'SEQUENCE' )
	{
		console.log('parsing sequence');
		for ( var i = 0; i < node.nodes.length; i++ )
		{
			var c = node.nodes[i];
			if ( idlookup[c.parentid] == undefined )
			{
				idlookup[c.parentid] = node;
			}
			idlookup[c.id] = c;
			parseAndIndex(c);
			
		}
	} 
	else if ( type=='FRAME')
	{
		console.log('parsing frame');
	}
	
}

function makeSampleTree()
{
    // make a root node sequence of 3 frames
    root = makeSequenceWith(2, 'r');

    // put a joint with 3 branches of 2 frames
    var joint0 = makeBranchWith(3, 2, 'j');
    addJointToSequence(joint0, root);

    for (var i = 0; i < 5; i++)
    {
    	makeAndAddBranchesToEnd(root);
    }

   // var json = JSON.stringify(root);
    //console.log(json);
    //console.log(root);
    //console.log(count);
}