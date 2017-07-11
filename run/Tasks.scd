~cTasks = {

	var dict;

	Tdef(\vocal, {
		{
			Ndef(\pulseTrain0).set(\density, [1,0.7,0.8,0.9, 0.7].choose);
			( 1.0.rand + 0.7 ).wait;
		}.loop;
	});

	Tdef(\vocal2, {
		{
			Ndef(\pulseTrain0).set(\vowel, [0,4,2].choose);
			( 3.0.rand + 0.7 ).wait;
		}.loop;
	});

	dict = Dictionary[
		\play -> {
			Tdef(\vocal).play;
			Tdef(\vocal2).play;
		},
		\stop -> {
			Tdef(\vocal).stop;
			Tdef(\vocal2).stop;
		}
	];

	dict;
};
