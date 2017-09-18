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
~createAiryTrig.value(amp: 0.5, freq: 1.0.rand + 0.5, pan: 2.0.rand - 1);
	~createWaterTrig.value(amp: 0.5, freq: 950.rand + 1500, pan: 2.0.rand - 1);
~createFireTrig.value(amp: 0.5, freq: 1.0.rand + 0.5, pan: 2.0.rand - 1);
~createEntranceScan.value(amp: 0.26 + 0.2, freq: 2700 + (200.0.rand), length: 0.08 + 0.1.rand, pan: 0);



(
Ndef(\noiseImpulse, { | amp=0, freq=1900, t_trigger=1 |
	var out;
	out = BPF.ar(GrayNoise.ar(),[ freq, freq*1.01 ],0.2);

	out = out + (BPF.ar(GrayNoise.ar(),[ freq*0.25, freq*0.21 ],0.2) * 0.35);
	out = out + SinOsc.ar(60, mul: 0.2);

	out = EnvGen.ar(Env.new([0,1,0],[0.00001, 0.6, 0.000001]), gate: t_trigger) * out;

	out = CombN.ar(out, delaytime: 0.03);
	Out.ar(~reverbBus, out);
	( out*2 ).tanh * amp * 1;
});
)
~thumpZoneIDs
~thumpZoneIDs.values.sum

(
~resetThump = {
	~thumpZoneIDs.keysValuesDo({ | value, key, i |
		~thumpZoneIDs[value] = 0;
	});
};
)
~resetThump.value();
(
~section = 0;
"SceneController2.scd".loadRelative; // returns ~cSceneController
~sceneController = ~cSceneController.value();
Ndef(\reverb2).play;
Ndef(\beep).play;
Ndef(\bass).stop;
)

// Section 0a
(
Ndef(\graySine).play; Ndef(\graySine2).play;
// Ndef(\graySine).fadeTime = 30;
Ndef(\graySine2).fadeTime = 30;
// Ndef(\graySine).xset(\vol, 0.5);
Ndef(\graySine2).xset(\vol, 0.5);
Ndef(\beep).play;
)
(
~section = 1;
"SceneController2.scd".loadRelative; // returns ~cSceneController
~sceneController = ~cSceneController.value();
Ndef(\graySine).fadeTime = 5; Ndef(\graySine2).fadeTime = 15;
Ndef(\graySine).xset(\vol, 0);Ndef(\graySine2).xset(\vol, 0);
Ndef(\bass).stop;
Ndef(\noiseImpulse).play;
)
(
~section = 2;
"SceneController2.scd".loadRelative; // returns ~cSceneController
~sceneController = ~cSceneController.value();
Ndef(\pulseTrain0).play; Ndef(\pulseTrain0).xset(\amp, 1);
Ndef(\bass).play;
Ndef(\noiseImpulse).stop;
Ndef(\graySine).set(\vol, 0);Ndef(\graySine2).set(\vol, 0);
)

(
~section = 3;
"SceneController2.scd".loadRelative; // returns ~cSceneController
~sceneController = ~cSceneController.value();
Ndef(\graySine).play; Ndef(\graySine2).play;
Ndef(\graySine).fadeTime = 10; Ndef(\graySine2).fadeTime = 10;
Ndef(\graySine).xset(\vol, 0.5);Ndef(\graySine2).xset(\vol, 0.5);
)

(
~section = 4;
"SceneController2.scd".loadRelative; // returns ~cSceneController
~sceneController = ~cSceneController.value();
Ndef(\graySine4).play; Ndef(\graySine5).play; Ndef(\graySine6).play;
Ndef(\graySine4).fadeTime = 30; Ndef(\graySine5).fadeTime = 30; Ndef(\graySine6).fadeTime = 30;
Ndef(\graySine4).xset(\vol, 0.5); Ndef(\graySine5).xset(\vol, 0.5); Ndef(\graySine6).xset(\vol, 0.5);
)

(

)
~resetThump.value();
~thumpZoneIDs.values.sum