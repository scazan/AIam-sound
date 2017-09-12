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

	// Different behaviors based on different camera "zones"
	var cameraFunctions = [
		Dictionary[ // 0: TOP LEFT
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];

				if((x >= 0.75) && (y <= -0.25), {
					// THUMP ZONE

					Ndef(\bass).set(\amp, 0.4);
				}, {
					Ndef(\bass).set(\amp, 0);

					// Setting up four sections on the x-axis
					if(x <= -0.5, {
						// Low sound
						Ndef(\graySine2).set(\freq, 900);
					}, {
						if(x <= 0, {
							//high sound
							Ndef(\graySine2).set(\freq, 2000);
						}, {
							if(x <= 0.5, {
								//med sound
								Ndef(\graySine2).set(\freq, 1500);
							}, {
								if(x <= 1, {
									//high sound
									Ndef(\graySine2).set(\freq, 2000);
								});
							});
						});
					});
				});
			},
			\energy -> { | id, vector1, vector2, energies, motion |
				var moving = false;
				var energy = ((vector1[0]*100) - (vector2[0]*100)).abs + ((vector1[2]*100) - (vector2[2]*100)).abs;


				energies = energies.shift(1);
				energies[0] = energy;

				energy = energies.sum / energies.size;


				if(energy > ~energyThreshold, {
					moving = true;

					// [id, "moving", vector1].postln;

					// If we are moving and we are not already flagged as moving
					if(motion == false, {

						var x = vector1[0],
						y = vector1[2];

						// Quadrants
						if((x >= 0) && (y >= 0), {

							/*Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);*/
							"QUAD 1".postln;
						},{
								if((x >= 0) && (y < 0), {
									/*Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1903, \switch, 1, \length, 1.3, \t_trigger, 1);*/
									"QUAD 2".postln;
								}, {
										if((x < 0) && (y < 0), {
										/*Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);*/
											"QUAD 3".postln;
									}, {
												if((x < 0) && (y >= 0), {
												/*Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 703, \switch, 2, \length, 1.3, \t_trigger, 1);*/
												"QUAD 4".postln;
											});
									});
								});
						});

						motion = true;

						});
				}, {
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
			},
			\new -> { | id, x, y, z |
				if(x >= 0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, -1);
				});
			},
			\lost -> { | id, x, y, z |
				if(x >= 0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, -1);
				});
			}
		],
		Dictionary[ // 1: TOP RIGHT
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];

				if((x <= -0.25) && (y <= -0.25), {
					// THUMP ZONE
					Ndef(\bass).set(\amp, 0.4);
				}, {
					Ndef(\bass).set(\amp, 0);
				});
			},
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
						},{
								if((x >= 0) && (y < 0), {
									Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1903, \switch, 1, \length, 1.3, \t_trigger, 1);
									"QUAD 2".postln;
								}, {
										if((x < 0) && (y < 0), {
										Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);
											"QUAD 3".postln;
									}, {
												if((x < 0) && (y >= 0), {
												Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 703, \switch, 2, \length, 1.3, \t_trigger, 1);
												"QUAD 4".postln;
											});
									});
								});
						});

						motion = true;

						});
				}, {
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
			},
			\new -> { | id, x, y |
				if(x <= -0.9, {
					//BEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, 1);
				});
			},
			\lost -> { | id, x, y, z |
				if(x <= -0.9, {
					//BEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, 1);
				});
			}
		],
		Dictionary[ // 2: BOTTOM LEFT
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];

				// [x,y].postln;
				if((x >= 0.75) && (y >= 0.75), {
					// THUMP ZONE
					["THUMP"].postln;
					Ndef(\bass).set(\amp, 0.4);
				}, {
					var actorY = (y + 1) / 2,
						actorYInverse =  ((y - 1) / 2).abs;

					Ndef(\bass).set(\amp, 0);


					// Encouraging/Discouraging sound
						Ndef(\encouraging).set(\volume, 1);
				Ndef(\discouraging).set(\volume, 1);
					Ndef(\encouraging).set(\amp, actorY);
					Ndef(\discouraging).set(\amp, actorYInverse);
				});

			},
			\energy -> { | id, vector1, vector2, energies, motion |
				[[0,0], [0,0]];
			},
			\proximity -> {|val|
				0;
			},
			\new -> { | id, x, y |
				if(x <= -0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, -1);
				}, {
					if( (y>=0.9) || (x >= 0.9), {
						// WALL
						Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
					});
				});
			},
			\lost -> { | id, x, y, z |
				if(x <= -0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan -1);
				}, {
					if( (y>=0.9) || (x >= 0.9), {
						// WALL
						Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
					});
				});

				Ndef(\encouraging).set(\volume, 0);
				Ndef(\discouraging).set(\volume, 0);
			}
		],
		Dictionary[ // 3: BOTTOM RIGHT
			\synths -> { | actor, actorIndex |
				var posVector = actor[\position];

				var synths = [
					[Ndef(\graySine), Ndef(\graySine2)],
					[Ndef(\graySine), Ndef(\graySine2)],
					[Ndef(\graySine), Ndef(\graySine2)]
				];

				synths[actorIndex].do({| synth, i |
					synth.set(\x, posVector[\x], \z, posVector[\z], \y, posVector[\y]);
				});
			},
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

						// QUADRANTS
						if((x <= -0.25) && (y >= 0.75), {
							// THUMP ZONE
							Ndef(\bass).set(\amp, 0.4);
						}, {
							Ndef(\bass).set(\amp, 0);
							if((x >= 0) && (y >= 0), {

								Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);
								"QUAD 1".postln;
							},{
								if((x >= 0) && (y < 0), {
									Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1903, \switch, 1, \length, 1.3, \t_trigger, 1);
									"QUAD 2".postln;
								}, {
									if((x < 0) && (y < 0), {
										Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);
										"QUAD 3".postln;
									}, {
										if((x < 0) && (y >= 0), {
											Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 703, \switch, 2, \length, 1.3, \t_trigger, 1);
											"QUAD 4".postln;
										});
									});
								});
							});
						});
						 // END QUADRANTS

						motion = true;

					});
				}, {
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
			},
			\new -> { | id, x, y |
				if(x >= 0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, 1);
				});
			},
			\lost -> { | id, x, y, z |
				if(x >= 0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, 1);
				});
			}
		],
	];

	// State is current state
	var scene = -1;

	Dictionary[
		\getState -> { scene; },
		\getSynths -> { synths[ scene ]; },
		\getCameraProcessor -> { | camera | cameraFunctions[ camera ]; },
		\next -> {

			if(scene >= 0, {
				tasks[ scene ][1].value(); // pseudo code
			});

			scene = scene + 1;
			scene.postln;
			tasks[ scene ][0].value();
		},
	];
};
