s.boot;
s.meter;
Ndef(\voice).clear
(
Ndef(\voice, { arg
	freq = 620,
	grainFreq = 20,
	amp = 0.5,
	vowel = 0,
	lag = 1,
	transpose = 1.0,
	pitchLag=0.001,
	trig = 0,
	voiceFreqBus,
	voiceAmpBus,
	mix = 0.4,
	pulseWidth = 0.5;

	var in, va, ve, vi, vo, vu, snd;

	var createVowel = { | input, vowel, voiceType = "counterTenor" |
		var formant = FormantTable.get((voiceType++vowel).asSymbol);

		BBandPass.ar(
			in: input,
			freq: formant[0],
			bw: formant[1],
			mul: formant[2]);
	};

	freq = freq;
	//# freq, hasFreq = Pitch.kr(SoundIn.ar(0) * 200);
	freq = Lag.kr(freq*transpose,pitchLag);
	//in = Saw.ar(Lag.kr(freq, lag)) * LFPulse.ar(grainFreq, width: pulseWidth + LFNoise1.kr(4, mul: 0.5).unipolar).tanh;
	in = Saw.ar(Lag.kr(freq, lag)) * LFPulse.ar(grainFreq, width: pulseWidth);

	va = createVowel.value(in, "A");
	ve = createVowel.value(in, "E");
	vi = createVowel.value(in, "I");
	vo = createVowel.value(in, "O");
	vu = createVowel.value(in, "U");

	snd = SelectX.ar(Lag.kr(vowel, lag), [va, ve, vi, vo, vu]);
	snd = snd.flatten(6);
	//snd = snd * (Lag.kr(In.kr(~voiceAmpBus), 0.001) * 0.25);

	snd = LPF.ar(snd, 3900) * EnvGen.ar(Env.perc(0.1,0.9), gate: Trig.kr(trig));
	//Out.ar(0, ([ snd, snd] * env * (amp.tanh * 6)).tanh );
	//snd = FreeVerb2.ar(Mix.ar(snd), DelayC.ar(Mix.ar(snd), delaytime: 0.001), room: 0.2, mix: 0.25, damp: 0.9);
	snd = snd * (amp ) * 1;
	snd = snd.tanh;
	snd = FreeVerb2.ar(Mix.ar(snd), DelayC.ar(Mix.ar(snd), delaytime: 0.000001), room: 0.2, mix: mix, damp: 0.9);
	//snd = FreeVerb2.ar(Mix.ar(snd), Mix.ar(snd), room: 0.2, mix: mix, damp: 0.9);


	snd.tanh * amp;
});

)


Ndef(\voice).stop;
Ndef(\voice).play;
Ndef(\voice).set(\amp, 1.0);
Ndef(\voice).set(\grainFreq, 14, \pulseWidth, 0.01);
Ndef(\voice).set(\vowel, 1);
Ndef(\voice).set(\freq, 600, \pulseWidth, 1);
(
	Tdef(\vowels, {
		{
			Ndef(\voice).set(\trig, -1);
			0.01.wait;
			Ndef(\voice).set(\mix, [0,0.4,0.6].choose, \amp, [0,0,0,1].choose*1, \vowel, [0,2,5].choose, \freq, [6000, 9000,  200, 3000].choose/2, \trig, 1, \grainFreq, [14, 10, 20, 18].choose, \pulseWidth, [0.01, 0.03, 0.02, 0.01].choose*[8,2].choose);
			//Ndef(\voice).set(\mix, [0,0.4,0.6].choose, \vowel, [0,2,5].choose, \freq, [6000, 9000, 60, 2000, 3000].choose/5, \trig, 1, \grainFreq, [14, 10, 20, 8].choose, \pulseWidth, 1);
			//Ndef(\voice).set(\mix, [0,0.4,0.6].choose, \vowel, [0,2,5].choose, \freq, [6000, 9000, 60, 2000, 3000].choose/15,\gate, 1, \trig, 1, \grainFreq, 1, \pulseWidth, 1);
			([1, 0.2, 0.1, 0.1, 0.3].choose/2).wait;
		}.loop;
	});
)
Tdef(\vowels).play;
Tdef(\vowels).stop;

FormantTable.keys.asArray


(
	{
		Ndef(\voice).set(\trig, -1);
		0.01.wait;
		Ndef(\voice).set(\vowel, 0, \freq, 200, \trig, 1);
		0.3.wait;
		Ndef(\voice).set(\vowel, 2, \freq, 190);
	}.fork;
)
s.meter



