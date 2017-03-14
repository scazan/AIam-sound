
Ndef(\voice).clear
(
Ndef(\voice, { arg
	freq = 620,
	grainFreq = 20,
	amp = 0.5,
	vibratoSpeed = 0,
	vibratoDepth = 4,
	vowel = 0,
	att = 0.01,
	rel = 0.1,
	lag = 1,
	gate = 1,
	hasFreq = 0,
	transpose = 0.5,
	pitchLag=0.00001,
	trig = 0,
	voiceFreqBus,
	voiceAmpBus,
	mix = 0.4,
	pulseWidth = 0.5;

	var in, vibrato, env, va, ve, vi, vo, vu, snd;

	freq = freq;
	//# freq, hasFreq = Pitch.kr(SoundIn.ar(0) * 200);
	freq = Lag.kr(freq*transpose,pitchLag);
	vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
	in = LFPulse.ar(Lag.kr(freq, lag) + vibrato) * LFPulse.ar(grainFreq, width: pulseWidth);
	env = EnvGen.kr(Env.asr(att, 1, rel), gate, doneAction: 2);

	va = BBandPass.ar(
		in: in,
		//freq: FormantTable.get( 0 ),
		freq: [ 600, 1040, 2250, 2450, 2750 ],
		bw: [ 0.1, 0.067307692307692, 0.048888888888889, 0.048979591836735, 0.047272727272727 ],
		mul: [ 1, 0.44668359215096, 0.35481338923358, 0.35481338923358, 0.1 ]);

	ve = BBandPass.ar(
		in: in,
		freq: [ 400, 1620, 2400, 2800, 3100 ] ,
		bw: [ 0.1, 0.049382716049383, 0.041666666666667, 0.042857142857143, 0.038709677419355 ],
		mul: [ 1, 0.25118864315096, 0.35481338923358, 0.25118864315096, 0.12589254117942 ]);

	vi = BBandPass.ar(
		in: in,
		freq: [ 250, 1750, 2600, 3050, 3340 ] ,
		bw: [ 0.24, 0.051428571428571, 0.038461538461538, 0.039344262295082, 0.035928143712575 ],
		mul: [ 1, 0.031622776601684, 0.15848931924611, 0.079432823472428, 0.03981071705535 ] );

	vo = BBandPass.ar(
		in: in,
		freq:[ 400, 750, 2400, 2600, 2900 ] ,
		bw: [ 0.1, 0.10666666666667, 0.041666666666667, 0.046153846153846, 0.041379310344828 ],
		mul: [ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 ]);

	vu = BBandPass.ar(
		in: in,
		freq: [ 350, 600, 2400, 2675, 2950 ],
		bw: [ 0.11428571428571, 0.13333333333333, 0.041666666666667, 0.044859813084112, 0.040677966101695 ],
		mul: [ 1, 0.1, 0.025118864315096, 0.03981071705535, 0.015848931924611 ]);

	snd = SelectX.ar(Lag.kr(vowel, lag), [va, ve, vi, vo, vu]);
	snd = snd.flatten(6);
	//snd = snd * (Lag.kr(In.kr(~voiceAmpBus), 0.001) * 0.25);

	snd = LPF.ar(snd, 3900) * EnvGen.ar(Env.perc(0.1,0.9), gate: Trig.kr(trig));
	//Out.ar(0, ([ snd, snd] * env * (amp.tanh * 6)).tanh );
	//snd = FreeVerb2.ar(Mix.ar(snd), DelayC.ar(Mix.ar(snd), delaytime: 0.001), room: 0.2, mix: 0.25, damp: 0.9);
	snd = snd * env * (amp.tanh ) * 8;
	snd = snd.tanh;
	snd = FreeVerb2.ar(Mix.ar(snd), DelayC.ar(Mix.ar(snd), delaytime: 0.001), room: 0.2, mix: mix, damp: 0.9);


	snd.tanh;
});

)
s.boot;


Ndef(\voice).play;
Ndef(\voice).set(\amp, 1.0);
Ndef(\voice).set(\grainFreq, 14, \pulseWidth, 0.01);
(
	Tdef(\vowels, {
		{
			Ndef(\voice).set(\trig, -1);
			0.01.wait;
			Ndef(\voice).set(\mix, [0,0.4,0.6].choose, \vowel, [0,2,5].choose, \freq, [6000, 9000, 60, 2000, 3000].choose, \trig, 1, \grainFreq, [14, 10, 20, 8].choose, \pulseWidth, [0.01, 0.03, 0.02, 0.001].choose/1);
			([1, 0.2, 0.1, 0.1, 0.3].choose/1).wait;
		}.loop;
	});
)
Tdef(\vowels).play;
Tdef(\vowels).stop;

s.meter
