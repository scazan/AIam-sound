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
						energies[i][\x] = energies[i][\x] - 0.00027;
						synths[i][\freqBus].set(energies[i][\x]**1.15);
						//synths[i][\ampBus].set(energies[i][\x]**2);
					}, {
						synths[i][\freqBus].set(0);
						synths[i][\ampBus].set(0);
					});
				});

				0.001.wait;
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

				if(proximityX < 0.25, {
					Ndef(\pad).set(\amp, ((proximityX * -1 + 0.25) * 4)**2);
				}, {
					Ndef(\pad).set(\amp, 0);
				});
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
			});
		};

		{ while { window.isClosed.not } { window.refresh; 0.04.wait; } }.fork(AppClock);
	};

	SynthDef(\voice, { arg
		freq = 620,
		amp = 0.5,
		vowel = 0,
		att = 0.01,
		rel = 0.1,
		lag = 1,
		gate = 1,
		hasFreq = 0,
		transpose = 0.5,
		pitchLag=0.00001,
		voiceFreqBus,
		voiceAmpBus;

		var in, env, va, ve, vi, vo, vu, snd;

		var createVowel = { | input, vowel, voiceType = "counterTenor" |
			var formant = FormantTable.get((voiceType++vowel).asSymbol);

			BBandPass.ar(
				in: input,
				freq: formant[0],
				bw: formant[1],
				mul: formant[2]);
		};

		freq = In.kr(voiceFreqBus).squared * 600 + 60;
		freq = Lag.kr(freq*transpose,pitchLag);
		in = Saw.ar(Lag.kr(freq, lag));

		va = createVowel.value(in, "A");
		ve = createVowel.value(in, "E");
		vi = createVowel.value(in, "I");
		vo = createVowel.value(in, "O");
		vu = createVowel.value(in, "U");

		snd = SelectX.ar(Lag.kr(vowel, lag), [va, ve, vi, vo, vu]);
		snd = snd.flatten(2);
		snd = snd * (Lag.kr(In.kr(voiceAmpBus), 0.001) * 0.25);

		Out.ar(0, ([ snd, snd] * (amp.tanh * 6)).tanh );
	}).add;

	Ndef(\pad, { | amp=0, freq = 500, mod = 0.3 |
		var out = LFPulse.ar(freq) + (LFPulse.ar(freq * 1.5) * LFPulse.ar(20.2, mul: SinOsc.kr(0.1, mul:0.5), add: 0.4)) ;
		out = out + (SinOsc.ar(freq *3) * SinOsc.ar(0.01));
		//out = (out * 2).tanh;
		out = LPF.ar(out, 200).tanh * Lag.kr(amp, 0.5);
		//out = out + ((Mix.new(LFPulse.ar([freq*1.5, freq*2, freq*1.25, freq*0.75, freq*1.1], width: 0.09)) * 42).tanh * mod);
		out!2;
	});


	Ndef(\pad).play;

	AppClock.sched(3, startReceiver);
});

