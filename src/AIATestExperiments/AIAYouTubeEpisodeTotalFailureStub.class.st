Class {
	#name : 'AIAYouTubeEpisodeTotalFailureStub',
	#superclass : 'AIAYouTubeEpisodeFallbackStub',
	#category : 'AIATestExperiments-AIAYouTube-Tests',
	#package : 'AIATestExperiments',
	#tag : 'AIAYouTube-Tests'
}

{ #category : 'as yet unclassified' }
AIAYouTubeEpisodeTotalFailureStub >> episodeGeminiTranscript: episodeId [
    "Simulate a Gemini transcription failure."

    self error: 'Simulated Gemini failure'
]
