"
Tests that tool support in `OpenAIApi` can be switched on and off, both at provider (class) level and per instance, and that the generated request entity reflects that setting. Also verifies that reasoning models disable tools by default and send a `reasoning_effort` field instead.
"
Class {
	#name : 'AilienApiToolsTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'tests' }
AilienApiToolsTest >> testInstanceOverrideDoesNotChangeProviderSetting [
    | original api |

    original := OpenAIApi toolsEnabled.

    [
        OpenAIApi toolsEnabled: false.
        api := OpenAIApi new.

        self deny: api toolsEnabled.

        api toolsEnabled: true.

        self assert: api toolsEnabled.
        self deny: OpenAIApi toolsEnabled
    ]
    ensure: [
        OpenAIApi toolsEnabled: original ]
]

{ #category : 'tests' }
AilienApiToolsTest >> testInstanceUsesProviderToolsSetting [
    | original api |

    original := OpenAIApi toolsEnabled.

    [
        OpenAIApi toolsEnabled: false.
        api := OpenAIApi new.

        self deny: api toolsEnabled
    ]
    ensure: [
        OpenAIApi toolsEnabled: original ]
]

{ #category : 'tests' }
AilienApiToolsTest >> testLynxAvailable [
    "Verify that the installed Lynx is accessible from Pharo."

    self assert: ApiToolWebReader new lynxAvailable
]

{ #category : 'tests' }
AilienApiToolsTest >> testLynxReadUrl [
    "Verify that Lynx retrieves readable text rather than raw HTML."

    | result |

    result := ApiToolWebReader new
        lynxReadUrl: 'https://example.com'.

    self assert: (result includesSubstring: 'documentation examples').
    self deny: (result includesSubstring: '<html').
    self assert: result isNotEmpty
]

{ #category : 'tests' }
AilienApiToolsTest >> testProviderToolsAreEnabledByDefault [
    self assert: OpenAIApi toolsEnabled
]

{ #category : 'tests' }
AilienApiToolsTest >> testRequestContainsToolsWhenEnabled [
    | api entity |

    api := OpenAIApi new.
    api
        toolsEnabled: true;
        messageList: #().

    entity := api znClientEntity asDictionary.

    self assert: (entity includesKey: 'tools')
]

{ #category : 'tests' }
AilienApiToolsTest >> testRequestOmitsToolsWhenDisabled [
    | api entity |

    api := OpenAIApi new.
    api
        toolsEnabled: false;
        messageList: #().

    entity := api znClientEntity asDictionary.

    self deny: (entity includesKey: 'tools')
]

{ #category : 'tests' }
AilienApiToolsTest >> testToolsCanBeDisabledForInstance [
    | api |

    api := OpenAIApi new.
    api toolsEnabled: false.

    self deny: api toolsEnabled
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderContinuesAfterError [
    "Verify that a failed URL does not prevent processing subsequent URLs."

    | reader result |

    reader := ApiToolWebReader new.
    reader returnRaw: false.

    result := reader executeTool:
        { 'website' -> {
            'not-a-valid-url'.
            'https://example.com'
        } } asDictionary.

    self assert: (result includesSubstring: 'ERROR accessing not-a-valid-url').
    self assert: (result includesSubstring: 'documentation examples')
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderInvalidUrl [
    "Verify that an invalid URL produces an error message
    without interrupting tool execution."

    | reader result |

    reader := ApiToolWebReader new.
    reader returnRaw: false.

    result := reader executeTool:
        { 'website' -> { 'not-a-valid-url' } } asDictionary.

    self assert: (result includesSubstring: 'ERROR accessing').
    self assert: (result includesSubstring: 'not-a-valid-url')
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderLynxReducesSize [
    "Verify that Lynx substantially reduces the size of retrieved HTML."

    | reader args raw text |

    reader := ApiToolWebReader new.
    args := { 'website' -> { 'https://example.com' } } asDictionary.

    reader returnRaw: true.
    raw := reader executeTool: args.

    reader returnRaw: false.
    text := reader executeTool: args.

    self assert: text isNotEmpty.
    self assert: raw size > (text size * 3)
        description: 'Raw: ', raw size asString,
            ', Lynx: ', text size asString
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderMultipleUrls [
    "Verify that multiple URLs are processed in one request."

    | result |

    result := ApiToolWebReader new executeTool:
        { 'website' -> {
            'https://example.com'.
            'https://www.wikipedia.org'
        } } asDictionary.

    self assert: (result includesSubstring: 'URL: https://example.com').
    self assert: (result includesSubstring: 'URL: https://www.wikipedia.org').
    self assert: (result includesSubstring: 'documentation examples')
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderRejectsInvalidTimeout [
    "Verify that nonpositive timeout values are rejected."

    | reader |

    reader := ApiToolWebReader new.

    self
        should: [ reader timeoutSeconds: 0 ]
        raise: Error.

    self
        should: [ reader timeoutSeconds: -1 ]
        raise: Error
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderReturnsRawHtml [
    "Verify that returnRaw forces HTML retrieval through ZnClient."

    | reader result |

    reader := ApiToolWebReader new.
    reader returnRaw: true.

    result := reader executeTool:
        { 'website' -> { 'https://example.com' } } asDictionary.

    self assert: (result includesSubstring: 'documentation examples').
    self assert: (result includesSubstring: '<html')
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderUsesLynx [
    "Verify that returnRaw: false retrieves readable text using Lynx."

    | reader result |

    reader := ApiToolWebReader new.
    reader returnRaw: false.

    result := reader executeTool:
        { 'website' -> { 'https://example.com' } } asDictionary.

    self assert: (result includesSubstring: 'documentation examples').
    self deny: (result includesSubstring: '<html').
    self assert: result isNotEmpty
]

{ #category : 'tests' }
AilienApiToolsTest >> testWebReaderWithTimeout [
    "Verify that Lynx retrieves readable text with a configured timeout."

    | reader result |

    reader := ApiToolWebReader new.
    reader returnRaw: false.
    reader timeoutSeconds: 15.

    result := reader executeTool:
        { 'website' -> { 'https://example.com' } } asDictionary.

    self assert: (result includesSubstring: 'documentation examples').
    self deny: (result includesSubstring: '<html')
]
