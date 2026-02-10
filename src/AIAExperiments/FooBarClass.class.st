Class {
	#name : 'FooBarClass',
	#superclass : 'Object',
	#category : 'AIAExperiments-AlgorithmicCore',
	#package : 'AIAExperiments',
	#tag : 'AlgorithmicCore'
}

{ #category : 'as yet unclassified' }
FooBarClass class >> githubIssueDiscussion: issueNumber [
    "Return a clean text summary of the GitHub issue discussion.
     repoFullName = 'owner/repo' e.g. 'pillar-markup/Microdown'
     issueNumber = Integer e.g. 989
     Returns a multi-line String ready for LLM context."

    | baseUrl repoFullName issueUrl commentsUrl client issueJson commentsJson discussion |
	 repoFullName := 'pillar-markup/Microdown'.
    baseUrl := 'https://api.github.com/repos/' , repoFullName.
    issueUrl := baseUrl , '/issues/' , issueNumber asString.
    commentsUrl := issueUrl , '/comments'.

    client := ZnClient new
        beOneShot;               "ikke persistent"
        timeout: 10;             "sekunder"
        yourself.

    "Hent issue selv (body + metadata)"
    issueJson := client get: issueUrl.
    issueJson isEmptyOrNil ifTrue: [ ^ 'Fejl: Kunne ikke hente issue' ].

    "Parse JSON (Zn giver String, vi bruger NeoJSONReader)"
    issueJson := STONJSON fromString: issueJson.
	 issueJson at: 'user' ifAbsent: [^ 'Issue number: ', issueNumber asString , ' is not found'].
    discussion := WriteStream on: String new.

    discussion
        nextPutAll: 'Title: ';
        nextPutAll: (issueJson at: 'title' ifAbsent: ['(no title)']);
        cr; cr;
        nextPutAll: 'Opened by: ';
        nextPutAll: ((issueJson at: 'user') at: 'login');
        nextPutAll: ' on ';
        nextPutAll: (issueJson at: 'created_at');
        cr;
        nextPutAll: 'State: ';
        nextPutAll: (issueJson at: 'state');
        cr; cr;
        nextPutAll: 'Original post / Body:'; cr;
        nextPutAll: (issueJson at: 'body' ifAbsent: ['(no body)']); cr; cr.

    "Hent kommentarer"
    commentsJson := client get: commentsUrl.
    commentsJson := STONJSON fromString: commentsJson.

    discussion
        nextPutAll: 'Comments:'; cr.

    commentsJson isEmpty
        ifTrue: [ discussion nextPutAll: '(yet no comments)'; cr ]
        ifFalse: [
            commentsJson withIndexDo: [ :comment :index |
                discussion
                    nextPutAll: index asString , '. By ';
                    nextPutAll: ((comment at: 'user') at: 'login');
                    nextPutAll: ' on ';
                    nextPutAll: (comment at: 'created_at');
                    cr;
                    nextPutAll: (comment at: 'body' ifAbsent: ['(no text)']);
                    cr; cr ] ].

    ^ discussion contents
]

{ #category : 'logical operations' }
FooBarClass >> githubIssueDiscussion: issueNumber forRepo: repoFullName [
    "Return a clean text summary of the GitHub issue discussion.
     repoFullName = 'owner/repo' e.g. 'pillar-markup/Microdown'
     issueNumber = Integer e.g. 989
     Returns a multi-line String ready for LLM context."

    | baseUrl issueUrl commentsUrl client issueJson commentsJson discussion |

    baseUrl := 'https://api.github.com/repos/' , repoFullName.
    issueUrl := baseUrl , '/issues/' , issueNumber asString.
    commentsUrl := issueUrl , '/comments'.

    client := ZnClient new
        beOneShot;               "ikke persistent"
        timeout: 10;             "sekunder"
        yourself.

    "Hent issue selv (body + metadata)"
    issueJson := client get: issueUrl.
    issueJson isEmptyOrNil ifTrue: [ ^ 'Fejl: Kunne ikke hente issue' ].

    "Parse JSON (Zn giver String, vi bruger NeoJSONReader)"
    issueJson := STONJSON fromString: issueJson.

    discussion := WriteStream on: String new.

    discussion
        nextPutAll: 'Title: ';
        nextPutAll: (issueJson at: 'title' ifAbsent: ['(ingen titel)']);
        cr; cr;
        nextPutAll: 'Opened by: ';
        nextPutAll: ((issueJson at: 'user') at: 'login');
        nextPutAll: ' on ';
        nextPutAll: (issueJson at: 'created_at');
        cr;
        nextPutAll: 'State: ';
        nextPutAll: (issueJson at: 'state');
        cr; cr;
        nextPutAll: 'Original post / Body:'; cr;
        nextPutAll: (issueJson at: 'body' ifAbsent: ['(ingen body)']); cr; cr.

    "Hent kommentarer"
    commentsJson := client get: commentsUrl.
    commentsJson := STONJSON fromString: commentsJson.

    discussion
        nextPutAll: 'Comments:'; cr.

    commentsJson isEmpty
        ifTrue: [ discussion nextPutAll: '(ingen kommentarer endnu)'; cr ]
        ifFalse: [
            commentsJson withIndexDo: [ :comment :index |
                discussion
                    nextPutAll: index asString , '. By ';
                    nextPutAll: ((comment at: 'user') at: 'login');
                    nextPutAll: ' on ';
                    nextPutAll: (comment at: 'created_at');
                    cr;
                    nextPutAll: (comment at: 'body' ifAbsent: ['(ingen tekst)']);
                    cr; cr ] ].

    ^ discussion contents
]

{ #category : 'logical operations' }
FooBarClass >> | foo [
	^ 7 + foo
]
