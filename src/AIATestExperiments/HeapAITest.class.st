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

{ #category : 'tests' }
HeapAITest >> testDownHeap [
	| array expected |
	"Set the sort block to default min-heap order and index update block to nil"
	refHeap instVarAt: 3 put: [ :a :b | a <= b ].
	refHeap instVarAt: 4 put: nil.
	
	"Test case 1: Sift down swapping with left child"
	array := #(3 1 2) asArray.
	refHeap
		instVarAt: 1 put: array copy;
		instVarAt: 2 put: 3.
	refHeap downHeap: 1.
	expected := #(1 3 2) asArray.
	self assert: (refHeap instVarAt: 1) equals: expected.
	
	"Test case 2: Sift down swapping with right child (right is smaller)"
	array := #(3 2 1) asArray.
	refHeap
		instVarAt: 1 put: array copy;
		instVarAt: 2 put: 3.
	refHeap downHeap: 1.
	expected := #(1 2 3) asArray.
	self assert: (refHeap instVarAt: 1) equals: expected.
	
	"Test case 3: Multi-level sift down"
	array := #(4 1 3 2) asArray.
	refHeap
		instVarAt: 1 put: array copy;
		instVarAt: 2 put: 4.
	refHeap downHeap: 1.
	expected := #(1 2 3 4) asArray.
	self assert: (refHeap instVarAt: 1) equals: expected.
	
	"Test case 4: No violation, no sift down occurs"
	array := #(1 3 2) asArray.
	refHeap
		instVarAt: 1 put: array copy;
		instVarAt: 2 put: 3.
	refHeap downHeap: 1.
	self assert: (refHeap instVarAt: 1) equals: array.
	
	"Test case 5: anIndex = 0 returns immediately, no change"
	array := #(3 1 2) asArray.
	refHeap
		instVarAt: 1 put: array copy;
		instVarAt: 2 put: 3.
	refHeap downHeap: 0.
	self assert: (refHeap instVarAt: 1) equals: array
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

{ #category : 'AI generated test' }
HeapAITest >> testUpHeap [
	| arr |
	"Test upHeap: for index 0, should do nothing"
	refHeap upHeap: 0.
	self assert: true. "No error, no change expected"

	"Set up min-heap sort block"
	refHeap sortBlock: [ :a :b | a <= b ].

	"Test upHeap:1 on single element, no change"
	arr := Array new: 10.
	arr at: 1 put: 5.
	refHeap instVarAt: 1 put: arr.
	refHeap instVarAt: 2 put: 1.
	refHeap upHeap: 1.
	self assert: ((refHeap instVarAt: 1) at: 1) equals: 5.

	"Test upHeap:2 with swap needed (smaller child)"
	arr := Array new: 10.
	arr at: 1 put: 3.
	arr at: 2 put: 1.
	refHeap instVarAt: 1 put: arr.
	refHeap instVarAt: 2 put: 2.
	refHeap upHeap: 2.
	self assert: ((refHeap instVarAt: 1) at: 1) equals: 1.
	self assert: ((refHeap instVarAt: 1) at: 2) equals: 3.

	"Test upHeap:2 with no swap (larger child)"
	arr := Array new: 10.
	arr at: 1 put: 3.
	arr at: 2 put: 4.
	refHeap instVarAt: 1 put: arr.
	refHeap instVarAt: 2 put: 2.
	refHeap upHeap: 2.
	self assert: ((refHeap instVarAt: 1) at: 1) equals: 3.
	self assert: ((refHeap instVarAt: 1) at: 2) equals: 4.

	"Test upHeap:3 with one swap to root"
	arr := Array new: 10.
	arr at: 1 put: 3.
	arr at: 2 put: 4.
	arr at: 3 put: 2.
	refHeap instVarAt: 1 put: arr.
	refHeap instVarAt: 2 put: 3.
	refHeap upHeap: 3.
	self assert: ((refHeap instVarAt: 1) at: 1) equals: 2.
	self assert: ((refHeap instVarAt: 1) at: 2) equals: 4.
	self assert: ((refHeap instVarAt: 1) at: 3 )equals: 3.

	"Test upHeap:4 with multiple swaps"
	arr := Array new: 10.
	arr at: 1 put: 1.
	arr at: 2 put: 3.
	arr at: 3 put: 2.
	arr at: 4 put: 0.
	refHeap instVarAt: 1 put: arr.
	refHeap instVarAt: 2 put: 4.
	refHeap upHeap: 4.
	self assert: ((refHeap instVarAt: 1) at: 1) equals: 0.
	self assert: ((refHeap instVarAt: 1) at: 2) equals: 1.
	self assert: ((refHeap instVarAt: 1) at: 3) equals: 2.
	self assert: ((refHeap instVarAt: 1) at: 4 )equals: 3.
]

{ #category : 'AI generated test' }
HeapAITest >> testUpdateObjectIndex [
	"Test that updateObjectIndex: notifies the object at the given index via the indexUpdateBlock if it is set."

	| heap updateCalls obj |
	updateCalls := OrderedCollection new.
	heap := Heap new.
	"Add an object without the block set, so no notification yet"
	obj := 42.
	heap add: obj.
	"Now set the indexUpdateBlock to capture the notifications"
	heap indexUpdateBlock: [ :object :index | updateCalls add: object -> index ].
	"Directly invoke the method to test it"
	heap updateObjectIndex: 1.
	"Verify the notification was sent with correct object and index"
	self assert: updateCalls size equals: 1.
	self assert: (updateCalls first key) equals: obj.
	self assert: (updateCalls first value) equals: 1
]
