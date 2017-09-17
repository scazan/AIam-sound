(

x = {

	}.play;
)

192.168.48.97.


Ndef(\wood).clear;

(
Ndef(\wood, {arg amp=0.3, pan=0, sustain=0.5, t_trig=1, freq=300, rq=0.06;
	var env, signal;
	var rho, theta, b1, b2;
	b1 = 2.0 * 0.97576 * cos(0.161447);
	b2 = 0.9757.squared.neg;
	signal = SOS.ar(K2A.ar(t_trig), 1.0, 0.0, 0.0, b1, b2);
	signal = Decay2.ar(signal, 0.4, 0.8, signal);
	signal = Limiter.ar(Resonz.ar(signal, freq, rq*0.5), 0.9);
	env = EnvGen.kr(Env.perc(0.00001, sustain, amp), doneAction:2);
	Pan2.ar(signal, pan)*env;
});
)

Ndef(\wood).set(\t_trig, 1);
Ndef(\wood).set(\t_trig, -1);


~createGraySineTrig.value(pan: 1, amp: 2, freq: 1003, switch: 3, length: 1.3, t_trigger: 1);
~createGraySineTrig.value(amp: 2, freq: 903, switch: 3, length: 1.3, t_trigger: 1);

a = [[0],[1],[7], [9,12]];
i = 2;

~octave = 6;
(
~createGraySineTrig.value(amp: 04, freq: (a[i].choose + (~octave*12)).midicps, switch: 3, length: 1.3, t_trigger: 1);
i = (i - 1) % a.size;
)

Tdef(\wood, {
	{
		~createGraySineTrig.value(amp: 2, freq: (a[i].choose + (~octave*12)).midicps, switch: 3, length: 1.3, t_trigger: 1);
		i = (i - 1) % a.size;
		0.12.wait;
	}.loop;
});
Tdef(\wood).stop;

~createGraySineTrig.value(amp: 2, freq: (a[1] + (4*12)).midicps, switch: 3, length: 1.3, t_trigger: 1);
~createGraySineTrig.value(amp: 2, freq: (a[2] + (4*12)).midicps, switch: 3, length: 1.3, t_trigger: 1);

~graySineVol = 0;


(
 {arg out=0, amp=0.3, t_trig=1, sustain=0.5, gate=1, freq=100, rq=0.006;
	var env, signal;
	var rho, theta, b1, b2;
	env = EnvGen.kr(Env.adsr(0.0001, sustain, sustain/2, 0.3), gate, doneAction:2);
	b1 = 1.987 * 0.9889999999 * cos(0.09);
	b2 = 0.998057.neg;
	signal = SOS.ar(K2A.ar(t_trig), 0.3, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal*0.8, freq, rq) + DelayC.ar(RHPF.ar(signal*0.9, freq*0.99999, rq*0.999), 0.02, 0.01223);
	signal = Decay2.ar(signal, 0.4, 0.3, signal);
	(signal*env)*(amp*0.65)!2;
}.play;
)






{| amp=0, freq=703, q=0.4, x=0.5, y=0.5, z=0.5, length=0.5, t_trigger=1, switch=0 |
	var verb, filtered;

var env, signal;
	var rho, theta, b1, b2;
		var pan=0, sustain=0.05, rq=0.06;

	b1 = 2.0 * 0.97576 * cos(0.161447);
	b2 = 0.9757.squared.neg;
	signal = SOS.ar(K2A.ar(t_trigger), 1.0, 0.0, 0.0, b1, b2);
	signal = Decay2.ar(signal, 0.4, 0.8, signal);
			signal = Limiter.ar(Resonz.ar(signal, [freq, freq*1.1], rq*0.5), 0.9);
	env = EnvGen.kr(Env.perc(0.00001, sustain, amp), doneAction:2);
	filtered = Pan2.ar(signal, pan)*env;

	verb = FreeVerb.ar( filtered * amp.lag(0.1),
		mix: 0.6,
		room: 0.5,
		damp: 0.1
	);


	verb = verb * 0.995 * SelectX.kr(switch, [0.5, 0.5, 0.5, 4]);

	verb = EnvGen.ar(Env.perc(0.01, length/2), gate: t_trigger, doneAction: 2) * verb;
	Out.ar(~reverbBus, verb * 0.6);

	verb * ~graySineVol;
}.play;


~createAiryTrig.value(amp: 0.5, freq: 803, pan: 2.0.rand - 1);

Ndef(\bass).set(\amp, 0);
// One person goes into The Thump Zone, all other sounds turn off.
// Record playback

// Duet is proximity

// Wowow
// X No energy results in dip in volume
// X Invert the gaussian pitch
// How do we tell when someone exits the thump through the space? There is no \lost signal

// Create a recording system
// X Create a global that turns off the interactions while thump is active


~createMetalTrig.value(amp: 0.5, freq: 1.0.rand + 0.5, pan: 2.0.rand - 1);
~createEarthTrig.value(amp: 0.5, freq: 1.0.rand + 0.5, pan: 2.0.rand - 1);