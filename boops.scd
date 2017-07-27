s.boot;

(
	w = Window(bounds:Rect(200,200,200,200)).layout_(
		    VLayout(
			HLayout(
				Button().action_({
					{| amp=0.5, freq=4000 | SinOsc.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=0.5, freq=2000 | LFTri.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=0.5, freq=2000 | LFTri.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=0.15, freq=4000 | SinOsc.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 4.1), doneAction: 2);}.play;
				}),
			),
			HLayout(
				Button().action_({
					{| amp=0.5, freq=600 | SinOsc.ar([freq + 200.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=0.5, freq=900 | SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=0.25, freq=800 | SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 1.4), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=0.5, freq=600 | SinOsc.ar([freq + 200.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 5.1), doneAction: 2);}.play;
				}),
			),
			HLayout(
				Button().action_({
					{| amp=0.59, freq=30 | SinOsc.ar([freq + 100.0.rand * 1.1, freq + 100.0.rand], mul: 4).tanh * amp * EnvGen.ar(Env.perc(0.01, 0.4), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=0.29, freq=30 | SinOsc.ar([freq + 100.0.rand * 1.1, freq + 100.0.rand], mul: 49).tanh * amp * EnvGen.ar(Env.perc(0.01, 5.1), doneAction: 2);}.play;
				}),
				Button().action_({
					{| amp=1.95, freq=70 | SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 9.1), doneAction: 2);}.play;
				})
			)
		)
	).front;
)

(
	{| amp=0.25, freq=4000 |
		var out;
		freq = freq + XLine.ar(0,200, 0.01);
		out = SinOsc.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);

		Out.ar(~reverbBus, out * 0.1);
		out;
	}.play;
)

(
	{| amp=0.25, freq=9000 |
		var out;
		out = LFTri.ar([freq * 1.1, freq], width: 0.5) * amp * EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);

		Out.ar(~reverbBus, out * 0.3);
		out;
	}.play;
)

(
	{| amp=0.05, freq=4000 |
		var out;

		freq = freq + Line.kr(0, 500, 4);
		out = LFTri.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 2.1), doneAction: 2);

		Out.ar(~reverbBus, out * 0.3);
		out;
	}.play;
)

