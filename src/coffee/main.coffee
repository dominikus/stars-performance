d3.csv "assets/data/hygdata_v3.csv", (stars) ->

	x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,500])
	y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,500])
	z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,500])

	hi_x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,1000])
	hi_y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,1000])
	hi_z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,1000])


	svg = d3.select('.container').append("svg").attr(
		"width": "500"
		"height": "500"
	)

	console.time("render-svg")

	circles = svg.selectAll("circle").data(stars)

	circleEnter = circles.enter()
	circleEnter.append("circle")

	circles
		.attr("cx", (d) -> x_scale(+d.x))
		.attr("cy", (d) -> y_scale(+d.y))
		.attr("r", 2)
		.style("fill", "black")
		.style("stroke", "none")

	circles.exit().remove()

	console.timeEnd("render-svg")

	canvas = d3.select('.container').append("canvas")
		.attr(
			"width": "1000"
			"height": "1000"
		)
		.style(
			"width": "500px"
			"height": "500px"
		)

	console.time("render-canvas")

	ctx = canvas[0][0].getContext("2d")
	ctx.fillStyle = "#000"

	stars.forEach (d) ->
		ctx.beginPath()
		ctx.arc(hi_x_scale(+d.x), hi_y_scale(+d.y), 4, 0, 2*Math.PI, false)
		ctx.fill()

	console.timeEnd("render-canvas")

	#
	# "virtual" DOM
	#

