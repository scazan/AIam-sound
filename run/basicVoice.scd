s.waitForBoot({
	var startReceiver = {
		var lastX = 0,
			lastY = 0,
			lastZ = 0,
			maxY = 0,
			maxX = 0,
			window;

		var addEnergy = { | mag |
			var newEnergy = (~energyX + mag);

			if(newEnergy >= 1, {
				~energyX = 1;
			}, {
				~energyX = newEnergy;
			});
		};

		~energyX = 0;

		Tdef(\gravity, {
			{
				if(~energyX > 0.01, {
					~energyX = ~energyX - 0.00027;
					~voiceFreqBus.set(~energyX**1.15);
					~voiceAmpBus.set(~energyX**2);
				}, {
					~voiceFreqBus.set(0);
					~voiceAmpBus.set(0);
				});

				0.001.wait;
			}.loop;
		}).play;


		OSCdef(\tracker, { | msg |
			var id = msg[1].asFloat,
				x = msg[2].asFloat / 1800,
				y = msg[3].asFloat / 500,
				z = msg[4].asFloat / 7000;

			var diffX = 0,
				diffY = 0,
				diffZ = 0;
			var synths = [~synth, ~synth2];

			msg.postln;

			diffX = (lastX - x).abs;
			diffY = (lastY - y).abs;
			diffZ = (lastZ - z).abs;

			addEnergy.value(diffX);
			z = (z-0.5).abs / (1-0.5);

			if(diffX > 0.045, {
				synths[0].set(\vowel, [1,2,3,4,5].choose);
				synths[1].set(\vowel, [1,2,3,4,5].choose);
			});

			#lastX, lastY, lastZ = [x, y, z];

		}, path: \center, recvPort: 15002);

	~synth = Synth(\voice, [\voiceFreqBus, ~voiceFreqBus, \voiceAmpBus, ~voiceAmpBus]);

	u = Pbind(
		\type, \set,
		\id, ~synth.nodeID,
		\args, #[\vowel],
		\dur, 4.5,
		\vowel, Prand([0,1,2,3,4], inf),
	).play;

	~synth2 = Synth(\voice, [\voiceFreqBus, ~voiceFreqBus, \voiceAmpBus, ~voiceAmpBus]);

		h = Pbind(
			\type, \set,
			\id, ~synth2.nodeID,
			\args, #[\vowel, \transpose],
			\transpose, 0.5,
			\dur, 4.5,
			\vowel, Prand([0,1,2,3,4], inf),
		).play;

		window = Window.new("AIam Sound", Rect(100, 100, 100, 100)).front;
		window.view.background_(Color.new255(153, 255, 102));

		window.drawFunc = Routine({
			{
				window.view.background_(Color.new255(~energyX * 255, 0, 102));
				0.yield;
			}.loop;
		});

		window.onClose = {
			~synth.free;~synth2.free;
		};

		{ while { window.isClosed.not } { window.refresh; 0.04.wait; } }.fork(AppClock);
	};

	~voiceFreqBus = Bus.control(s,1);
	~voiceAmpBus = Bus.control(s,1);
	~voiceAmpBus.set(1);

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
		snd = snd * (Lag.kr(In.kr(~voiceAmpBus), 0.001) * 0.25);

		Out.ar(0, ([ snd, snd] * (amp.tanh * 6)).tanh );
	}).add;


	AppClock.sched(3, startReceiver);
});
