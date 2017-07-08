~cSceneController = {
	var dict;

	var synths = [
		[
			[Ndef(\graySine)]
		],
		[
			[ Ndef(\saw) ],
			[ Ndef(\saw2) ],
			[ Ndef(\saw2) ]
		]
	];

	var tasks = [
		[
			[ Tdef(\vocal) ],
			[ Tdef(\vocal2) ]
		]
	];

	var state = Dictionary[
		\scene -> 0
	];

	Dictionary[
		\getState -> { state[\scene]; },
		\getSynths -> { synths[ state[\scene] ]; }
	];
};