~cSceneController = {
	var dict;

	//Synths are what are controlled per Actor
	var synths = [
		[ // 0
			\graySine2,
			\graySine,
			\graySine2,
			\graySine
		],
		[ // 1
			\graySine2,
			\graySine,
			\graySine2,
			\graySine
		],
		[ // 2
			\graySine2,
			\graySine,
			\graySine2,
			\graySine
		],
		[ // 3
			\graySine2,
			\graySine,
			\graySine2,
			\graySine
		]

	];


	// Different behaviors based on different camera "zones"
	var cameraFunctions = [
		Dictionary[ // 3: TOP LEFT
			\synths -> { | actor, actorIndex |
				var posVector = actor[\position];

				var x = posVector[\x],
				y = posVector[\y];

				Ndef(synths[0][actorIndex % (synths[0].size)]).set(\freq, ((x.abs.pow(3) * 8000) + 90) );

				if( ((x >= 0.75) && (y >= 0.75)).not(), {
							// THUMP ZONE
					Ndef(\bass).set(\amp, 0.4);
					Ndef(synths[0][actorIndex % (synths[0].size)]).set(\amp, 0.4);
				});

			},
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

						var x = vector1[0],
						y = vector1[2];


						// QUADRANTS
						// if((x >= 0.75) && (y >= 0.75), {
						if((x >= 0.75) && (y <= -0.25), {
							// THUMP ZONE
							Ndef(\bass).set(\amp, 0.4);
							Ndef(synths[0][0]).set(\amp, 0);
						}, {
							Ndef(\bass).set(\amp, 0);
							Ndef(\discouraging).set(\volume, 0.2);

							if((x >= 0) && (y >= 0), {

								// Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);
								~createGraySineTrig.value(amp: 3, freq: 903, switch: 3, length: 1.3, t_trigger: 1);
								"QUAD 1".postln;
							},{
								if((x >= 0) && (y < 0), {
									// Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1903, \switch, 1, \length, 1.3, \t_trigger, 1);
									~createGraySineTrig.value(amp: 2, freq: 1203, switch: 3, length: 1.3, t_trigger: 1);
									"QUAD 2".postln;
								}, {
									if((x < 0) && (y < 0), {
										// Ndef(\graySineTrig).set(\pan, 1, \amp, 3, \freq, 703, \switch, 3, \length, 1.3, \t_trigger, 1);
										~createGraySineTrig.value(amp: 2, freq: 903, switch: 3, length: 1.3, t_trigger: 1);
										"QUAD 3".postln;
									}, {
										if((x < 0) && (y >= 0), {
											// Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 703, \switch, 2, \length, 1.3, \t_trigger, 1);
											~createGraySineTrig.value(amp: 2, freq: 1203, switch: 3, length: 1.3, t_trigger: 1);
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
						Ndef(\discouraging).set(\volume, 0);

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
		Dictionary[ // 1: TOP RIGHT
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];

				if((x >= 0.75) && (y <= -0.25), {
					// THUMP ZONE
					Ndef(\bass).set(\amp, 0.4);
				}, {
					Ndef(\bass).set(\amp, 0);
				});

				Ndef(synths[0][actorIndex % (synths[0].size)]).set(\freq, ((x.abs.pow(3) * 8000) + 90) );
			},
			\energy -> { | id, vector1, vector2, energies, motion |
				var moving = false;
				var energy = ((vector1[0]*100) - (vector2[0]*100)).abs + ((vector1[2]*100) - (vector2[2]*100)).abs;


				energies = energies.shift(1);
				energies[0] = energy;

				energy = energies.sum / energies.size;

				// energy.postln;

				if(energy > ~energyThreshold, {
					var x = vector1[0],
						y = vector1[2];

					moving = true;

					Ndef(synths[1][id % (synths[1].size)]).set(\amp, 0.4);
					Ndef(\discouraging).set(\volume, 0.2);


						// THUMP ZONE
						if((x <= -0.25) && (y >= 0.75), {
							Ndef(synths[1][id % (synths[1].size)]).set(\amp, 0.0);
						Ndef(\pad).set(\amp, 0);
						}, {
							Ndef(synths[1][id % (synths[1].size)]).set(\amp, 0.4);
						});

					// Ndef(synths[1][id % (synths[1].size)]).set(\x, (x + 1)/2);
					Ndef(\pad).set(\dist, (x + 1)*2);
					Ndef(\pad).set(\amp, 0.1);

					// If we are moving and we are not already flagged as moving
					if(motion == false, {



						// Quadrants
						/*if((x >= 0) && (y >= 0), {

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
						});*/

						motion = true;

						});
				}, {
						var x = vector1[0],
						y = vector1[2];

						Ndef(\pad).set(\amp, 0.01);
						Ndef(synths[1][id % (synths[1].size)]).set(\amp, 0.05);


						if(motion == true, {
						Ndef(\discouraging).set(\volume, 0);

							// THE THUMP ZONE
							if((x <= -0.25) && (y <= -0.25), {
								Ndef(synths[1][id % (synths[1].size)]).set(\amp, 0.0);
							}, {
								Ndef(synths[1][id % (synths[1].size)]).set(\amp, 0.05);

							});

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
				Ndef(\stillness).set(\amp, 0.2);
			},
			\lost -> { | id, x, y, z |
				if(x <= -0.9, {
					//BEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, 1);
				});

				Ndef(\stillness).set(\amp, 0);
			}
		],
		Dictionary[ // 2: BOTTOM LEFT
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];

				// [x,y].postln;
				if((x <= -0.25) && (y >= 0.75), {
					// THUMP ZONE
					["THUMP"].postln;
					//Ndef(\bass).set(\amp, 0.4);
				}, {
					var actorY = (y + 1) / 2,
						actorYInverse =  ((y - 1) / 2).abs;

					Ndef(\bass).set(\amp, 0);


					// Encouraging/Discouraging sound
					// Ndef(synths[0][actorIndex % (synths[0].size)]).set(\freq, ((x.abs.pow(3) * 8000) + 90) );
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

						//Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.4);

						// THUMP ZONE
						if((x >= 0.75) && (y <= -0.25), {
							Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.0);
						}, {
							//Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.4);
							Ndef(\discouraging).set(\volume, 0.2);
						});


						motion = true;

						});
				}, {
						var x = vector1[0],
						y = vector1[2];

						if(motion == true, {

						Ndef(\discouraging).set(\volume, 0);
							if((x >= 0.75) && (y <= -0.25), {
								Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.0);
							}, {
								//Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.05);
							});


							motion = false;

						});

				});

				[energies, moving];
			},
			\proximity -> {|val|
				0;
			},
			\new -> { | id, x, y |
				if(x >= 0.7, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, -1);
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, -1);
				}, {
					if( (y>=0.9) || (x >= 0.9) || (y<= -0.25) || (x <= -0.25), {
						// WALL
						//Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
					});
				});
			},
			\lost -> { | id, x, y, z |
				if(x <= -0.9, {
					//bEEP
					Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
					//Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan -1);
				}, {
					if( (y>=0.9) || (x >= 0.9) || (x <= -0.21) || (y <= -0.21), {
						// WALL
						Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
					});
				});

				Ndef(\encouraging).set(\volume, 0);
				Ndef(\discouraging).set(\volume, 0);
			}
		],
		Dictionary[ // 0: BOTTOM RIGHT
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];



//				if((x <= -0.25) && (y <= -0.25), {
				if((x >= 0.75) && (y >= 0.75), {
					// THUMP ZONE

					Ndef(\bass).set(\amp, 0.4);
				}, {
					Ndef(\bass).set(\amp, 0);


					Ndef(synths[0][actorIndex % (synths[0].size)]).set(\freq, ((x.abs.pow(3) * 8000) + 90) );
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

						// Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.4);

						// THUMP ZONE
						if((x >= 0.75) && (y >= 0.75), {
							Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.0);
						}, {
							Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.4);
							Ndef(\discouraging).set(\volume, 0.2);
						});


						motion = true;

						});
				}, {
						var x = vector1[0],
						y = vector1[2];

						if(motion == true, {

						Ndef(\discouraging).set(\volume, 0);
							if((x >= 0.75) && (y <= -0.25), {
								Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.0);
							}, {
								Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.05);
							});


							motion = false;

						});

				});

				[energies, moving];
			},
			\proximity -> {|val|
				val = ((1 - val)**1 * 2).abs;


				//[val, ~proximityDistance].postln;
				if(val > ~proximityDistance, {
					Tdef(\vocal).stop;
					Ndef(\pulseTrain0).set(\lag, 4 );
					Ndef(\pulseTrain0).set(\density, val+0.5 );
				}, {
					Tdef(\vocal).play;
				});
			},
			\new -> { | id, x, y, z |

				Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0.4);
				if(x >= 0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, -1);
				});
			},
			\lost -> { | id, x, y, z |

				Ndef(synths[0][id % (synths[0].size)]).set(\amp, 0);
				if(x >= 0.9, {
					//bEEP
					Ndef(\beep).set(\amp, 0.26 + 0.2.rand, \freq, 2700 + (200.0.rand), \length, 0.08 + 0.1.rand, \t_trigger, 1, \pan, -1);
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

			/*if(scene >= 0, {
				tasks[ scene ][1].value(); // pseudo code
			});

			scene = scene + 1;
			scene.postln;
			tasks[ scene ][0].value();*/
		},
	];
};