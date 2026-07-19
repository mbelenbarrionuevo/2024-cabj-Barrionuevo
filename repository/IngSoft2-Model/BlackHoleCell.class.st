Class {
	#name : 'BlackHoleCell',
	#superclass : 'Cell',
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'action' }
BlackHoleCell >> applyBaseEffectTo: aSpaceship on: aGame [
    aGame move: aSpaceship a: -4
]