Saw.help

(
	Ndef(\hum, { | amp=0, freq=2000 |
		MoogSaw.ar(freq);
	});

)

Ndef(\hum).play();
Ndef(\hum).stop(0);
Ndef(\hum).xset();



(
x.free;
x = {

	var out = MoogLadder.ar(Mix(
	LFSaw.ar([120, 180], 0, 0.33) * Lag.ar(LFPulse.ar(MouseX.kr(1, 34), width: MouseX.kr(0.001, 0.6) ), 0.07)

	), LinExp.kr(MouseY.kr(0.1, 0.5 * pi), -1, 1, 180, 8500), 0.75).dup;

	out = GVerb.ar(out, roomsize: 10, revtime: 5, damping: 0.7);
	out;

}.play
)


(
	y.free;
	y = {
		Lag.ar(LFPulse.ar(2), 1.2) * 0.25;
	}.scope;
)





s.boot;

(
	Ndef(\wah, { | amp=0, freq=30, vowel=0 |
		var ampModFreq = LFNoise1.kr(0.05).unipolar.lag(0.2);
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
		source * amp * SinOsc.kr(0.2).unipolar;
	});

)

FreeVerb2.help
Ndef(\wah).play();
Ndef(\wah).clear;
Ndef(\wah).stop(0);
Ndef(\wah).set(\amp, 2.0);


s.meter
