~reverbBus = Bus.audio(s,2);
(
	~reverb.free;
	~reverb = {
		FreeVerb.ar(In.ar(~reverbBus, 2), mix: 0.2);
	}.play;
)
// New'ish sounds:
(
	w = Window(bounds:Rect(200,200,200,200)).layout_(
		    VLayout(
			HLayout(
				Button().action_({
					{| amp=0.25, freq=4000 |
						var out;
						freq = freq + XLine.ar(0,200, 0.01);
						out = SinOsc.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);

						Out.ar(~reverbBus, out * 0.1);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.15, freq=5000 |
						var out;
						freq = freq - XLine.ar(0,200 + 200.0.rand, 0.01);
						out = SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.25, freq=9000 |
						var out;
						out = LFTri.ar([freq * 1.1, freq], width: 0.5) * amp * EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=4000 |
						var out;

						freq = freq + Line.kr(0, 500+500.0.rand, 4);
						out = LFTri.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 2.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
			),
			HLayout(
				Button().action_({
					{| amp=0.25, freq=900 |
						var out;
						freq = freq + XLine.ar(0,200, 0.01);
						out = SinOsc.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);

						Out.ar(~reverbBus, out * 0.1);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.15, freq=800 |
						var out;
						freq = freq - XLine.ar(0,200 + 200.0.rand, 0.01);
						out = SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.25, freq=900 |
						var out;
						out = LFTri.ar([freq * 1.1, freq], width: 0.5) * amp * EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=700 |
						var out;

						freq = freq + Line.kr(0, 500+500.0.rand, 4);
						out = LFTri.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 2.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.8);
						out;
					}.play;
				}),
			),
			HLayout(
				Button().action_({
					{| amp=0.25, freq=50 |
						var out;
						freq = freq + XLine.ar(0,20, 0.01);
						out = SinOsc.ar([freq + 6.0.rand * 1.1, freq + 90.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.1);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.15, freq=90 |
						var out;
						freq = freq - XLine.ar(0,20 + 10.0.rand, 0.01);
						out = SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.25, freq=50 |
						var out;
						out = LFTri.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=20 |
						var out;

						out = LFTri.ar([freq + 10.0.rand * 1.1, freq + 20.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 2.1), doneAction: 2);

					out = (out * 13).tanh;

						Out.ar(~reverbBus, out * 0.8);
						out;
					}.play;
				}),
			),
			//HLayout(
				//Button().action_({
					//{| amp=0.5, freq=600 |
						//SinOsc.ar([freq + 200.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);}.play;
				//}),
				//Button().action_({
					//{| amp=0.5, freq=900 | SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);}.play;
				//}),
				//Button().action_({
					//{| amp=0.25, freq=800 | SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 1.4), doneAction: 2);}.play;
				//}),
				//Button().action_({
					//{| amp=0.5, freq=600 | SinOsc.ar([freq + 200.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 5.1), doneAction: 2);}.play;
				//}),
			//),
			//HLayout(
				//Button().action_({
					//{| amp=0.59, freq=30 | SinOsc.ar([freq + 100.0.rand * 1.1, freq + 100.0.rand], mul: 4).tanh * amp * EnvGen.ar(Env.perc(0.01, 0.4), doneAction: 2);}.play;
				//}),
				//Button().action_({
					//{| amp=0.29, freq=30 | SinOsc.ar([freq + 100.0.rand * 1.1, freq + 100.0.rand], mul: 49).tanh * amp * EnvGen.ar(Env.perc(0.01, 5.1), doneAction: 2);}.play;
				//}),
				//Button().action_({
					//{| amp=1.95, freq=70 | SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 9.1), doneAction: 2);}.play;
				//})
			//)
		)
	).front;
)



~reverbBus = Bus.audio(s,2);
(
	Ndef(\reverb, {
	FreeVerb.ar(In.ar(~reverbBus, 2) + Ndef(\noiseImpulse).ar, mix: 0.2);
	}).play;
)
	Ndef(\reverb).play;

(
	c = Buffer.readChannel(s, "/home/scott/dev/AIam-sound/samples/emptywordsCompressSOLO.wav", channels: [0], action: { |buffer|
		"".postln;
		"Loaded: ".post;

		Ndef(\stutter0, { | x=1,y=1, rate=0.45, amp=0.8, switch=1, t_trigger=1, pan=1 |
			var buffer=c;

			var out = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate * 2, trigger: 1, startPos: 0, loop: 1) * amp;

			out = LPF.ar(out, SelectX.kr(switch, [900, 9000]).lag(0.3)) * 0.15 * amp.lag(0.2)!2;

			out = LPF.ar(out, 9000);

			out = EnvGen.ar(Env.perc(0.1, 0.4), gate: t_trigger) * out;
			Out.ar(~reverbBus, out * 0.6);
			Pan2.ar(out, pan);
		});

		Ndef(\stretch, { | x=1,y=1, rate=0.45, amp=0.8, switch=1, t_trigger=1, length = 1.5, pan=1 |
			var buffer=c;

			//var out = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate * 2, trigger: 1, startPos: 0, loop: 1) * amp;
			var out = GrainBuf.ar(2, Impulse.kr(9), 0.2, c, pos: LFSaw.kr(0.03).unipolar, rate: rate * 2);
			out = LPF.ar(out, SelectX.kr(switch, [900, 9000]).lag(0.3)) * amp.lag(0.2)!2;

			out = EnvGen.ar(Env.perc(0.1, length), gate: t_trigger) * out;
			Out.ar(~reverbBus, out * 0.6);
			Pan2.ar(out, pan);

		});

	});




	Ndef(\graySineTrig, { | amp=0, freq=703, q=0.4, x=0.5, y=0.5, z=0.5, length=0.5, t_trigger=1 |
		var verb;
		var noise = WhiteNoise.ar();
		var modFreq = SelectX.kr((y.linlin(-1,1,0,1 * 4)).abs.floor % 2, [x.linlin(-1,1, 0, 18).sin * 20 + 0.1, x.linlin(-1,1, 0, 18).cos * 20 + 0.1]);
		var lag = (modFreq/10).pow(4).clip(0,1);

		var filtered;
		var freqs = [freq, (freq.cpsmidi + 3).midicps, (freq.cpsmidi + 7).midicps, (freq.cpsmidi - 5).midicps];

		freq = SelectX.kr(y.linlin(-1,1,0,1 * freqs.size).abs.floor, freqs).lag(0.00012);

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
		) ;


		verb = verb * 0.995;

	verb = EnvGen.ar(Env.perc(0.1, length), gate: t_trigger) * verb;
			Out.ar(~reverbBus, verb * 0.6);

	verb * 3;
	});


