Class {
	#name : 'AtomicBombCell',
	#superclass : 'Cell',
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'action' }
AtomicBombCell >> applyBaseEffectTo: aSpaceship on: aGame [
    aSpaceship resetToOne
]

{ #category : 'action' }
AtomicBombCell >> targetType [
    ^ #all

]
