Class {
	#name : 'AIAYouTubeEpisodeFallbackStub',
	#superclass : 'AIAYouTubeEpisode',
	#category : 'AIATestExperiments-AIAYouTube-Tests',
	#package : 'AIATestExperiments',
	#tag : 'AIAYouTube-Tests'
}

{ #category : 'as yet unclassified' }
AIAYouTubeEpisodeFallbackStub >> episodeDownloadVtt: episodeId [
    "Simulate a YouTube subtitle download failure."

    self error: 'Simulated YouTube failure'
]

{ #category : 'as yet unclassified' }
AIAYouTubeEpisodeFallbackStub >> episodeGeminiTranscript: episodeId [
    "Simulate successful Gemini transcription."

    ^ 'Transcript supplied by Gemini'
]
