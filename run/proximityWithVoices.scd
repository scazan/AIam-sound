s.options.memSize = 1024 * 100;

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


// make tracking work better for when ids have changed (violent takeover)

//Second section of part 1 lotsa contact?

// pulseTrain0 solo for proximity in section 2
