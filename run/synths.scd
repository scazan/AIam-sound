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

	Ndef(\saw2, { | section=1, freq=600, x=0.5, y=0.5 |
		var out;
		//var freq = (0 + (3*12)).midicps;
		var pulses = Array.newClear(4);
		freq = freq.lag(0.3);
		4.do({ | i |
			//pulses[i] = LFPulse.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			pulses[i] = Saw.ar([ freq, freq * (x + 1.01) ] * (i+1), mul: 0.25);
		});

		out = (Mix.new(pulses) * ( 600 * LFPulse.ar(8).lag(0.1) )).tanh * 0.5 ;
		out = out + (SinOsc.ar(freq /4) + SinOsc.ar(freq/5) * (x*0.8));
		out = FreeVerb.ar(out);

		//out = RLPFD.ar(out, MouseY.kr(200, 1000), 0.9) * 0.5;
		out = LPF.ar(out, (y*800) + 200) * 0.5;
		//out = LPF.ar(out, MouseY.kr(200, 1000)) * 0.5;

		SelectX.ar(section, [out, out * LFPulse.ar(8, width: 0.7).unipolar.lag(0.1)])*0.15;
	});

	Ndef(\saw, { | section=0, freq=300, x=0.5, y=0.5 |
		var out;
		//var freq = (0 + (3*12)).midicps;
		var pulses = Array.newClear(4);
		freq = freq.lag(0.3);
		4.do({ | i |
			//pulses[i] = LFPulse.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			//pulses[i] = Saw.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			pulses[i] = Saw.ar([ freq, freq * (x+1)] * (i+1), mul: 0.25);
		});

		out = (Mix.new(pulses) * ( freq/6 * LFPulse.ar(8).lag(0.1) )).tanh * 0.5 ;
		out = out + (SinOsc.ar(freq /4) * (x*0.8));
		out = FreeVerb.ar(out);

		out = RLPFD.ar(out, (y * 800) + 200, 0.9) * 0.5;
		//out = LPF.ar(out, MouseY.kr(200, 1000)) * 0.5;

		(SelectX.ar(section, [out, out * LFPulse.ar(8, width: 0.7).unipolar.lag(0.1)]) * 5).tanh * 0.15;
	});

	Ndef(\reverb, { | amp=0, freq=2000 |
		FreeVerb.ar( Ndef(\saw).ar + Ndef(\saw2).ar );
	});

    Ndef(\pulseTrain0).play();
	Ndef(\pulseTrain0).fadeTime = 1;
	Ndef(\bass).play();
	Ndef(\reverb).play();
