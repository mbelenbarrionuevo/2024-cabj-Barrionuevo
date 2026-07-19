Class {
	#name : 'Cell',
	#superclass : 'Object',
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'action' }
Cell >> applyBaseEffectTo: aSpaceship on: aGame [
]

{ #category : 'action' }
Cell >> applyEffectTo: aSpaceship on: aGame [
	
	aGame applyEffectOf: self to: aSpaceship
	
]

{ #category : 'action' }
Cell >> isCell [
    ^ true
]

{ #category : 'action' }
Cell >> targetType [
    ^ #single
]