(
	Ndef(\pulseTrain0, {arg freq = 200, ramp=2.2, dist=1, amp=0, octave=1, density=1, vowel=0;
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
			Env.perc(0, 0.10, 1),gate: Impulse.kr(ramp * (density.pow(4)*10+1))
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


)

	Ndef(\pad).stop;
	Ndef(\buffer).stop;

Ndef(\pulseTrain0).set(\amp, 6.7);
Ndef(\pulseTrain0).set(\density, 1.03);

Ndef(\pulseTrain0).set(\vowel, 0);
Ndef(\pulseTrain0).set(\freq, 200);
Ndef(\pulseTrain0).stop;

s.meter


(
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


)

(

)
"".help

Ndef(\buffer).play();
Ndef(\buffer).stop(0);
Ndef(\buffer).xset();

s.queryAllNodes
s.sendMsg(\n_free, 1076);


///


s.boot;
(
	Ndef(\bass2, { | amp=0, freq=2000 |
		var reverb = FreeVerb.ar(_, mix: 0.5, room: 0.8);
		var lpf = LPF.ar(_, 180);
		var bpf = BPF.ar(_, 40, 0.5);
		var rumble = bpf.value(GrayNoise.ar());

		var hum = LFTri.ar([50, 54]) * (0.7 + Pulse.ar(0.2, width: 0.01).unipolar.lag(0.5) * 0.1);

		var out = reverb.value( lpf.value(rumble + hum) );

		HPF.ar(out, 30).tanh * 0.9;
	});

)

Ndef(\bass).clear();
Ndef(\bass2).play();
Ndef(\bass).stop(0);
Ndef(\bass).xset();
s.meter







//// New Stuff!
s.options.memSize = 1024 * 100;
s.boot;
(
	Ndef(\pulseTrain0, {arg freq = 200, noiseFreq=2, ramp=2.2, dist=1, amp=8.7, octave=1, density=1, vowel=0, lag=5;
		var out, formants, createVowel, snd;
		var noise = LFNoise1.kr(noiseFreq).unipolar;

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
Ndef(\pulseTrain0).fadeTime = 1;

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

	Ndef(\reverb, { | amp=0, inAmp=0 |
		//var reverb = FreeVerb.ar(_, mix: 0.99, room: 0.8, damp: 0.9);
		var reverb = GVerb.ar(_, roomsize: 30, damping: 0.2);
		var source = Ndef(\pulseTrain0).ar * inAmp;

		reverb.value(source) * amp.lag(0.5);
	});


	Ndef(\reverb).play();
)

	Ndef(\pulseTrain0).play();

	(
	~speed1 = 1.0;
	Tdef(\vocal, {
		{
			Ndef(\pulseTrain0).set(\density, [1,0.7,0.8,0.9, 0.7].choose);
			( (~speed1 * 3).rand + 0.7 ).wait;
		}.loop;
	});
	Tdef(\vocal).play;

	~speed2 = 3.0;
	Tdef(\vocal2, {
		{
			Ndef(\pulseTrain0).set(\vowel, [0,4,2].choose);
			( (~speed2 * 10).rand + 0.7 ).wait;
		}.loop;
	});

	Tdef(\vocal2).play;
)
Tdef(\vocal2).gui


MIDIIn.connectAll
(
	MIDIdef.cc(\lightpads, { | val, control, block |
		var controlNum = control + (block * 14);
		val = val/127;
		controlNum.postln;

		switch(controlNum,
			112, { ~speed1 = val; },
			105, { Ndef(\reverb).set(\inAmp, val); },
			115, { Ndef(\reverb).set(\amp, val); },
			113, { Ndef(\pulseTrain0).set(\noiseFreq, val * 20); },

			119, {
				if(val == 1, {
				Tdef(\vocal).stop;
				Ndef(\pulseTrain0).set(\lag, 5 );
			}, {
				Tdef(\vocal).play;
			});
			},
			129, {
				Ndef(\pulseTrain0).set(\density, (val*1)+0.5 );
			},
			126, { ~speed2 = val; },
		);
		val.postln;
	});
)



(
	var vectors = [ [1,2], [1,3], [1,2] ];
	//var vectors = ~actors.collect({ | item | [item[\position][\x],item[\position][\z] ] ; });

	var computeProximity2XZ = { | vectors |
		var x=0, y=1, euclideanDistance;

		euclideanDistance = ((vectors[0][x] - vectors[1][x]).pow(2) + (vectors[0][y] - vectors[1][y]).pow(2)).sqrt;
		euclideanDistance;
	};

	var computeProximity2D = { | vectors |
		var distances = Array.newClear(vectors.size),
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

	computeProximity2D.value(vectors);
)

////// 6/19

(
	Ndef(\ladder, { | amp=0, freq=2000 |

		var out = MoogLadder.ar(Mix(
		LFSaw.ar([120, 180], 0, 0.33) * Lag.ar(LFPulse.ar(MouseX.kr(1, 34), width: MouseX.kr(0.001, 0.6) ), 0.07)

		), LinExp.kr(MouseY.kr(0.1, 0.5 * pi), -1, 1, 180, 8500), 0.75).dup;

		out = GVerb.ar(out, roomsize: 10, revtime: 5, damping: 0.7);
		out * amp;

	});

)

Ndef(\ladder).play();
Ndef(\ladder).stop(0);
Ndef(\ladder).xset();
(
	Ndef(\graySine, { | amp=0, freq=2100, q=0.4, modFreq=12 |
		var verb;
		var noise = WhiteNoise.ar();
		var lag = (modFreq/20).pow(4).clip(0,1);

		var filtered = BPF.ar(noise,
			//freq: [freq, freq * 1.1] + LFPulse.ar(modFreq, mul: 240).unipolar.lag(0.1),
			freq: [freq, freq * 1.1, freq*0.5, freq*0.55] + LFPulse.ar(modFreq.clip(1,20), mul: [freq/4, freq/2, freq/3]).unipolar.lag(lag.abs),
			rq: q * 0.001
		);

		filtered = (filtered*2).tanh;
		filtered = LPF.ar(filtered, freq: 7500);

		verb = FreeVerb.ar( filtered * amp,
			mix: 0.6,
			room: 0.5,
			damp: 0.1
		) ;

		verb;
	});

)

Ndef(\graySine).play();
Ndef(\graySine).stop(0);
Ndef(\graySine).clear();
Ndef(\graySine).xset();

m = NdefMixer.new(s);

(
	Ndef(\sine, { | amp=0, freq=300, q=0.1 |
		var verb;
		var noise = WhiteNoise.ar();

		var filtered = BPF.ar(noise,
			freq: [freq, freq * 1.01],
			rq: q * 0.001
		);

		filtered = ((filtered*amp)*300).max.tanh;

		verb = FreeVerb.ar( filtered,
			mix: 0.8,
			room: 0.7,
			damp: 0.8
		) ;

		verb * 8;
	});

)
//G# 414.5 415
// 196

Ndef(\sine).playN([2,3]);
Ndef(\sine).stop(0);
Ndef(\sine).xset();


0+(3*12).midicps


// REPRO
m = NdefMixer.new(s)
(
	Ndef(\drone, { | amp=0, note=0, octave=8, lpfFreq=600 |
		var dist, osc1, osc2, mix, out;
		var freq = (note + (octave * 12)).midicps;

		osc1 = {|x| LFPulse.ar([ x, x * 1.5, x/4 ], width: 0.1)};
		osc2 = {|x| LFSaw.ar([x, x * 1.5]/2) * 0.8};
		//osc2 = LPF.ar(osc2, 9000);

		//mix = (osc1 + osc2);
		//mix = {|freq| osc1.value(freq).sum + (osc2.value(freq*1.1).sum * LFPulse.kr(1).unipolar)};
		mix = {|freq| osc1.value(freq).sum};
		dist = ([mix.value(freq), mix.value(freq*1.01)] * 60.dbamp).wrap;

		out = dist;
		LPF.ar(out * amp, lpfFreq);
	});

)

Ndef(\drone).play();
Ndef(\drone).stop(0);
Ndef(\drone).clear();

m = NdefMixer.new(s)

(

Ndef(\sawPad, { arg freq=75, amp=1;
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
	out = Shaper.ar(buf, out);
	out = FreeVerb2.ar(out[0], out[1]);
	out * 0.15 * amp;
});
)




~onsetBus = Bus.control(s, 3);
(
// Onset timin
Ndef(\onsets, { | amp=0 |
	var trackb,trackh,trackq,tempo;
	var buf = LocalBuf(512);
	var input = ~onsetBus;

	var chain = FFT(buf, input.kr);
	var onsets = Onsets.kr(chain, 0, \rcomplex);
	var timer = Timer.kr(onsets);

	SendReply.kr(onsets, '/reply', timer);
});

)

Ndef(\onsets).play();
Ndef(\onsets).stop(0);
Ndef(\onsets).xset();

OSCdef(\timing, {arg msg; msg.asInteger.postln;}, '/reply');

~onsetBusses[0].set(1,9,3)

~onsetBusses[0].get({|val| val.postln;});


s.volume = 12;

s.boot;
// More Tests

Ndef(\rhythm).clear
(
	Ndef(\rhythm, { | amp=0, freq=200 |
		var pulse = LFPulse.ar([ freq, freq * 1.01 ], width: 0.2);

		var filter = LPF.ar(_, 300 + SinOsc.kr(1, mul: 600).unipolar );
		var delays = AllpassC.ar(CombN.ar(filter.value(pulse!2), maxdelaytime: 0.9, delaytime: 0.7), decaytime: 3.0);

		delays = RLPFD.ar(delays, 700 + SinOsc.kr(3, mul: 900).unipolar, res: 0.4, dist: 0.5) * 1;

		delays = (delays * 16.9).tanh * amp * (LFPulse.ar(4, width: 0.1).unipolar).lag(0.1);

		FreeVerb.ar(delays, damp: 0.1, room: 0.1, mix: 0.2);

	});

)

Ndef(\rhythm).play();
Ndef(\rhythm).stop(0);
Ndef(\rhythm).set(\amp, 0.01);
Ndef(\rhythm).set(\freq, 200);
(

	Tdef(\sequence, {
		var index = 0;
		var pitches = [0,3];
		var octave = 5;

		{
			Ndef(\rhythm).set(\freq, (pitches[index%pitches.size] + (12*octave)).midicps );
			index = index + 1;
			0.2.wait;
		}.loop;
	});
	Tdef(\sequence).play;
)
	Tdef(\sequence).stop;

(
	Ndef(\clink, { | amp=0, freq=2000 |
	var noise = WhiteNoise.ar() * LFPulse.ar(2, width: 0.1);
		var delay = AllpassC.ar(noise, decaytime: 2.2);

		delay = HPF.ar(delay, [ 10000, 10100 ]);

		delay = delay * amp;
		delay = FreeVerb.ar(delay );

		delay;
	});

)

Ndef(\clink).play();
Ndef(\clink).stop(0);
Ndef(\clink).set(\amp, 0.1);
Ndef(\clink).set(\amp, 0.0051);



(
	Ndef(\grainer, { | amp=0, freq=2000 |
		WarpN.ar();
	});

)

Ndef(\grainer).play();
Ndef(\grainer).stop(0);
Ndef(\grainer).xset();

(
Ndef(\reverb).stop;
Ndef(\bass).stop;
Ndef(\sawPad).stop;
)


FreqScope.new

////// Sample

~length= 1;        //segment lengths in seconds - should be the same for positions to scan correctly
~b1= RedBuffer(s, "/home/scott/dev/AIam-sound/samples/shortOneNONOISE.wav", 0.1, ~length);
~b2= RedBuffer(s, "/home/scott/dev/AIam-sound/samples/shortOneNONOISE.wav", 0.3, ~length);
~b3= RedBuffer(s, "/home/scott/dev/AIam-sound/samples/shortOneNONOISE.wav", 0.5, ~length);

//-- create and start the granulator object
r= RedAGrain(s);
r.start;

//again note that all lfo synths must send audiorate
//and be careful to free lfo synths before creating new ones - to not loose handle

//-- init lfo synth
(
//create lfo synth for trigger - here 30 hz
a= SynthDef("trig", {Out.ar(r.trigBus.index, Impulse.ar(30))}).play;
//create lfo synth for bufnum - static at ~b1 bufnum
b= SynthDef("buf", {Out.ar(r.bufBus.index, DC.ar(~b1.bufnum))}).play;
//create lfo synth for rate - slowly rising
c= SynthDef("rate", {Out.ar(r.rateBus.index, LFSaw.ar(0.1, 0, 0.1, 1))}).play;
//create lfo synth for position - static at 0
d= SynthDef("pos", {Out.ar(r.posBus.index, DC.ar(0))}).play;
//create lfo synth for duration - slow drunk walk
e= SynthDef("dur", {Out.ar(r.durBus.index, LFNoise2.ar(1, 0.1, 0.11))}).play;
//create lfo synth for amplitude control - static at 0.4
f= SynthDef("pan", {Out.ar(r.panBus.index, DC.ar(0.4))}).play;
//create lfo synth for amplitude control - static at 0.4
g= SynthDef("amp", {Out.ar(r.ampBus.index, DC.ar(0.4))}).play;
)


//-- trigBus
//change trigger control lfo to another dusty one
a.free;
a= SynthDef("trig", {Out.ar(r.trigBus.index, Dust.ar(10))}).play;

//change to static fast trigger
a.free;
a= SynthDef("trig", {Out.ar(r.trigBus.index, Impulse.ar(140))}).play;

//let mouseX control trigger rate
a.free;
a= SynthDef("trig", {Out.ar(r.trigBus.index, Impulse.ar(MouseX.kr(2, 200)))}).play;


//-- bufBus
//change buffer to ~b2
b.free;
b= SynthDef("buf", {Out.ar(r.bufBus.index, DC.ar(~b2.bufnum))}).play;

//play from the 3 buffers in cycle
b.free;
b= SynthDef("buf", {Out.ar(r.bufBus.index, Demand.ar(Impulse.ar(4), 0, Dseq([~b1.bufnum, ~b2.bufnum, ~b3.bufnum], inf)))}).play;

//quick drunk walk change buffers (little bit dangerous if ~b1-3 not following each other here)
b.free;
b= SynthDef("buf", {Out.ar(r.bufBus.index, Demand.ar(Impulse.ar(100), 0, Dbrown(~b1.bufnum, ~b3.bufnum, 1, inf)))}).play;

//slow back and forth change of buffers - 4 changes per segment length
b.free;
b= SynthDef("buf", {Out.ar(r.bufBus.index, Demand.ar(Impulse.ar(~length.reciprocal*4), 0, Dseq([~b1.bufnum, ~b2.bufnum, ~b3.bufnum, ~b2.bufnum], inf)))}).play;

//faster back and forth change of buffers - 32 changes per segment length
b.free;
b= SynthDef("buf", {Out.ar(r.bufBus.index, Demand.ar(Impulse.ar(~length.reciprocal*32), 0, Dseq([~b1.bufnum, ~b2.bufnum, ~b3.bufnum, ~b2.bufnum], inf)))}).play;


//-- rateBus
//varying rate with drunk walk
c.free;
c= SynthDef("rate", {Out.ar(r.rateBus.index, LFNoise2.ar(1, 0.3, 1))}).play;

//halfspeed backwards static rate
c.free;
c= SynthDef("rate", {Out.ar(r.rateBus.index, DC.ar(-0.5))}).play;

//falling rate during segment length
c.free;
c= SynthDef("rate", {Out.ar(r.rateBus.index, LFSaw.ar(~length.reciprocal.neg, 0, 0.1, 1))}).play;


//-- posBus
//set position to normal speed scanning forwards
d.free;
d= SynthDef("pos", {Out.ar(r.posBus.index, LFSaw.ar(~length.reciprocal, 0, 0.5, 0.5))}).play;

//position slow scanning forwards
d.free;
d= SynthDef("pos", {Out.ar(r.posBus.index, LFSaw.ar(0.4, 0, 0.5, 0.5))}).play;

//position slow scanning backwards
d.free;
d= SynthDef("pos", {Out.ar(r.posBus.index, LFSaw.ar(-0.5, 0, 0.5, 0.5))}).play;

//mouseX controls position
d.free;
d= SynthDef("pos", {Out.ar(r.posBus.index, K2A.ar(MouseX.kr(0, 1, lag:1)))}).play;

//mouseXY control + a little random
d.free;
d= SynthDef("pos", {Out.ar(r.posBus.index, LFNoise2.ar(120, MouseY.kr(0, 0.1), MouseX.kr(0, 1, lag:1)))}).play;

//back to static position
d.free;
d= SynthDef("pos", {Out.ar(r.posBus.index, DC.ar(0))}).play;


//-- durBus
//change to short static duration
e.free;
e= SynthDef("dur", {Out.ar(r.durBus.index, DC.ar(0.02))}).play;

//random duration between 0.01 and 0.41
e.free;
e= SynthDef("dur", {Out.ar(r.durBus.index, LFNoise0.ar(4, 0.2, 0.21))}).play;

//mouseY controls duration
e.free;
e= SynthDef("dur", {Out.ar(r.durBus.index, K2A.ar(MouseY.kr(0, 0.6)))}).play;

//slow phasor control duration
e.free;
e= SynthDef("dur", {Out.ar(r.durBus.index, LFSaw.ar(0.4, 0, 0.04, 0.05))}).play;


//-- panBus
//sine panning
f.free;
f= SynthDef("pan", {Out.ar(r.panBus.index, SinOsc.ar(4))}).play;

//slow random panning
f.free;
f= SynthDef("pan", {Out.ar(r.panBus.index, LFNoise2.ar(0.3))}).play;

//random discrete panning at fast rate
f.free;
f= SynthDef("pan", {Out.ar(r.panBus.index, Demand.ar(Impulse.ar(100), 0, Dseq([-0.9, 0, 0.9], inf)))}).play;


//-- ampBus
//fast jumps in amplitude
g.free;
g= SynthDef("amp", {Out.ar(r.ampBus.index, LFNoise0.ar(40, 0.2, 0.2).max(0))}).play;

//fade out during each segment
g.free;
g= SynthDef("amp", {Out.ar(r.ampBus.index, LFSaw.ar(~length.reciprocal.neg, 0, 0.5, 0.5))}).play;


//-- more complex example
[a, b, c, d, e, f, g].do(_.free);
(
//master trigger controlling the other lfos
a= SynthDef("trig", {Out.ar(r.trigBus.index, Impulse.ar(LFNoise1.ar(0.5, 10, 80)))}).play;
b= SynthDef("buf", {Out.ar(r.bufBus.index, DC.ar(~b1.bufnum))}).play;
c= SynthDef("rate", {Out.ar(r.rateBus.index, Demand.ar(InFeedback.ar(r.trigBus.index), 0, Dseq([1, 2], inf)))}).play;
d= SynthDef("pos", {Out.ar(r.posBus.index, Demand.ar(InFeedback.ar(r.trigBus.index), 0, Dseq([Dseries(0, 0.002, 900)], inf)))}).play;
e= SynthDef("dur", {Out.ar(r.durBus.index, Demand.ar(InFeedback.ar(r.trigBus.index), 0, Dseq([Dseries(0.01, 0.001, 100)], inf)))}).play;
f= SynthDef("pan", {Out.ar(r.panBus.index, Demand.ar(InFeedback.ar(r.trigBus.index), 0, Dseq([-0.9, 0, 0.9], inf)))}).play;
g= SynthDef("amp", {Out.ar(r.ampBus.index, DC.ar(0.4))}).play;
)


//-- clean up and stop
[a, b, c, d, e, f, g, ~b1, ~b2, ~b3].do(_.free);
r.free


s.boot
(
Dialog.openPanel({ arg path;
	b = Buffer.read(s, path, action: { |buffer|
		"".postln;
		"Loaded: ".post;
		path.postln;
		"Channels: ".post;
		buffer.numChannels.postln;
	});
});

)

(
Dialog.openPanel({ arg path;
	c = Buffer.read(s, path, action: { |buffer|
		"".postln;
		"Loaded: ".post;
		path.postln;
		"Channels: ".post;
		buffer.numChannels.postln;
	});
});

)


(
Dialog.openPanel({ arg path;
	d = Buffer.read(s, path, action: { |buffer|
		"".postln;
		"Loaded: ".post;
		path.postln;
		"Channels: ".post;
		buffer.numChannels.postln;
	});
});

)

	Ndef(\one).clear
(
	Ndef(\one, { | x=1,y=1, amp=0 |
		var buffer=b;

		PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: x.linlin(-1, 1, 0, 1), trigger: 1, startPos: 0, loop: 1) * amp * y!2;
	});

)

Ndef(\one).play();
Ndef(\one).stop(0);
Ndef(\one).xset();

(
Ndef(\stutter1, { | x=1,y=1, rate=1.0, amp=0.5, switch=1 |
	var buffer=b;

	// PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: x.linlin(-1, 1, 0, 1), trigger: 1, startPos: 0, loop: 1) * amp * y!2;
	var out = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 48000 * SinOsc.kr(12, mul: 0.5, add: 0.1).unipolar, 500 ));

	var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

	out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;

});


Ndef(\stutter2, { | x=1,y=1, rate=1.0, amp=0.50, switch=1 |
	var buffer=b;

	// PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: x.linlin(-1, 1, 0, 1), trigger: 1, startPos: 0, loop: 1) * amp * y!2;
	var out = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 48000 * SinOsc.kr(12, mul: 0.5, add: 0.1).unipolar, 500 ));

	var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

	out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;

});

)

