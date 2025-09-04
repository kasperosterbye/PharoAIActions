Class {
	#name : 'AIBellmanFordAITest_m2',
	#superclass : 'TestCase',
	#instVars : [
		'refAIBellmanFord'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIBellmanFordAITest_m2 >> setUp [
	super setUp.
	refAIBellmanFord := AIBellmanFord new.
]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testEdgeClass [
	"Test that edgeClass returns the correct class for weighted edges in Bellman-Ford algorithm"

	self assert: refAIBellmanFord edgeClass equals: AIWeightedEdge

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testEnd [
	| node |
	"Test that end: sets the end node correctly"
	node := refAIBellmanFord findNode: $a.
	refAIBellmanFord end: $a.
	self assert: refAIBellmanFord end equals: node

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testNodeClass [
	"Test that nodeClass returns the correct class for nodes in the Bellman-Ford algorithm."

	| expectedClass actualClass |
	expectedClass := AIPathDistanceNode.
	actualClass := refAIBellmanFord nodeClass.
	self assert: actualClass equals: expectedClass

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testReconstructPath [
	| graphType graph |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	refAIBellmanFord runFrom: 0 to: 8.
	self assertCollection: refAIBellmanFord reconstructPath asArray equals: #(0 1 5 6 7 8)

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testRelaxEdges [
	"Test that relaxEdges correctly updates path distances and stops early if no edges are relaxed"

	| graphType graph |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord
		edges: graph edges
		from: #first
		to: #second
		weight: #third.

	refAIBellmanFord start: 0.
	refAIBellmanFord relaxEdges.

	"Verify that path distances are correctly updated"
	self assert: (refAIBellmanFord findNode: 1) pathDistance equals: 5.
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: 25.
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: 35.
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: 100.
	self assert: (refAIBellmanFord findNode: 5) pathDistance equals: 35.
	self assert: (refAIBellmanFord findNode: 6) pathDistance equals: 65.
	self assert: (refAIBellmanFord findNode: 7) pathDistance equals: 15.
	self assert: (refAIBellmanFord findNode: 8) pathDistance equals: 85.
	self assert: (refAIBellmanFord findNode: 9) pathDistance equals: 200

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testRelaxEdgesToNegativeInfinity [
	| graphType graph |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	refAIBellmanFord start: 0.
	refAIBellmanFord relaxEdges.
	refAIBellmanFord relaxEdgesToNegativeInfinity.
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 9) pathDistance equals: Float negativeInfinity

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testReset [
	"Test that reset sets all nodes' pathDistance to Float infinity and previousNode to nil"

	refAIBellmanFord reset.

	refAIBellmanFord nodes do: [ :node |
		self assert: node pathDistance equals: Float infinity.
		self assert: node previousNode isNil ]

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testRun [
	| graphType graph |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	refAIBellmanFord start: 0.
	refAIBellmanFord run.
	self assert: (refAIBellmanFord findNode: 1) pathDistance equals: 5.
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 5) pathDistance equals: 35.
	self assert: (refAIBellmanFord findNode: 6) pathDistance equals: 40.
	self assert: (refAIBellmanFord findNode: 7) pathDistance equals: -10.
	self assert: (refAIBellmanFord findNode: 8) pathDistance equals: -20.
	self assert: (refAIBellmanFord findNode: 9) pathDistance equals: Float negativeInfinity

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testRunFrom [
	| graphType graph |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	refAIBellmanFord runFrom: 0.
	self assert: (refAIBellmanFord findNode: 1) pathDistance equals: 5.
	self assert: (refAIBellmanFord findNode: 2) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 3) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 4) pathDistance equals: Float negativeInfinity.
	self assert: (refAIBellmanFord findNode: 5) pathDistance equals: 35.
	self assert: (refAIBellmanFord findNode: 6) pathDistance equals: 40.
	self assert: (refAIBellmanFord findNode: 7) pathDistance equals: -10.
	self assert: (refAIBellmanFord findNode: 8) pathDistance equals: -20.
	self assert: (refAIBellmanFord findNode: 9) pathDistance equals: Float negativeInfinity

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testRunFromTo [
	| graphType graph |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType negativeWeightedGraph.
	refAIBellmanFord nodes: graph nodes.
	refAIBellmanFord
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	refAIBellmanFord runFrom: 0 to: 8.
	self assertCollection: refAIBellmanFord reconstructPath asArray equals: #(0 1 5 6 7 8).

]

{ #category : 'AI generated test' }
AIBellmanFordAITest_m2 >> testStart [
	"Test that start: sets the start node and initializes its path distance to 0"

	| startNode |
	startNode := $a.
	refAIBellmanFord start: startNode.
	self assert: (refAIBellmanFord start model) equals: startNode.
	self assert: (refAIBellmanFord start pathDistance) equals: 0

]
