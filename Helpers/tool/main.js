var root,
	idcount = 0;

$(document).ready(function() {
	$.fn.editable.defaults.mode = 'inline';
	init();
	render();
});

function init()
{
	var data = localStorage.getItem("root");
	if ( data ){
		root = JSON.parse( data );
		parseAndIndex(root);
	} else {
		root = makeSequenceWith(0, 'root');
		localStorage.setItem("root", JSON.stringify(root));
	}
	$('#save').click(function(){
		data = $('#fucker').val();
		root = JSON.parse(data);
		parseAndIndex(root);
		render();
	});
}

function render()
{
	var $main = $('#main');
	$main.empty();
	renderSequenceIntoDiv(root, $main);
	localStorage.setItem("root", JSON.stringify(root));
	$('#fucker').val(JSON.stringify(root));
}

function renderSequenceIntoDiv( seq, $div )
{
	var $sequence = $('<div class="sequence"></div>');
	var $hs = $('<div class="heading">sequence</div>');
	if ( seq.id != undefined ){
		var $dl = $('<span data-id="' + seq.id + '" class="delete">[remove]</span>');
		$dl.click(function(){
			console.log('click');
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
			var $img = $('<div class="imagetext" data-id="' + node.id + '">' + node.image + '</div>');
			$node.append($img);
			$img.editable({
			    type: 'text',
			    title: '',
			    success: function(response, newValue) {
					var extractedid = $(this).attr('data-id');
					var resultnode = idlookup[extractedid];
					if (newValue=='null') newValue = null;
					resultnode.image = newValue;
					render();
			    }
			});
			
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
				var textie = childseq.caption;
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
				node.selected = $selectedoption.attr('id');
				render();
			});
			$node.append($select);
			var $addseq = $('<span data-id="' + node.id + '" class="add addbranch">[add branch]</span>');
			$addseq.click(function(){
				var id = $(this).attr('data-id');
				var joint = idlookup[id];
				var newsequence = makeSequenceWith(1, "empty");
				addSequenceToJoint(newsequence, joint);
				render();
			});
			
			$node.append($addseq);
			var $fuckingbranch = $('<div class="node"><div class="heading">branch</div></div>');
			$node.append($fuckingbranch);
			var $img = $('<div class="imagetext" data-id="' + node.children[node.selected].id + '">' + node.children[node.selected].image + '</div>');
			$fuckingbranch.append($img);
			$img.editable({
			    type: 'text',
			    title: '',
			    success: function(response, newValue) {
					var extractedid = $(this).attr('data-id');
					var resultnode = idlookup[extractedid];
					if (newValue=='null') newValue = null;
					resultnode.image = newValue;
					render();
			    }
			});
			var $framediv = $('<div class="captiontext" data-id="' + node.children[node.selected].id + '">' + node.children[node.selected].caption + '</div>');
			var $cap = $('<div class="caption"></div>');
			$cap.append($framediv);
			$fuckingbranch.append($cap);
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
			var joint = makeBranchWith(2, 1, 'empty');
			addJointToSequence(joint, seq);
			render();
		});
		$sequence.append($addie);
	}
	$div.append($sequence);
}