Ndef(\reverbOut).clear
(
Ndef(\reverbOut, {
	var out = [Ndef(\stutter1).ar, Ndef(\stutter2).ar];
	FreeVerb.ar(out);
});
)

Ndef(\reverbOut).play();
Ndef(\stutter).stop(0);
Ndef(\stutter1).set(\rate, 5, \switch, 0, \amp, 0.95);
Ndef(\stutter1).set(\rate, 1, \switch, 1, \amp, 0.5);
Ndef(\stutter2).set(\rate, 3.5, \switch, 0, \amp, 0.95);
Ndef(\stutter2).set(\rate, 1, \switch, 1, \amp, 0.5);



(
	Ndef(\two, { | x=1, y=1, amp=0 |
		var buffer=c;

	/*PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: x.linlin(-1,1, 0,1), trigger: 1, startPos: 0, loop: 1) * amp * y;*/
	PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: x.linlin(-1,1, 0.1, 6), trigger: 1, startPos: 0, loop: 1) * amp * y;
	});

)

Ndef(\two).play();
Ndef(\two).stop(0);
Ndef(\two).xset();

(
	Ndef(\three, { | x=1, y=1, amp=0 |
		var buffer=d;

	PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: x.linlin(-1,1, 0, 1), trigger: 1, startPos: 0, loop: 1) * amp * y;
	});

)

