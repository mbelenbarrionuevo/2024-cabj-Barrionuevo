Class {
	#name : 'LoadedRandomProvider',
	#superclass : 'Object',
	#instVars : [
		'values',
		'index'
	],
	#category : 'IngSoft2-Tests',
	#package : 'IngSoft2-Tests'
}

{ #category : 'instance creation' }
LoadedRandomProvider class >> with: aCollectionOfValues [

	^ self new initializeWith: aCollectionOfValues
]

{ #category : 'initialization' }
LoadedRandomProvider >> initializeWith: aCollectionOfValues [

	values := aCollectionOfValues.
	index := 1
]

{ #category : 'initialization' }
LoadedRandomProvider >> next [

	| value |
	value := values at: index.
	index := index + 1.
	index > values size ifTrue: [ index := 1 ].
	^ value
]
