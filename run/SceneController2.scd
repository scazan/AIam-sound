~cSceneController = {
	var dict;
	var thumpZone = false;
	var thumpZoneIDs = ~thumpZoneIDs = Dictionary.new;

	//Synths are what are controlled per Actor
	// [quadrant, section, synth]
	var synths = [
		[ // 0
			[ // 0
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[],
			[ // 3
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[ // 4
				\graySine4,
				\graySine5,
				\graySine6
			]

		],
		[ // 1
			[ // 0
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[],
			[ // 3
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[ // 4
				\graySine4,
				\graySine5,
				\graySine6
			]
		],
		[ // 2
			[ // 0
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[],
			[ // 3
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[ // 4
				\graySine4,
				\graySine5,
				\graySine6
			]
		],
		[ // 3
			[ // 0
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[],
			[],
			[ // 3
				\graySine2,
				\graySine,
				\graySine2,
				\graySine
			],
			[ // 4
				\graySine4,
				\graySine5,
				\graySine6
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

							if( (~section == 0) || (~section == 3), {
								Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, ((  (x.abs - 1).abs.pow(3) * 8000) + 90) );

							});

							if(~section == 4, {
								// GraySine controlled
								// Setting up four sections on the x-axis
								if(x <= -0.5, {
									// Low sound
									Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, 1000/2);
									}, {
										if(x <= 0, {
											//high sound
											Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, 1500);
											}, {
												if(x <= 0.5, {
													//med sound
													Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, 2700/1, \amp, 0.1);
													}, {
														if(x <= 1, {
															//high sound
															Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, 1700/2);
														});
												});
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

				// energy.postln;

				if(energy > ~energyThreshold, {
					moving = true;


					// IF WE ARE MOVING and we are not already flagged as moving
					if(motion == false, {
						var x = vector1[0],
						y = vector1[2];


						// QUADRANTS
						if((x >= 0.75) && (y <= -0.25), {
							// THUMP ZONE
							if(~section == 0, {
								Ndef(synths[0][~section][id % (synths[0][~section].size)]).set(\amp, 0);
							});
						}, {
								if(thumpZoneIDs.values.sum < 1, {

									if(~section == 4, {
										// If we are moving, turn up the synth
										Ndef(synths[0][~section][id % (synths[0][~section].size)]).set(\amp, 0.4);
									});

									if(~section == 0, {
										// If we are moving, trigger a BOOP
										~createGraySineTrig.value(amp: 2, freq: 1703, switch: 3, length: 0.25, t_trigger: 1);
									});

									if(~section == 4, {
										// If we are moving, trigger a BOOP
										~createAiryTrig.value(amp: 1, freq: 1703, switch: 3, length: 0.25, t_trigger: 1);
									});

								});
						});
						 // END QUADRANTS

						motion = true;

					});
				}, {
					// IF WE ARE NOT MOVING
					if(motion == true, {
						if(~section == 0, {
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
			},
			\lost -> { | id, x, y, z |

				if(x >= 0.9, {
					//bEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				if( ((x >= 0.75) && (y >= 0.75)), {
					// Ndef(\bass).set(\amp, 0);
					thumpZoneIDs[id] = 1;
					// thumpZone = false; // TODO: Fix for multiple users
				}, {
					thumpZoneIDs[id] = 0;
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
					// thumpZone = true;
					}, {
						thumpZoneIDs[ actor[\id] ] = 0;


						if( (~section == 0) || (~section == 3), {
							Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, (((x.abs - 1).abs.pow(3) * 8000) + 90) );
						});

						if(thumpZoneIDs.values.sum < 1, {
							Ndef(\bass).set(\amp, 0);

							if(~section == 4, {
								// Setting up four sections on the x-axis
								if(x <= -0.5, {
									// Low sound
									Ndef(synths[1][~section][actorIndex % (synths[1][~section].size)]).set(\freq, 1000/2);
									}, {

										// graySine controlled
										if(x <= 0, {
											//high sound
											Ndef(synths[1][~section][actorIndex % (synths[1][~section].size)]).set(\freq, 1500);
											}, {
												if(x <= 0.5, {
													//med sound

													Ndef(synths[1][~section][actorIndex % (synths[1][~section].size)]).set(\freq, 2700/1, \amp, 0.1);
													}, {
														if(x <= 1, {
															//high sound
															Ndef(synths[1][~section][actorIndex % (synths[1][~section].size)]).set(\freq, 1700/2);
														});
												});
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

				// energy.postln;

				if(energy > ~energyThreshold, {
					var x = vector1[0],
						y = vector1[2];

					moving = true;

					// Ndef(synths[1][id % (synths[1].size)]).set(\amp, 0.4);


					// Ndef(synths[1][id % (synths[1].size)]).set(\x, (x + 1)/2);
					/* Ndef(\pad).set(\dist, (x + 1)*2);
					Ndef(\pad).set(\amp, 0.1);*/

					// If we are moving and we are not already flagged as moving
					if(motion == false, {

						// THUMP ZONE
						if((x <= -0.25) && (y >= 0.75), {
							if(~section == 0, {
								//If in the thumpZone, turn off the synth
								Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.0);
							});
						}, {
							if(thumpZoneIDs.values.sum < 1 , {
									if( (~section == 0) || (~section == 4), {
										// IF WE ARE MOVING then turn up the synth
										Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.4);
									});
									if( (~section == 0), {
										// If we are moving, trigger a boop
										~createGraySineTrig.value(amp: 3, freq: 603, switch: 3, length: 1.3, t_trigger: 1);
									});

									if(~section == 4, {
										// If we are moving, trigger a BOOP
										~createEarthTrig.value(amp: 0.5, freq: 1.0.rand + 0.5, pan: 2.0.rand - 1);
									});
							});
						});


						motion = true;

						});
				}, {
						var x = vector1[0],
						y = vector1[2];

						if( (~section == 0) || (~section == 4), {
							// If we are not moving, turn down the synth
							Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.2);
						});

						if(motion == true, {

							// THE THUMP ZONE
							if((x <= -0.25) && (y <= -0.25), {
								if( (~section == 0) || (~section == 4), {
									Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.0);
								});
							}, {
								if( (~section == 0) || (~section == 4), {
									Ndef(synths[1][~section][id % (synths[1][~section].size)]).set(\amp, 0.2);
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

			},
			\lost -> { | id, x, y, z |

				if(x <= -0.9, {
					//BEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				if((x >= 0.75) && (y <= -0.25), {
					// THUMP ZONE
					// Ndef(\bass).set(\amp, 0); // TODO: make this work for multiple ids
					thumpZoneIDs[id] = 1;
				}, {
					thumpZoneIDs[id] = 0;
				});

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

							if( (~section == 3), {
								Ndef(synths[2][~section][actorIndex % (synths[2][~section].size)]).set(\freq, ((  (x.abs - 1).abs.pow(3) * 8000) + 90) );
							});

							if( (~section == 4), {
								// Setting up four sections on the x-axis
								if(x <= -0.5, {
									// Low sound
									Ndef(synths[2][~section][actorIndex % (synths[2][~section].size)]).set(\freq, 1000/2);
									}, {
										if(x <= 0, {
											//high sound
											Ndef(synths[2][~section][actorIndex % (synths[2][~section].size)]).set(\freq, 1500);
											}, {
												if(x <= 0.5, {
													//med sound

													Ndef(synths[2][~section][actorIndex % (synths[2][~section].size)]).set(\freq, 2700/1, \amp, 0.1);
													}, {
														if(x <= 1, {
															//high sound
															Ndef(synths[2][~section][actorIndex % (synths[2][~section].size)]).set(\freq, 1700/2);
														});
												});
										});
								});
							}); // End Section


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
							if( (~section == 4), {
								Ndef(synths[2][~section][id % (synths[2][~section].size)]).set(\amp, 0.0);
							});
						}, {
								if(thumpZoneIDs.values.sum < 1, {
									if( (~section == 4), {
									// If we are moving, turn up the synth
										Ndef(synths[2][~section][id % (synths[2][~section].size)]).set(\amp, 0.4);
									});

									if(~section == 4, {
										// If we are moving, trigger a BOOP
										~createWaterTrig.value(amp: 0.5, freq: 950.rand + 1500, pan: 2.0.rand - 1);
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
								if( (~section == 0) || (~section == 4), {
									Ndef(synths[2][~section][id % (synths[2][~section].size)]).set(\amp, 0.0);
								});
							}, {
								if( (~section == 0) || (~section == 4), {
									// If we are not moving and not in thump zone, turn down the synth
									Ndef(synths[2][~section][id % (synths[2][~section].size)]).set(\amp, 0.2);
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
				}, {

				});
			},
			\lost -> { | id, x, y, z |

				if( (~section == 1), {
					if(x <= -0.9, {
						// WALL
						Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
					}, {
						if( (y>=0.9) || (x >= 0.9) || (x <= -0.21) || (y <= -0.21), {
							// WALL
							Ndef(\noiseImpulse).set(\amp, 0.6, \t_trigger, 1);
						});
					});
				});

				if((x <= -0.25) && (y >= 0.75), {
					// THUMP ZONE
					thumpZoneIDs[id] = 1;
				}, {
					thumpZoneIDs[id] = 0;
				});

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

							if( (~section == 0) || (~section == 3), {
								Ndef(synths[0][~section][actorIndex % (synths[0][~section].size)]).set(\freq, ((   (x.abs - 1).abs.pow(3) * 8000) + 90) );
							});

							if( (~section == 4), {
								// Setting up four sections on the x-axis
								// GRAYSINE CONTROLLED
								if(x <= -0.5, {
									// Low sound
									Ndef(synths[3][~section][actorIndex % (synths[3][~section].size)]).set(\freq, 1000/2);
									}, {
										if(x <= 0, {
											//high sound
											Ndef(synths[3][~section][actorIndex % (synths[3][~section].size)]).set(\freq, 1500);
											}, {
												if(x <= 0.5, {
													//med sound
													Ndef(synths[3][~section][actorIndex % (synths[3][~section].size)]).set(\freq, 2700/1, \amp, 0.1);
													}, {
														if(x <= 1, {
															//high sound
															Ndef(synths[3][~section][actorIndex % (synths[3][~section].size)]).set(\freq, 1700/2);
														});
												});
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

					// If we are moving and we are not already flagged as moving
					if(motion == false, {

						var x = vector1[0],
						y = vector1[2];

						if( (~section == 0) || (~section == 3) || (~section == 4), {
							Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.4);
						});

						// THUMP ZONE
						if((x >= 0.75) && (y >= 0.75), {
							if( (~section == 0) || (~section == 3), {
								Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0);
							});
						}, {

								if(thumpZoneIDs.values.sum < 1 , {
									if( (~section == 0) || (~section == 3), {
										// IF NOT IN THUMP ZONE AND MOVING, turn up synth
										Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.4);
									});


									if( (~section == 0), {
										// QUADRANTS
										if((x >= 0) && (y >= 0), {
											// LOW
											~createGraySineTrig.value(amp: 3, freq: 603, switch: 3, length: 1.3, t_trigger: 1);

											"QUAD 2".postln;
											},{
												if((x >= 0) && (y < 0), {
													// HIGH
													~createGraySineTrig.value(amp: 2, freq: 1703, switch: 3, length: 0.25, t_trigger: 1);

													"QUAD 4".postln;
													}, {
														if((x < 0) && (y < 0), {
															// LOW
															~createGraySineTrig.value(amp: 3, freq: 603, switch: 3, length: 1.3, t_trigger: 1);

															"QUAD 3".postln;
															}, {
																if((x < 0) && (y >= 0), {
																	// MEDIUM
																	~createGraySineTrig.value(amp: 2, freq: 1003, switch: 3, length: 0.55, t_trigger: 1);

																	"QUAD 1".postln;
																});
														});
												});
										});
									});


									if(~section == 4, {
										// If we are moving, trigger a BOOP
										~createMetalTrig.value(amp: 0.5, freq: 1.0.rand + 0.5, pan: 2.0.rand - 1);

									});

								});
						});


						motion = true;

						});
				}, {
						var x = vector1[0],
						y = vector1[2];

						if(motion == true, {

							if( (~section == 0) || (~section == 3) || (~section == 4), {
								if((x >= 0.75) && (y <= -0.25), {
									Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.0);
								}, {
									// IF NOT MOVING turn down synth
									Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.2);
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

				if( (~section == 0) || (~section == 3) || (~section == 4), {
					Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0.4);
				});

				if(x >= 0.9, {
					//bEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});
			},
			\lost -> { | id, x, y, z |

				if( (~section == 0) || (~section == 3) || (~section == 4), {
					Ndef(synths[3][~section][id % (synths[3][~section].size)]).set(\amp, 0);
				});
				if(x >= 0.9, {
					//bEEP
					~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);
				});

				if((x >= 0.75) && (y >= 0.75), {
					// THUMP ZONE
					thumpZoneIDs[id] = 1;
				}, {
					thumpZoneIDs[id] = 0;
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

		},
	];
};