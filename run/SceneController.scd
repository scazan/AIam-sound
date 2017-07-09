~cSceneController = {
	var dict;

	//Synths are what are controlled per Actor
	var synths = [
		[
			[Ndef(\graySine)]
		],
		[
			[ Ndef(\saw), Ndef(\graySine) ],
			[ Ndef(\saw2) ],
			[ Ndef(\saw2) ]
		]
	];

	// Tasks are all the automated bits of a scene (don't see the need for the 2D array).
	var tasks = [
		[
			Tdef(\vocal),
			Tdef(\vocal2)
		]
	];

	var processingFunctions = [
		Dictionary[
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;

				"processing".postln;

				if(val > 1.0, {
				// [">>", val ].postln;
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 1 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;

				if(val > 1.0, {
				// [">>", val ].postln;
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 1 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
	];
	// State is current state
	var scene = 0;

	Dictionary[
		\getState -> { scene; },
		\getSynths -> { synths[ scene ]; },
		\getProcessors -> { processingFunctions[ scene ]; },
		\next -> {
			tasks[ scene ].stop; // pseudo code

			synths[scene].do(_.do(_.stop)); // Actually we need a stop method to only stop the necessary synths and tasks
			scene.increment;
			synths[scene].do(_.do(_.play));
			tasks[scene].do(_.play);
		},
	];
};
