Class {
	#name : 'CheckCollection',
	#superclass : 'OrderedCollection',
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'inspector' }
CheckCollection >> inspectionChecks: specBuilder [
    "Present each LLM check as a readable entry, while retaining
    the original result dictionary for further inspection."

    <inspectorPresentationOrder: -1 title: 'Checks'>

    | inspectorBuilder |

    inspectorBuilder := StSimpleInspectorBuilder on: specBuilder.

    self doWithIndex: [ :result :index |
        | provider model status label |

        provider := result at: #provider.
        model := result at: #model.
        status := result at: #status.

        label := provider name, ' - ',
            model asString, ' - ',
            status asString.

        inspectorBuilder
            key: label
            value: result ].

    ^ inspectorBuilder table
]
