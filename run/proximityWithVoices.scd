s.options.memSize = 1024 * 100;

s.waitForBoot({
	var tasks, synthDefs, main;

	// Globals

	~dirgeVol = 0.05;
	~energyThreshold = 0.45;
	~quadrant2 = false;
	~proximityDistance = 0.9;
	~energyThreshold = 0.7;


	// Load Synths
	"Synths.scd".loadRelative; // returns ~cSynths
	synthDefs = ~cSynths.value();
	// synthDefs[\play].value();


	// ROUTINES
	"Tasks.scd".loadRelative; // returns ~cTasks
	tasks = ~cTasks.value();
	// tasks[\play].value();

	// Main Program
	"Main.scd".loadRelative; // returns ~cMain
	main = ~cMain.value({}, {
		// tasks[\stop].value();
		synthDefs[\stop].value();
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

s.volume = 2;


/*

Starts with prettier drone thing but needs to be more active, more responsive

Low bass comes in
pulseTrain starts, this is signal for the duo to start up
During duo, the whiney voices come in.

Trio starts while the saw drone comes in.
Explosion in dance is cause for drone to cut out and the samples in motion comes in (stillness/motion)

WTF IS NEXT?

*/