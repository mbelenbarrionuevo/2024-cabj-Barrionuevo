Class {
	#name : 'OverloadCard',
	#superclass : 'Card',
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'comparing' }
OverloadCard >> = aCard [

	| compareResult |
	compareResult := self class == aCard class.
	compareResult ifTrue: [ ^ (self targetIdOf: spaceshipAffected) = (self targetIdOf: aCard id) ].
	^ compareResult
]

{ #category : 'effect' }
OverloadCard >> applyEffectOn: throwResult for: aSpaceship [

	spaceshipAffected = aSpaceship ifTrue: [ ^ throwResult - 2 ].
	^ throwResult
]

{ #category : 'accessing' }
OverloadCard >> id [

	^ spaceshipAffected 
]
