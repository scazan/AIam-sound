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
		],
		[
			[ Ndef(\saw), Ndef(\graySine) ],
			[ Ndef(\saw2) ],
			[ Ndef(\saw2) ]
		],
		[
			[Ndef(\saw)],
			[Ndef(\saw2)],
			[Ndef(\saw2)]
		],
		[
			[Ndef(\grainer)],
			[Ndef(\two)],
			[Ndef(\three)]
		]


	];

	// Tasks are all the automated bits of a scene (don't see the need for the 2D array).
	var tasks = [
		[{ // 0
			synths[scene].do(_.do(_.play));

			Ndef(\graySine).fadeTime = 2;
			Ndef(\graySine).xset(\amp, 1);

		}, {
		}],
		[{ // 1
			Ndef(\bass).fadeTime = 30;
			Ndef(\bass).play();
			Ndef(\bass).xset(\amp, 0.1);
		}, {
		}],
		[{ // 2
			//synths[scene].do(_.do(_.play));

			Tdef(\vocal).play;
			Tdef(\vocal2).play;

			Ndef(\pulseTrain0).rebuild();
			Ndef(\pulseTrain0).play();
			Ndef(\pulseTrain0).fadeTime = 5;
			Ndef(\pulseTrain0).xset(\amp, 0.25);
		},
			{ // end
		}],
		[{ // 3
			//synths[scene].do(_.do(_.play));

			Ndef(\reverb).fadeTime = 60;
			Ndef(\reverb).play();
			{
				30.wait;
				Ndef(\reverb).xset(\amp, 0.75);
			}.fork;

			{
				(60*6).wait;
				Ndef(\sawPad).fadeTime = 60*4;
				Ndef(\sawPad).play();
				Ndef(\sawPad).xset(\amp, 0.15);
			}.fork;
		},
		{ // end
				Ndef(\sawPad).stop();
				Ndef(\reverb).stop();
				Ndef(\bass).stop();
				Ndef(\pulseTrain0).stop();
		}],
		[{ // 4
			Ndef(\stutter0).play();
			Ndef(\stutter1).play();
			Ndef(\stutter2).play();
			Ndef(\clink).play();

			{
				(60*2).wait;
				Ndef(\clink).set(\amp, 0.031);
			}.fork;

		},
			{ // end
		}]
	];

	var processingFunctions = [
		Dictionary[
			\energy -> { | id, vector1, vector2, energies, motion |
				var moving = false;
				var energy = ((vector1[0]*100) - (vector2[0]*100)).abs + ((vector1[2]*100) - (vector2[2]*100)).abs;


				energies = energies.shift(1);
				energies[0] = energy;

				energy = energies.sum / energies.size;

				if(energy > ~energyThreshold, {
					moving = true;

					// [id, "moving"].postln;

					// If we are moving and we are not already flagged as moving
					if(motion == false, {
						// Ndef(("stutter"++id).asSymbol).set(\rate, 5, \switch, 0, \amp, 0.95);
						// Ndef(("stutter"++id).asSymbol).set(\rate, 0.26, \switch, 1, \amp, 0.85);
						// Ndef(("stutter"++id).asSymbol).set(\rate, 0.75 * 2.5, \switch, 0, \amp, 0.95);
						Ndef(("stutter"++id).asSymbol).set(\rate, 0.26 * 2.5, \switch, 0, \amp, 0.45);
						// Ndef(\stutter2).set(\rate, 0.26, \switch, 1, \amp, 0.85);

						// [id, "moving"].postln;

						motion = true;

						});
				}, {
						// [id, "not moving"].postln;
						if(motion == true, {

							// Ndef(\stutter2).set(\rate, 0.95, \switch, 0, \amp, 0.95);
							Ndef(("stutter"++id).asSymbol).set(\rate, 0.26, \switch, 1, \amp, 0.85);

							motion = false;

							});

				});

				[energies, moving];
			},
			\proximity -> {|val|
				val = ((1 - val)**1 * 2).abs;


				if(val > 1.2, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 2
			\energy -> { | id, vector1, vector2, energies, motion |
				var moving = false;
				var energy = ((vector1[0]*100) - (vector2[0]*100)).abs + ((vector1[2]*100) - (vector2[2]*100)).abs;


				energies = energies.shift(1);
				energies[0] = energy;

				energy = energies.mean;

				if(energy > ~energyThreshold, {
					moving = true;

					// If we are moving and we are not already flagged as moving
					if(motion == false, {

						Ndef(("stutter"++id).asSymbol).set(\rate, 0.26 * 2.5, \switch, 0, \amp, 0.45);

						// [id, "moving"].postln;

						motion = true;

						});
				}, {
						if(motion == true, {
							Ndef(("stutter"++id).asSymbol).set(\rate, 0.26, \switch, 1, \amp, 0.85);
							// [id, "not moving"].postln;
							motion = false;

							});

				});

				[energies, moving];
			},
			\proximity -> {|val|
				val = ((1 - val)**1 * 2).abs;


				if(val > 1.2, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 3
			\energy -> { |id, vector1, vector2, activeActor|
				[0,0];

			},
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;


				if(val > 1.2, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 4
			\energy -> { |actor|
				[0,0];
			},
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;

				if(val > 1.2, {
				// [">>", val ].postln;
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 5
			\energy -> { | id, vector1, vector2, energies, motion |
				var moving = false;
				var energy = ((vector1[0]*100) - (vector2[0]*100)).abs + ((vector1[2]*100) - (vector2[2]*100)).abs;


				energies = energies.shift(1);
				energies[0] = energy;

				energy = energies.sum / energies.size;

				if(energy > ~energyThreshold, {
					moving = true;

					// [id, "moving"].postln;

					// If we are moving and we are not already flagged as moving
					if(motion == false, {
						// Ndef(("stutter"++id).asSymbol).set(\rate, 5, \switch, 0, \amp, 0.95);
						// Ndef(("stutter"++id).asSymbol).set(\rate, 0.26, \switch, 1, \amp, 0.85);
						// Ndef(("stutter"++id).asSymbol).set(\rate, 0.75 * 2.5, \switch, 0, \amp, 0.95);
						Ndef(("stutter"++id).asSymbol).set(\rate, 0.26 * 2.5, \switch, 0, \amp, 0.45);
						// Ndef(\stutter2).set(\rate, 0.26, \switch, 1, \amp, 0.85);

						// [id, "moving"].postln;

						motion = true;

						});
				}, {
						// [id, "not moving"].postln;
						if(motion == true, {

							// Ndef(\stutter2).set(\rate, 0.95, \switch, 0, \amp, 0.95);
							Ndef(("stutter"++id).asSymbol).set(\rate, 0.26, \switch, 1, \amp, 0.85);

							motion = false;

							});

				});

				[energies, moving];
			},
			\proximity -> {|val|
				val = ((1 - val)**1 * 2).abs;


				if(val > 1.2, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
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
			scene.postln;
			//synths[scene].do(_.do(_.play));
			tasks[ scene ][0].value();
		},
	];
};
