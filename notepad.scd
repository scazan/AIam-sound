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


~createGraySineTrig.value(pan: 1, amp: 2, freq: 1203, switch: 3, length: 1.3, t_trigger: 1);
~createGraySineTrig.value(amp: 2, freq: 903, switch: 3, length: 1.3, t_trigger: 1);

a = [[0],[3],[7], [9,12]];
i = 2;

~octave = 4;
(
~createGraySineTrig.value(amp: 2, freq: (a[i].choose + (~octave*12)).midicps, switch: 3, length: 1.3, t_trigger: 1);
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

~graySineVol = 0.15;


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