Ndef(\noiseImpulse, {| amp=0.15, freq=50, t_trigger=1, length=2, rand=0 |
	var out;

	out = BPF.ar(GrayNoise.ar(),[ freq, freq*1.01 ],0.2);

	out = out + (BPF.ar(GrayNoise.ar(),[ freq*0.25, freq*0.21 ],0.2)  * 0.35) * amp;

	out = LFTri.ar([freq, freq*1.1]);
	out = LPF.ar(out, 800);
	out = (out*0.25) + SinOsc.ar(60+rand)!2;
	out = EnvGen.ar(Env.perc(0.1, length), gate: t_trigger) * out;
	out = (out * 130).tanh * 0.5;

	out * amp;
});
)

Ndef(\noiseImpulse).set(\amp, 0.15, \length, 0.02, \freq, 50 + 200.0.rand, \rand, 10.0.rand, \t_trigger, 1);
Ndef(\noiseImpulse).play;
Ndef(\stutter0).play;
Ndef(\stretch).play;
Ndef(\graySineTrig).play;
Ndef(\stretch).set(\amp, 0.8, \t_trigger, 1);
Ndef(\stutter0).clear;
Ndef(\stretch).clear;
s.meter;
/// Trying for voices
(
	w = Window(bounds:Rect(200,200,200,200)).layout_(
		    VLayout(
			HLayout(
				Button().action_({
					Ndef(\stutter0).set(\pan, -1, \amp, 2, \rate, 0.45, \t_trigger, 0);
				}),
				Button().action_({
					Ndef(\stutter0).set(\pan, -1, \amp, 2, \rate, 0.35, \t_trigger, 1);
				}),
				Button().action_({
					Ndef(\stretch).set(\pan, -1, \amp, 2, \rate, 0.45, \length, 0.9, \t_trigger, 1);
				}),
				Button().action_({
					Ndef(\stretch).set(\pan, -1, \amp, 2, \rate, 0.35, \length, 2, \t_trigger, 1);
				}),
			),
			HLayout(
				Button().action_({
					Ndef(\stutter0).set(\pan, 1, \amp, 2, \rate, 0.5, \t_trigger, 1);
				}),
				Button().action_({
					Ndef(\stutter0).set(\pan, 1, \amp, 2, \rate, 0.35, \t_trigger, 1);
				}),
				Button().action_({
					Ndef(\stretch).set(\pan, 1, \amp, 2, \rate, 0.45, \length, 0.9, \t_trigger, 1);
				}),
				Button().action_({
					Ndef(\stretch).set(\pan, 1, \amp, 2, \rate, 0.35, \length, 2, \t_trigger, 1);
				}),
			),
		HLayout(
				Button().action_({
					Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 703, \x, 0.4, \y, 0.9, \length, 0.8, \t_trigger, 1);
				}),
				Button().action_({
				Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 903, \x, 0.4, \y, 0.9, \length, 1.3, \t_trigger, 1);
				}),
				Button().action_({
				Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1003, \x, 0.14, \y, 0.9, \length, 1.3, \t_trigger, 1);
				}),
				Button().action_({
				Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1903, \x, 0.4, \y, 0.1, \length, 3.3, \t_trigger, 1);
				}),
			),
		HLayout(
				Button().action_({
					Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 703, \x, 0.4, \y, 0.9, \length, 0.8, \t_trigger, 1);
				}),
				Button().action_({
				Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 903, \x, 0.4, \y, 0.9, \length, 1.3, \t_trigger, 1);
				}),
				Button().action_({
				Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1003, \x, 0.14, \y, 0.9, \length, 1.3, \t_trigger, 1);
				}),
				Button().action_({
				Ndef(\graySineTrig).set(\pan, 1, \amp, 2, \freq, 1903, \x, 0.4, \y, 0.1, \length, 3.3, \t_trigger, 1);
				}),
			),
		HLayout(
				Button().action_({
					{| amp=0.05, freq=4000 |
						var out;
						freq = freq + XLine.ar(0,200, 0.01);
						out = SinOsc.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);

						Out.ar(~reverbBus, out * 0.1);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=5000 |
						var out;
						freq = freq - XLine.ar(0,200 + 200.0.rand, 0.01);
						out = SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=9000 |
						var out;
						out = LFTri.ar([freq * 1.1, freq], width: 0.5) * amp * EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=4000 |
						var out;

						freq = freq + Line.kr(0, 500+500.0.rand, 4);
						out = LFTri.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 2.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
			),
			HLayout(
				Button().action_({
					{| amp=0.05, freq=900 |
						var out;
						freq = freq + XLine.ar(0,200, 0.01);
						out = SinOsc.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.01), doneAction: 2);

						Out.ar(~reverbBus, out * 0.1);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=800 |
						var out;
						freq = freq - XLine.ar(0,200 + 200.0.rand, 0.01);
						out = SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=900 |
						var out;
						out = LFTri.ar([freq * 1.1, freq], width: 0.5) * amp * EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=700 |
						var out;

						freq = freq + Line.kr(0, 500+500.0.rand, 4);
						out = LFTri.ar([freq + 600.0.rand * 1.1, freq + 900.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 2.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.8);
						out;
					}.play;
				}),
			),
			HLayout(
				Button().action_({
					{| amp=0.25, freq=50 |
						var out;
						freq = freq + XLine.ar(0,20, 0.01);
						out = SinOsc.ar([freq + 6.0.rand * 1.1, freq + 90.rand]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.1);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.15, freq=90 |
						var out;
						freq = freq - XLine.ar(0,20 + 10.0.rand, 0.01);
						out = SinOsc.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.25, freq=50 |
						var out;
						out = LFTri.ar([freq * 1.1, freq]) * amp * EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);

						Out.ar(~reverbBus, out * 0.3);
						out;
					}.play;
				}),
				Button().action_({
					{| amp=0.05, freq=20 |
						var out;

						out = LFTri.ar([freq + 10.0.rand * 1.1, freq + 20.0.rand]) * amp * EnvGen.ar(Env.perc(0.01, 2.1), doneAction: 2);

					out = (out * 13).tanh;

						Out.ar(~reverbBus, out * 0.8);
						out;
					}.play;
				}),
			),

		)
	).front;
)




