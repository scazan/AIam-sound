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

Ndef(\sawPad, { arg freq=75;
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
	out * 0.15;
});
)