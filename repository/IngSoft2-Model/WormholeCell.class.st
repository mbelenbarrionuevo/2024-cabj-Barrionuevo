Class {
	#name : 'WormholeCell',
	#superclass : 'Cell',
	#instVars : [
		'cellPosition',
		'positionToGoTo'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'evaluating' }
WormholeCell class >> in: aPosition to: anotherPosition [

	^ self new initializeIn: aPosition to: anotherPosition
]

{ #category : 'action' }
WormholeCell >> applyBaseEffectTo: aSpaceship on: aGame [
    | numberOfMovements cellOfSpaceship |
    cellOfSpaceship := aSpaceship position cell.
    numberOfMovements := positionToGoTo - cellOfSpaceship.
    aGame move: aSpaceship a: numberOfMovements
]

{ #category : 'accessing' }
WormholeCell >> cell [

	^ cellPosition
]

{ #category : 'initialization' }
WormholeCell >> initializeIn: aPosition to: anotherPosition [

	cellPosition := aPosition.
	positionToGoTo := anotherPosition
]