Ndef(\three).play();
Ndef(\three).stop(0);
Ndef(\three).xset();


s.meter

NdefMixer.new(s);

Ndef(\one).play();
Ndef(\one).stop(0);
Ndef(\one).xset();

s.boot;

(
Dialog.openPanel({ arg path;
	b = Buffer.read(s, path, action: { |buffer|
		"".postln;
		"Loaded: ".post;
		path.postln;
		"Channels: ".post;
		buffer.numChannels.postln;
	});
});

)

(
Dialog.openPanel({ arg path;
	b = Buffer.readChannel(s, path, channels: 0);
});

)


s.boot;

w.plot
w = Env([0, 1,1, 0], [0.05, 1, 0.05], [8, -8]);
f = Buffer.sendCollection(s, w.discretize, 1);

	Ndef(\grainer).clear;
(
	Ndef(\grainer, { | amp=0, x=1, pos=0.5, z=0.1 |

	var out = GrainBuf.ar(1, trigger: Impulse.kr(5 + SinOsc.kr(3, mul: 5) ), dur: z.linexp(0.24, 0.4, 0.7, 1), sndbuf: b, rate: x.linexp(-0.4, 0.8, 0.51, 1.2), pos: SinOsc.kr(LFNoise1.kr(9)).unipolar, pan: LFNoise1.kr(13), envbufnum: f ) * amp;

		var in = out;
	var chain = FFT(LocalBuf(2048), in);
		chain = PV_RandComb(chain, 0.01, Impulse.kr(0));
		out = IFFT(chain).tanh * amp;
		out = Limiter.ar([out + DelayL.ar(out,0.3,0.1), DelayL.ar(out,0.5,0.1) + DelayL.ar(out,0.2,0.1)], 0.5, 0.1);

	out = out + (CombN.ar(out, delaytime: 0.07) * 0.2 );

		out!2;

	});

)



