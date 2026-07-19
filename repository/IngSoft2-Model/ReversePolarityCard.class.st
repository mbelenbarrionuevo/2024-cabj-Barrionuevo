Class {
	#name : 'ReversePolarityCard',
	#superclass : 'Card',
	#instVars : [
		'cellIndex'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'instance creation' }
ReversePolarityCard class >> toDoEffectFor: aCellIndex [
    ^ self new initializeToDoEffectFor: aCellIndex
]

{ #category : 'initialization' }
ReversePolarityCard >> = aCard [
	| compareResult |
	compareResult := self class == aCard class.
	compareResult ifTrue: [ ^ cellIndex = aCard cellIndex ].
	^ compareResult

]

{ #category : 'initialization' }
ReversePolarityCard >> cellIndex [
    ^ cellIndex
]

{ #category : 'initialization' }
ReversePolarityCard >> initializeToDoEffectFor: aCellIndex [
    cellIndex := aCellIndex.
    spaceshipAffected := nil
]

{ #category : 'initialization' }
ReversePolarityCard >> isReversePolarity [
    ^ true
]
