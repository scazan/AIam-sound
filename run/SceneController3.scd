~cSceneController = {
	var dict;
	var thumpZone = false;
	var thumpZoneIDs = ~thumpZoneIDs = Dictionary.new;

	//Synths are what are controlled per Actor
	// [quadrant, section, synth]
	var synths = [
		[ // 0
			[ // 0
			],
			[ // 1
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[], // 2
			[ // 3
			],
			[ // 4
			]

		],
		[ // 1
			[ // 0
				\graySine2,
				\graySine2,
				\graySine2,
				\graySine2
			],
			[ // 1
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[ // 3
			],
			[ // 4
			]
		],
		[ // 2
			[ // 0
			],
			[ // 1
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[ // 3
			],
			[ // 4
			]
		],
		[ // 3
			[ // 0
			],
			[ // 1
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[ // 3
			],
			[ // 4
			]
		],
		[ // 4
			[ // 0
			],
			[ // 1
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[ // 3
			],
			[ // 4
			]
		]

	];


	// Different behaviors based on different camera "zones"
	var cameraFunctions = [
		Dictionary[ // Q1: TOP LEFT ////////////////////////////////////////////////////////////////////////////////////
			\synths -> { | actor, actorIndex |
				var posVector = actor[\position];

				var x = posVector[\x],
					y = posVector[\y];

				if( ((x >= 0.75) && (y >= 0.75)), {
					// THUMP ZONE
					Ndef(\bass).set(\amp, 0.4);

					thumpZoneIDs[actor[\id]] = 1;
					// thumpZone = true;
				}, {

					thumpZoneIDs[ actor[\id] ] = 0;

					if(thumpZoneIDs.values.sum < 1, {
						Ndef(\bass).set(\amp, 0);

						if( (~section == 2), {
							Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, ((  (x.abs - 1).abs.pow(3) * 8000) + 90), \pan, -1 );
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


					// IF WE ARE MOVING and we are not already flagged as moving
					if(motion == false, {
						var x = vector1[0],
						y = vector1[2];


						// QUADRANTS
						if((x >= 0.75) && (y <= -0.25), {
							// THUMP ZONE
							if(~section == 1, {
								Ndef(synths[0][~section][id % (synths[0][~section].size)]).set(\amp, 0);
							});
						}, {
							if(thumpZoneIDs.values.sum < 1, {

								if( (~section == 4), {
									// If we are moving, turn up the synth
										Ndef(synths[0][~section][id % (synths[0][~section].size)]).set(\amp, 0.4);
								});

								if(~section == 0, {
									// If we are moving, trigger a BOOP
									~createGraySineTrig.value(amp: 2, freq: 1703, switch: 3, length: 0.25, t_trigger: 1);
								});

							});
						});
						 // END QUADRANTS

						motion = true;

					});
				}, {
					// IF WE ARE NOT MOVING
					if(motion == true, {
						if(~section == 1, {
							// If we are not moving, turn down the volume on the synth
								Ndef(synths[0][~section][id % (synths[0][~section].size)]).set(\amp, 0.2);
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
				thumpZoneIDs[id] = 0;

				if(x >= 0.9, {
					//bEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				if( (~section == 1) || (~section == 2) || (~section == 2), {
					["turning off Q1"].postln;
					Ndef(\q1Callback).set(\amp, 0);
					Ndef(\pulseTrain0).play;
					Ndef(\graySine).play;
					Ndef(\graySine2).play;
				});
			},
			\lost -> { | id, x, y, z |

				if(x >= 0.9, {
					//bEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				// Thump ZOne
				// if( ((x >= 0.75) && (y >= 0.75)), {
					thumpZoneIDs[id] = 0;
				// }, {
				// 	thumpZoneIDs[id] = 0;
				// });

				if( (~section == 1), {
					if( (x >= 0.9) || (y >= 0.9), {
						["callback", x, y].postln;
						~createQ1Callback.value(pan: 1);
					});
				});


				if( (~wallOn == true), {
					"WALL".postln;
					if( (y>=0.9) || (x >= 0.9) || (x <= -0.21) || (y <= -0.21), {
						// WALL
						"WALL".postln;
						Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
					});
				});
			}
		],
		Dictionary[ // Q2: TOP RIGHT ////////////////////////////////////////////////////////////////////////////////////
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];


				if((x >= 0.75) && (y <= -0.25), {
					// THUMP ZONE
					Ndef(\bass).set(\amp, 0.4);
					thumpZoneIDs[ actor[\id] ] = 1;
				}, {
						thumpZoneIDs[ actor[\id] ] = 0;

					if( (~section == 0) || (~section == 1), {
						Ndef(synths[1][~section][actorIndex % (synths[1][~section].size)]).set(\freq, (((x.abs - 1).abs.pow(3) * 8000) + 90), \pan, -1 );
					});

					if(thumpZoneIDs.values.sum < 1, {
						/*Ndef(\bass).set(\amp, 0);*/
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
					var x = vector1[0],
						y = vector1[2];

					moving = true;

					// If we are moving and we are not already flagged as moving
					if(motion == false, {

						// THUMP ZONE
						if((x <= -0.25) && (y >= 0.75), {
							if(~section == 0, {
								//If in the thumpZone, turn off the synth
								/*Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.0);*/
							});
						}, {
							if(thumpZoneIDs.values.sum < 1 , {

								if( (~section == 0) || (~section == 4), {
									// IF WE ARE MOVING then turn up the synth
									Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.4);
								});

							});
						});

						motion = true;

					});
				}, {
						var x = vector1[0],
							y = vector1[2];

						if( (~section == 0) || (~section == 1), {
							// If we are not moving, turn down the synth
							Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.3);
						});

						if(motion == true, {

							// IF IN THE THUMP ZONE and not moving
							if((x <= -0.25) && (y <= -0.25), {
								if( (~section == 0) || (~section == 1), {
									Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.3);
								});
							}, {
								if( (~section == 0) || (~section == 1), {
									Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.3);
								});

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
				thumpZoneIDs[id] = 0;

				if(x <= -0.9, {
					//BEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});


				/*Ndef(\q2Callback).set(\amp, 0);
				Ndef(\pulseTrain0).play;
				Ndef(\graySine).play;
				Ndef(\graySine2).play;*/

			},
			\lost -> { | id, x, y, z |

				if(x <= -0.9, {
					//BEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				/*if((x >= 0.75) && (y <= -0.25), {*/
					// THUMP ZONE
					thumpZoneIDs[id] = 0;
				/*}, {*/
					/*thumpZoneIDs[id] = 0;*/
				/*});*/

				/*if( (~section == 1) || (~section == 2) || (~section == 3), {*/
					/*if( (x <= -0.9) || (y >= 0.9), {*/
						/*["lost", x, y].postln;*/
						/*~createQ2Callback.value(pan: 1);*/
					/*});*/
				/*});*/

			}
		],
		Dictionary[ // Q3: BOTTOM LEFT ////////////////////////////////////////////////////////////////////////////////////
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];

				if( (x <= -0.25) && (y >= 0.75), {
					// THUMP ZONE
					["THUMP"].postln;
					Ndef(\bass).set(\amp, 0.4);
					thumpZoneIDs[ actor[\id] ] = 1;
				}, {
					var actorY = (y + 1) / 2,
						actorYInverse =  ((y - 1) / 2).abs;

					thumpZoneIDs[ actor[\id] ] = 0;

					// GRAYSINE CONTROLLED
					if(thumpZoneIDs.values.sum < 1 , {
						Ndef(\bass).set(\amp, 0);

						if( (~section == 1), {
							Ndef(synths[2][~section][actorIndex % (synths[2][~section].size)]).set(\freq, ((  (x.abs - 1).abs.pow(3) * 8000) + 90) );
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

					// If we are moving and we are not already flagged as moving
					if(motion == false, {
						var x = vector1[0],
							y = vector1[2];

						// THUMP ZONE
						if((x >= 0.75) && (y <= -0.25), {
						}, {
							if(thumpZoneIDs.values.sum < 1, {
								if( (~section == 1), {
								// If we are moving, turn up the synth
									Ndef(synths[2][~section][id % (synths[2][~section].size)]).set(\amp, 0.4);
								});

							});
						});


						motion = true;

						});
				}, {
					var x = vector1[0],
					y = vector1[2];

					if(motion == true, {

						if((x >= 0.75) && (y <= -0.25), {
							if(  (~section == 1), {
								Ndef(synths[2][~section][id % (synths[2][~section].size)]).set(\amp, 0.3);
							});
						}, {
							if( (~section == 1), {
								// If we are not moving and not in thump zone, turn down the synth
								Ndef(synths[2][~section][id % (synths[2][~section].size)]).set(\amp, 0.3);
							});
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
				thumpZoneIDs[id] = 0;

				if(x >= 0.7, {
					//bEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				/*Ndef(\q3Callback).xset(\amp, 0);
				Ndef(\pulseTrain0).play;
				Ndef(\graySine).play;
				Ndef(\graySine2).play;*/
			},
			\lost -> { | id, x, y, z |

				/*if( (~section == 1), {*/
					/*if(x <= -0.9, {*/
						/*// WALL*/
						/*Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);*/
					/*}, {*/
						/*if( (y>=0.9) || (x >= 0.9) || (x <= -0.21) || (y <= -0.21), {*/
							/*// WALL*/
							/*Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);*/
						/*});*/
					/*});*/
				/*});*/

				/*if((x <= -0.25) && (y >= 0.75), {*/
					// THUMP ZONE
					thumpZoneIDs[id] = 0;
				/*}, {*/
					/*thumpZoneIDs[id] = 0;*/
				/*});*/

				/*
				if( (~section == 1) || (~section == 2) || (~section == 3), {
					if( (x >= 0.9) || (y <= -0.9), {
						["lost", x, y].postln;
						~createQ3Callback.value(pan: -1);
					});
				});
				*/

			}
		],
		Dictionary[ // Q4: BOTTOM RIGHT ////////////////////////////////////////////////////////////////////////////////////
			\synths -> { | actor, actorIndex |
				var x = actor[\position][\x],
					y = actor[\position][\y];


				if((x >= 0.75) && (y >= 0.75), {
					// THUMP ZONE
					Ndef(\bass).set(\amp, 0.4);

					thumpZoneIDs[ actor[\id] ] = 1;
				}, {
					thumpZoneIDs[ actor[\id] ] = 0;

					if(thumpZoneIDs.values.sum < 1, {
						Ndef(\bass).set(\amp, 0);

						if( (~section == 1), {
							Ndef(synths[3][~section][actorIndex % (synths[3][~section].size)]).set(\freq, ((   (x.abs - 1).abs.pow(3) * 8000) + 90) );
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

					// If we are moving and we are not already flagged as moving
					if(motion == false, {

						var x = vector1[0],
						y = vector1[2];

						if( (~section == 2), {
							Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.4);
						});

						// THUMP ZONE
						if((x >= 0.75) && (y >= 0.75), {
							if( (~section == 2), {
								Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0);
							});
						}, {

							if(thumpZoneIDs.values.sum < 1 , {
								if((~section == 2), {
									// IF NOT IN THUMP ZONE AND MOVING, turn up synth
									Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.4);
								});

								if( (~section == 0), {
									~createGraySineTrig.value(amp: 3, freq: 603, switch: 3, length: 1.3, t_trigger: 1);
								});

							});
						});

						motion = true;

					});
				}, {
						var x = vector1[0],
						y = vector1[2];

						if(motion == true, {

							if( (~section == 2), {
								// Thump Zone
								if((x >= 0.75) && (y <= -0.25), {
									Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.3);
								}, {
									// IF NOT MOVING turn down synth
									Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.3);
								});
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
			\new -> { | id, x, y, z |

				thumpZoneIDs[id] = 0;

				if( (~section == 1), {
					Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.4);
				});

				if(x <= 0.1, {
					//bEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				/*Ndef(\q4Callback).set(\amp, 0);
				Ndef(\pulseTrain0).play;
				Ndef(\graySine).play;
				Ndef(\graySine2).play;*/
			},
			\lost -> { | id, x, y, z |

				if( (~section == 2), {
					Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0);
				});

				/*if((x >= 0.75) && (y >= 0.75), {*/
					// THUMP ZONE
					thumpZoneIDs[id] = 0;
				/*}, {*/
					/*thumpZoneIDs[id] = 0;*/
				/*});*/

				// Callback at corner
				/*if( (~section == 1) || (~section == 2) || (~section == 3), {*/
					/*if( (x <= -0.9) || (y <= -0.9), {*/
						/*["lost", x, y].postln;*/
						/*~createQ4Callback.value(pan: -1);*/
					/*});*/
				/*});*/
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

		},
	];
};
