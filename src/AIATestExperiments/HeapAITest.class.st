Class {
	#name : 'HeapAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refHeap'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
HeapAITest >> setUp [
	super setUp.
	refHeap := Heap new.
]

{ #category : 'AI generated test' }
HeapAITest >> testArray [
	"Test that the array method returns the internal storage array of the heap"

	| initialArraySize |
	initialArraySize := 10.
	self assert: refHeap array isArray.
	self assert: refHeap array size equals: initialArraySize.
	self assert: refHeap size equals: 0.

	"Add an element and verify it is stored in the array"
	refHeap add: 42.
	self assert: (refHeap array includes: 42).
	self assert: refHeap size equals: 1.

	"Add another element to ensure the array grows or accommodates it"
	refHeap add: 100.
	self assert: (refHeap array includes: 100).
	self assert: refHeap size equals: 2
]

{ #category : 'AI generated test' }
HeapAITest >> testAt [
	"Test that at: raises an error since Heap is not designed for sequential access."

	| index |
	index := 1.
	self should: [ refHeap at: index ] raise: Error
]

{ #category : 'AI generated test' }
HeapAITest >> testAtPut [
	"Test that at:put: raises an error as Heap is not designed for sequential access."

	self should: [ refHeap at: 1 put: 42 ] raise: ShouldNotImplement
]

{ #category : 'AI generated test' }
HeapAITest >> testCollect [
	"Test that collect: applies the block to each element and returns an Array with the results."

	| block result |

	"Add some elements to the heap"
	refHeap add: 1; add: 3; add: 2.

	"Define a block that doubles each element"
	block := [ :each | each * 2 ].

	"Apply collect: with the block"
	result := refHeap collect: block.

	"Verify the result has the correct number of elements"
	self assert: result size equals: 3.

	"Verify the result contains all expected transformed values (order may vary due to heap structure)"
	self assert: (result includesAll: #(2 4 6))
]

{ #category : 'AI generated test' }
HeapAITest >> testDownHeap [
	"Test that downHeap: restores the min-heap property when the root is too large (violates with children)"
| extracted |
	
	refHeap add: 1; add: 3; add: 2.
	"Builds a valid min-heap: #(nil, 1, 3, 2)"
	refHeap array at: 1 put: 4.
	"Violate heap property: #(nil, 4, 3, 2), root 4 > children 3 and 2"
	refHeap downHeap: 1.
	"Should sift down to #(nil, 2, 3, 4)"
	self assert: (refHeap array at: 1) equals: 2.
	self assert: (refHeap array at: 2) equals: 3.
	self assert: (refHeap array at: 3) equals: 4.
	"Verify by extracting all elements in sorted order"
	extracted := OrderedCollection new.
	[ refHeap isEmpty ] whileFalse: [ extracted add: refHeap removeFirst ].
	self assert: extracted asArray equals: #(2 3 4)
]

{ #category : 'AI generated test' }
HeapAITest >> testDownHeapSingle [
	"Test the downHeapSingle: method for various cases: when anIndex is 0, sift down, and sift up."

	| array before |

	"Case 1: anIndex = 0, should do nothing"
	array := refHeap instVarAt: 1.
	array at: 1 put: 1; at: 2 put: 2; at: 3 put: 3.
	refHeap instVarAt: 2 put: 3.
	before := array copyFrom: 1 to: 3.
	refHeap downHeapSingle: 0.
	self assert: (array copyFrom: 1 to: 3) equals: before.

	"Case 2: Sift down from root, violation at index 1"
	array at: 1 put: 3; at: 2 put: 1; at: 3 put: 2.
	refHeap downHeapSingle: 1.
	self assert: (array at: 1) equals: 1.
	self assert: (array at: 2) equals: 3.
	self assert: (array at: 3) equals: 2.
	"Verify heap property: parent <= children"
	self assert: (array at: 1) <= (array at: 2).
	self assert: (array at: 1) <= (array at: 3).

	"Case 3: Sift up from leaf, violation at index 3"
	array at: 1 put: 1; at: 2 put: 3; at: 3 put: 0.
	refHeap downHeapSingle: 3.
	self assert: (array at: 1) equals: 0.
	self assert: (array at: 2) equals: 3.
	self assert: (array at: 3) equals: 1.
	"Verify heap property"
	self assert: (array at: 1) <= (array at: 2).
	self assert: (array at: 1) <= (array at: 3).
]

{ #category : 'AI generated test' }
HeapAITest >> testFirst [
	"Test that first returns the smallest element according to the default sort block."

	refHeap
		add: 5;
		add: 1;
		add: 3.
	self assert: refHeap first equals: 1
]

{ #category : 'AI generated test' }
HeapAITest >> testFullySort [
	"Test that fullySort sorts the internal array in ascending order while preserving the heap invariants."

	| elements expected actualArray |
	elements := #(4 2 1 3).
	refHeap addAll: elements.
	expected := elements sorted.

	"Verify the internal array is not sorted before fullySort"
	actualArray := refHeap instVarAt: 1.
	self deny: ((actualArray first: refHeap size) sorted = (actualArray first: refHeap size)).

	refHeap fullySort.

	"Verify the internal array is now sorted in ascending order"
	actualArray := refHeap instVarAt: 1.
	self assert: (actualArray first: refHeap size) equals: expected.

	"Verify heap invariants are preserved by checking removeFirst returns the minimum"
	self assert: refHeap removeFirst equals: expected first
]

{ #category : 'AI generated test' }
HeapAITest >> testGrow [
	| initialCapacity newCapacity elements |
	elements := #(1 2 3 4 5).
	refHeap := Heap withAll: elements.
	"Heap is created with array of size 5, fully filled with 5 elements"
	initialCapacity := (refHeap instVarNamed: #array) size.
	self assert: initialCapacity equals: 5.
	"Call grow, which should increase capacity to 10 (5 + growSize of 5)"
	refHeap grow.
	newCapacity := (refHeap instVarNamed: #array) size.
	self assert: newCapacity equals: 10.
	"Verify that the number of elements remains the same"
	self assert: refHeap size equals: 5.
	"Verify that the contents are preserved by comparing sorted versions"
	self assert: (refHeap asArray sorted) equals: elements sorted
]

{ #category : 'AI generated test' }
HeapAITest >> testGrowSize [
	| smallHeap mediumHeap |
	"Test growSize when array size is less than 5, should return 5"
	smallHeap := Heap new: 3.
	self assert: smallHeap growSize equals: 5.
	
	"Test growSize when array size is greater than 5, should return array size"
	mediumHeap := Heap new: 7.
	self assert: mediumHeap growSize equals: 7.
	
	"Test growSize for default heap size of 10"
	self assert: refHeap growSize equals: 10
]

{ #category : 'AI generated test' }
HeapAITest >> testGrowTo [
	| elementsBefore newCapacity oldCapacity |
	oldCapacity := (refHeap instVarNamed: #array) size.
	"Add some elements to the heap"
	refHeap
		add: 10;
		add: 5;
		add: 15;
		add: 1.
	self assert: refHeap size equals: 4.
	elementsBefore := SortedCollection withAll: refHeap.
	newCapacity := oldCapacity + 10.
	"Grow the heap to a larger capacity"
	refHeap growTo: newCapacity.
	"Verify that the capacity has increased"
	self assert: (refHeap instVarNamed: #array) size equals: newCapacity.
	"Verify that the number of elements remains the same"
	self assert: refHeap size equals: 4.
	"Verify that the elements are preserved"
	self assert: (SortedCollection withAll: refHeap) equals: elementsBefore
]

{ #category : 'AI generated test' }
HeapAITest >> testIndexUpdateBlock [
	"Test that indexUpdateBlock: sets the block correctly and affects the behavior during add operations."

	| called |
	called := 0.
	refHeap indexUpdateBlock: [ :data :index | called := called + 1 ].
	refHeap add: 42.
	self assert: called > 0 description: 'The block should be called during add when set'.

	called := 0.
	refHeap indexUpdateBlock: nil.
	refHeap add: 43.
	self assert: called = 0 description: 'The block should not be called during add when set to nil'.
]