Ndef(\grainer).play();
Ndef(\grainer).stop(0);
Ndef(\grainer).xset();


Ndef(\grainPlayer).clear;
(
	Ndef(\grainer, { | x=1, amp=0, z=0.1 |
		var buffer=b;

	var input = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: x.linlin(-1,1, 0.75, 1), trigger: 1, startPos: 0, loop: 1) * amp;

	var out = GrainIn.ar(1, Impulse.kr(5), dur: z.linlin(0,1,0.1, 2), in: input, pan: 0, envbufnum: -1);

		var chain = FFT(LocalBuf(2048), out);
		chain = PV_RandComb(chain, 0.01, Impulse.kr(0));
		out = IFFT(chain).tanh * amp;
		out = Limiter.ar([out + DelayL.ar(out,0.3,0.1), DelayL.ar(out,0.5,0.1) + DelayL.ar(out,0.2,0.1)], 0.5, 0.1);

	// out = CombN.ar(out, delaytime: 0.07);
		//out = FreeVerb.ar(out);
		out * amp;
	});

)

Ndef(\grainPlayer).play();
Ndef(\grainPlayer).stop(0);
Ndef(\grainPlayer).xset();

s.boot

(
	Ndef(\TB303, { | amp=0, freq=2000, waveform=0, cutoff=30, porta=0.2, resonance=0.1, distortion=1, slide=0, accent=0 |
		var reverb = GVerb.ar(_, room: 0.2, mix: 0.1);
		var saw = Saw.ar(freq.lag(slide * porta));
		var waveforms = [saw, LFPulse.ar(freq.lag(slide * porta))];
		var selectedWaveform = Select.ar(waveform, waveforms);

		var filter = RLPFD.ar( selectedWaveform, cutoff.lag(slide * porta + accent), resonance.lag(slide * porta + accent), distortion ) * 3;

		var out = filter * ( amp + accent );
		//out = (reverb.value(out)*MouseY.kr(2,20)).tanh * 0.2;
		var chain = FFT(LocalBuf(2048), out);
		chain = PV_RandComb(chain, 0.01, Impulse.kr(0));
		out = IFFT(chain).tanh * amp;
		out = Limiter.ar([out + DelayL.ar(out,0.3,0.1), DelayL.ar(out,0.5,0.1) + DelayL.ar(out,0.2,0.1)], 0.5, 0.1);

		LPF.ar(out, 9000);
	});

)

