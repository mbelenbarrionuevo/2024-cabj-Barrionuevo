Class {
	#name : 'RewardManager',
	#superclass : 'Object',
	#instVars : [
		'randomProvider'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'instance creation' }
RewardManager class >> withRandomProvider: aRandomProvider [

	^ self new initializeWithRandomProvider: aRandomProvider
]

{ #category : 'initialization' }
RewardManager >> applyRewardOn: aSpaceship [

	| randomValue |
	randomValue := randomProvider next.
	randomValue < 0.8
		ifTrue: [ aSpaceship changeCapacity: 1 ]
		ifFalse: [ aSpaceship changeCapacity: -1 ]
]

{ #category : 'initialization' }
RewardManager >> initializeWithRandomProvider: aRandomProvider [

	randomProvider := aRandomProvider
]
