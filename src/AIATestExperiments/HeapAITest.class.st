Class {
	#name : 'HeapAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refHeap'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'AI generated test' }
HeapAITest >> API [ Error: tried more than the 50 allowed TOOLS calls
]

{ #category : 'initialization' }
HeapAITest >> setUp [
	super setUp.
	refHeap := Heap new.
]

{ #category : 'AI generated test' }
HeapAITest >> testAdd [
	| newObject |
	newObject := 'testObject'.
	refHeap add: newObject.
	self assert: (refHeap includes: newObject).
	self assert: (refHeap size = 1).
	self assert: (refHeap first = newObject).
]

{ #category : 'AI generated test' }
HeapAITest >> testArray [
	"Test that Heap>>array answers the underlying Array used as storage.
	We only rely on messages confirmed to exist in Pharo 14 for Heap and TestCase."

	| internalArray |
	internalArray := refHeap array.

	self assert: (internalArray isKindOf: Array).
	self assert: (internalArray == (refHeap array)).
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
HeapAITest >> testCopyEmpty [
	"Test that copyEmpty returns a new empty Heap instance with the same sortBlock as the receiver, without modifying the original."

	| emptyCopy |
	refHeap add: 1; add: 2.
	emptyCopy := refHeap copyEmpty.
	self assert: (emptyCopy isKindOf: Heap).
	self assert: emptyCopy isEmpty.
	self assert: (emptyCopy sortBlock = refHeap sortBlock).
	self assert: (refHeap size = 2)
]

{ #category : 'AI generated test' }
HeapAITest >> testDefaultSortBlock [
	"Test that the defaultSortBlock returns a block that compares elements using <=."

	| block |
	block := refHeap defaultSortBlock.
	self assert: (block isKindOf: BlockClosure).
	"Test that smaller <= larger is true"
	self assert: (block cull: 1 cull: 2).
	"Test that larger <= smaller is false"
	self assert: (block cull: 2 cull: 1) not
]

{ #category : 'AI generated test' }
HeapAITest >> testDo [
	"Test that do: evaluates the block for each element in the heap"

	| sum expected |
	"Add some elements to the heap"
	refHeap
		add: 1;
		add: 3;
		add: 2.
	"Initialize variables for summing elements"
	sum := 0.
	expected := 6.
	"Apply do: to sum all elements"
	refHeap do: [ :each | sum := sum + each ].
	"Assert the sum matches the expected total"
	self assert: sum equals: expected
]

{ #category : 'AI generated test' }
HeapAITest >> testDownHeap [
	"Test the downHeap: method by manually setting a violated heap state and verifying restoration for a min-heap."
	
	refHeap := Heap new: 2.
	refHeap instVarNamed: #array put: (Array with: 2 with: 1).
	refHeap instVarNamed: #tally put: 2.
	refHeap downHeap: 1.
	self assert: ((refHeap instVarNamed: #array) = (Array with: 1 with: 2))
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
HeapAITest >> testIsEmpty [
	"Test that an empty Heap returns true for isEmpty"
	self assert: refHeap isEmpty.
	
	"Test that a non-empty Heap returns false for isEmpty"
	refHeap add: 42.
	self deny: refHeap isEmpty
]

{ #category : 'AI generated test' }
HeapAITest >> testIsHeap [
	"Test that instances of Heap return true for isHeap"
	self assert: (refHeap isHeap)
]

{ #category : 'AI generated test' }
HeapAITest >> testIsSorted [
	"Test the isSorted method on Heap instances."

	"Test empty heap"
	self assert: refHeap isEmpty.
	self assert: (refHeap isSorted).

	"Test heap with single element"
	refHeap add: 42.
	self assert: (refHeap size = 1).
	self assert: (refHeap isSorted).

	"Test that isSorted raises Error for heaps with multiple elements,
	since at: is not implemented"
	refHeap add: 10.
	self should: [ refHeap isSorted ] raise: Error
]

{ #category : 'AI generated test' }
HeapAITest >> testIsSortedBy [
	| heap sortBlock |
	sortBlock := [ :a :b | a <= b ].
	"Test empty heap returns true"
	heap := Heap new.
	self assert: (heap isSortedBy: sortBlock).
	"Test heap with one element returns true"
	heap add: 42.
	self assert: (heap isSortedBy: sortBlock).
	"Test that accessing with multiple elements raises an error due to at:"
	heap add: 10.
	self
		should: [ heap isSortedBy: sortBlock ]
		raise: Error
		whoseDescriptionIncludes: 'at:'
		description: 'Heap does not implement at: so isSortedBy: errors for size > 1'
]

{ #category : 'AI generated test' }
HeapAITest >> testMergeFirstMiddleLastIntoBy [
	"Test the private merge method by setting up a heap with two sorted halves and verifying the merged result in dst."

	| dst |
	"Set up array with first half [1,5] sorted, second half [2,3] sorted"
	refHeap instVarNamed: #array put: #(1 5 2 3) asArray.
	refHeap instVarNamed: #tally put: 4.
	dst := Array new: 4.
	refHeap
		mergeFirst: 1
		middle: 2
		last: 4
		into: dst
		by: [ :a :b | a <= b ].
	self assert: (dst = #(1 2 3 5) asArray)
]

{ #category : 'AI generated test' }
HeapAITest >> testPostCopy [
	| copy |
	"Add some elements to the heap to have a non-empty array"
	refHeap add: 1; add: 3; add: 2.
	"Create a shallow copy, which triggers postCopy"
	copy := refHeap copy.
	"Verify that the arrays are different objects after copying"
	self assert: (refHeap array ~~ copy array) description: 'postCopy should create a new array copy'.
	"Verify that the sizes are the same initially"
	self assert: (refHeap size = copy size) description: 'Copy should have the same size'.
	"Modify the original by removing the first element (smallest, 1)"
	refHeap removeFirst.
	"Verify that the copy remains unchanged"
	self assert: (copy size = 3) description: 'Copy size should not change after modifying original'.
	self assert: (copy first = 1) description: 'Copy first element should remain the smallest'.
]

{ #category : 'AI generated test' }
HeapAITest >> testPrivateRemoveAt [
	| removed arrayAfter |
	"Create a heap with elements 1,3,4,2 to form [1,2,4,3]"
	refHeap
		add: 1;
		add: 3;
		add: 4;
		add: 2.
	"Remove the root (index 1), which is 1, last element 3 moves to root, then downheap to [2,3,4,nil]"
	removed := refHeap privateRemoveAt: 1.
	self assert: (removed = 1).
	self assert: (refHeap size = 3).
	arrayAfter := refHeap instVarNamed: #array.
	self assert: ((arrayAfter at: 1) = 2).
	self assert: ((arrayAfter at: 2) = 3).
	self assert: ((arrayAfter at: 3) = 4).
	self assert: ((arrayAfter at: 4) = nil).
	"Verify the heap property by sequential removal"
	self assert: (refHeap removeFirst = 2).
	self assert: (refHeap removeFirst = 3).
	self assert: (refHeap removeFirst = 4).
	self assert: refHeap isEmpty
]

{ #category : 'AI generated test' }
HeapAITest >> testPrivateReverseSort [
	"Test that privateReverseSort arranges the heap array in descending order for a min-heap."

	| elements size internalArray |
	"Create a collection of unsorted numbers"
	elements := (1 to: 5) shuffled.
	"Add elements to the heap, which maintains the min-heap property"
	elements do: [ :each | refHeap add: each ].
	"Save the current size before sorting"
	size := refHeap size.
	"Invoke the private method to reverse sort"
	refHeap privateReverseSort.
	"Access the internal array to verify the order"
	internalArray := refHeap instVarNamed: #array.
	"Check that the array is sorted in descending order"
	1 to: size - 1 do: [ :i |
		self assert: (internalArray at: i) >= (internalArray at: i + 1) ]
]

{ #category : 'AI generated test' }
HeapAITest >> testReSort [
	| elements extracted |
	"Test that reSort properly heapifies an unsorted collection"
	elements := {3. 1. 4. 1. 5}.
	refHeap setCollection: elements tally: elements size.
	"Before reSort, the heap is not sorted, so first is not the minimum"
	self assert: (refHeap first = 3).
	self assert: (refHeap first ~= 1).
	refHeap reSort.
	"Now extract all elements via removeFirst to verify sorted order"
	extracted := OrderedCollection new.
	[ refHeap isEmpty ] whileFalse: [ extracted add: refHeap removeFirst ].
	self assert: extracted asArray equals: #(1 1 3 4 5).
	"Test reSort on empty heap does nothing"
	refHeap reSort.
	self assert: refHeap isEmpty
]

{ #category : 'AI generated test' }
HeapAITest >> testRemoveAll [
	"Test that removeAll empties the heap correctly."

	| initialSize |
	"Add some elements to the heap"
	refHeap add: 1.
	refHeap add: 3.
	refHeap add: 2.
	initialSize := refHeap size.
	self assert: initialSize equals: 3.

	"Remove all elements"
	refHeap removeAll.

	"Verify the heap is empty"
	self assert: (refHeap isEmpty).
	self assert: refHeap size equals: 0
]

{ #category : 'AI generated test' }
HeapAITest >> testRemoveFirst [
	"Test that removeFirst removes and returns the smallest element according to the default sort block."
	| removed |
	refHeap add: 3; add: 1; add: 2.
	self assert: (refHeap size = 3).
	removed := refHeap removeFirst.
	self assert: (removed = 1).
	self assert: (refHeap size = 2).
	self assert: (refHeap first = 2)
]

{ #category : 'AI generated test' }
HeapAITest >> testRemoveIfAbsent [
	| removed |
	"Test removing an existing element"
	refHeap add: 5.
	refHeap add: 3.
	self assert: refHeap size equals: 2.
	removed := refHeap remove: 5 ifAbsent: [ self error: 'Should find element' ].
	self assert: removed equals: 5.
	self assert: refHeap size equals: 1.
	
	"Test removing an absent element"
	removed := refHeap remove: 10 ifAbsent: [ 42 ].
	self assert: removed equals: 42.
	self assert: refHeap size equals: 1.
	
	"Test removing when multiple equal elements exist"
	refHeap add: 3.
	refHeap add: 3.
	self assert: refHeap size equals: 3.
	removed := refHeap remove: 3 ifAbsent: [ self error: 'Should find element' ].
	self assert: removed equals: 3.
	self assert: refHeap size equals: 2.
	"Remove another 3, confirming multiple were present"
	removed := refHeap remove: 3 ifAbsent: [ self error: 'Should find another element' ].
	self assert: removed equals: 3.
	self assert: refHeap size equals: 1.
	"Remove the last 3"
	removed := refHeap remove: 3 ifAbsent: [ self error: 'Should find last element' ].
	self assert: removed equals: 3.
	self assert: refHeap size equals: 0.
	
	"Test absent after all removed"
	removed := refHeap remove: 3 ifAbsent: [ 99 ].
	self assert: removed equals: 99.
	self assert: refHeap size equals: 0
]

{ #category : 'AI generated test' }
HeapAITest >> testSetCollection [
	| testArray |
	testArray := #(1 2 3).
	"Set the collection on the heap instance"
	refHeap setCollection: testArray.
	"Verify that the array slot is set to the provided collection"
	self assert: (refHeap instVarNamed: #array) equals: testArray.
	"Verify that the tally is reset to 0"
	self assert: (refHeap instVarNamed: #tally) equals: 0
]

{ #category : 'AI generated test' }
HeapAITest >> testSetCollectionTally [
	"Test that setCollection: tally: correctly sets the array and tally slots."
	| collection expectedTally |
	collection := #(1 2 3).
	expectedTally := 3.
	refHeap setCollection: collection tally: expectedTally.
	self assert: (refHeap instVarNamed: #array) equals: collection.
	self assert: (refHeap instVarNamed: #tally) equals: expectedTally
]

{ #category : 'AI generated test' }
HeapAITest >> testSize [
	"Test the size method of Heap, which returns the number of elements (tally)"

	"Verify empty heap has size 0"
	self assert: (refHeap size = 0).

	"Add one element and verify size is 1"
	refHeap add: 42.
	self assert: (refHeap size = 1).

	"Add another element and verify size is 2"
	refHeap add: 10.
	self assert: (refHeap size = 2).

	"Remove one element and verify size is 1"
	refHeap removeFirst.
	self assert: (refHeap size = 1)
]

{ #category : 'AI generated test' }
HeapAITest >> testSort [
	"Verify that Heap>>sort arranges elements in ascending order (using <=).
	We validate the order by repeatedly removing the first (minimum) element."

	| previous current |
	refHeap addAll: #(3 1 4 1 5 9 2 6 5).

	refHeap sort.

	self assert: (refHeap isEmpty not).

	previous := refHeap removeFirst.
	[ refHeap isEmpty ] whileFalse: [
		current := refHeap removeFirst.
		self assert: (previous <= current).
		previous := current
	].
]

{ #category : 'AI generated test' }
HeapAITest >> testSortBlock [
	| elements customBlock |
	elements := #(3 1 2).
	refHeap addAll: elements.
	self assert: refHeap size equals: 3.
	"Default behavior is min-heap, so first element is the smallest"
	self assert: (refHeap first) equals: 1.
	"Set custom sort block for max-heap (descending order)"
	customBlock := [ :a :b | a >= b ].
	refHeap sortBlock: customBlock.
	"Verify the sort block was set"
	self assert: (refHeap instVarNamed: #sortBlock) equals: customBlock.
	"After reSort, the heap is reorganized, first should now be the largest"
	self assert: (refHeap first) equals: 3.
	"Verify removal order is descending"
	self assert: refHeap removeFirst equals: 3.
	self assert: (refHeap first) equals: 2.
	self assert: refHeap removeFirst equals: 2.
	self assert: (refHeap first) equals: 1.
	self assert: refHeap removeFirst equals: 1.
	self assert: refHeap isEmpty
]

{ #category : 'AI generated test' }
HeapAITest >> testSorted [
	| elements sortedHeap extracted |

	"Use a small, deterministic set of numbers"
	elements := #(4 2 5 1 3).

	"Fill the reference heap provided by setUp (do not create another heap variable)"
	elements do: [ :each |  refHeap add: each ].
	self assert: (self refHeap size = elements size).

	"sorted: should return a NEW Heap instance, sorted using default order when argument is nil"
	sortedHeap := self refHeap sorted: nil.
	self assert: (sortedHeap class = Heap).
	self assert: (sortedHeap size = self refHeap size).

	"Verify sorted order by repeatedly removing the first element from the sorted heap"
	extracted := OrderedCollection new.
	[ sortedHeap isEmpty ] whileFalse: [
		extracted add: sortedHeap removeFirst ].
	self assert: (extracted asArray = #(1 2 3 4 5)).

	"Verify the original heap was not consumed by operations on the sorted copy"
	self assert: (self refHeap size = elements size)
]

{ #category : 'AI generated test' }
HeapAITest >> testSortsBefore [
	| customHeap |
	"Test the default sort block (ascending order)"
	self assert: (refHeap sorts: 1 before: 2).
	self deny: (refHeap sorts: 2 before: 1).
	
	"Test a custom sort block (descending order)"
	customHeap := Heap sortBlock: [ :a :b | a >= b ].
	self assert: (customHeap sorts: 2 before: 1).
	self deny: (customHeap sorts: 1 before: 2)
]

{ #category : 'AI generated test' }
HeapAITest >> testTrim [
	"trim should remove empty slots by shrinking the internal storage array
	to exactly the number of elements (tally/size), without changing the heap's
	logical contents."

	| internalArrayBefore internalArrayAfter sizeBefore sizeAfter |
	refHeap add: 5; add: 3; add: 7.

	"Capture internal storage size before trimming."
	internalArrayBefore := refHeap instVarNamed: #array.
	sizeBefore := refHeap size.

	"Sanity: internal array should be at least as large as the number of elements."
	self assert: (internalArrayBefore size >= sizeBefore).

	"Exercise"
	refHeap trim.

	"Verify: size unchanged, but internal array shrunk to exactly size."
	internalArrayAfter := refHeap instVarNamed: #array.
	sizeAfter := refHeap size.

	self assert: (sizeAfter = sizeBefore).
	self assert: (internalArrayAfter size = sizeAfter).
]

{ #category : 'AI generated test' }
HeapAITest >> testUpHeap [
	"Test the upHeap: method by setting up a small heap with violated property and verifying restoration."

	| array |
	array := Array with: 3 with: 1.
	refHeap instVarNamed: #array put: array.
	refHeap instVarNamed: #tally put: 2.

	refHeap upHeap: 2.

	self assert: ((refHeap instVarNamed: #array) at: 1) equals: 1.
	self assert: ((refHeap instVarNamed: #array) at: 2) equals: 3.

	"Test case where no swap is needed"
	array := Array with: 1 with: 3.
	refHeap instVarNamed: #array put: array.
	refHeap instVarNamed: #tally put: 2.

	refHeap upHeap: 2.

	self assert: ((refHeap instVarNamed: #array) at: 1) equals: 1.
	self assert: ((refHeap instVarNamed: #array) at: 2) equals: 3.

	"Test for anIndex = 0, should do nothing"
	array := Array with: 3 with: 1.
	refHeap instVarNamed: #array put: array.
	refHeap instVarNamed: #tally put: 2.

	refHeap upHeap: 0.

	self assert: ((refHeap instVarNamed: #array) at: 1) equals: 3.
	self assert: ((refHeap instVarNamed: #array) at: 2) equals: 1
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