Ndef(\TB303).play();
Ndef(\TB303).stop(0);
Ndef(\TB303).xset(\waveform, 0);

Ndef(\TB303).set(\amp, 0.15);
Ndef(\TB303).set(\cutoff, 900);

(
	var pitches = [ 0, 12, 0, 0, -12, 0, 0, 0, -12, 0, 12, 0, 3, -5, 2, 0 ],
	//var pitches = [ 5, 6, 6, 6, 6*2, 1, 6*2, 5*2 ],
	//var pitches = [ 5, 6, 6, 6, 6*2, 1, 6*2, 5*2 ],
		cutoff = [613, 2000, 3600, 2000, 1000, 500, 500, 400],
		resonance = [0.5, 0.8, 0.7, 0.7,  0.6, 0.8, 0.4],
		slides = [ 1, 1, 1, 1, 0, 1, 0, 0],
		accents = [0, 0, 0, 0, 0, 0, 0.8, 0.8],
		i=0;

	Tdef(\seq, {
		{
			Ndef(\TB303).set(\freq, (pitches[i%pitches.size] + (4*12)).midicps);
			Ndef(\TB303).set(\cutoff, cutoff[i%cutoff.size]);
			Ndef(\TB303).set(\resonance, resonance[i%resonance.size]);
			Ndef(\TB303).set(\slide, slides[i%slides.size]);
			Ndef(\TB303).set(\accent, accents[i%accents.size]);

			//if(i%4 == 1, {
				//{
					//var out = SinOsc.ar(600) * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);
					//Pan2.ar(out, -0.25);
				//}.play;
			//});
			//if(i%8 == 1, {
				//{
					//var out = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.01, 0.01));
					//out = FreeVerb.ar(out) * EnvGen.ar(Env.perc(0.01, 1), doneAction: 2);

					//Pan2.ar(out, 0.25);
				//}.play;
			//});
			i = i+1;
			0.19.wait;
		}.loop;
	});
)
Tdef(\seq).play;
Tdef(\seq).stop;




// One sample player with west coast soundings
// One grainer with voices
// \saw