Ndef(\bass2).clear;
(
Ndef(\bass2, { | freq=60, amp=0.0, dist=1 |
	var out;
	var seq = Dseq([freq, freq/2, freq, freq*1.5],inf);

	freq = Demand.kr(Impulse.kr(0.1), 0, seq).lag(0.25);

	out = LFPulse.ar(freq) + (LFPulse.ar(freq / 0.75) * LFPulse.ar(20.2, mul: SinOsc.kr(0.1, mul:0.5), add: 0.4)) ;
	out = LFNoise1.ar(0.5, mul: 0.4, add: 0.6) * out;
	out = LPF.ar(out, 300).tanh;

		out = out + ((SinOsc.ar(freq *2) * Lag.kr( dist, 0.7 )/2) * LFPulse.ar(4).unipolar);
		out = out + ((SinOsc.ar(freq *1.5) * Lag.kr( dist, 0.7 )/2) * LFPulse.ar(2.5).unipolar);

		out = out + (LPF.ar(SinOsc.ar(freq / 4) * LFPulse.ar(2.0/8, width: 0.25).unipolar, 70) * 0.25);
	out = out + (SinOsc.ar(freq / 3) * SinOsc.ar(0.1).unipolar * 0.75);

	// var out = (LFTri.ar([freq, freq * 1.1]) * 3).tanh * amp.lag(1.2)/2;
	FreeVerb.ar([out,out] * amp * 0.1, mix: 1);

});
)


Ndef(\bass2).play
Ndef(\stop).play

Ndef(\bass2).set(\amp, 0)


NdefMixer.new(s);
c