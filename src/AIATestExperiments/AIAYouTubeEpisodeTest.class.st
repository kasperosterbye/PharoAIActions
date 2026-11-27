Class {
	#name : 'AIAYouTubeEpisodeTest',
	#superclass : 'TestCase',
	#category : 'AIATestExperiments-AIAYouTube-Tests',
	#package : 'AIATestExperiments',
	#tag : 'AIAYouTube-Tests'
}

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testBothTranscriptionMethodsFail [
    "An error must propagate if both transcription methods fail."

    | episode |

    episode := AIAYouTubeEpisodeTotalFailureStub new.

    self
        should: [
            episode episodeTranscriptWithFallback: 'test123' ]
        raise: Error
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testEpisodeDownloadVtt [
    "Download subtitles from a real YouTube video."

    | episode path |

    episode := AIAYouTubeEpisode new.
    episode channel: 'SabineHossenfelder'.

    path := episode episodeDownloadVtt: 'jrP7buPo2yA'.

    self assert: (File named: path) exists.
    self assert:
        ((episode episodeTranscript: 'jrP7buPo2yA')
            isNotEmpty).
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testEpisodeFetch [
    "Fetch an episode using the preferred transcription mechanism."

    | episode path file |

    episode := AIAYouTubeEpisode new.
    episode channel: 'SabineHossenfelder'.

    path := episode episodeFetch: 'jrP7buPo2yA'.
    file := File named: path.

    self assert: file exists.
    self assert: file readStream contents size > 100.
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testEpisodeTextFromVtt [
    "VTT timestamps, tags and duplicate lines should be removed."

    | vtt result |

    vtt := String lf join: {
        'WEBVTT'.
        ''.
        '00:00:01.000 --> 00:00:03.000'.
        '<c>Hello world.</c>'.
        ''.
        '00:00:03.000 --> 00:00:05.000'.
        '<c>Hello world.</c>'.
        ''.
        '00:00:05.000 --> 00:00:07.000'.
        '<c>This is a test.</c>' }.

    result := AIAYouTubeEpisode new episodeTextFromVtt: vtt.

    self assert: result equals:
        'Hello world.', String lf, 'This is a test.'
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testFailedReloadPreservesTranscript [
    "A failed reload must not overwrite an existing transcript."

    | episode path file original |

    episode := AIAYouTubeEpisodeTotalFailureStub new.
    episode channel: 'SabineHossenfelder'.

    path := (episode episodePath: 'jrP7buPo2yA'),
        'jrP7buPo2yA.txt'.

    file := File named: path.

    self assert: file exists.

    original := file readStream contents.

    self
        should: [
            episode episodeReload: 'jrP7buPo2yA' ]
        raise: Error.

    self
        assert: file readStream contents
        equals: original
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testFallsBackToAutomaticSubtitles [
    "Try automatic subtitles when manual subtitles are unavailable."

    | episode |

    episode := AIAYouTubeEpisodeDownloadStub new.
    episode availableLanguage: 'en-orig'.

    episode episodeDownloadVtt: 'test123'.

    self
        assert: episode attempts asArray
        equals: #(('en' false) ('en-orig' true)).

    self
        assert: (episode instVarNamed: #language)
        equals: 'en-orig'
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testGeminiFallback [
    "Gemini should be used when YouTube subtitles fail."

    | episode result |

    episode := AIAYouTubeEpisodeFallbackStub new.

    result := episode
        episodeTranscriptWithFallback: 'test123'.

    self
        assert: result
        equals: 'Transcript supplied by Gemini'
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testNoSubtitlesAvailable [
    "Both subtitle types must be attempted before reporting failure."

    | episode |

    episode := AIAYouTubeEpisodeDownloadStub new.

    self
        should: [
            episode episodeDownloadVtt: 'test123' ]
        raise: Error.

    self
        assert: episode attempts asArray
        equals: #(('en' false) ('en-orig' true))
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testPrefersManualSubtitles [
    "Manual English subtitles must have priority."

    | episode |

    episode := AIAYouTubeEpisodeDownloadStub new.
    episode availableLanguage: 'en'.

    episode episodeDownloadVtt: 'test123'.

    self
        assert: episode attempts asArray
        equals: #(('en' false)).

    self
        assert: (episode instVarNamed: #language)
        equals: 'en'
]

{ #category : 'tests' }
AIAYouTubeEpisodeTest >> testReloadPreservesReadState [
    "Reloading an episode must preserve its read state."

    | episode episodeId wasRead |

    episode := AIAYouTubeEpisode new.
    episode channel: 'SabineHossenfelder'.
    episodeId := 'jrP7buPo2yA'.

    episode episodeMeta: episodeId.

    wasRead := episode episodeIsRead: episodeId.

    [
        episode episodeMarkAsRead: episodeId.

        self assert: (episode episodeIsRead: episodeId).

        episode episodeReload: episodeId.

        self assert: (episode episodeIsRead: episodeId)
    ] ensure: [
        wasRead ifFalse: [
            episode episodeMarkAsUnread: episodeId ] ]
]
