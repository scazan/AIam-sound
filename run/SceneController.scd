~cSceneController = {
	var dict;

	var synths = [
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

	Dictionary[
		\getSynths -> { | sceneIndex |
			synths[sceneIndex];
		}
	];
};