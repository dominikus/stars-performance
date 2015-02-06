d3.csv "assets/data/hygdata_v3.csv", (stars) ->

	x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,500])
	y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,500])
	z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,500])

	hi_x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([0,1000])
	hi_y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([0,1000])
	hi_z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([0,1000])

	bi_x_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.x)).range([-500,500])
	bi_y_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.y)).range([-500,500])
	bi_z_scale = d3.scale.linear().domain(d3.extent(stars, (d) -> +d.z)).range([-500,500])


	animationDuration = 2000

	counter = 0
	stars.forEach (s) -> s.number = counter++

	#stars = stars.slice(0, 50000)

	# remove stars around earth?
	filteredStars = []
	stars.forEach (s) ->
		if Math.abs(+s.x) > 500 or Math.abs(+s.y) > 500 or Math.abs(+s.z) > 500
			filteredStars.push(s)

	console.log "stars: #{filteredStars.length} (from: #{stars.length})"

	#stars = filteredStars


	# init fps counter:
	stats = new Stats()
	stats.domElement.style.position = 'absolute'
	stats.domElement.style.left = '0px'
	stats.domElement.style.top = '0px'
	document.body.appendChild(stats.domElement)


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
		canvas = d3.select('.container').append("canvas")
			.attr(
				"width": "1000"
				"height": "1000"
			)
			.style(
				"width": "500px"
				"height": "500px"
			)

		ctx = canvas[0][0].getContext("2d")
		ctx.fillStyle = "#000"

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': hi_x_scale(+d.x)
				'y': hi_y_scale(+d.y)
				'data': d
				'source':
					'x': hi_x_scale(+d.x)
					'y': hi_y_scale(+d.y)
				'target':
					'x': hi_y_scale(+d.y)
					'y': hi_z_scale(+d.z)
			)

		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		forward = true
		lastDiff = 0
		lastT = 0

		render = () ->
			stats.begin()
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
			mt = 1-t

			# clear canvas
			canvas[0][0].width = 1000
			canvas[0][0].height = 1000

			starModels.forEach (d) ->
				# animate model
				d.x = t*d.source.x + mt*d.target.x
				d.y = t*d.source.y + mt*d.target.y

				# render
				ctx.beginPath()
				ctx.arc(d.x, d.y, 2, 0, 2*Math.PI, false)
				ctx.fill()

			lastDiff = diff

			requestAnimationFrame(render)

			stats.end()

		render()

	animateCanvasSprite = () ->
		canvas = d3.select('.container').append("canvas")
			.attr(
				"width": "1000"
				"height": "1000"
			)
			.style(
				"width": "500px"
				"height": "500px"
			)

		ctx = canvas[0][0].getContext("2d")
		ctx.fillStyle = "#000"

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': hi_x_scale(+d.x)
				'y': hi_y_scale(+d.y)
				'data': d
				'source':
					'x': hi_x_scale(+d.x)
					'y': hi_y_scale(+d.y)
				'target':
					'x': hi_y_scale(+d.y)
					'y': hi_z_scale(+d.z)
			)

		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		forward = true
		lastDiff = 0
		lastT = 0

		# create sprite
		tex = document.createElement("img")

		render = () ->
			stats.begin()
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
			mt = 1-t

			# clear canvas
			canvas[0][0].width = 1000
			canvas[0][0].height = 1000

			starModels.forEach (d) ->
				# animate model
				d.x = t*d.source.x + mt*d.target.x
				d.y = t*d.source.y + mt*d.target.y

				# render sprite
				ctx.drawImage(tex, d.x, d.y)

			lastDiff = diff

			requestAnimationFrame(render)

			stats.end()

		tex.onload = () ->
			render()
		tex.src = "assets/img/circle_4.png"



	animateCanvasCanvasSprite = () ->
		canvas = d3.select('.container').append("canvas")
			.attr(
				"width": "1000"
				"height": "1000"
			)
			.style(
				"width": "500px"
				"height": "500px"
			)

		ctx = canvas[0][0].getContext("2d")
		ctx.fillStyle = "#000"

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': hi_x_scale(+d.x)
				'y': hi_y_scale(+d.y)
				'data': d
				'source':
					'x': hi_x_scale(+d.x)
					'y': hi_y_scale(+d.y)
				'target':
					'x': hi_y_scale(+d.y)
					'y': hi_z_scale(+d.z)
			)

		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		forward = true
		lastDiff = 0
		lastT = 0

		# create sprite
		tex = document.createElement("canvas")
		tex.width = 4
		tex.height = 4

		render = () ->
			stats.begin()
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
			mt = 1-t

			# clear canvas
			canvas[0][0].width = 1000
			canvas[0][0].height = 1000

			starModels.forEach (d) ->
				# animate model
				d.x = t*d.source.x + mt*d.target.x
				d.y = t*d.source.y + mt*d.target.y

				# render sprite
				ctx.drawImage(tex, d.x, d.y)

			lastDiff = diff

			requestAnimationFrame(render)

			stats.end()

		texctx = tex.getContext("2d")
		texctx.fillStyle = '#000'
		texctx.beginPath()
		texctx.arc(2,2,2,0,2*Math.PI, false)
		texctx.fill()

		render()


	animateVirtualDOM = () ->
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
					.each("end", (d,i) ->
						if +d.number == counter - 2
							forward = !forward
							scheduleAnimation(forward)
					)
			else
				virtualStars
					.transition()
					.duration(animationDuration)
					.attr("cx", (d) -> hi_x_scale(+d.x))
					.attr("cy", (d) -> hi_y_scale(+d.y))
					.each("end", (d,i) ->
						if +d.number == counter - 2
							forward = !forward
							scheduleAnimation(forward)
					)

		virtualStars.exit().remove()

		# draw the virtual DOM

		render = () ->
			stats.begin()

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

			stats.end()

			requestAnimationFrame(render)

		render()
		scheduleAnimation()

	animateWebGL = () ->
		canvas = d3.select('.container').append("canvas")
			.attr(
				"width": "1000"
				"height": "1000"
			)
			.style(
				"width": "500px"
				"height": "500px"
			)

		gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
		gl.viewport.width = 1000
		gl.viewport.height = 1000

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

		gl.clearColor(1.0, 1.0, 1.0, 1.0)                    # Set clear color to white, fully opaque
		gl.enable(gl.DEPTH_TEST)                             # Enable depth testing
		gl.depthFunc(gl.LEQUAL)                               # Near things obscure far things
		gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT)

	animateTwo = () ->
		two = new Two(
			type: Two.Types.webgl
			width: 500
			height: 500
		).appendTo(document.getElementsByClassName('container')[0])

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': x_scale(+d.x)
				'y': y_scale(+d.y)
				'data': d
				'source':
					'x': x_scale(+d.x)
					'y': y_scale(+d.y)
				'target':
					'x': y_scale(+d.y)
					'y': z_scale(+d.z)
			)
		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		loopTime = new Date
		forward = true
		lastDiff = 0
		lastT = 0

		# init objects
		starModels.forEach (d) ->
			d.g = two.makeCircle(d.x, d.y, 1)
			d.g.fill = '#000000'
			d.g.stroke = 'none'

		render = () ->
			stats.begin()

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
			mt = 1-t

			starModels.forEach (d) ->
				# animate model
				d.x = t*d.source.x + mt*d.target.x
				d.y = t*d.source.y + mt*d.target.y

				d.g.translation.set(d.x, d.y)

			lastDiff = diff

			stats.end()

		two.bind('update', render).play()

		console.log two.type


	animateThree = () ->
		scene = new THREE.Scene
		camera = new THREE.OrthographicCamera(-500, 500, 500, -500, 1, 1000)
		camera.position.z = 20

		renderer = new THREE.WebGLRenderer
		renderer.setClearColor( 0xffffff, 0 )
		renderer.setSize(1000,1000)
		renderer.domElement.style.width = "500px"
		renderer.domElement.style.height = "500px"

		document.getElementsByClassName('container')[0].appendChild(renderer.domElement)

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': bi_x_scale(+d.x)
				'y': bi_y_scale(+d.y)
				'z': bi_z_scale(+d.z)
				'data': d
				'source':
					'x': bi_x_scale(+d.x)
					'y': bi_y_scale(+d.y)
				'target':
					'x': bi_y_scale(+d.y)
					'y': bi_z_scale(+d.z)
			)
		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		loopTime = new Date
		forward = true
		lastDiff = 0
		lastT = 0

		# init stage
		geometry = new THREE.CircleGeometry(2, 10)
		material = new THREE.MeshBasicMaterial({color: 0x000000})

		starModels.forEach (d) ->
			d.g = new THREE.Mesh(geometry, material)
			d.g.position.x = d.x
			d.g.position.y = d.y
			d.g.position.z = d.z

			scene.add(d.g)

		render = () ->
			stats.begin()

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
			mt = 1-t

			starModels.forEach (d) ->
				# animate model
				d.x = t*d.source.x + mt*d.target.x
				d.y = t*d.source.y + mt*d.target.y

				d.g.position.x = d.x
				d.g.position.y = d.y

			renderer.render(scene, camera)

			lastDiff = diff

			stats.end()

			requestAnimationFrame(render)

		render()

	animateThreeSprite = () ->
		scene = new THREE.Scene
		camera = new THREE.OrthographicCamera(-500, 500, 500, -500, 1, 1000)
		camera.position.z = 20

		renderer = new THREE.WebGLRenderer
		renderer.setClearColor( 0xffffff, 0 )
		renderer.setSize(1000,1000)
		renderer.domElement.style.width = "500px"
		renderer.domElement.style.height = "500px"

		document.getElementsByClassName('container')[0].appendChild(renderer.domElement)

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': bi_x_scale(+d.x)
				'y': bi_y_scale(+d.y)
				'z': bi_z_scale(+d.z)
				'data': d
				'source':
					'x': bi_x_scale(+d.x)
					'y': bi_y_scale(+d.y)
				'target':
					'x': bi_y_scale(+d.y)
					'y': bi_z_scale(+d.z)
			)
		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		loopTime = new Date
		forward = true
		lastDiff = 0
		lastT = 0

		# create sprites
		tex = THREE.ImageUtils.loadTexture("assets/img/circle_4.png")

		# create an optimized material from the texture
		material = new THREE.SpriteMaterial(
			map:tex
			color: 0x000000
			depthTest: false
			depthWrite: false
			blending: THREE.NoBlending
		)

		starModels.forEach (d) ->
			d.g = new THREE.Sprite(material)
			d.g.position.set d.x, d.y, 1
			d.g.scale.set 4,4,4

			scene.add(d.g)

		render = () ->
			stats.begin()

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
			mt = 1-t

			starModels.forEach (d) ->
				# animate model
				d.x = t*d.source.x + mt*d.target.x
				d.y = t*d.source.y + mt*d.target.y

				d.g.position.x = d.x
				d.g.position.y = d.y

			renderer.render(scene, camera)

			lastDiff = diff

			stats.end()

			requestAnimationFrame(render)

		render()

	animateThreeParticles = () ->
		scene = new THREE.Scene
		camera = new THREE.OrthographicCamera(-500, 500, 500, -500, 1, 1000)
		camera.position.z = 20

		renderer = new THREE.WebGLRenderer
		renderer.setClearColor( 0xffffff, 0 )
		renderer.setSize(1000,1000)
		renderer.domElement.style.width = "500px"
		renderer.domElement.style.height = "500px"

		document.getElementsByClassName('container')[0].appendChild(renderer.domElement)

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': bi_x_scale(+d.x)
				'y': bi_y_scale(+d.y)
				'z': bi_z_scale(+d.z)
				'data': d
				'source':
					'x': bi_x_scale(+d.x)
					'y': bi_y_scale(+d.y)
					'z': bi_z_scale(+d.z)
				'target':
					'x': bi_y_scale(+d.y)
					'y': bi_z_scale(+d.z)
					'z': bi_x_scale(+d.x)
			)
		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		loopTime = new Date
		forward = true
		lastDiff = 0
		lastT = 0

		# create particles
		particle_geometry = new THREE.Geometry

		# create a particle material
		material = new THREE.PointCloudMaterial(
			size: 4
			color: 0x000000
			map: THREE.ImageUtils.loadTexture('assets/img/circle_4.png')
			blending: THREE.AdditiveBlending
			transparent: false
		)

		starModels.forEach (d) ->
			particle_geometry.vertices.push(new THREE.Vector3(d.x, d.y, 1))

		pointcloud = new THREE.PointCloud(particle_geometry, material)
		scene.add(pointcloud)

		render = () ->
			stats.begin()

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
			mt = 1-t

			i = 0
			starModels.forEach (d) ->
				# animate model
				d.x = t*d.source.x + mt*d.target.x
				d.y = t*d.source.y + mt*d.target.y

				particle_geometry.vertices[i] = new THREE.Vector3(d.x, d.y, 1)
				i++

			particle_geometry.verticesNeedUpdate = true

			renderer.render(scene, camera)

			lastDiff = diff

			stats.end()

			requestAnimationFrame(render)

		render()


	animateFullThreeD = () ->
		scene = new THREE.Scene
		camera = new THREE.OrthographicCamera(-500, 500, 500, -500, 1, 1000)
		camera.position.z = 20

		renderer = new THREE.WebGLRenderer
		renderer.setClearColor( 0xffffff, 0 )
		renderer.setSize(1000,1000)
		renderer.domElement.style.width = "500px"
		renderer.domElement.style.height = "500px"

		document.getElementsByClassName('container')[0].appendChild(renderer.domElement)

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': bi_x_scale(+d.x)
				'y': bi_y_scale(+d.y)
				'z': bi_z_scale(+d.z)
				'data': d
				'source':
					'x': bi_x_scale(+d.x)
					'y': bi_y_scale(+d.y)
					'z': bi_z_scale(+d.z)
				'target':
					'x': bi_y_scale(+d.y)
					'y': bi_z_scale(+d.z)
					'z': bi_x_scale(+d.x)
			)
		ease = d3.ease("cubic-in-out")

		startTime = new Date().getTime()
		loopTime = new Date
		forward = true
		lastDiff = 0
		lastT = 0

		# create particles
		particle_geometry = new THREE.Geometry

		# create a particle material
		material = new THREE.PointCloudMaterial(
			size: 2
			color: 0x000000
			map: THREE.ImageUtils.loadTexture('assets/img/circle_64.png')
			transparent: false
			blending: THREE.SubtractiveBlending
		)

		starModels.forEach (d) ->
			particle_geometry.vertices.push(new THREE.Vector3(d.x, d.y, d.z))

		pointcloud = new THREE.PointCloud(particle_geometry, material)
		scene.add(pointcloud)

		render = () ->
			stats.begin()

			pointcloud.rotation.y += 0.01

			renderer.render(scene, camera)

			stats.end()

			requestAnimationFrame(render)

		render()


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
			stats.begin()

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


			renderer.render(stage)

			lastDiff = diff

			requestAnimationFrame(render)

			stats.end()

		render()

		#end = new Date().getTime()
		#timerDisplay.text("rendering canvas... #{end-begin}ms")

	animatePixiSprite = () ->
		renderer = PIXI.autoDetectRenderer(500, 500, {resolution: 2})
		document.getElementsByClassName('container')[0].appendChild(renderer.view)

		stage = new PIXI.Stage(0xFFFFFF)
		graphics = new PIXI.Graphics
		stage.addChild(graphics)

		container = new PIXI.SpriteBatch
		stage.addChild(container)

		# create model
		starModels = []
		stars.forEach (d) ->
			starModels.push(
				'x': x_scale(+d.x)
				'y': y_scale(+d.y)
				'data': d
				'source':
					'x': x_scale(+d.x)
					'y': y_scale(+d.y)
				'target':
					'x': y_scale(+d.y)
					'y': z_scale(+d.z)
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
			d.g = new PIXI.Sprite.fromImage("assets/img/circle.png")

			d.g.width = 2
			d.g.height = 2

			d.g.position.x = d.x
			d.g.position.y = d.y

			container.addChild(d.g)

		render = () ->
			stats.begin()

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
			mt = 1 -t

			starModels.forEach (d) ->
				# animate model
				d.x = t* d.source.x + mt * d.target.x
				d.y = t* d.source.y + mt * d.target.y

				d.g.position.x = d.x
				d.g.position.y = d.y

			renderer.render(stage)

			lastDiff = diff

			requestAnimationFrame(render)

			stats.end()

		render()



	# run tests
	# renderSVG()
	# renderCanvas()
	# renderVirtualDOM()

	#animateSVG()
	#animateCanvas()
	#animateCanvasSprite()
	#animateCanvasCanvasSprite()
	#animateVirtualDOM()
	#animateWebGL()
	#animateThree()
	#animateThreeSprite()
	#animateThreeParticles()
	#animateFullThreeD()
	#animatePixi()
	animatePixiSprite()
	#animateTwo()
