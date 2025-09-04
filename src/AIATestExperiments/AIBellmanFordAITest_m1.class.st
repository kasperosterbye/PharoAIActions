Class {
	#name : 'AIBellmanFordAITest_m1',
	#superclass : 'TestCase',
	#instVars : [
		'refAIBellmanFord'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIBellmanFordAITest_m1 >> setUp [
	super setUp.
	refAIBellmanFord := AIBellmanFord new.
]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testEdgeClass [
	"Tests the edgeClass method of AIBellmanFord.
	edgeClass returns AIWeightedEdge"

	| edgeClassResult |
	"Get the result of calling edgeClass on the AIBellmanFord instance."
	edgeClassResult := refAIBellmanFord edgeClass.

	"Assert that the result is the expected class, AIWeightedEdge."
	self assert: edgeClassResult equals: AIWeightedEdge.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testEnd [
	| aModel node |
	"Arrange: Create a model and add it to the graph."
	aModel := 'testModel'.
	node := AIGraphNode new model: aModel.
	refAIBellmanFord nodes add: node.
	
	"Act: Call end: with the model."
	refAIBellmanFord end: aModel.

	"Assert: Check that the end instance variable is correctly set."
	self assert: refAIBellmanFord end equals: node.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testNodeClass [
	"Test that nodeClass returns the correct class."
	| nodeClass |
	"Get the class returned by nodeClass"
	nodeClass := refAIBellmanFord nodeClass.
	"Assert that the returned class is AIPathDistanceNode"
	self assert: nodeClass equals: AIPathDistanceNode.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testReconstructPath [
	| graphType graph startNode endNode nodeA nodeB nodeC edge1 edge2 shortestPath |
	"Set up a simple graph for testing"
	graphType := AINonWeightedDAGFixture new.
	graph := graphType simpleGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord edges: graph edges from: #first to: #second.

	"Set start and end nodes"
	nodeA := refAIBellmanFord findNode: $a.
	nodeB := refAIBellmanFord findNode: $b.
	nodeC := refAIBellmanFord findNode: $c.

	"Test case 1: Path exists"
	refAIBellmanFord start: $a.
	refAIBellmanFord end: $c.
	nodeC previousNode: nodeB.
	nodeB previousNode: nodeA.
	shortestPath := refAIBellmanFord reconstructPath.
	self assert: shortestPath asArray equals: #($a $b $c).

	"Test case 2: No path exists (end node has no previous node)"
	refAIBellmanFord start: $a.
	refAIBellmanFord end: $d.
	shortestPath := refAIBellmanFord reconstructPath.
	self assert: shortestPath asArray equals: #( ).

	"Test case 3: No path exists (end pathDistance is infinity)"
	refAIBellmanFord reset.
	refAIBellmanFord start: $a.
	refAIBellmanFord end: $c.
	nodeC pathDistance: Float infinity.
	shortestPath := refAIBellmanFord reconstructPath.
	self assert: shortestPath asArray equals: #( ).

	"Test case 4: No path exists (end pathDistance is negative infinity)"
	refAIBellmanFord reset.
	refAIBellmanFord start: $a.
	refAIBellmanFord end: $c.
	nodeC pathDistance: Float negativeInfinity.
	shortestPath := refAIBellmanFord reconstructPath.
	self assert: shortestPath asArray equals: #( ).

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testRelaxEdges [
	| graphType graph edgeFrom edgeTo |
	"Set up a simple graph for testing"
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord edges: graph edges
		from: #first
		to: #second
		weight: #third.

	"Initialize path distances (important for relaxEdges)"
	refAIBellmanFord reset.

	"Call the method to be tested"
	refAIBellmanFord relaxEdges.

	"Assert that the path distances have been updated correctly.  This requires knowing the expected outcome based on the graph."
	"Example assertions - adjust these based on the simpleWeightedGraph structure"
	"The simpleWeightedGraph has edges: #( #( 1 2 5 ) #( 1 3 4 ) #( 2 3 2 ) #( 3 4 5 ) #( 2 4 3 ) #( 4 5 1 ) #( 5 1 2 ) #( 1 5 3 ) )"
	"After relaxation, the shortest paths should be calculated."
	self assert: ((refAIBellmanFord findNode: 2) pathDistance) equals: 5.
	self assert: ((refAIBellmanFord findNode: 3) pathDistance) equals: 4.
	self assert: ((refAIBellmanFord findNode: 4) pathDistance) equals: 8.
	self assert: ((refAIBellmanFord findNode: 5) pathDistance) equals: 3.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testRelaxEdgesToNegativeInfinity [
	| graphType graph node0 node1 node2 edge01 edge12 |
	"Set up a graph with a negative cycle."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord edges: graph edges from: #first to: #second weight: #third.
	node0 := refAIBellmanFord findNode: 0.
	node1 := refAIBellmanFord findNode: 1.
	node2 := refAIBellmanFord findNode: 2.
	edge01 := refAIBellmanFord findEdge: #(0 1 5).
	"Initialize path distances (important for the test)."
	refAIBellmanFord start: 0.
	refAIBellmanFord run.
	"Run the method to test."
	refAIBellmanFord relaxEdgesToNegativeInfinity.
	"Verify that nodes in the negative cycle have a pathDistance of negative infinity."
	self assert: node2 pathDistance equals: Float negativeInfinity.
	self assert: node1 pathDistance equals: Float negativeInfinity.
	self assert: node0 pathDistance equals: 5.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testReset [
	"Test that the reset method correctly sets pathDistance to infinity and previousNode to nil for all nodes."
	| aNode |
	"First, ensure the graph has some nodes.  Assume refAIBellmanFord is initialized in setUp."
	refAIBellmanFord nodes: { (AIGraphNode new model: 'A'). (AIGraphNode new model: 'B') }.

	"Set up some initial values to test the reset."
	(refAIBellmanFord findNode: 'A') pathDistance: 10.
	(refAIBellmanFord findNode: 'A') previousNode: (AIGraphNode new model: 'C').
	(refAIBellmanFord findNode: 'B') pathDistance: 20.
	(refAIBellmanFord findNode: 'B') previousNode: (AIGraphNode new model: 'D').

	"Call the method to be tested."
	refAIBellmanFord reset.

	"Verify the results for each node."
	aNode := refAIBellmanFord findNode: 'A'.
	self assert: aNode pathDistance equals: Float infinity.
	self assert: aNode previousNode isNil.

	aNode := refAIBellmanFord findNode: 'B'.
	self assert: aNode pathDistance equals: Float infinity.
	self assert: aNode previousNode isNil.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testRun [
	"Test the run method of AIBellmanFord."
	| graphType graph startNode endNode value |
	"1. Set up the graph for testing.  Use a known graph from the fixtures."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.

	"2. Configure the Bellman-Ford algorithm with the graph."
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord
		edges: graph edges
		from: #first
		to: #second
		weight: #third.

	"3. Choose a start node."
	startNode := graph nodes first. "Assuming nodes are simple objects like numbers"

	"4. Run the algorithm from the start node."
	refAIBellmanFord start: startNode model.
	refAIBellmanFord run.

	"5. Verify the results.  Check path distances to some nodes."
	"Check the path distance to node 2"
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: 5.
	"Check the path distance to node 3"
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: 4.
	"Check the path distance to node 4"
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: 8.
	"Check the path distance to node 5"
	self assert: (refAIBellmanFord findNode: 5) pathDistance equals: 3.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testRunFrom [
	| graphType graph startNode |
	"Set up the test: Get a graph and set the start node."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord  edges: graph edges
		from: #first
		to: #second
		weight: #third.

	startNode := $a. "Assuming $a is a node in the graph"
	refAIBellmanFord runFrom: startNode.

	"Verify that the start node's path distance is 0"
	self assert: ((refAIBellmanFord findNode: startNode) pathDistance) equals: 0.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testRunFromTo [
	| graphType graph shortestPath |
	"Set up the test: Get a graph and initialize the Bellman-Ford algorithm."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.

	"Test case 1: Run from node 1 to node 2"
	shortestPath := refAIBellmanFord runFrom: 1 to: 2.
	self assertCollection: shortestPath asArray equals: #( 1 2 ).

	"Test case 2: Run from node 1 to node 3"
	refAIBellmanFord reset. "Reset the algorithm before the next test"
	shortestPath := refAIBellmanFord runFrom: 1 to: 3.
	self assertCollection: shortestPath asArray equals: #( 1 3 ).

	"Test case 3: Run from node 1 to node 4"
	refAIBellmanFord reset.
	shortestPath := refAIBellmanFord runFrom: 1 to: 4.
	self assertCollection: shortestPath asArray equals: #( 1 2 4 ).

	"Test case 4: Run from node 1 to node 5"
	refAIBellmanFord reset.
	shortestPath := refAIBellmanFord runFrom: 1 to: 5.
	self assertCollection: shortestPath asArray equals: #( 1 5 ).

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m1 >> testStart [
	| graphType graph nodeA |
	"Set up the graph for testing"
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord  edges: graph edges
		from: #first
		to: #second
		weight: #third.

	"Get a node to use as the start node"
	nodeA := refAIBellmanFord findNode: 1.

	"Call the start: method"
	refAIBellmanFord start: 1.

	"Verify that the start node's pathDistance is set to 0"
	self assert: nodeA pathDistance equals: 0.
	"Verify that the start node is correctly set"
	self assert: refAIBellmanFord start equals: nodeA.

]
