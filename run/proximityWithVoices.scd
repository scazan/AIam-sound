s.options.memSize = 1024 * 100;
s.waitForBoot({
	var startReceiver = {
		var maxY = 0,
			maxX = 0,
			maxNumTracked = 8,
			window;

		// Creating a struct/Dictionary for each synth
		var synths = Array.fill(maxNumTracked, {
			var freqBus = Bus.control(s,1),
				ampBus = Bus.control(s,1),
				node = Synth(\voice, [\voiceFreqBus, freqBus, \voiceAmpBus, ampBus ]),
				controller = Pbind(
				\type, \set,
				\id, node.nodeID,
				\args, #[\vowel, \transpose],
				\transpose, 0.75 + 0.25.rand,
				\dur, 4.5,
				\vowel, Prand([0,1,2,3,4], inf),
			).play;

			Dictionary[
				\ampBus -> ampBus,
				\freqBus -> freqBus,
				\node -> node,
				\controller -> controller
			];
		});


		// Create 3D vectors for each possible tracked person
		var energies = Array.fill(maxNumTracked, {Dictionary[\x -> 0, \y -> 0, \z -> 0 ]});
		var previousEnergies = Array.fill(maxNumTracked, {Dictionary[\x -> 0, \y -> 0, \z -> 0 ]});
		var positions = Array.fill(maxNumTracked, {Dictionary[\x -> 0, \y -> 0, \z -> 0 ]});

		var addEnergy = { | mag, id |
			var newEnergy = (energies[id][\x] + mag);

			if(newEnergy >= 1, {
				energies[id][\x] = 1;
			}, {
				energies[id][\x] = newEnergy;
			});
		};

		~prev = previousEnergies;
		~energies = energies;

		Tdef(\gravity, {
			{
				energies.do({ | item, i |
					if(energies[i][\x] > 0.01, {
						//energies[i][\x] = energies[i][\x] - 0.00027;
						//synths[i][\freqBus].set(energies[i][\x]**1.15);
						//synths[i][\node].set(\ramp, energies[i][\x] * 5);
						//synths[i][\ampBus].set(energies[i][\x]**2);
					}, {
						synths[i][\freqBus].set(0);
						synths[i][\ampBus].set(0);
					});
				});

				0.001.wait;
			}.loop;
		}).play;


		Tdef(\vowelChanger, {
			{
				synths.do({ |synth, i|
					var vowel = 5.rand;
					synth[\node].set(\vowel, vowel);
				});

				(2 + 3.0.rand).wait;
			}.loop;
		}).play;

		OSCdef(\tracker, { | msg |
			var id = msg[1].asFloat - 1,
				x = msg[2].asFloat / 1800,
				y = msg[3].asFloat / 500,
				z = msg[4].asFloat / 7000;

			var diffX = 0,
				diffY = 0,
				diffZ = 0;


			positions[id][\x] = x;
			positions[id][\y] = y;

			// Proximity
			if(id == 0, {
				var proximityX = (x - positions[1][\x]).abs,
					proximityY = (y - positions[1][\y]).abs;

				//[id, proximityX, x, positions[1][\x], (x - positions[1][\x]).abs].postln;
				//[id, proximityX].postln;

				~computeDensity.value(proximityX);
			}, {

				if(id == 1, {
					var proximityX = (x - positions[0][\x]).abs,
						proximityY = (y - positions[0][\y]).abs;

					//[id, proximityX, x, positions[0][\x]].postln;
				});
			});

			diffX = (previousEnergies[id][\x] - x).abs;
			diffY = (previousEnergies[id][\y] - y).abs;
			diffZ = (previousEnergies[id][\z] - z).abs;

			addEnergy.value(diffX, id);
			z = (z-0.5).abs / (1-0.5);

			if(diffX > 0.045, {
				synths[id][\node].set(\vowel, [1,2,3,4,5].choose);
			});

			previousEnergies[id] = Dictionary[\x -> x, \y -> y, \z -> z];

		}, path: \center, recvPort: 15002);



		// GUI
		window = Window.new("AIam Sound", Rect(100, 100, 100, 100)).front;
		window.view.background_(Color.new255(153, 255, 102));

		window.drawFunc = Routine({
			{
				window.view.background_(Color.new255(energies[0][\x] * 255, 0, 102));
				0.yield;
			}.loop;
		});

		window.onClose = {
			synths.do({ | synth, i |
				synth[\node].free;
				synth[\controller].stop;
				Tdef(\vocal).stop;
				Tdef(\vocal2).stop;
				Ndef(\bass).stop;
				Ndef(\pulseTrain0).stop;
			});
		};

		{ while { window.isClosed.not } { window.refresh; 0.04.wait; } }.fork(AppClock);
	};

	SynthDef(\voice, { 
		| amp=2, freq=30, vowel=0, voiceAmpBus, voiceFreqBus |
		var ampModFreq = LFNoise1.kr(MouseY.kr(0.05, 2)).unipolar.lag(0.2);
		var ampMod = Saw.ar(ampModFreq * 10 + 1).unipolar;
		var source, source2;


		var formants = Dictionary[
			\A -> [ [ 660, 1120, 2750, 3000, 3350 ], [ 1, 0.50118723362727, 0.070794578438414, 0.063095734448019, 0.012589254117942 ], [ 0.12121212121212, 0.080357142857143, 0.043636363636364, 0.043333333333333, 0.041791044776119 ] ],
			\E -> [ [ 440, 1800, 2700, 3000, 3300 ], [ 1, 0.19952623149689, 0.12589254117942, 0.1, 0.1 ], [ 0.15909090909091, 0.044444444444444, 0.037037037037037, 0.04, 0.036363636363636 ] ],
			\O -> [ [ 430, 820, 2700, 3000, 3300 ], [ 1, 0.31622776601684, 0.050118723362727, 0.079432823472428, 0.019952623149689 ], [ 0.093023255813953, 0.097560975609756, 0.037037037037037, 0.04, 0.036363636363636 ] ],
			\I -> [ [ 270, 1850, 2900, 3350, 3590 ], [ 1, 0.063095734448019, 0.063095734448019, 0.015848931924611, 0.015848931924611 ], [ 0.14814814814815, 0.048648648648649, 0.03448275862069, 0.035820895522388, 0.033426183844011 ] ],
			\U -> [ [ 370, 630, 2750, 3000, 3400 ], [ 1, 0.1, 0.070794578438414, 0.031622776601684, 0.019952623149689 ], [ 0.10810810810811, 0.095238095238095, 0.036363636363636, 0.04, 0.035294117647059 ] ]
		];

		var createVowel = { | input, vowel, voiceType = "counterTenor" |
			//var formant = FormantTable.get((voiceType++vowel).asSymbol);
			var formant = formants[vowel.asSymbol];

			var out = BBandPass.ar(
				in: input.at(0),
				freq: formant[0] * 1,
				bw: formant[1],
				mul: formant[2]
			);
			var out2 = BBandPass.ar(
				in: input.at(1),
				freq: formant[0] * 1,
				bw: formant[1],
				mul: formant[2]
			);

			[out.flatten(6), out2.flatten(6)];
		};



		freq = In.kr(voiceFreqBus).squared * 500 + 60;
		freq = ampModFreq * freq + 40;
		//source = Saw.ar([ freq, freq*1.01 ]);
		source = Saw.ar([ freq, freq*1.01 ]);

		source = source * ampMod;
		source = LPF.ar( source, 3000 );

		vowel = (LFNoise1.kr(2) * 4).floor;
		source = SelectX.ar(Lag.kr(vowel, 0.5), [createVowel.value(source, "A"), createVowel.value(source, "E"), createVowel.value(source, "I"), createVowel.value(source, "O"), createVowel.value(source, "U")]);

		//source = CombN.ar(source, delaytime: 0.06, decaytime: 0.2);
		source2 = FreeVerb2.ar(source, source, room: 0.1, damp: 1.0, mix: 0.5);
		source = Ringz.ar(source, 800, decaytime: 0.05, mul: 0.03) + source2;

		source = source * (Lag.kr(In.kr(voiceAmpBus), 0.001) * 0.25);
		Out.ar(0, (source * (amp.tanh * 6)).tanh );
	}).add;

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

	Ndef(\bass).play();

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
			Env.perc(0, 0.10, 1),gate: Impulse.kr(ramp * (density.lag(lag).pow(4)*10+1))
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
		snd ;
	});

	Ndef(\pulseTrain0).play();

	Tdef(\vocal, {
		{
			Ndef(\pulseTrain0).set(\density, [1,0.7,0.8,0.9, 0.7].choose);
			( 1.0.rand + 0.7 ).wait;
		}.loop;
	});
	Tdef(\vocal).play;

	Tdef(\vocal2, {
		{
			Ndef(\pulseTrain0).set(\vowel, [0,4,2].choose);
			( 3.0.rand + 0.7 ).wait;
		}.loop;
	});

	Tdef(\vocal2).play;

	~computeDensity = { |val|
		val = ((1 - val)**1 * 2).abs;

		if(val > 1.0, {
			Tdef(\vocal).stop;
			Ndef(\pulseTrain0).set(\lag, 5 );
			Ndef(\pulseTrain0).set(\density, val+0.5 );
		}, {
			Tdef(\vocal).play;
		});
	};
	Ndef(\pulseTrain0).fadeTime = 1;

	AppClock.sched(3, startReceiver);
});

Ndef(\pulseTrain0).edit;
