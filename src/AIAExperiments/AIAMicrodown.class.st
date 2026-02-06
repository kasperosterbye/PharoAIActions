Class {
	#name : 'AIAMicrodown',
	#superclass : 'Object',
	#category : 'AIAExperiments-MicrodownExperiments',
	#package : 'AIAExperiments',
	#tag : 'MicrodownExperiments'
}

{ #category : 'as yet unclassified' }
AIAMicrodown class >> issue: issueNumber [
    ^ self new githubIssueDiscussion: issueNumber forRepositories: 'pillar-markup/Microdown'
]

{ #category : 'as yet unclassified' }
AIAMicrodown >> githubIssueDiscussion: issueNumber forRepositories: repoFullName [
    "Return a clean text summary of the GitHub issue discussion.
     repoFullName = 'owner/repo' e.g. 'pillar-markup/Microdown'
     issueNumber = Integer e.g. 989
     Returns a multi-line String ready for LLM context."

    | baseUrl  issueUrl commentsUrl client issueJson commentsJson discussion |
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

{ #category : 'as yet unclassified' }
AIAMicrodown >> githubOpenIssuesForRepo [
	"Return a clean text list of ONLY OPEN issues in the repo.
     repoFullName = 'owner/repo' e.g. 'pillar-markup/Microdown'
     Returns a multi-line String with issue summaries, ready for LLM."

	| url page info client json |
	info := OrderedCollection new.
	page := 1.
	[
		url := 'https://api.github.com/repos/pillar-markup/Microdown/issues?state=open&per_page=30&page=' , page asString. "per_page=30 er max uden pagination – øg hvis nødvendigt og håndter sider"

		client := ZnClient new
			          beOneShot;
			          timeout: 15;
			          yourself.

		json := client get: url.
		json isEmptyOrNil ifTrue: [ ^ 'Fejl: Kunne ikke hente issues' ].

		json := STONJSON fromString: json.
		json do: [ :issue |
				info add: {
						(issue at: 'number').
						(issue at: 'title').
						((issue at: 'user') at: 'login') } ].
		json size = 30. 
	] whileTrue: [ 
		page := page + 1.
	 ].
self halt.
	^ info
]

{ #category : 'as yet unclassified' }
AIAMicrodown >> githubOpenIssuesForRepo: repoFullName [
    "Return a clean text list of ONLY OPEN issues in the repo.
     repoFullName = 'owner/repo' e.g. 'pillar-markup/Microdown'
     Returns a multi-line String with issue summaries, ready for LLM."

    | url client json issuesStream |

    url := 'https://api.github.com/repos/' , repoFullName , '/issues?state=open&per_page=30&page=3'.
    "per_page=30 er max uden pagination – øg hvis nødvendigt og håndter sider"

    client := ZnClient new
        beOneShot;
        timeout: 15;
        yourself.

    json := client get: url.
    json isEmptyOrNil ifTrue: [ ^ 'Fejl: Kunne ikke hente issues' ].

    json := STONJSON fromString: json.
    issuesStream := WriteStream on: String new.

    issuesStream
        nextPutAll: 'Open issues in repository: ';
        nextPutAll: repoFullName;
        cr; cr;
        nextPutAll: 'Total open: ';
        nextPutAll: json size asString;
        cr; cr.

    json do: [ :issue |
        issuesStream
            nextPutAll: '#';
            nextPutAll: (issue at: 'number') asString;
            nextPutAll: ' - ';
            nextPutAll: (issue at: 'title');
            cr;
            nextPutAll: 'Opened by: ';
            nextPutAll: ((issue at: 'user') at: 'login');
            nextPutAll: ' on ';
            nextPutAll: (issue at: 'created_at');
            cr;
            nextPutAll: 'Link: ';
            nextPutAll: (issue at: 'html_url');
            cr; cr;
            nextPutAll: 'Body snippet: ';
            nextPutAll: ((issue at: 'bodyyyy' ifAbsent: ['(ingen body)']));
            cr; cr; nextPutAll: '---'; cr; cr ].

    ^ issuesStream contents
]

{ #category : 'as yet unclassified' }
AIAMicrodown >> old_githubOpenIssuesForRepo: repoFullName [
    "Return a clean text list of ONLY OPEN issues in the repo.
     repoFullName = 'owner/repo' e.g. 'pillar-markup/Microdown'
     Returns a multi-line String with issue summaries, ready for LLM."

    | url client json issuesStream |

    url := 'https://api.github.com/repos/' , repoFullName , '/issues?state=open&per_page=30&page=3'.
    "per_page=30 er max uden pagination – øg hvis nødvendigt og håndter sider"

    client := ZnClient new
        beOneShot;
        timeout: 15;
        yourself.

    json := client get: url.
    json isEmptyOrNil ifTrue: [ ^ 'Fejl: Kunne ikke hente issues' ].

    json := STONJSON fromString: json.
    issuesStream := WriteStream on: String new.

    issuesStream
        nextPutAll: 'Open issues in repository: ';
        nextPutAll: repoFullName;
        cr; cr;
        nextPutAll: 'Total open: ';
        nextPutAll: json size asString;
        cr; cr.

    json do: [ :issue |
        issuesStream
            nextPutAll: '#';
            nextPutAll: (issue at: 'number') asString;
            nextPutAll: ' - ';
            nextPutAll: (issue at: 'title');
            cr;
            nextPutAll: 'Opened by: ';
            nextPutAll: ((issue at: 'user') at: 'login');
            nextPutAll: ' on ';
            nextPutAll: (issue at: 'created_at');
            cr;
            nextPutAll: 'Link: ';
            nextPutAll: (issue at: 'html_url');
            cr; cr;
            nextPutAll: 'Body snippet: ';
            nextPutAll: ((issue at: 'bodyyyy' ifAbsent: ['(ingen body)']));
            cr; cr; nextPutAll: '---'; cr; cr ].

    ^ issuesStream contents
]
