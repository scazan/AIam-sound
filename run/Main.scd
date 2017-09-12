// Synths need an interface of these arguments: x, y, z, proximity
var synths, sceneController;
var numActors = 3;


// Actor class
var actor = { | index |
	var position = Dictionary[\x -> 0, \y -> 0, \z -> 0 ];


	var dict = Dictionary[
		\id -> 0,
		\active -> false,
		\position -> position,
		\lastPosition ->  Dictionary[\x -> 0, \y -> 0, \z -> 0 ],
		\energies -> Array.fill(12, 0),
		\motion -> false,
	];

	dict;
};

var actors;
var actorProximity = 999;


var getCameraID = { | actorID |
	var cameraID;

	// Determine which camera we are using
	if((actorID >= 100) && (actorID < 200), {
		cameraID = 1;
	},
	{

		if((actorID >= 200) && (actorID < 300), {
			cameraID = 2;
		},
		{
			if((actorID >= 300) && (actorID < 400), {
				cameraID = 3;
			},
			{
				cameraID = 0;
			});

		});
	});

	cameraID;
};


// Distance Calculations
var utils, computeProximity2XZ, computeProximityN2D;

"Utils.scd".loadRelative; // returns ~cUtils
utils = ~cUtils.value();

computeProximity2XZ = utils[\computeProximity2XZ];
computeProximityN2D = utils[\computeProximityN2D];



"SceneController.scd".loadRelative; // returns ~cSceneController
~sceneController = ~cSceneController.value();

//Set the synths for the initial scene
//synths = ~sceneController[\getSynths].value(0); // You need to not set this but to constantly query the scene controller

// Create Actors
actors = Array.fill(numActors, {|i| actor.value(i)});

