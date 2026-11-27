Class {
	#name : 'AIAYouTubeEpisodeDownloadStub',
	#superclass : 'AIAYouTubeEpisode',
	#instVars : [
		'availableLanguage',
		'attempts'
	],
	#category : 'AIATestExperiments-AIAYouTube-Tests',
	#package : 'AIATestExperiments',
	#tag : 'AIAYouTube-Tests'
}

{ #category : 'accessing' }
AIAYouTubeEpisodeDownloadStub >> attempts [
    ^ attempts
]

{ #category : 'accessing' }
AIAYouTubeEpisodeDownloadStub >> availableLanguage: aString [
    availableLanguage := aString
]

{ #category : 'as yet unclassified' }
AIAYouTubeEpisodeDownloadStub >> episodeTryDownloadVtt: episodeId language: lang automatic: isAutomatic [
    "Record the language and subtitle type.
    Simulate subtitle availability."

    attempts add: { lang. isAutomatic }.

    ^ lang = availableLanguage
]

{ #category : 'initialization' }
AIAYouTubeEpisodeDownloadStub >> initialize [
    super initialize.
    availableLanguage := nil.
    attempts := OrderedCollection new
]
