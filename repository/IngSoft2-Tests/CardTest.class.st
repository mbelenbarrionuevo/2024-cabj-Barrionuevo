Class {
	#name : 'CardTest',
	#superclass : 'TestCase',
	#category : 'IngSoft2-Tests',
	#package : 'IngSoft2-Tests'
}

{ #category : 'tests' }
CardTest >> test01ActiveDeckActivateOverLoadCardThenApplyEffectApplysEffectOfIt [
	| aActiveDeck aSpaceship |
	aActiveDeck := ActiveDeck startGame.
	aSpaceship := Spaceship launchWithFuel: 10.
	aActiveDeck activate: (OverloadCard toDoEffectFor: aSpaceship).

	self assert: (aActiveDeck applyEffectOn: 10 withCurrentSpaceship: aSpaceship) equals: 8
]

{ #category : 'tests' }
CardTest >> test02ActiveDeckRemoveOverloadCardThenNoEffectOnThatId [
	| aActiveDeck spaceshipOne spaceshipTwo |
	aActiveDeck := ActiveDeck startGame.
	spaceshipOne := Spaceship launchWithFuel: 10.
	spaceshipTwo := Spaceship launchWithFuel: 10.
	aActiveDeck activate: (OverloadCard toDoEffectFor: spaceshipOne).
	aActiveDeck activate: (OverloadCard toDoEffectFor: spaceshipTwo).
	
	aActiveDeck removeACard: (OverloadCard toDoEffectFor: spaceshipTwo).

	self assert: (aActiveDeck applyEffectOn: 10 withCurrentSpaceship: spaceshipTwo) equals: 10
]

{ #category : 'tests' }
CardTest >> test03BaseCardHasNoCellIndex [
	| aCard |
	aCard := Card new.

	self assert: aCard cellIndex isNil.
	

]

{ #category : 'tests' }
CardTest >> test04BaseCardIsNotReversePolarity [
	| aCard |
	aCard := Card new.
	self deny: aCard isReversePolarity
]

{ #category : 'tests' }
CardTest >> test05BaseCardDoesNotModifyThrowResult [
	| aCard aSpaceship |
	aCard := Card new.
	aSpaceship := Spaceship launchWithFuel: 10.
	self assert: (aCard applyEffectOn: 5 for: aSpaceship) equals: 5
]

{ #category : 'tests' }
CardTest >> test06BaseCardIsDeactivatedByDefault [
	| aCard |
	aCard := Card new.
	self assert: aCard deactivate
]

{ #category : 'tests' }
CardTest >> test07BaseCardResolvesTargetIdFromSpaceship [
	| aCard aSpaceship |
	aCard := Card new.
	aSpaceship := Spaceship launchWithFuel: 10.

	self assert: (aCard targetIdOf: aSpaceship) equals: aSpaceship id

]
