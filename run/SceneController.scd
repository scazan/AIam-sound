~cSceneController = {
	var dict;

	//Synths are what are controlled per Actor
	var synths = [
		[ // 0
			[Ndef(\graySine), Ndef(\graySine2)],
			[Ndef(\graySine), Ndef(\graySine2)],
			[Ndef(\graySine), Ndef(\graySine2)]
		],
		[ // 1
			[ Ndef(\saw), Ndef(\graySine), Ndef(\graySine2) ],
			[ Ndef(\saw2) ],
			[ Ndef(\saw2) ]
		],
		[ // 2
			[ Ndef(\saw), Ndef(\graySine), Ndef(\graySine2)],
			[ Ndef(\saw2) ],
			[ Ndef(\saw2) ]
		],
		[ // 3
			[Ndef(\saw),  Ndef(\graySine), Ndef(\graySine2)],
			[Ndef(\saw2)],
			[Ndef(\saw2)]
		],
		[ // 4
			[Ndef(\grainer)],
			[Ndef(\two)],
			[Ndef(\three)]
		]


	];

	// Tasks are all the automated bits of a scene (don't see the need for the 2D array).
	var tasks = [
		[{ // 0
			"In ONE!".postln;
			// synths[scene].do(_.do(_.play));

			~energyThreshold = 0.45;

			/*Ndef(\graySine).fadeTime = 20;
			Ndef(\graySine).xset(\amp, 1);
			Ndef(\graySine2).fadeTime = 2;
			Ndef(\graySine2).xset(\amp, 1)*/
			Ndef(\noiseImpulse).play;
			Ndef(\stretch).play;
			Ndef(\graySineTrig).play;

		}, {
		}],
		[{ // 1

			// WHEN IN QUAD 2 and Nea is leaving we trigger the pre-recorded sound

			/*Ndef(\bass).fadeTime = 40;
			Ndef(\bass).play();
			Ndef(\bass).xset(\amp, 0.3);*/
			~energyThreshold = 0.7;
		}, {
		}],
		[{ // 2 Nea start spiralling


			// WHEN Pre-recorded sound ends, then we

			//synths[scene].do(_.do(_.play));

			/*Tdef(\vocal).play;
			Tdef(\vocal2).play;

			Ndef(\pulseTrain0).rebuild();
			Ndef(\pulseTrain0).play();
			Ndef(\pulseTrain0).fadeTime = 5;
			Ndef(\pulseTrain0).xset(\amp, 0.8);
			Ndef(\bass).xset(\amp, 0.45);*/
		},
			{ // end
				// Ndef(\graySine).xset(\amp, 0);
		}],
		[{ // 3

			Ndef(\reverb).fadeTime = 60*2;
			Ndef(\reverb).play();
			Ndef(\pulseTrain0).xset(\amp, 0.8);
			{
				20.wait;
				Ndef(\reverb).xset(\amp, 0.5);
			}.fork;

			{
				(60*3).wait;
				Ndef(\sawPad).fadeTime = 60*4;
				Ndef(\sawPad).play();
				Ndef(\sawPad).xset(\amp, 0.02);
			}.fork;
		},
		{ // end
				Ndef(\sawPad).stop();

				Ndef(\bass).stop();
				Ndef(\pulseTrain0).stop();
				// Ndef(\reverb).stop();
		}],
		[{ // 4
			Ndef(\stutter0).rebuild();
			Ndef(\stutter1).rebuild();
			Ndef(\stutter2).rebuild();

			Ndef(\stutter0).play();
			Ndef(\stutter1).play();
			Ndef(\stutter2).play();
			Ndef(\clink).play();

			{
				(60*1).wait;
				Ndef(\clink).set(\amp, 0.011);
			}.fork;

		},
			{ // end
		}]
	];

	var processingFunctions = [
		Dictionary[ // 0
			\energy -> { | id, vector1, vector2, energies, motion |
				var moving = false;
				var energy = ((vector1[0]*100) - (vector2[0]*100)).abs + ((vector1[2]*100) - (vector2[2]*100)).abs;


				energies = energies.shift(1);
				energies[0] = energy;

				energy = energies.sum / energies.size;

				// energy.postln;

				if(energy > ~energyThreshold, {
					moving = true;

					[id, "moving", vector1].postln;

					// If we are moving and we are not already flagged as moving
					if(motion == false, {

						var x = vector1[0],
						y = vector1[2];

						// Quadrants
						if((x >= 0) && (y >= 0), {

							Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);
							"QUAD 1".postln;
							// ~quadrant2 = false;
						},{
								if((x >= 0) && (y < 0), {
									Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1903, \switch, 1, \length, 1.3, \t_trigger, 1);
									"QUAD 2".postln;
									// ~quadrant2 = true;
								}, {
										if((x < 0) && (y < 0), {
										Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);
											"QUAD 3".postln;
											// ~quadrant2 = false;
									}, {
												if((x < 0) && (y >= 0), {
												Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 703, \switch, 2, \length, 1.3, \t_trigger, 1);
												"QUAD 4".postln;
													// ~quadrant2 = false;
											});
									});
								});
						});


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


				if(val > ~proximityDistance, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 1
			\energy -> { | id, vector1, vector2, energies, motion |
				var moving = false;
				var energy = ((vector1[0]*100) - (vector2[0]*100)).abs + ((vector1[2]*100) - (vector2[2]*100)).abs;


				energies = energies.shift(1);
				energies[0] = energy;

				energy = energies.sum / energies.size;

				energy.postln;

				if(energy > ~energyThreshold, {
					moving = true;

					// [id, "moving", vector1].postln;

					// If we are moving and we are not already flagged as moving
					if(motion == false, {
						// Ndef(("stutter"++id).asSymbol).set(\rate, 5, \switch, 0, \amp, 0.95);
						// Ndef(("stutter"++id).asSymbol).set(\rate, 0.26, \switch, 1, \amp, 0.85);
						// Ndef(("stutter"++id).asSymbol).set(\rate, 0.75 * 2.5, \switch, 0, \amp, 0.95);
						// Ndef(("stutter"++id).asSymbol).set(\rate, 0.26 * 2.5, \switch, 0, \amp, 0.45);

						// Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 903, \x, 0.4, \y, 0.9, \length, 1.3, \t_trigger, 1);



						if(id == 0, {
							Ndef(\stretch).set(\amp, 0.8, \t_trigger, 1);
						}, {

								Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 903, \x, vector1[1], \y, vector1[0], \length, 1.3, \t_trigger, 1);
						});

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

				if(val > ~proximityDistance, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 2
			\energy -> { |id, vector1, vector2, activeActor|
				[[0,0],0];

			},
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;


				if(val > ~proximityDistance, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 3
			\energy -> { |actor|
				[[0,0],0];
			},
			\proximity -> { |val|
				val = ((1 - val)**1 * 2).abs;

				if(val > ~proximityDistance, {
				// [">>", val ].postln;
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			}
		],
		Dictionary[ // 4
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


				if(val > ~proximityDistance, {
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
