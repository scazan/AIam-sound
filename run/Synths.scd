~cSynths = {
	var dict, sceneSynths;

	// Busses
	~onsetBusses = [Bus.control(s,3), Bus.control(s,3), Bus.control(s,3)];

	// Synths

	// Scene 1
	// Fold space into sine
	// Ndef(\graySine, { | amp=0, freq=2100, q=0.4, x=0.5, y=0.5, z=0.5 |
	Ndef(\graySine, { | amp=0, freq=703, q=0.4, x=0.5, y=0.5, z=0.5 |
		var verb;
		var noise = WhiteNoise.ar();
		var modFreq = ( x.linlin(-1,1, 0, 4).sin * 20).abs + 0.1;
		var lag = (modFreq/20).pow(4).clip(0,1);

		var filtered;
		var freqs = [freq, freq * 1.2, freq * 0.6, freq * 0.75];

		freq = SelectX.kr(y.linlin(-1,1,0,1 * freqs.size).abs.floor, freqs);

		// freq = freq + (x.abs * 100);


		filtered = BPF.ar(noise,
			//freq: [freq, freq * 1.1] + LFPulse.ar(modFreq, mul: 240).unipolar.lag(0.1),
			freq: [freq * 0.7, freq * 0.61, freq*0.5, freq*0.55] + LFPulse.ar(modFreq.clip(1,20), mul: [freq/4, freq/2, freq/3]).unipolar.lag(lag.abs),
			rq: q * 0.001
		);

		filtered = (filtered*2).tanh * 1;
		filtered = LPF.ar(filtered, freq: 9500);

		verb = FreeVerb.ar( filtered * amp.lag(1),
			mix: 0.6,
			room: 0.5,
			damp: 0.1
		) ;

		verb = verb * 0.995;

		verb * 3;
		//* z.abs;
	});

	//Scene 2
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

		HPF.ar(out, 30).tanh * 0.9 * amp;
	});


	Ndef(\pulseTrain0, {arg freq = 200, ramp=2.2, dist=1, amp=0, octave=1, density=1, vowel=0, lag=1;
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
			Env.perc(0, 0.10, 1),gate: Impulse.kr(ramp * (density.lag(lag).pow(4)*8+1).clip(0,30))
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
		snd = HPF.ar(snd, 700);
		snd * amp * 18.7 ;
	});

	Ndef(\saw, { | section=1, freq=200, x=0.5, y=0.5, z=0.5, amp=1 |
		var out;
		//var freq = (0 + (3*12)).midicps;
		var pulses = Array.newClear(4);
		freq = freq.lag(0.3);
		4.do({ | i |
			//pulses[i] = LFPulse.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			pulses[i] = Saw.ar([ freq, freq * (x.linlin(-1,1, 0,1).abs + 1.01) ] * (i+1), mul: 0.25);
		});

		out = (Mix.new(pulses) * ( 600 * LFPulse.ar(8).lag(0.1) )).tanh * 0.5 ;
		out = out + (SinOsc.ar(freq /4) + SinOsc.ar(freq/6) * (x.abs*0.8) * 10).tanh;
		out = FreeVerb.ar(out);

		//out = RLPFD.ar(out, MouseY.kr(200, 1000), 0.9) * 0.5;
		out = LPF.ar(out, (z.lag(0.1).abs*800) + 200) * 0.5;
		//out = LPF.ar(out, MouseY.kr(200, 1000)) * 0.5;

		SelectX.ar(section, [out, out * LFPulse.ar(8, width: 0.7).unipolar.lag(0.1)])*0.5 * y.linlin(-1.7,2, 0,1).clip(0,1).lag(0.5) * amp;
	});

	Ndef(\saw2, { | section=0, freq=300, x=0.5, y=0.5, z=0.5, amp=1 |
		var out;
		//var freq = (0 + (3*12)).midicps;
		var pulses = Array.newClear(4);
		freq = freq.lag(0.3);
		4.do({ | i |
			//pulses[i] = LFPulse.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			// pulses[i] = Saw.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			pulses[i] = Saw.ar([ freq, freq * (x.abs+1.01)] * (i+1), mul: 0.25);
		});

		out = (Mix.new(pulses) * ( freq/6 * LFPulse.ar(8).lag(0.1) )).tanh * 0.5 ;


		// out = out + (SinOsc.ar(freq /4) * (x.abs*0.8));
		out = FreeVerb2.ar(out[0], out[1]);

		// out = RLPFD.ar(out, MouseY.kr(200, 1000),0.9) * 0.5;
		out = RLPFD.ar(out, (z.lag(0.1).abs * 800) + 200, 0.9) * 0.5;
		// out = LPF.ar(out, MouseY.kr(200, 1000)) * 0.5;

		(SelectX.ar(x-1, [out, out * LFPulse.ar(8, width: 0.7).unipolar.lag(0.1)]) * 5).tanh * 0.35  * y.linlin(-2,2, 0,1).lag(0.5) * amp;
	});



	Ndef(\reverb, { | amp=0, freq=2000 |
		FreeVerb.ar( Ndef(\saw).ar + Ndef(\saw2).ar, room:0.8, mix: 0.6 ) * 1.0 * amp;
	});


	Ndef(\sawPad, { arg freq=75, amp=0, resonantFreq=1760;
		var waveTable = Wavetable.chebyFill(513, [0, 0, 1]);
		var buf = LocalBuf.newFrom(waveTable);
		var out;
		var numSaws = 9;
		// var spread = MouseY.kr(3, 50);
		var spread = 5;
		var saws = Array.newClear(numSaws);
		var saws2 = Array.newClear(numSaws);

		// A bit of portamento...
		freq = freq.lag(0.25);

		numSaws.do({ arg index; // Which one are we doing... which iteration we are on
			saws.put(index, Saw.ar(freq + (spread * 1.0.rand) ) );
			saws2.put(index, Saw.ar(freq + (spread * 1.0.rand) ) );
		});

		out = LPF.ar([ Mix.new(saws), Mix.new(saws2) ], 2000) * 0.6;
		out = Shaper.ar(buf, out) + LPF.ar((BMoog.ar(out,freq: resonantFreq, q: 0.1, mode: 2.5, mul: 1) *0.9).wrap * 0.95, 9000);
		out = FreeVerb2.ar(out[0], out[1]);
		out * amp;
	});


	Ndef(\clink, { | amp=0, freq=2000 |
	var noise = WhiteNoise.ar() * LFPulse.ar(2, width: 0.1);
		var delay = AllpassC.ar(noise, decaytime: 2.2);

		delay = HPF.ar(delay, [ 10000, 10100 ]);

		delay = delay * amp;
		delay = FreeVerb.ar(delay );

		delay;
	});






	// Onset timing
	3.do({ |i|
		Ndef(("onsets"++i).asSymbol, { | amp=0 |
			var trackb,trackh,trackq,tempo;
			var input = ~onsetBusses[i];

			var chain = FFT({ LocalBuf(512) } ! input.numChannels, input);
			var onsets = Onsets.kr(chain, 0, \rcomplex);
			var timer = Timer.kr(onsets);

			SendReply.kr(onsets, '/reply', timer, i);
		});

	});




	dict = Dictionary[
		\play -> {
			// Ndef(\pulseTrain0).play();
			//Ndef(\pulseTrain0).fadeTime = 1;
			/*Ndef(\bass).play();
			Ndef(\reverb).play();
			Ndef(\sawPad).play();*/
			//Ndef(\sawPad).fadeTime = 60*4;
			// Ndef(\sawPad).xset(\amp, 0.15);
		},
		\stop -> {
			Ndef(\bass).stop;
			// Ndef(\pulseTrain0).stop;
			Ndef(\reverb).stop;
			Ndef(\sawPad).stop();

		}
	];

	dict;
};
