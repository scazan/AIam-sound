s.options.memSize = 1024 * 100;

s.waitForBoot({
	var numActors = 3;
	var actor = {
		var position = Dictionary[\x -> 0, \y -> 0, \z -> 0 ];

		Dictionary[
			\id -> 0,
			\active -> false,
			\position -> position,
			\synths -> [],
		];
	};

	var actors = Array.fill(numActors, actor);
	var actorProximity = 999;

	var computeProximity2XZ = { | vectors |
		var x=0, y=1, euclideanDistance;

		euclideanDistance = ((vectors[0][x] - vectors[1][x]).pow(2) + (vectors[0][y] - vectors[1][y]).pow(2)).sqrt;
		euclideanDistance;
	};

	var computeProximityN2D = { | vectors |
		var distances = Array.fill(vectors.size, 0),
			index = 0,
			averageDistance = 0;

		vectors.do({ | subject, i |
			var others = (vectors++[]);
			others = others.copyToEnd(i+1);

			others.do({ | other, k |
				var distance = computeProximity2XZ.value([subject, other]);

				distances[index] = distance;
				index = index + 1;
			});

		});

		averageDistance = distances.sum()/distances.size;
	};

	var startReceiver = {
		var maxY = 0,
			maxX = 0,
			maxNumTracked = numActors,
			window;

		~computeDensity = { |val|
			val = ((1 - val)**1 * 2).abs;

			if(val > 1.0, {
				[">>", val ].postln;
				Tdef(\vocal).stop;
				Ndef(\pulseTrain0).set(\lag, 1 );
				Ndef(\pulseTrain0).set(\density, val+0.5 );
			}, {
				Tdef(\vocal).play;
			});
		};





		// Listeners
		OSCdef(\actorStateListener, { | msg |
			var state = msg[2],
				id = msg[1].asInteger();

			case(
				{state == "new"
				|| state == "visible"}, {
					var inactiveSynths;
					var existingSynths = actors.select({ | synth |
						(synth[\trackingID] == id) && (synth[\active] == true);
					});

					if(existingSynths.size == 0, {
						inactiveSynths = actors.select({ | synth |
							synth[\active] == false;
						});

					}, {
						inactiveSynths = existingSynths;
					});

					if(inactiveSynths.size > 0, {
						// grab the first inactive synth available
						var inactiveSynth = inactiveSynths[0];
						// Set it to be active with this id
						inactiveSynth[\trackingID] = id;
						inactiveSynth[\active] = true;
					});
				},
				{state == "tracking"}, {},
				{state == "lost"
				|| state == "stopped_tracking"}, {
					// find where this was being tracked previously
					var lostSynth = actors.select({ | synth |
						synth[\trackingID] == id;
					});

					// Deactivate the slot
					lostSynth.do({ | synth |
						synth[\active] = false;
					});
				},
			);
		}, path: \state, recvPort: 15002);

		OSCdef(\tracker, { | msg |
			//var id = msg[1].asFloat - 1,
			var id = msg[1].asFloat,
				x = msg[2].asFloat / 1800,
				y = msg[3].asFloat / 500,
				z = msg[4].asFloat / 7000;

			var diffX = 0,
				diffY = 0,
				diffZ = 0;


			var activeActor;
			var activeActors;
			id = id - 1;
			activeActors = actors.select({ | actor |
				actor[\id] == id;
			});

			if(activeActors.size == 0, {
				// get all the inactive synths
				var inactiveSynths = actors.select({ | synth |
					synth[\active] == false;
				});


				// if we have inactive synths available
				if(inactiveSynths.size > 0, {
					// use the first inactive synth
					var inactiveSynth = inactiveSynths[0];
					inactiveSynth[\id] = id;
					inactiveSynth[\active] = true;

					activeActor = inactiveSynth;
				});

				// TODO: what to do when there are no synths available? currently ignore that actor

			}, {
				activeActor = activeActors[0];
			});


			// If we have an actor, then set its position
			if(activeActor.notNil, {
				var allActiveActors = actors.select({|item| item[\active] == true});

				activeActor[\position][\x] = x;
				activeActor[\position][\y] = y;
				activeActor[\position][\z] = z;

				//z = (z-0.5).abs / (1-0.5);


				// update the proximities
				// We need at least two actors to judge a distance
				if(allActiveActors.size >= 2, {
					actorProximity = computeProximityN2D.value(allActiveActors.collect({ | item | [item[\position][\x], item[\position][\z] ] ; }));
					actorProximity.postln;
				});

				// Update any synths with new info
				~computeDensity.value(actorProximity);
			});

		}, path: \center, recvPort: 15002);


		// GUI
		window = Window.new("AIam Sound", Rect(100, 100, 100, 100)).front;
		window.view.background_(Color.new255(153, 255, 102));

		//window.drawFunc = Routine({
			//{
				//window.view.background_(Color.new255(energies[0][\x] * 255, 0, 102));
				//0.yield;
			//}.loop;
		//});

		window.onClose = {
			//synths.do({ | synth, i |
				Tdef(\vocal).stop;
				Tdef(\vocal2).stop;
				Ndef(\bass).stop;
				Ndef(\pulseTrain0).stop;
			//});
		};

		{ while { window.isClosed.not } { window.refresh; 0.04.wait; } }.fork(AppClock);
	};

	// Synths

	Ndef(\pad, { | amp=0.25, freq = 500, mod = 0.3, dist=0 |
		var out = LFPulse.ar(freq) + (LFPulse.ar(freq / 0.75) * LFPulse.ar(20.2, mul: SinOsc.kr(0.1, mul:0.5), add: 0.4)) ;
		out = LFNoise1.ar(0.5, mul: 0.4, add: 0.6) * out;
		out = LPF.ar(out, 300).tanh;

		out = out + ((SinOsc.ar(freq *2) * Lag.kr( dist, 0.7 )/2) * LFPulse.ar(4).unipolar);
		out = out + ((SinOsc.ar(freq *3) * Lag.kr( dist, 0.7 )/2) * LFPulse.ar(2.5).unipolar);

		out = out + (LPF.ar(SinOsc.ar(freq / 8) * LFPulse.ar(2.0/8, width: 0.25).unipolar, 70) * 0.25);

		([ out, DelayL.ar( out) ] * 1).tanh * Lag.kr(amp, 0.5);
	});


	Ndef(\bass, { | amp=0, freq=2000 |
		var reverb = FreeVerb.ar(_, mix: 0.5, room: 0.8);
		var lpf = LPF.ar(_, 180);
		var bpf = BPF.ar(_, 40, 0.5);
		var rumble = bpf.value(GrayNoise.ar());

		var hum = LFTri.ar([50, 54]) * (0.7 + Pulse.ar(0.2, width: 0.01).unipolar.lag(0.5) * 0.2);

		var out = reverb.value( lpf.value(rumble + hum) );

		HPF.ar(out, 30).tanh * 0.9;
	});


	Ndef(\pulseTrain0, {arg freq = 200, ramp=2.2, dist=1, amp=7.7, octave=1, density=1, vowel=0, lag=5;
		var out, formants, createVowel, snd;
		var noise = LFNoise1.kr(2).unipolar;

		freq = freq/octave;
		out = (CombN.ar(
			LFPulse.ar(
				[freq * 1.0,freq * 1.01]
			),
			0.35, 0.051 
		)*dist).tanh
		*
		0.8 *
		EnvGen.ar(
			Env.perc(0, 0.10, 1),gate: Impulse.kr(ramp * (density.lag(lag).pow(4)*8+1))
		) * amp;

		formants = Dictionary[
			\A -> [ [ 660, 1120, 2750, 3000, 3350 ], [ 1, 0.50118723362727, 0.070794578438414, 0.063095734448019, 0.012589254117942 ], [ 0.12121212121212, 0.080357142857143, 0.043636363636364, 0.043333333333333, 0.041791044776119 ] ],
			\E -> [ [ 440, 1800, 2700, 3000, 3300 ], [ 1, 0.19952623149689, 0.12589254117942, 0.1, 0.1 ], [ 0.15909090909091, 0.044444444444444, 0.037037037037037, 0.04, 0.036363636363636 ] ],
			\O -> [ [ 430, 820, 2700, 3000, 3300 ], [ 1, 0.31622776601684, 0.050118723362727, 0.079432823472428, 0.019952623149689 ], [ 0.093023255813953, 0.097560975609756, 0.037037037037037, 0.04, 0.036363636363636 ] ],
			\I -> [ [ 270, 1850, 2900, 3350, 3590 ], [ 1, 0.063095734448019, 0.063095734448019, 0.015848931924611, 0.015848931924611 ], [ 0.14814814814815, 0.048648648648649, 0.03448275862069, 0.035820895522388, 0.033426183844011 ] ],
			\U -> [ [ 370, 630, 2750, 3000, 3400 ], [ 1, 0.1, 0.070794578438414, 0.031622776601684, 0.019952623149689 ], [ 0.10810810810811, 0.095238095238095, 0.036363636363636, 0.04, 0.035294117647059 ] ]
		];

		createVowel = { | input, vowel, voiceType = "counterTenor" |
			//var formant = FormantTable.get((voiceType++vowel).asSymbol);
			var formant = formants[vowel.asSymbol];

			var out = BBandPass.ar(
				in: input.at(0),
				freq: formant[0],
				bw: formant[1],
				mul: formant[2]
			);
			var out2 = BBandPass.ar(
				in: input.at(1),
				freq: formant[0],
				bw: formant[1],
				mul: formant[2]
			);

			[out.flatten(6), out2.flatten(6)];
		};
		snd = SelectX.ar(Lag.kr(vowel, 0.5), [createVowel.value(out, "A"), createVowel.value(out, "E"), createVowel.value(out, "I"), createVowel.value(out, "O"), createVowel.value(out, "U")]);
		snd = RLPFD.ar(snd, noise * 600 + 100, (noise * 0.4 + 0.2).clip(0,1) );
		snd = MidEQ.ar(snd, 642, 0.1, 15);
		snd * 1 ;
	});


	// ROUTINES
	Tdef(\vocal, {
		{
			Ndef(\pulseTrain0).set(\density, [1,0.7,0.8,0.9, 0.7].choose);
			( 1.0.rand + 0.7 ).wait;
		}.loop;
	});

	Tdef(\vocal2, {
		{
			Ndef(\pulseTrain0).set(\vowel, [0,4,2].choose);
			( 3.0.rand + 0.7 ).wait;
		}.loop;
	});

	Ndef(\pulseTrain0).play();
	Ndef(\pulseTrain0).fadeTime = 1;
	Ndef(\bass).play();

	Tdef(\vocal).play;
	Tdef(\vocal2).play;


	AppClock.sched(3, startReceiver);
});

