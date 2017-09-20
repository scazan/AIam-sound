s.options.memSize = 1024 * 100; s.boot;
"Buffers.scd".loadRelative;

s.waitForBoot({
	var tasks, synthDefs, main;

	// Globals

	~section = 0;

	~dirgeVol = 0.05;
	~energyThreshold = 1.05;
	~quadrant2 = false;
	~proximityDistance = 0.9;
	//~energyThreshold = 0.47;

	~graySineVol = 0.05;
	~entranceScanVol = 0.1;
	~airySineVol = 0.02;
	~metalVol = 0.01;
	~earthVol = 0.02;
	~fireVol = 0.02;
	~waterVol = 0.25;

	// Callback volumes
	~q1CallbackVol = 0.04;
	~q2CallbackVol = 0.01;
	~q3CallbackVol = 0.01;
	~q4CallbackVol = 0.01;


	// Load Synths
	"Synths.scd".loadRelative; // returns ~cSynths
	synthDefs = ~cSynths.value();


	// Main Program
	"Main.scd".loadRelative; // returns ~cMain
	main = ~cMain.value({}, {
	});

	// Start main function
	AppClock.sched(3, main);


	NdefMixer.new(s);

});

//Second section of part 1 lotsa contact?

// pulseTrain0 solo for proximity in section 2


// Critical Mass
// Rashad
// You Got It

// grainer is an advanced stage: Maybe make this better?

//s.volume = 2;


/*
EARLY SHOW
Starts with prettier drone thing but needs to be more active, more responsive

Low bass comes in
pulseTrain starts, this is signal for the duo to start up
During duo, the whiney voices come in.

Trio starts while the saw drone comes in.
Explosion in dance is cause for drone to cut out and the samples in motion comes in (stillness/motion)

*/

// BASS Thump method is not so reliable

// Add corners that cause a sound when you are lost. This should be panned towards the corner.
// Mock up sound that is triggered when you want the dancers to move towards that area (panned)
// When the dancers move towards that space the volume goes up towards the edge as if to punish (sort of)

~graySineVol = 0.0;
	~entranceScanVol = 0;
	~airySineVol = 0.0;
	~metalVol = 0.0;
	~earthVol = 0.00;
	~fireVol = 0.0;
	~waterVol = 0;


