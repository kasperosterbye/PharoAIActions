Class {
	#name : 'ApiToolWebReader',
	#superclass : 'AilienApiTool',
	#instVars : [
		'returnRaw',
		'timeoutSeconds'
	],
	#category : 'AIActions-AIApiTool',
	#package : 'AIActions',
	#tag : 'AIApiTool'
}

{ #category : 'evaluating' }
ApiToolWebReader >> evaluateTool [
	| desc desc1 |
	desc := 'Can load any website, returning the html at that site. Always try https before http'.
	desc1 := 'The arrayed list of websites'.
    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'evaluating' }
ApiToolWebReader >> evaluateTool: descs [
	"Evaluates the tool with the given descriptions and returns a dictionary representation of the tool's configuration."
	| desc desc1|
	desc := descs first.
	desc1 := descs second.
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    required -> (Dictionary newFrom: {
                        'type' -> 'array'.
							  'items' -> (Dictionary newFrom: { 'type' -> 'string'}).
                        'description' -> desc1
                    })
                }).
                'required' -> {required} 
            })
        })
    }
]

{ #category : 'initialization' }
ApiToolWebReader >> executeTool: args [
    "Retrieve websites as readable text or raw HTML,
    according to the returnRaw setting."

    | response websites |

    super executeTool: args.
    response := WriteStream on: String new.
    websites := args at: required.

    websites do: [ :aWebsite |
        response
            nextPutAll: 'URL: ';
            nextPutAll: aWebsite;
            nextPut: Character lf.

        [
            response nextPutAll: (
                returnRaw
                    ifTrue: [ ZnClient new url: aWebsite; get ]
                    ifFalse: [ self lynxReadUrl: aWebsite ])
        ]
            on: Error
            do: [ :ex |
                response
                    nextPutAll: 'ERROR accessing ';
                    nextPutAll: aWebsite;
                    nextPutAll: ': ';
                    nextPutAll: ex messageText ].

        response nextPut: Character lf
    ].

    ^ response contents
]

{ #category : 'initialization' }
ApiToolWebReader >> initialize [
    "Initialize the web reader with its default retrieval settings."

    super initialize.
    name := 'getWebSite'.
    required := 'website'.
    returnRaw := self lynxAvailable not.
    timeoutSeconds := 15
]

{ #category : 'accessing' }
ApiToolWebReader >> lynxAvailable [
    "Answer whether Lynx can be executed from this Pharo process."

    ^ (LibC uniqueInstance system:
        'test -x /opt/homebrew/bin/lynx || command -v lynx >/dev/null 2>&1') = 0
]

{ #category : 'accessing' }
ApiToolWebReader >> lynxReadUrl: aUrl [
    "Retrieve readable text using Lynx, with connection and read timeouts."

    | file executable quotedUrl command status |

    ((aUrl beginsWith: 'https://')
        or: [ aUrl beginsWith: 'http://' ])
        ifFalse: [ self error: 'Unsupported URL scheme' ].

    executable := ('/opt/homebrew/bin/lynx' asFileReference exists)
        ifTrue: [ '/opt/homebrew/bin/lynx' ]
        ifFalse: [ 'lynx' ].

    file := FileLocator temp /
        ('lynx-', UUID new asString, '.txt').

    quotedUrl := '''',
        (aUrl copyReplaceAll: '''' with: '''"''"'''),
        ''''.

    command := executable,
        ' -dump -width=1000',
        ' -connect_timeout=', timeoutSeconds asString,
        ' -read_timeout=', timeoutSeconds asString,
        ' ', quotedUrl,
        ' > ', file fullName,
        ' 2>&1'.

    [
        status := LibC uniqueInstance system: command.

        status = 0
            ifFalse: [ self error: 'Lynx failed: ', status asString ].

        ^ file contents
    ] ensure: [
        file ensureDelete ]
]

{ #category : 'accessing' }
ApiToolWebReader >> returnRaw: aBoolean [
    "Control whether the tool returns raw HTML instead of Lynx text."

    returnRaw := aBoolean
]

{ #category : 'accessing' }
ApiToolWebReader >> timeoutSeconds: anInteger [
    "Set the connection and read timeouts in seconds."

    (anInteger isInteger and: [ anInteger > 0 ])
        ifFalse: [ self error: 'Timeout must be a positive integer' ].

    timeoutSeconds := anInteger
]
