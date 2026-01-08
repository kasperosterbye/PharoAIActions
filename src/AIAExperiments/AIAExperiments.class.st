Class {
	#name : 'AIAExperiments',
	#superclass : 'Object',
	#category : 'AIAExperiments-AlgorithmicCore',
	#package : 'AIAExperiments',
	#tag : 'AlgorithmicCore'
}

{ #category : 'sorting' }
AIAExperiments >> merge: left and: right [
    | result i j |
    result := OrderedCollection new.
    i := j := 1.

    [ i <= left size and: [ j <= right size ] ] whileTrue: [
        (left at: i) <= (right at: j)
            ifTrue: [ result add: (left at: i). i := i + 1 ]
            ifFalse: [ result add: (right at: j). j := j + 1 ]
    ].

    "Add any remaining elements"
    i <= left size ifTrue: [ result addAll: (left copyFrom: i to: left size) ].
    j <= right size ifTrue: [ result addAll: (right copyFrom: j to: right size) ].

    ^ result asArray
]

{ #category : 'sorting' }
AIAExperiments >> partition: anArray from: low to: high [
    "Partition array around pivot (last element)"
    | pivot i |
    pivot := anArray at: high.
    i := low - 1.
    
    low to: high - 1 do: [ :j |
        (anArray at: j) <= pivot ifTrue: [
            i := i + 1.
            self swap: anArray at: i with: j
        ]
    ].
    
    self swap: anArray at: i + 1 with: high.
    ^ i + 1
]

{ #category : 'sorting' }
AIAExperiments >> quickSort: anArray from: low to: high [
    "Quicksort with in-place partitioning"
    low < high ifTrue: [
        | pivotIndex |
        pivotIndex := self partition: anArray from: low to: high.
        self quickSort: anArray from: low to: pivotIndex - 1.
        self quickSort: anArray from: pivotIndex + 1 to: high
    ].
    ^ anArray

]

{ #category : 'sorting' }
AIAExperiments >> sortClaude: anArray [
    "Efficient quicksort implementation"
    ^ self quickSort: anArray from: 1 to: anArray size
]

{ #category : 'sorting' }
AIAExperiments >> sortEva: anArray [
	| pivot smaller larger |
	anArray size <= 1 ifTrue: [ ^ anArray ].
	pivot := anArray first.
	smaller := anArray allButFirst select: [ :each | each <= pivot ].
	larger := anArray allButFirst select: [ :each | each > pivot ].
	^ (self sortMe: smaller), { pivot }, (self sortMe: larger)
]

{ #category : 'sorting' }
AIAExperiments >> sortMe: anArray [
	1 to: anArray size -1 do: [ :a |
		a + 1 to: anArray size do: [ :b |
			(anArray at: a) > (anArray at: b)
				ifTrue: [ |x| 
					x := anArray at: a.
					anArray at: a put: (anArray at: b).
					anArray at: b put: x ]  ]
		 ].
	^ anArray 
]

{ #category : 'sorting' }
AIAExperiments >> sortMistral: anArray [
    | n mid left right|
    n := anArray size.
    n <= 1 ifTrue: [ ^ anArray ].

    "Split the array into two halves"
    mid := n // 2.
    left := anArray copyFrom: 1 to: mid.
    right := anArray copyFrom: mid + 1 to: n.

    "Recursively sort each half"
    left := self sortMe: left.
    right := self sortMe: right.

    "Merge the sorted halves"
    ^ self merge: left and: right
]

{ #category : 'sorting' }
AIAExperiments >> swap: anArray at: i with: j [
    "Swap elements at positions i and j"
    | temp |
    temp := anArray at: i.
    anArray at: i put: (anArray at: j).
    anArray at: j put: temp
]
