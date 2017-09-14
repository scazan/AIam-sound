
~energyThreshold = 0.85;

(

b = Buffer.read(s, "/home/scott/discog/albums/Ingress/Scott Cazan - Ingress - 01 Ingress.aiff", action: { |buffer|
	"".postln;
	"Loaded: ".post;
	/*path.postln;
	"Channels: ".post;
	buffer.numChannels.postln;*/
	Ndef(\stutter2, { | x=1,y=1, rate=1.0, amp=0.5, switch=1 |
		var buffer=b;

		var out2 = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate, trigger: 1, startPos: 0, loop: 1) * amp;
		var out = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate/1.5, 48000 * SinOsc.kr(12, mul: 0.5, add: 0.1).unipolar, 500 ));

		// var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

		// out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;
		out = LPF.ar(XFade2.ar(out, out2, switch.linlin(0,1, -1, 1).lag(0.01) ), SelectX.kr(switch, [900, 9000]).lag(0.3)) * amp;

	});

	Ndef(\stutter1, { | x=1,y=1, rate=1.0, amp=0.5, switch=1 |
		var buffer=b;

		var out2 = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate/1.5, trigger: 1, startPos: 0, loop: 1) * amp;
		var out = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 48000 * SinOsc.kr(12, mul: 0.5, add: 0.1).unipolar, 500 ));

		// var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

		// out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;
		out = LPF.ar(XFade2.ar(out, out2, switch.linlin(0,1, -1, 1).lag(0.01) ), SelectX.kr(switch, [900, 9000]).lag(0.3)) * amp;

	});

});


c = Buffer.read(s, "/home/scott/dev/AIam-sound/samples/emptywords.wav"), action: { |buffer|
	"".postln;
	"Loaded: ".post;

	Ndef(\stutter0, { | x=1,y=1, rate=1.0, amp=0.5, switch=1 |
		var buffer=c;

		var out2 = PlayBuf.ar(buffer.numChannels, bufnum: buffer, rate: rate * 2, trigger: 1, startPos: 0, loop: 1) * amp;
		var out = BufRd.ar(1, c, Phasor.ar(0, BufRateScale.kr(b) * rate, start: 44100 * 3.1, end: (44100 * 3.1) + 980)) * 0.1;

		// var out2 = BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b) ));

		// out = LPF.ar(SelectX.ar(switch, [out, out2]), SelectX.kr(switch, [900, 9000])) * amp;
		out = LPF.ar(XFade2.ar(out, out2, switch.linlin(0,1, -1, 1).lag(0.01) ), SelectX.kr(switch, [900, 9000]).lag(0.3)) * amp!2;

	});


});

)


(

)
Ndef(\stutter0).clear;

Ndef(\stutter1).play;
Ndef(\stutter2).playN([1]);


Ndef(\stutter0).set(\switch, 0)
(
Ndef(\stutter2, { | x=1,y=1, rate=1.0, amp=0.5, switch=1 |

var out = GrainBuf.ar(1, trigger: Impulse.kr(5 + SinOsc.kr(3, mul: 5) ), dur: SelectX.kr(switch, [0.1, 1]).lag(0.1), sndbuf: b, rate: 0.8, pos: SinOsc.kr(LFNoise1.kr(9)).unipolar, pan: LFNoise1.kr(13), envbufnum: f ) * amp;

		var in = out;
	var chain = FFT(LocalBuf(2048), in);
		chain = PV_RandComb(chain, 0.01, Impulse.kr(0));
		out = IFFT(chain).tanh * amp;
		out = Limiter.ar([out + DelayL.ar(out,0.3,0.1), DelayL.ar(out,0.5,0.1) + DelayL.ar(out,0.2,0.1)], 0.5, 0.1);

	out = out + (CombN.ar(out, delaytime: 0.07) * 0.2 );

		out!2;
});
)




(
~energyThreshold = 0.85;
Ndef(\stutter0, { | x=1,y=1, rate=1.0, amp=0.5, switch=1 |


	var out2 = WhiteNoise.ar() * amp * 0.6;
	var out = SinOsc.ar(90) * amp;

	out = LPF.ar(SelectX.ar(switch, [out, out2]).lag(0.2), SelectX.kr(switch, [900, 9000])) * amp;

});

Ndef(\stutter1, { | x=1,y=1, rate=1.0, amp=0.5, switch=1 |

	var out2 = WhiteNoise.ar() * amp * 0.6;
	var out = SinOsc.ar(90) * amp;

	out = LPF.ar(SelectX.ar(switch, [out, out2]).lag(0.2), SelectX.kr(switch, [900, 9000])) * amp;

});

)


// Density vs spread



// Processing functions can now be camera functions
// Tasks are mostly unused but could be in the future
// How do we make the interactions and synths more modular and real-time flexible?





// TODO
// X Make Ndef(\encouraging) and Ndef(\discouraging)
// X On new functions pass the x,y coordinates to determiine where it appeared for walls and beeps
// Make sounds for the high medium low in Top Left (using graySine for now)
// X Design Ndef(\beep)
// Setup proximity to work across all four

// Each section should really kind of suport more than one person. If not, it should be limited specifically to ID==0

