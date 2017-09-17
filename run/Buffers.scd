

~breathBuffers = Array.newClear(5);
~breathBuffers.do({ |item, i|
	i.postln;
	~breathBuffers[i] = Buffer.read(s, "/Users/scott/dev/AIam-sound/samples/breaths-00"++ (i+1) ++".wav");
});
~metalBuffers = Array.newClear(4);
~metalBuffers.do({ |item, i|
	i.postln;
	~metalBuffers[i] = Buffer.read(s, "/Users/scott/dev/AIam-sound/samples/metal-00"++ (i+1) ++".wav");
});

~earthBuffers = Array.newClear(1);
~earthBuffers.do({ |item, i|
	(i+1).postln;
	~earthBuffers[0] = Buffer.read(s, "/Users/scott/dev/AIam-sound/samples/wood-001.wav");
});

~fireBuffers = Array.newClear(1);
~fireBuffers.do({ |item, i|
	(i+1).postln;
	~fireBuffers[0] = Buffer.read(s, "/Users/scott/dev/AIam-sound/samples/wood-001.wav");
});

u = Buffer.read(s, "/Users/scott/dev/AIam-sound/samples/pads.wav");
// u = Buffer.read(s, "/Users/aiam/projects/AIam-sound/samples/pads.wav", action: { |buffer|
c = Buffer.read(s, "/Users/scott/dev/AIam-sound/samples/emptywordsCompress.wav");