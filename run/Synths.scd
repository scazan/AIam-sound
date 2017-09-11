~cSynths = {
	var dict, sceneSynths;

	// Busses
	~onsetBusses = [Bus.control(s,3), Bus.control(s,3), Bus.control(s,3)];

	// Synths

	// Scene 1

	Ndef(\graySine, { | amp=0, freq=703, q=0.4, x=0.5, y=0.5, z=0.5 |
		var verb;
		var noise = WhiteNoise.ar();
		// var modFreq = ( x.linlin(-1,1, 0, 4).sin * 20).abs + 0.1;
		// var modFreq = SelectX.kr((MouseY.kr(0,1) * 4).abs.floor % 2, [MouseX.kr(0.0, 18.0).sin * 20 + 0.1, MouseX.kr(0.0, 18.0).cos * 20 + 0.1]);
		var modFreq = SelectX.kr((y.linlin(-1,1,0,1 * 4)).abs.floor % 2, [x.linlin(-1,1, 0, 18).sin * 20 + 0.1, x.linlin(-1,1, 0, 18).cos * 20 + 0.1]);
		var lag = (modFreq/10).pow(4).clip(0,1);

		var filtered;
		var freqs = [freq, (freq.cpsmidi + 1).midicps, (freq.cpsmidi + 3).midicps, (freq.cpsmidi - 1).midicps];

		// freq = SelectX.kr(y.linlin(-1,1,0,1 * freqs.size).abs.floor, freqs);
		// freq = SelectX.kr((MouseY.kr(0,1) * freqs.size).abs.floor, freqs).lag(0.012);
		freq = SelectX.kr(y.linlin(-1,1,0,1 * freqs.size).abs.floor, freqs).lag(0.012);

		// freq = freq + (x.abs * 100);


		filtered = BPF.ar(noise,
			//freq: [freq, freq * 1.1] + LFPulse.ar(modFreq, mul: 240).unipolar.lag(0.),
			freq: [freq * 0.7, freq * 0.61] + LFPulse.ar(modFreq.clip(5, 30), mul: [freq/4, freq/2], width: 0.015).unipolar.lag(lag.abs),
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

	Ndef(\graySine2, { | amp=1, freq=2109, q=0.4, x=0.5, y=0.5, z=0.5 |
		var verb;
		var noise = WhiteNoise.ar();
		// var modFreq = ( x.linlin(-1,1, 0, 4).sin * 20).abs + 0.1;
		var modFreq = SelectX.kr(y.linlin(-1,1,0,1 * 4).abs.floor % 2, [x.linlin(-1,1, 0, 18).sin * 20 + 0.1, x.linlin(-1,1, 0, 18).cos * 20 + 0.1]);
		var lag = (modFreq/2).pow(4).clip(0,1);

		var filtered;
		var freqs = [freq, (freq.cpsmidi + 1).midicps, (freq.cpsmidi + 7).midicps, (freq.cpsmidi - 2).midicps];

		// freq = SelectX.kr(y.linlin(-1,1,0,1 * freqs.size).abs.floor, freqs);
		freq = SelectX.kr(y.linlin(-1,1,0,1 * freqs.size).abs.floor, freqs).lag(0.082);

		freq = freq/2;
		// freq = freq + (x.abs * 100);


		filtered = BPF.ar(noise,
			//freq: [freq, freq * 1.1] + LFPulse.ar(modFreq, mul: 240).unipolar.lag(0.),
			freq: [freq * 0.7, freq * 0.61] + LFPulse.ar(modFreq.clip(5, 30), mul: [freq/4, freq/2], width: 0.2).unipolar,
			// .lag(lag.abs),
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

		verb * 3 * 0.19;
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
Ndef(\saw, { | section=1, freq=300, x=0.5, y=0.5, z=0.5, amp=1 |
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
		out = LPF.ar(out, (y.lag(0.1).abs*800) + 200) * 0.5;
	out = HPF.ar(out, 200);
		//out = LPF.ar(out, MouseY.kr(200, 1000)) * 0.5;

		SelectX.ar(section, [out, out * LFPulse.ar(8, width: 0.7).unipolar.lag(0.1)])*0.5 * amp;
});

Ndef(\saw2, { | section=1, freq=600, x=0.5, y=0.5, z=0.5, amp=1, vowel=0 |
	var out;
	var formants, createVowel, snd;
		//var freq = (0 + (3*12)).midicps;
		var pulses = Array.newClear(4);

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


		freq = freq.lag(0.3);
		4.do({ | i |
			//pulses[i] = LFPulse.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			// pulses[i] = Saw.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			pulses[i] = Saw.ar([ freq, freq * (x.abs+1.01)] * (i+1), mul: 0.25);
		});

		out = (Mix.new(pulses) * ( freq/6 * LFPulse.ar(8).lag(0.1) )).tanh * 0.5 ;

	out = SelectX.ar(Lag.kr(y.linlin(0,1,0,5), 0.5), [createVowel.value(out, "A"), createVowel.value(out, "E"), createVowel.value(out, "I"), createVowel.value(out, "O"), createVowel.value(out, "U")]);

		// out = out + (SinOsc.ar(freq /4) * (x.abs*0.8));
		out = FreeVerb2.ar(out[0], out[1]);

		// out = RLPFD.ar(out, MouseY.kr(200, 1000),0.9) * 0.5;
		// out = RLPFD.ar(out, (y.lag(0.1).abs * 800) + 200, 0.9) * 0.85;
		out = LPF.ar(out, (y.lag(0.1).abs*800) + 200) * 0.5;
		// out = LPF.ar(out, MouseY.kr(200, 1000)) * 0.5;

		(SelectX.ar(x-1, [out, out * LFPulse.ar(8, width: 0.7).unipolar.lag(0.1)]) * 5).tanh * 0.95  * amp;

});

/*	Ndef(\saw, { | section=1, freq=600, x=0.5, y=0.5, z=0.5, amp=1, vowel=0 |
		var out;
	var formants, createVowel, snd;
		//var freq = (0 + (3*12)).midicps;
		var pulses = Array.newClear(4);

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


		freq = freq.lag(0.3);
		4.do({ | i |
			//pulses[i] = LFPulse.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			// pulses[i] = Saw.ar([ freq, freq * MouseX.kr(1, 1.01) ] * (i+1), mul: 0.25);
			pulses[i] = Saw.ar([ freq, freq * (x.abs+1.01)] * (i+1), mul: 0.25);
		});

		out = (Mix.new(pulses) * ( freq/6 * LFPulse.ar(8).lag(0.1) )).tanh * 0.5 ;

	out = SelectX.ar(Lag.kr(y.linlin(0,1,0,5), 0.5), [createVowel.value(out, "A"), createVowel.value(out, "E"), createVowel.value(out, "I"), createVowel.value(out, "O"), createVowel.value(out, "U")]);

		// out = out + (SinOsc.ar(freq /4) * (x.abs*0.8));
		out = FreeVerb2.ar(out[0], out[1]);

		// out = RLPFD.ar(out, MouseY.kr(200, 1000),0.9) * 0.5;
		// out = RLPFD.ar(out, (y.lag(0.1).abs * 800) + 200, 0.9) * 0.85;
		out = LPF.ar(out, (y.lag(0.1).abs*800) + 200) * 0.5;
		// out = LPF.ar(out, MouseY.kr(200, 1000)) * 0.5;

		(SelectX.ar(x-1, [out, out * LFPulse.ar(8, width: 0.7).unipolar.lag(0.1)]) * 5).tanh * 0.95  * amp;

	});*/


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

	// Buffer synths
b = Buffer.read(s, "/home/scott/discog/albums/Ingress/Scott Cazan - Ingress - 01 Ingress.aiff", action: { |buffer|
	"".postln;
	"Loaded: ".post;
	/*path.postln;
	"Channels: ".post;
	buffer.numChannels.postln;*/
	Ndef(\stutter2, { | x=1,y=1, rate=0.26, amp=0.85, switch=1 |
		var buffer=b;

		var out2 = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate, trigger: 1, startPos: 0, loop: 1) * amp;
		var out = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate/1.5, 48000 * SinOsc.kr(12, mul: 0.5, add: 0.1).unipolar, 500 ));

		// var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

		// out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;
		out = LPF.ar(XFade2.ar(out, out2, switch.linlin(0,1, -1, 1).lag(0.01) ), SelectX.kr(switch, [900, 9000]).lag(0.3)) * amp;

	});

	Ndef(\stutter1, { | x=1,y=1, rate=0.26, amp=0.85, switch=1 |
		var buffer=b;

		var out2 = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate/1.5, trigger: 1, startPos: 0, loop: 1) * amp;
		var out = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 48000 * SinOsc.kr(12, mul: 0.5, add: 0.1).unipolar, 500 ));

		// var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

		// out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;
		out = LPF.ar(XFade2.ar(out, out2, switch.linlin(0,1, -1, 1).lag(0.01) ), SelectX.kr(switch, [900, 9000]).lag(0.3)) * amp;

	});

});


c = Buffer.read(s, "/home/scott/dev/AIam-sound/samples/emptywordsCompress.wav", action: { |buffer|
	"".postln;
	"Loaded: ".post;

	Ndef(\stutter0, { | x=1,y=1, rate=0.26, amp=0.85, switch=1 |
		var buffer=c;

		var out2 = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate * 2, trigger: 1, startPos: 0, loop: 1) * amp;
		var out = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(b) * rate, start: 44100 * 3.1, end: (44100 * 3.1) + 980)) * 0.1;

		// var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

		// out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;
		out = LPF.ar(XFade2.ar(out, out2, switch.linlin(0,1, -1, 1).lag(0.01) ), SelectX.kr(switch, [900, 9000]).lag(0.3)) * 0.15 * amp!2;

		LPF.ar(out, 9000)

	});


});

