d3.csv "assets/data/hygdata_v3.csv", (stars) ->

	x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,500])
	y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,500])
	z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,500])

	hi_x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,1000])
	hi_y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,1000])
	hi_z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,1000])


	animationDuration = 2000

	counter = 0
	stars.forEach (s) -> s.number = counter++

	stars = stars.slice(0, 10000)

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

	animateSVG = () ->

		svg = d3.select('.container').append("svg").attr(
			"width": 500
			"height": 500
		)

		circles = svg.selectAll("circle").data(stars)
		circles.enter().append("circle")

		scheduleAnimation = () ->
			counter = svg.selectAll("circle")[0].length

			svg.selectAll("circle")
				.attr("cx", (d) -> x_scale(+d.x))
				.attr("cy", (d) -> y_scale(+d.y))
				.attr("r", 1)
				.style("fill", "black")
				.style("stroke", "none")
				.transition()
				.duration(animationDuration)
				.attr("cx", (d) -> y_scale(+d.y))
				.attr("cy", (d) -> z_scale(+d.z))
				.each('end', () ->
					d3.select(@)
					.transition()
					.duration(animationDuration)
					.attr("cx", (d) -> x_scale(+d.x))
					.attr("cy", (d) -> y_scale(+d.y))
					.each("end", (d,i) -> if +d.number == counter - 2 then scheduleAnimation())
				)

		scheduleAnimation()
		circles.exit().remove()

		loopTime = new Date
		checkFps = () ->
			currentTime = new Date
			fps = 1000 / (currentTime - loopTime)
			$('#fpsCounter').text(fps.toFixed(1) + " fps")
			loopTime = currentTime
			requestAnimationFrame(checkFps)
		checkFps()

		#end = new Date().getTime()
		#timerDisplay.text("rendering svg... #{end-begin}ms")

	animateCanvas = () ->
		#timerDisplay = d3.select('.container').append('p').text("rendering canvas...")

		canvas = d3.select('.container').append("canvas")
			.attr(
				"width": "1000"
				"height": "1000"
			)
			.style(
				"width": "500px"
				"height": "500px"
			)

		#begin = new Date().getTime()

		ctx = canvas[0][0].getContext("2d")
		ctx.fillStyle = "#000"

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': hi_x_scale(+d.x)
				'y': hi_y_scale(+d.y)
				'data': d
			)
		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		loopTime = new Date
		forward = true
		lastDiff = 0
		lastT = 0

		render = () ->
			# calculate time offset
			currentTime = new Date().getTime()
			diff = (currentTime - startTime) % animationDuration

			# check if we're done
			if diff < lastDiff
				forward = !forward

			if forward
				t = ease(diff/animationDuration)
			else
				t = 1 - ease(diff/animationDuration)

			canvas[0][0].width = 1000
			canvas[0][0].height = 1000

			starModels.forEach (d) ->
				# animate model
				d.x = d3.interpolate(hi_x_scale(+d.data.x), hi_y_scale(+d.data.y))(t)
				d.y = d3.interpolate(hi_y_scale(+d.data.y), hi_z_scale(+d.data.z))(t)

				# render
				ctx.beginPath()
				ctx.arc(d.x, d.y, 2, 0, 2*Math.PI, false)
				ctx.fill()

			lastDiff = diff

			fps = 1000 / (currentTime - loopTime)
			$('#fpsCounter').text(fps.toFixed(1) + " fps")
			loopTime = currentTime

			requestAnimationFrame(render)

		render()

		#end = new Date().getTime()
		#timerDisplay.text("rendering canvas... #{end-begin}ms")

	animateVirtualDOM = () ->
		#timerDisplay = d3.select('.container').append('p').text("creating virtual DOM...")

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

		scheduleAnimation = (forward = true) ->
			counter = virtualStars[0].length

			if forward
				virtualStars
					.transition()
					.duration(animationDuration)
					.attr("cx", (d) -> hi_y_scale(+d.y))
					.attr("cy", (d) -> hi_z_scale(+d.z))
					.each("end", (d,i) -> if +d.number == counter - 2 then scheduleAnimation(!forward))
			else
				virtualStars
					.transition()
					.duration(animationDuration)
					.attr("cx", (d) -> hi_x_scale(+d.x))
					.attr("cy", (d) -> hi_y_scale(+d.y))
					.each("end", (d,i) -> if +d.number == counter - 2 then scheduleAnimation(!forward))


		virtualStars.exit().remove()

		# draw the virtual DOM
		loopTime = new Date

		render = () ->
			c2[0][0].width = 1000
			c2[0][0].height = 1000

			ctx2 = c2[0][0].getContext("2d")
			ctx2.fillStyle = "#000"

			elements = virtualContainer.selectAll("custom.circle")

			elements.each (d) ->
				node = d3.select(@)

				ctx2.beginPath()
				ctx2.arc(node.attr('cx'), node.attr('cy'), node.attr('r'), 0, 2*Math.PI, false)
				ctx2.fill()

			currentTime = new Date
			fps = 1000 / (currentTime - loopTime)
			$('#fpsCounter').text(fps.toFixed(1) + " fps")
			loopTime = currentTime

			requestAnimationFrame(render)

		render()
		scheduleAnimation()

	animatePixi = () ->
		renderer = PIXI.autoDetectRenderer(500, 500, {resolution: 2})
		document.getElementsByClassName('container')[0].appendChild(renderer.view)

		stage = new PIXI.Stage(0xFFFFFF)
		graphics = new PIXI.Graphics

		stage.addChild(graphics)

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': x_scale(+d.x)
				'y': y_scale(+d.y)
				'data': d
			)
		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		loopTime = new Date
		forward = true
		lastDiff = 0
		lastT = 0

		$('canvas').css(
			"width": 500
			"height": 500
		)

		# init stage
		starModels.forEach (d) ->
			d.g = new PIXI.Graphics
			d.width = 2
			d.height = 2
			d.g.lineStyle(0)
			d.g.beginFill(0x000000)
			d.g.drawCircle(1,1,1)

			d.g.x = d.x
			d.g.y = d.y
			stage.addChild(d.g)

		render = () ->
			# calculate time offset
			currentTime = new Date().getTime()
			diff = (currentTime - startTime) % animationDuration

			# check if we're done
			if diff < lastDiff
				forward = !forward

			if forward
				t = ease(diff/animationDuration)
			else
				t = 1 - ease(diff/animationDuration)

			graphics.clear()
			graphics.lineStyle(0)

			starModels.forEach (d) ->
				# animate model
				d.x = d3.interpolate(x_scale(+d.data.x), y_scale(+d.data.y))(t)
				d.y = d3.interpolate(y_scale(+d.data.y), z_scale(+d.data.z))(t)

				d.g.x = d.x
				d.g.y = d.y

				# render
				# graphics.beginFill(0x000000)
				# graphics.drawCircle(d.x, d.y, 1)
				# graphics.endFill()

			renderer.render(stage)

			lastDiff = diff

			fps = 1000 / (currentTime - loopTime)
			$('#fpsCounter').text(fps.toFixed(1) + " fps")
			loopTime = currentTime

			requestAnimationFrame(render)

		render()

		#end = new Date().getTime()
		#timerDisplay.text("rendering canvas... #{end-begin}ms")


	# run tests
	# renderSVG()
	# renderCanvas()
	# renderVirtualDOM()

	#animateSVG()
	#animateCanvas()
	#animateVirtualDOM()
	animatePixi()
