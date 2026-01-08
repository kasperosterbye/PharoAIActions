Class {
	#name : 'AIAAIAstarTest',
	#superclass : 'TestCase',
	#instVars : [
		'astar'
	],
	#category : 'AIAExperiments-Tests',
	#package : 'AIAExperiments',
	#tag : 'Tests'
}

{ #category : 'running' }
AIAAIAstarTest >> setUp [
	super setUp.
	astar := AIAstar new
]

{ #category : 'tests' }
AIAAIAstarTest >> testHeuristicFromTo [
	| graphType graph dijkstra addEdges pathD use |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType aseCircuitWeightedGraph.
	dijkstra := AIDijkstra new.
	dijkstra nodes: graph nodes.
	dijkstra edges: graph edges
		from: #first
		to: #second
		weight: #third.
	use := OrderedCollection new.
	use add: $a.
	use add: $h.
	dijkstra start: use first.
	dijkstra end: use second.
	dijkstra run.
	pathD := (dijkstra findNode: $h) pathDistance.
	self assert: pathD equals: 5
]

{ #category : 'tests' }
AIAAIAstarTest >> testHeuristicFromTo01 [
	| graphType graph dijkstra addEdges pathD use |
	graphType := AIWeightedDAGFixture new.
	graph := graphType withoutCyclesComplexWeightedGraph.
	dijkstra := AIDijkstra new.
	dijkstra nodes: (graph nodes first to: graph nodes last).
	dijkstra edges: graph edges
		from: [ :each | each first ]
		to: [ :each | each second ]
		weight: [ :each | each third ].
	use := OrderedCollection new.
	use add: $b.
	use add: $r.
	dijkstra start: use first.
	dijkstra end: use second.
	dijkstra run.
	pathD := (dijkstra findNode: $r) pathDistance.
	self assert: pathD equals: 41
]

{ #category : 'tests' }
AIAAIAstarTest >> testHeuristicFromTo02 [
	| graphType graph dijkstra addEdges pathD use |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType aseCircuitWeightedGraph.
	dijkstra := AIDijkstra new.
	dijkstra nodes: graph nodes.
	dijkstra edges: graph edges from: #first to: #second weight: #third.
	use := OrderedCollection new.
	use add: $a.
	use add: $b.
	dijkstra start: use first.
	dijkstra end: use second.
	dijkstra run.
	pathD := (dijkstra findNode: $b) pathDistance.
	self assert: pathD equals: 1
]

{ #category : 'tests' }
AIAAIAstarTest >> testHeuristicFromTo03 [
	| graphType graph dijkstra addEdges pathD use |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType aseCircuitWeightedGraph.
	dijkstra := AIDijkstra new.
	dijkstra nodes: graph nodes.
	dijkstra edges: graph edges from: #first to: #second weight: #third.
	use := OrderedCollection new.
	use add: $a.
	use add: $h.
	dijkstra start: use first.
	dijkstra end: use second.
	dijkstra run.
	pathD := (dijkstra findNode: use second) pathDistance.
	self assert: pathD equals: 5
]

{ #category : 'nil' }
AIAAIAstarTest >> testReconstructPath [
	| graphType graph shortestPath |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	astar nodes: graph nodes.
	astar
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	shortestPath := astar
		runFrom: 1 to: 4;
		reconstructPath.
	self assertCollection: shortestPath hasSameElements: #(1 2 4).
]

{ #category : 'tests' }
AIAAIAstarTest >> testReset [
	astar := AIAstar new.
	astar nodes: (1 to: 5).
	astar edges: #( #( 1 2 5 ) #( 1 3 4 ) #( 2 3 2 ) #( 3 4 5 ) #( 2 4 3 ) #( 4 5 1 ) #( 5 1 2 ) #( 1 5 3 ) )
		from: #first
		to: #second
		weight: #third.
	astar start: 1.
	astar end: 5.
	astar run.
	self assert: (astar findNode: 2) pathDistance equals: 5.
	self assert: (astar findNode: 3) pathDistance equals: 4.
	self assert: (astar findNode: 4) pathDistance equals: 8.
	self assert: (astar findNode: 5) pathDistance equals: 3.
	astar reset.
	self assert: (astar findNode: 2) pathDistance equals: Float infinity.
	self assert: (astar findNode: 3) pathDistance equals: Float infinity.
	self assert: (astar findNode: 4) pathDistance equals: Float infinity.
	self assert: (astar findNode: 5) pathDistance equals: Float infinity.
]

{ #category : 'tests' }
AIAAIAstarTest >> testRun [
	| graphType graph |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	astar nodes: graph nodes.
	astar
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	astar runFrom: 1 to: 5.
	self assert: (astar findNode: 5) pathDistance equals: 3.
	self assertCollection: astar reconstructPath asArray equals: #(1 5)
]

{ #category : 'tests' }
AIAAIAstarTest >> testRunFromTo [
	| graphType graph shortestPath |
	graphType := AICyclicWeightedSimpleFixture new.
	graph := graphType simpleWeightedGraph.
	astar nodes: graph nodes.
	astar
		edges: graph edges
		from: #first
		to: #second
		weight: #third.
	shortestPath := astar
		runFrom: 1 to: 4;
		reconstructPath.
	self assertCollection: shortestPath hasSameElements: #(1 2 4).
]

{ #category : 'nil' }
AIAAIAstarTest >> testUpdateDistanceOfPreviousNode [
	| astar node1 node2 edge |
	astar := AIAstar new.
	node1 := AIPathDistanceNode new.
	node2 := AIPathDistanceNode new.
	edge := AIWeightedEdge new.
	edge from: node1; to: node2; weight: 5.
	astar updateDistance: 10 of: node2 previousNode: node1.
	self assert: node2 pathDistance equals: 10.
	self assert: node2 previousNode equals: node1.
]
