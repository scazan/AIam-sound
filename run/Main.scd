	// Synths need an interface of these arguments: x, y, proximity
	var synths = [
		[ Ndef(\saw) ],
		[ Ndef(\saw2) ],
		[ Ndef(\saw2) ]
	];
	var numActors = 3;


// Actor class
	var actor = { | index, synths |
		var position = Dictionary[\x -> 0, \y -> 0, \z -> 0 ];


		var dict = Dictionary[
			\id -> 0,
			\active -> false,
			\position -> position,
			\synths -> List[],
		];

		// Add all assigned synths
		synths[index].do({ |item, i|
			dict[\synths].add(item);
		});

		dict;
	};

	var actors = Array.fill(numActors, {|i| actor.value(i, synths)});
	var actorProximity = 999;




	// Distance Calculations
	var utils, computeProximity2XZ, computeProximityN2D;

    "Utils.scd".loadRelative; // returns ~cUtils
	utils = ~cUtils.value();

    computeProximity2XZ = utils[\computeProximity2XZ];
    computeProximityN2D = utils[\computeProximityN2D];



	// Main Function
	~cMain = { | init, onClose |
		var maxY = 0,
			maxX = 0,
			maxNumTracked = numActors,
			window;

		~computeDensity = { |val|
			val = ((1 - val)**1 * 2).abs;

			if(val > 1.0, {
				[">>", val ].postln;
				Tdef(\vocal).stop;
				Ndef(\pulseTrain0).set(\lag, 1 );
				Ndef(\pulseTrain0).set(\density, val+0.5 );
			}, {
				Tdef(\vocal).play;
			});
		};





		// Listeners
		OSCdef(\actorStateListener, { | msg |
			var state = msg[2],
				id = msg[1].asInteger();

			case(
				{state == "new"
				|| state == "visible"}, {
					var inactiveSynths;
					var existingSynths = actors.select({ | synth |
						(synth[\trackingID] == id) && (synth[\active] == true);
					});

					if(existingSynths.size == 0, {
						inactiveSynths = actors.select({ | synth |
							synth[\active] == false;
						});

					}, {
						inactiveSynths = existingSynths;
					});

					if(inactiveSynths.size > 0, {
						// grab the first inactive synth available
						var inactiveSynth = inactiveSynths[0];
						// Set it to be active with this id
						inactiveSynth[\trackingID] = id;
						inactiveSynth[\active] = true;
					});
				},
				{state == "tracking"}, {},
				{state == "lost"
				|| state == "stopped_tracking"}, {
					// find where this was being tracked previously
					var lostSynth = actors.select({ | synth |
						synth[\trackingID] == id;
					});

					// Deactivate the slot
					lostSynth.do({ | synth |
						synth[\active] = false;
					});
				},
			);
		}, path: \state, recvPort: 15002);

		OSCdef(\tracker, { | msg |
			//var id = msg[1].asFloat - 1,
			var id = msg[1].asFloat,
				x = msg[2].asFloat / 1800,
				y = msg[3].asFloat / 500,
				z = msg[4].asFloat / 7000;

			var diffX = 0,
				diffY = 0,
				diffZ = 0;


			var activeActor;
			var activeActors;
			id = id - 1;
			activeActors = actors.select({ | actor |
				actor[\id] == id;
			});

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
				});

				// TODO: what to do when there are no synths available? currently ignore that actor

			}, {
				activeActor = activeActors[0];
			});


			// If we have an actor, then set its position
			if(activeActor.notNil, {
				var allActiveActors = actors.select({|item| item[\active] == true});

				activeActor[\position][\x] = x;
				activeActor[\position][\y] = y;
				activeActor[\position][\z] = z;

				//z = (z-0.5).abs / (1-0.5);


				// update the proximities
				// We need at least two actors to judge a distance
				if(allActiveActors.size >= 2, {
					actorProximity = computeProximityN2D.value(allActiveActors.collect({ | item | [item[\position][\x], item[\position][\z] ] ; }));
					actorProximity.postln;
				});

				// Update any synths with new info
				~computeDensity.value(actorProximity);

				activeActor[\synths].do({| synth, i |
					synth.set(\x,activeActor[\position][\z], \y, activeActor[\position][\x]);
				});

			});

		}, path: \center, recvPort: 15002);


		// GUI
		window = Window.new("AIam Sound", Rect(100, 100, 100, 100)).front;
		window.view.background_(Color.new255(153, 255, 102));

		window.onClose = {
			onClose.value();
		};

		{ while { window.isClosed.not } { window.refresh; 0.04.wait; } }.fork(AppClock);
	};