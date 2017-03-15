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


	snd.tanh;
});

)


Ndef(\voice).stop;
Ndef(\voice).play;
Ndef(\voice).set(\amp, 8.0);
Ndef(\voice).set(\grainFreq, 14, \pulseWidth, 0.01);
Ndef(\voice).set(\vowel, 1);
Ndef(\voice).set(\freq, 600, \pulseWidth, 1);
(
	Tdef(\vowels, {
		{
			Ndef(\voice).set(\trig, -1);
			0.01.wait;
			Ndef(\voice).set(\mix, [0,0.4,0.6].choose, \amp, [0,0,0,1].choose, \vowel, [0,2,5].choose, \freq, [6000, 9000,  200, 3000].choose/2, \trig, 1, \grainFreq, [14, 10, 20, 18].choose, \pulseWidth, [0.01, 0.03, 0.02, 0.01].choose*[4,2].choose);
			//Ndef(\voice).set(\mix, [0,0.4,0.6].choose, \vowel, [0,2,5].choose, \freq, [6000, 9000, 60, 2000, 3000].choose/5, \trig, 1, \grainFreq, [14, 10, 20, 8].choose, \pulseWidth, 1);
			//Ndef(\voice).set(\mix, [0,0.4,0.6].choose, \vowel, [0,2,5].choose, \freq, [6000, 9000, 60, 2000, 3000].choose/15,\gate, 1, \trig, 1, \grainFreq, 1, \pulseWidth, 1);
			([1, 0.2, 0.1, 0.1, 0.3].choose*1).wait;
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
