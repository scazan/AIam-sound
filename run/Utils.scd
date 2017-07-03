~cUtils = {
// Distance Calculations
	var computeProximity2XZ = { | vectors |
		var x=0, y=1, euclideanDistance;

		euclideanDistance = ((vectors[0][x] - vectors[1][x]).pow(2) + (vectors[0][y] - vectors[1][y]).pow(2)).sqrt;
		euclideanDistance;
	};

	var computeProximityN2D = { | vectors |
		var distances = Array.fill(vectors.size, 0),
			index = 0,
			averageDistance = 0;

		vectors.do({ | subject, i |
			var others = (vectors++[]);
			others = others.copyToEnd(i+1);

			others.do({ | other, k |
				var distance = computeProximity2XZ.value([subject, other]);

				distances[index] = distance;
				index = index + 1;
			});

		});

		averageDistance = distances.sum()/distances.size;
	};

	Dictionary[
		\computeProximity2XZ -> computeProximity2XZ,
		\computeProximityN2D -> computeProximityN2D
	];
};