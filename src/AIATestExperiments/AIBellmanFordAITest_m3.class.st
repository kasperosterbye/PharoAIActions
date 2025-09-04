Class {
	#name : 'AIBellmanFordAITest_m3',
	#superclass : 'TestCase',
	#instVars : [
		'refAIBellmanFord'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIBellmanFordAITest_m3 >> setUp [
	super setUp.
	refAIBellmanFord := AIBellmanFord new.
]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testEdgeClass [
	"Tests the edgeClass method of AIBellmanFord.
	edgeClass returns AIWeightedEdge"
	| edgeClass |
	"Get the edge class from the AIBellmanFord instance."
	edgeClass := refAIBellmanFord edgeClass.
	"Assert that the returned class is AIWeightedEdge."
	self assert: edgeClass equals: AIWeightedEdge

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testEnd [
	"Test that the 'end' instance variable is correctly set by the 'end:' method."
	|  graphType graph endNode |
	"Create a graph fixture."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	"Set the nodes and edges for the Bellman-Ford algorithm."
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord edges: graph edges
		from: #first
		to: #second
		weight: #third.
	"Get the end node."
	endNode := graph findNode: 5.
	"Call the end: method."
	refAIBellmanFord end: 5.
	"Assert that the 'end' instance variable is correctly set."
	self assert: refAIBellmanFord end equals: endNode

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testNodeClass [
	"Test that nodeClass returns the correct class."
	| result |
	"Get the result of calling nodeClass on the AIBellmanFord instance."
	result := refAIBellmanFord nodeClass.
	"Assert that the result is the expected class, AIPathDistanceNode."
	self assert: result equals: AIPathDistanceNode.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testReconstructPath [
	|  graphType graph startNode endNode expectedPath |
	"Test that reconstructPath returns an empty collection when no path exists."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.
	startNode := refAIBellmanFord findNode: 1.
	endNode := refAIBellmanFord findNode: 5.
	refAIBellmanFord start: 1.
	refAIBellmanFord end: 5.
	refAIBellmanFord reset.
	refAIBellmanFord run.
	"Set end pathDistance to infinity to simulate no path"
	(refAIBellmanFord findNode: 5) pathDistance: Float infinity.
	expectedPath := #(  ).
	self assert: (refAIBellmanFord reconstructPath asArray) equals: expectedPath.

	"Test that reconstructPath returns an empty collection when a negative cycle exists."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.
	refAIBellmanFord start: 0.
	refAIBellmanFord end: 2.
	refAIBellmanFord reset.
	refAIBellmanFord run.
	"Simulate a negative cycle by setting pathDistance to negative infinity"
	(refAIBellmanFord findNode: 2) pathDistance: Float negativeInfinity.
	expectedPath := #(  ).
	self assert: (refAIBellmanFord reconstructPath asArray) equals: expectedPath.

	"Test that reconstructPath correctly reconstructs a path."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.
	refAIBellmanFord start: 1.
	refAIBellmanFord end: 5.
	refAIBellmanFord reset.
	refAIBellmanFord run.
	expectedPath := #( 1 5 ).
	self assert: (refAIBellmanFord reconstructPath asArray) equals: expectedPath.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testRelaxEdges [
	| graphType graph nodeA nodeB nodeC edgeAB edgeBC |
	"Test that relaxEdges correctly updates path distances and previous nodes."

	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord edges: graph edges
		from: #first
		to: #second
		weight: #third.

	nodeA := refAIBellmanFord findNode: 1.
	nodeB := refAIBellmanFord findNode: 2.
	nodeC := refAIBellmanFord findNode: 3.
	edgeAB := refAIBellmanFord findEdge: #(1 2 5).
	edgeBC := refAIBellmanFord findEdge: #(2 3 2).

	refAIBellmanFord reset.
	nodeA pathDistance: 0.

	refAIBellmanFord relaxEdges.

	"Check if the path distances are updated correctly after relaxEdges"
	self assert: nodeB pathDistance equals: 5.
	self assert: nodeC pathDistance equals: 7.

	"Check if the previous nodes are updated correctly"
	self assert: nodeB previousNode equals: nodeA.
	self assert: nodeC previousNode equals: nodeB.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testRelaxEdgesToNegativeInfinity [
	| graphType graph nodeA nodeB nodeC edgeAB edgeBC |
	"Set up a graph with a negative cycle."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord edges: graph edges from: #first to: #second weight: #third.

	"Initialize path distances (important for the test)."
	refAIBellmanFord reset.
	(refAIBellmanFord findNode: 0) pathDistance: 0.

	"First relaxation (to set up the conditions for negative cycle detection)."
	refAIBellmanFord relaxEdges.

	"Run the method to test."
	refAIBellmanFord relaxEdgesToNegativeInfinity.

	"Verify that nodes in the negative cycle have pathDistance set to negative infinity."
	nodeA := refAIBellmanFord findNode: 2.
	nodeB := refAIBellmanFord findNode: 3.
	nodeC := refAIBellmanFord findNode: 2.

	self assert: nodeA pathDistance equals: Float negativeInfinity.
	self assert: nodeB pathDistance equals: Float negativeInfinity.
	self assert: nodeC pathDistance equals: Float negativeInfinity.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testReset [
	"Test that the reset method correctly sets pathDistance to infinity and previousNode to nil for all nodes."
	| aNode |
	"First, create a simple graph for testing.  Assume nodes and edges are already set up in refAIBellmanFord."
	"Get a node to test"
	aNode := refAIBellmanFord nodes first.

	"Set some initial values to verify reset works"
	aNode pathDistance: 10.
	aNode previousNode: refAIBellmanFord nodes second.

	"Call the reset method"
	refAIBellmanFord reset.

	"Verify that the pathDistance is now infinity"
	self assert: aNode pathDistance equals: Float infinity.

	"Verify that the previousNode is now nil"
	self assert: aNode previousNode isNil.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testRun [
	"Test the 'run' method of AIBellmanFord.  It should initialize path distances, relax edges, and detect negative cycles."
	| graphType graph startNode endNode |
	"Use a graph fixture with negative cycles to test the negative cycle detection."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.

	"Set the start node."
	startNode := graph nodes first.
	refAIBellmanFord start: startNode model.

	"Run the algorithm."
	refAIBellmanFord run.

	"Verify that the path distances are correctly calculated, and negative cycles are detected."
	"Check for negative infinity in nodes that are part of a negative cycle."
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 9) pathDistance equals: Float negativeInfinity.

	"Verify the path distance for a node not in a negative cycle."
	self assert: (refAIBellmanFord findNode: 1) pathDistance equals: 5.

	"Test with a different start node"
	refAIBellmanFord reset.
	startNode := graph nodes at: 7.
	refAIBellmanFord start: startNode model.
	refAIBellmanFord run.
	self assert: (refAIBellmanFord findNode: 1) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 9) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 7) pathDistance equals: -10.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testRunFrom [
	"Test the runFrom: method of AIBellmanFord.
	It should set the start node and then run the Bellman-Ford algorithm."
	| graphType graph startNode expectedPath |
	"Create a graph fixture (assuming it exists and provides a graph)"
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.

	"Set up the AIBellmanFord instance with the graph's nodes and edges"
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.

	"Get the start node (e.g., node with value 1)"
	startNode := refAIBellmanFord findNode: 1.

	"Run the runFrom: method"
	refAIBellmanFord runFrom: 1.

	"Assert that the pathDistance of the start node is 0 (as it should be after run)"
	self assert: startNode pathDistance equals: 0.

	"Optionally, check the path distances of other nodes to verify the algorithm's correctness"
	"For example, check the path distance of node 2"
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: 5.

	"Check the path distance of node 3"
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: 4.

	"Check the path distance of node 4"
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: 8.

	"Check the path distance of node 5"
	self assert: (refAIBellmanFord findNode: 5) pathDistance equals: 3.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testRunFromTo [
	| graphType graph startNode endNode expectedPath |
	"Set up the test: Create a graph and set start and end nodes."
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.

	startNode := $1.
	endNode := $5.

	"Run the method under test."
	refAIBellmanFord runFrom: startNode to: endNode.

	"Define the expected path (using the graph's structure)."
	expectedPath := #( 1 5 ).

	"Assert that the returned path is as expected."
	self assertCollection: refAIBellmanFord reconstructPath asArray equals: expectedPath.

	"Test with a different start and end node"
	startNode := $1.
	endNode := $3.

	refAIBellmanFord reset. "Reset the algorithm before running again"
	refAIBellmanFord runFrom: startNode to: endNode.
	expectedPath := #( 1 3 ).
	self assertCollection: refAIBellmanFord reconstructPath asArray equals: expectedPath.

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m3 >> testStart [
	| graphType graph nodeA |
	"Test that start: correctly sets the start node and initializes its pathDistance to 0."
	"Get a graph for testing"
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	"Set the nodes and edges for the Bellman-Ford algorithm"
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord 	   edges: graph edges		from: #first		to: #second		weight: #third.
	"Get a node to use as the start node"
	nodeA := graph findNode: 1.
	"Call the start: method"
	refAIBellmanFord start: 1.
	"Assert that the start node is correctly set"
	self assert: refAIBellmanFord start equals: (refAIBellmanFord findNode: 1).
	"Assert that the pathDistance of the start node is initialized to 0"
	self assert: nodeA pathDistance equals: 0.

]