~reverbBus = Bus.audio(s,2);
Ndef(\reverb2, {
		FreeVerb.ar(In.ar(~reverbBus, 2) + (Ndef(\noiseImpulse).ar*0.0), mix: 0.2);
}).play;

Ndef(\graySineTrig, { | amp=0, freq=703, q=0.4, x=0.5, y=0.5, z=0.5, length=0.5, t_trigger=1, switch=0 |
	var verb;
	var noise = WhiteNoise.ar();
	var modFreq = SelectX.kr((y.linlin(-1,1,0,1 * 4)).abs.floor % 2, [x.linlin(-1,1, 0, 18).sin * 20 + 0.1, x.linlin(-1,1, 0, 18).cos * 20 + 0.1]);
	var lag = (modFreq/10).pow(4).clip(0,1);

	var filtered;
	// var freqs = [freq, (freq.cpsmidi + 3).midicps, (freq.cpsmidi + 7).midicps, (freq.cpsmidi - 5).midicps];
	var freqs = [freq, freq * 1.3, freq * 2.1, freq * 0.5];

	freq = SelectX.kr(switch, freqs).lag(0.00012);

	filtered = BPF.ar(noise,
		freq: [freq * 0.7, freq * 0.61] + LFPulse.ar(modFreq.clip(5, 30), mul: [freq/4, freq/2], width: 0.015).unipolar.lag(lag.abs),
		rq: q * 0.001
	);

	filtered = (filtered*2).tanh * 1;
	filtered = LPF.ar(filtered, freq: 9500);

	verb = FreeVerb.ar( filtered * amp.lag(0.1),
		mix: 0.6,
		room: 0.5,
		damp: 0.1
	);


	verb = verb * 0.995 * SelectX.kr(switch, [0.5, 0.5, 0.5, 4]);

	verb = EnvGen.ar(Env.perc(0.1, length), gate: t_trigger) * verb;
	Out.ar(~reverbBus, verb * 0.6);

	verb * 3;
});


Ndef(\noiseImpulse, { | amp=0, freq=9000, t_trigger=1 |
	var out;
	out = BPF.ar(GrayNoise.ar(),[ freq, freq*1.01 ],0.2);

	out = out + (BPF.ar(GrayNoise.ar(),[ freq*0.25, freq*0.21 ],0.2) * 0.35);

	out = EnvGen.ar(Env.new([0,1,0],[0.00001, 0.6, 0.000001]), gate: t_trigger) * out;

	( out*2 ).max * amp;
});

Ndef(\beep, { | amp=0, t_trigger=1 |
	var out;
	out = SinOsc.ar(200) ! 2;

	out = EnvGen.ar(Env.new([0,1,0],[0.00001, 0.6, 0.000001]), gate: t_trigger) * out;

	( out*2 ).max * amp;
}).play;



dict = Dictionary[
	\play -> {
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
