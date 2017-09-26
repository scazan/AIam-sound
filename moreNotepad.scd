~createGraySineTrigLow.value(amp: 3, freq: 190 + 20.0.rand, switch: 3, length: 1.3, t_trigger: 1);
~createGraySineTrigLow.value(amp: 0.04, freq: 9990 + 20.0.rand, switch: 3, length: 1.3, t_trigger: 1);

~createGraySineTrigLow = { | amp=0, freq=703, q=0.4, x=0.5, y=0.5, z=0.5, length=0.5, t_trigger=1, switch=0 |
		{
			var modFreq = SelectX.kr((y.linlin(-1,1,0,1 * 4)).abs.floor % 2, [x.linlin(-1,1, 0, 18).sin * 20 + 0.1, x.linlin(-1,1, 0, 18).cos * 20 + 0.1]);
			var lag = (modFreq/10).pow(4).clip(0,1);

			var filtered, verb;
			// var freqs = [freq, (freq.cpsmidi + 3).midicps, (freq.cpsmidi + 7).midicps, (freq.cpsmidi - 5).midicps];
			var freqs = [freq, freq * 1.3, freq * 2.1, freq * 0.5];

			freq = SelectX.kr(switch, freqs).lag(0.00012);

			filtered = SinOsc.ar([freq * 0.7, freq * 0.61] + LFPulse.ar(modFreq.clip(5, 30), mul: [freq/4, freq/2], width: 0.015).unipolar.lag(lag.abs) ) * 0.01;

			filtered = (filtered*2).tanh * 1;
			filtered = LPF.ar(filtered, freq: 9500);
		// filtered = HPF.ar(filtered, freq: 980);
			filtered * ~graySineVol;

			verb = FreeVerb.ar( filtered * amp.lag(0.1),
				mix: 0.6,
				room: 0.5,
				damp: 0.1
			);


			verb = verb * 0.995 * SelectX.kr(switch, [0.5, 0.5, 0.5, 4]);

			verb = EnvGen.ar(Env.perc(0.01, length/2), gate: t_trigger, doneAction: 2) * verb;
			Out.ar(~reverbBus, verb * 0.6);

			verb * 3;

		}.play;
	};