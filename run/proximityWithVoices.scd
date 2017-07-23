s.options.memSize = 1024 * 100;
~energyThreshold = 5;
s.waitForBoot({
	var tasks, synthDefs, main;

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

s.volume = 0;