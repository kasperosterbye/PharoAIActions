Extension { #name : 'Array' }

{ #category : '*AIActions' }
Array >> aiaComment [
	^ (AIAPackageComment new aiaCommentMany: self) response
]
