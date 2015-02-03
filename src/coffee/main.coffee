d3.csv "assets/data/hygdata_v3.csv", (stars) ->

	x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,500])
	y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,500])
	z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,500])

	hi_x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,1000])
	hi_y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,1000])
	hi_z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,1000])

	renderSVG = () ->
		timerDisplay = d3.select('.container').append('p').text("rendering svg...")

		svg = d3.select('.container').append("svg").attr(
			"width": 500
			"height": 500
		)

		begin = new Date().getTime()

		circles = svg.selectAll("circle").data(stars)
		circles.enter().append("circle")

		circles
			.attr("cx", (d) -> x_scale(+d.x))
			.attr("cy", (d) -> y_scale(+d.y))
			.attr("r", 1)
			.style("fill", "black")
			.style("stroke", "none")

		circles.exit().remove()

		end = new Date().getTime()
		timerDisplay.text("rendering svg... #{end-begin}ms")

	renderCanvas = () ->
		timerDisplay = d3.select('.container').append('p').text("rendering canvas...")

		canvas = d3.select('.container').append("canvas")
			.attr(
				"width": "1000"
				"height": "1000"
			)
			.style(
				"width": "500px"
				"height": "500px"
			)

		begin = new Date().getTime()

		ctx = canvas[0][0].getContext("2d")
		ctx.fillStyle = "#000"

		stars.forEach (d) ->
			ctx.beginPath()
			ctx.arc(hi_x_scale(+d.x), hi_y_scale(+d.y), 2, 0, 2*Math.PI, false)
			ctx.fill()

		end = new Date().getTime()
		timerDisplay.text("rendering canvas... #{end-begin}ms")

	#
	# "virtual" DOM
	# based on http://bl.ocks.org/mbostock/1276463

	# Register the "custom" namespace prefix for our custom elements.
	#d3.ns.prefix.custom = "http://github.com/mbostock/d3/examples/dom"
	renderVirtualDOM = () ->
		timerDisplay = d3.select('.container').append('p').text("creating virtual DOM...")

		virtualContainer = d3.select(document.createElement("custom"))
		virtual = virtualContainer.append("custom")
			.classed("sketch", true)
			.attr(
				"width": 1000
				"height": 1000
			)

		c2 = d3.select('.container').append("canvas")
			.attr(
				"width": "1000"
				"height": "1000"
			)
			.style(
				"width": "500px"
				"height": "500px"
			)

		begin = new Date()

		virtualStars = virtual.selectAll("custom.circle").data(stars)
		virtualStars.enter().append("custom").classed("circle", true)

		virtualStars
			.attr("cx", (d) -> hi_x_scale(+d.x))
			.attr("cy", (d) -> hi_y_scale(+d.y))
			.attr("r", 2)
			.style("fill", "black")
			.style("stroke", "none")

		virtualStars.exit().remove()

		end = new Date().getTime()
		timerDisplay.text("creating virtual DOM... #{end-begin}ms")

		timerDisplay = d3.select('.container').append('p').text("rendering virtual DOM...")

		begin = new Date()

		# draw the virtual DOM
		ctx2 = c2[0][0].getContext("2d")
		ctx2.fillStyle = "#000"

		elements = virtualContainer.selectAll("custom.circle")

		elements.each (d) ->
			node = d3.select(@)

			ctx2.beginPath()
			ctx2.arc(node.attr('cx'), node.attr('cy'), node.attr('r'), 0, 2*Math.PI, false)
			ctx2.fill()

		end = new Date().getTime()
		timerDisplay.text("rendering virtual DOM... #{end-begin}ms")

	renderSVG()
	renderCanvas()
	renderVirtualDOM()