// Main Function
~cMain = { | init, onClose |
	var maxY = 0,
	maxX = 0,
	maxNumTracked = numActors,
	window;







	// Listeners
	// Manages the assignment of ids to an "Actor". id is irrelevant in relation to the actual index of the actor.
	OSCdef(\actorStateListener, { | msg |
		var state = msg[2].asString().trim(),
			id = msg[1].asInteger(),
		x = msg[3].asFloat / 1430,
			y = msg[4].asFloat / 900,
			z = msg[5].asFloat / 7000;


		// [msg, state, state == "lost"].postln;
		case(
			{state == "new"}, {
				var inactiveSynths, cameraID = 0;
				var existingSynths = actors.select({ | synth |
					(synth[\id] == id) && (synth[\active] == true);
				});


				if(existingSynths.size == 0, {
					inactiveSynths = actors.select({ | synth |
						synth[\active] == false;
					});

					}, {
						// If there is an "active" synth.
						inactiveSynths = existingSynths; // Assigning like this as a shortcut to allow us to use the same logic below
				});



				if(inactiveSynths.size > 0, {
					// grab the first "inactive synth" available
					var inactiveSynth = inactiveSynths[0];

					// Set it to be active with this id (if this synth was already active it sets it again)
					inactiveSynth[\trackingID] = id;
					inactiveSynth[\id] = id;
					inactiveSynth[\active] = true;

					inactiveSynth[\position][\x] = x;
					inactiveSynth[\position][\y] = y;
					inactiveSynth[\position][\z] = z;
				});


				cameraID = getCameraID.value(id);
				~sceneController[\getCameraProcessor].value(cameraID)[\new].value(id, x, y, z);

			},
			{state == "tracking"}, {},
			{state == "lost"}, {
				var cameraID = 0;

				// find where this was being tracked previously
				var lostSynth = actors.select({ | synth |
					synth[\id] == id;
				});


				// Deactivate the slot allowing it to be re-assigned in the future
				lostSynth.do({ | synth |
					synth[\active] = false;
				});


				if(~quadrant2, {
					{
						var freq = 490, sin1, sin2, noise, out;

						freq = [290, 490, 900].choose/2;
						freq = Line.kr([ freq, freq*1.1 ], freq-30, 0.3);

						noise = DelayN.ar(BPF.ar(GrayNoise.ar(), 6000 + 1000.0.rand, 0.01), 0.5);
						noise = GrayNoise.ar() * EnvGen.ar(Env.perc(0.01, 0.01));
						noise = SinOsc.ar(80, mul: 2).max * EnvGen.ar(Env.perc(0.01, 0.01));
						noise = LPF.ar(noise, 690);
						sin1 = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.1, 0.2));
						sin2 = SinOsc.ar(freq * 2) * EnvGen.ar(Env.perc(0.1, 7), doneAction:2) * 0.5;
						out = (((sin1) * 3) + ( noise * 3 )).max;
						out = FreeVerb.ar(out, mix: 0.68);
						Out.ar(0, out * ~dirgeVol);

					}.play;
				});
				///////////////////////


				cameraID = getCameraID.value(id);
				~sceneController[\getCameraProcessor].value(cameraID)[\lost].value(id, x, y, z);
			},
			{
				// TODO: This seems to do nothing
				var existingSynths = actors.select({ | synth |
					// (synth[\trackingID] == id) && (synth[\active] == true);
					(synth[\id] == id);
				});
			}
		);
	}, path: \state, recvPort: 15002);


	OSCdef(\tracker, { | msg |
		//var id = msg[1].asFloat - 1,
		var id = msg[1].asFloat,
			x = msg[2].asFloat / 1430,
			y = msg[3].asFloat / 900,
			z = msg[4].asFloat / 7000;

		var diffX = 0,
		diffY = 0,
		diffZ = 0;


		var activeActor;
		var activeActors;

		// id = (id - 1);
		/*[msg[2], msg[3]].postln;*/

		// Check if this id already has an "Actor"
		activeActors = actors.select({ | actor |
			actor[\id] == id;
		});

		// If not, find one that is inactive
		if(activeActors.size == 0, {
			// get all the inactive synths
			var inactiveSynths = actors.select({ | synth |
				synth[\active] == false;
			});


			// if we have inactive synths available
			if(inactiveSynths.size > 0, {
				// use the first inactive synth
				var inactiveSynth = inactiveSynths[0];
				inactiveSynth[\id] = id;
				inactiveSynth[\active] = true;

				activeActor = inactiveSynth;
				}, {
					// TODO: what to do when there are no synths available? currently ignore that actor. This should be a violent takeover. Which one to takeover though... you don't want to takeover the one that is actually there and leave the ghost in charge. Maybe a timeout?

					// Otherwise, choose just the first active one and take it over. This will cause occasional glitches and shift in control
					// VIOLENT TAKEOVER
					activeActor = actors[0];
					activeActor[\id] = id;
					activeActor[\active] = true;
			});



			}, {
				// If we FOUND an active Actor with this id, then
				activeActor = activeActors[0];
		});


		// If we have an actor, then set its position (we should have an activeActor no matter what at this point)
		if(activeActor.notNil, {
			var allActiveActors = actors.select({|item| item[\active] == true});
			var energiesMotion = [0,0];
			var cameraID = 0;


			activeActor[\lastPosition][\x] = activeActor[\position][\x].asFloat;
			activeActor[\lastPosition][\y] = activeActor[\position][\y].asFloat;
			activeActor[\lastPosition][\z] = activeActor[\position][\z].asFloat;

			activeActor[\position][\x] = x;
			activeActor[\position][\y] = y;
			activeActor[\position][\z] = z;

			// [x,y,z, activeActor].postln;
			//z = (z-0.5).abs / (1-0.5);


			// Calculate the proximities
			// (we need at least two actors to judge a distance)
			if(allActiveActors.size >= 2, {
				actorProximity = computeProximityN2D.value(allActiveActors.collect({ | item | [item[\position][\x], item[\position][\y] ] ; }));
			});



			// UPDATES ///////////////////////////////////////
			// Update any synths with new info
			/*~sceneController[\getProcessors].value()[\proximity].value(actorProximity);*/

			cameraID = getCameraID.value(id);

			// PROXIMITY
			~sceneController[\getCameraProcessor].value(cameraID)[\proximity].value(actorProximity);

			// ENERGY
			energiesMotion = ~sceneController[\getCameraProcessor].value(cameraID)[\energy].value(actors.indexOf(activeActor),
				[
					activeActor[\position][\x],
					activeActor[\position][\z],
					activeActor[\position][\y]
				],
				[
					activeActor[\lastPosition][\x],
					activeActor[\lastPosition][\z],
					activeActor[\lastPosition][\y]
				],
				activeActor[\energies],
				activeActor[\motion]
			);

			// store energy here
			activeActor[\energies] = energiesMotion[0];
			activeActor[\motion] = energiesMotion[1];

			// SYNTHS
			~sceneController[\getCameraProcessor].value(cameraID)[\synths].value( activeActor, actors.indexOf(activeActor) );

		});

	}, path: \center, recvPort: 15002);








	// GUI
	window = Window.new("AIam Sound", Rect(100, 100, 100, 100)).front;
	window.view.background_(Color.new255(153, 255, 102));

	Button.new(window).action_(~sceneController[\next]);

	window.onClose = {
		onClose.value();
	};

	{ while { window.isClosed.not } { window.refresh; 0.04.wait; } }.fork(AppClock);

	/*AppClock.sched(5, {
		~sceneController[\next].value();
	});*/
};
