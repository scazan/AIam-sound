~cSceneController = {
	var dict;

	//Synths are what are controlled per Actor
	var synths = [
		[
			[Ndef(\graySine)],
			[Ndef(\graySine)],
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
		[{
			synths[scene].do(_.do(_.play));

			Ndef(\graySine).fadeTime = 2;
			Ndef(\graySine).xset(\amp, 1);

			{
				( 60 * 2 ).wait;
				Ndef(\bass).fadeTime = 30;
				Ndef(\bass).play();
				Ndef(\bass).xset(\amp, 1);
			}.fork;
		}, {
		}],
		[{ // start
			//synths[scene].do(_.do(_.play));

			Tdef(\vocal).play;
			Tdef(\vocal2).play;

			Ndef(\bass).play();
			Ndef(\reverb).fadeTime = 30;
			Ndef(\reverb).play();
			{
				30.wait;
				Ndef(\reverb).xset(\amp, 1);
			}.fork;

			{
				(60*2).wait;
				Ndef(\sawPad).fadeTime = 60*4;
				Ndef(\sawPad).play();
				Ndef(\sawPad).xset(\amp, 0.15);
			}.fork;

			Ndef(\pulseTrain0).rebuild();
			Ndef(\pulseTrain0).play();
			Ndef(\pulseTrain0).fadeTime = 5;
			Ndef(\pulseTrain0).xset(\amp, 1.5);
		}, { // end
		}]
	];

	var processingFunctions = [
		Dictionary[
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;

				if(val > 1.2, {
					// [">>", val ].postln;
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 2 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;

				if(val > 1.2, {
				// [">>", val ].postln;
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 2 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
	];
	// State is current state
	var scene = -1;

	Dictionary[
		\getState -> { scene; },
		\getSynths -> { synths[ scene ]; },
		\getProcessors -> { processingFunctions[ scene ]; },
		\next -> {
			if(scene >= 0, {
				tasks[ scene ][1].value(); // pseudo code
			});


			//synths[scene].do(_.do(_.stop)); // Actually we need a stop method to only stop the necessary synths and tasks
			scene = scene + 1;
			//synths[scene].do(_.do(_.play));
			tasks[ scene ][0].value(); // pseudo code
		},
	];
};
