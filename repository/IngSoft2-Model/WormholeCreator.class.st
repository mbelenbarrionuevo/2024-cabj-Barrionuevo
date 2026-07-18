Class {
	#name : 'WormholeCreator',
	#superclass : 'Object',
	#instVars : [
		'beginningWormhole',
		'endingWormhole'
	],
	#category : 'IngSoft2-Model',
	#package : 'IngSoft2-Model'
}

{ #category : 'instance creation' }
WormholeCreator class >> withBeginning: beginning andEnd: ending [

	^ self new initializeWithBeginning: beginning andEnd: ending
]

{ #category : 'accessing' }
WormholeCreator >> beginning [

	^ beginningWormhole
]

{ #category : 'accessing' }
WormholeCreator >> ending [

	^ endingWormhole
]

{ #category : 'initialization' }
WormholeCreator >> initializeWithBeginning: beginning andEnd: ending [

	beginningWormhole := WormholeCell in: beginning to: ending.
	endingWormhole := WormholeCell in: ending to: beginning
]
