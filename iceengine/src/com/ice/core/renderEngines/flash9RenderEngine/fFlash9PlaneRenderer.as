package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports
	  
		/**
		* This class renders fPlanes
		* @private
		*/
		public class fFlash9PlaneRenderer extends fFlash9ElementRenderer {
		
			// Private properties
			private var origWidth:Number
			private var origHeight:Number
			private var	cacheTimer:Timer

			public var scrollR:Rectangle							 // Scroll Rectangle for this plane, to optimize viewing areas.
			public var planeDeform:Matrix						   // Transformation matrix for this plane that sets the proper perspective
			public var clipPolygon:fPolygon						 // This is the shape polygon with perspective applied

			// Cache for this plane, to bake a bitmap of it when it doesn't change
			public var finalBitmapMask:Shape
			public var finalBitmap:Bitmap
			private var finalBitmapData:BitmapData

			// Light related data structures
			protected var lightC:Sprite								 // All lights
			private var environmentC:Shape				     // Global
			private var black:Shape				  				   // No light
			private var diffuseData:BitmapData			 	 // Diffuse map
			private var diffuse:Bitmap					 	 		 // Diffuse map
			private var simpleHolesC:Sprite				    

			private var spriteToDraw:Sprite
			public var baseContainer:DisplayObjectContainer
			private var behind:DisplayObjectContainer  // Elements behind the wall will added here
			private var infront:DisplayObjectContainer // Elements in front of the wall will added here
			
			private var bumpMap:BumpMap								 // Bump maps
			private var bumpMapData:BitmapData
			private var displacer:DisplacementMapFilter
			private var tMatrix:Matrix
			private var tMatrixB:Matrix
			private var firstBump:Boolean = true
			
			private var anyClosedHole:Boolean
			private var canBeSmoothed:Boolean

			public var deformedSimpleShadowsLayer:Sprite
			public var simpleShadowsLayer:Sprite		   // Simple shadows go here
			public var lightClips:Array                // List of containers used to represent lights (interior)
			public var lightMasks:Array                // List of containers representing the light mask / shape
			public var lightShadowsPl:Array            // Containers where geometry shadows are drawn
			public var lightShadowsObj:Array           // Containers where geometry shadows are drawn
			public var lightBumps:Array           	   // Bump map layers
			public var zIndex:Number = 0						   // zIndex
			public var lightStatuses:Array      			 // References to light status
			
			// Occlusion related
			private var occlusionCount:Number = 0
			private var occlusionLayer:Sprite
			private var occlusionSpots:Object

			// Constructor
			function fFlash9PlaneRenderer(rEngine:fFlash9RenderEngine,element:fPlane,width:Number,height:Number,spriteToDraw:Sprite,spriteToShowHide:fElementContainer):void {
				
				 // Previous
				 super(rEngine,element,null,spriteToShowHide)

				 // Properties
			   this.origWidth = width
			   this.origHeight = height
			   this.spriteToDraw = spriteToDraw

         // Listen to changes in material
         element.addEventListener(fPlane.NEWMATERIAL,this.newMaterial,false,0,true)
         
 			   // This is the polygon that is drawn to represent this plane, with perspective applied
				 this.clipPolygon = new fPolygon()
				 var contours:Array = element.shapePolygon.contours

				 // Process shape vertexes
				 if(element is fFloor) {
				 		
				 		var cl:int = contours.length
				 		for(var k:int=0;k<cl;k++) {
				 			var c:Array = contours[k]
				 			var projectedShape:Array = new Array
				 			var cl2:int = c.length
				 			for(var k2:int=0;k2<cl2;k2++) projectedShape[k2] = fScene.translateCoords(fEngine.RENDER_FINETUNE_3+c[k2].x*fEngine.RENDER_FINETUNE_1+c[k2].y*fEngine.RENDER_FINETUNE_2,fEngine.RENDER_FINETUNE_3+c[k2].y*fEngine.RENDER_FINETUNE_1+c[k2].x*fEngine.RENDER_FINETUNE_2,0)
				 			this.clipPolygon.contours[this.clipPolygon.contours.length] = projectedShape
				 		}
				 		
				 } else if(element is fWall) {

 				 		var w:fWall = element as fWall
				 	  if(w.vertical) {
				 	  	cl = contours.length
				 			for(k=0;k<cl;k++) {
				 				c = contours[k]
				 				projectedShape = new Array
				 				cl2 = c.length
				 				for(k2=0;k2<cl2;k2++) projectedShape[k2] = fScene.translateCoords(0,fEngine.RENDER_FINETUNE_3+c[k2].x*fEngine.RENDER_FINETUNE_1+c[k2].y*fEngine.RENDER_FINETUNE_2,fEngine.RENDER_FINETUNE_3+c[k2].y*fEngine.RENDER_FINETUNE_1+c[k2].x*fEngine.RENDER_FINETUNE_2)
				 				this.clipPolygon.contours[this.clipPolygon.contours.length] = projectedShape
				 			}
				 	  } else {
				 	  	cl = contours.length
				 			for(k=0;k<cl;k++) {
				 				c = contours[k]
				 				projectedShape = new Array
				 				cl2 = c.length
				 				for(k2=0;k2<cl2;k2++) projectedShape[k2] = fScene.translateCoords(-0.0+c[k2].x*fEngine.RENDER_FINETUNE_1+c[k2].y*fEngine.RENDER_FINETUNE_2,0,-0.0+c[k2].y*fEngine.RENDER_FINETUNE_1+c[k2].x*fEngine.RENDER_FINETUNE_2)
				 				this.clipPolygon.contours[this.clipPolygon.contours.length] = projectedShape
				 			}
				 	  }
				 }
         

			}
			
			/**
			* This method creates the assets for this plane. It is only called the first time the element scrolls into view
			*/
			public override function createAssets():void {
				
 			   // Retrieve diffuse map
 			   var element:fPlane = this.element as fPlane
 			   
 			   var d:DisplayObject = element.material.getDiffuse(element,this.origWidth,this.origHeight,true)
 			   if(d) {
 			   	 this.diffuseData = new BitmapData(element.bounds2d.width,element.bounds2d.height,true,0)
				 	 var oMatrix:Matrix = this.planeDeform.clone()
				 	 oMatrix.translate(0,-Math.round(element.bounds2d.y))
				 	 this.diffuseData.draw(d,oMatrix,null,null,null,true)
 			   	 this.diffuse = new Bitmap(this.diffuseData,"never",true)
 			   	 this.diffuse.y = Math.round(element.bounds2d.y)
 			   	 this.container.visible = true
 			   } else {
				 	 this.diffuseData = null
 			   	 this.diffuse = new Bitmap()
 			   	 this.container.visible = false
 			   }

				 // This is the Sprite where all light layers are generated.
				 // This Sprite is attached to the sprite that is visible onscreen
				 this.baseContainer = objectPool.getInstanceOf(Sprite) as Sprite
				 this.behind = objectPool.getInstanceOf(Sprite) as Sprite
				 this.infront = objectPool.getInstanceOf(Sprite) as Sprite
			   this.behind.cacheAsBitmap = true
			   this.infront.cacheAsBitmap = true
			   
			   this.baseContainer.addChild(this.behind)
			   this.baseContainer.addChild(this.diffuse)
			   this.baseContainer.addChild(this.infront)
			   
			   this.finalBitmap = new Bitmap(null,"never",true)
			   this.finalBitmapMask = new Shape()
				 this.finalBitmapMask.graphics.clear()
				 this.finalBitmapMask.graphics.beginFill(0xFF0000,1)
				 this.clipPolygon.draw(this.finalBitmapMask.graphics)
				 this.spriteToDraw.addChild(this.finalBitmapMask)
				 this.finalBitmapMask.graphics.endFill()
				 this.finalBitmap.mask = this.finalBitmapMask

			   // LIGHT
			   this.lightClips = new Array  
			   this.lightStatuses = new Array   		
			   this.lightMasks = new Array   		
			   this.lightShadowsObj = new Array   		
			   this.lightShadowsPl = new Array   		
			   this.lightBumps = new Array   		
			   this.lightC = objectPool.getInstanceOf(Sprite) as Sprite
			   this.simpleHolesC = objectPool.getInstanceOf(Sprite) as Sprite
				 this.black = new Shape()
			   this.environmentC = new Shape()

			   this.baseContainer.addChild(this.lightC)
			   this.lightC.addChild(this.black)
			   this.lightC.addChild(this.environmentC)
			   this.lightC.blendMode = BlendMode.MULTIPLY
 			   this.lightC.mouseEnabled = false
 			   this.lightC.mouseChildren = false
				 this.baseContainer.mouseEnabled = false

				 // Object shadows with qualities other than fShadowQuality.BEST will be drawn here instead of into each lights's ERASE layer
				 this.deformedSimpleShadowsLayer = objectPool.getInstanceOf(Sprite) as Sprite
				 this.deformedSimpleShadowsLayer.mouseEnabled = false
				 this.deformedSimpleShadowsLayer.mouseChildren = false
				 this.deformedSimpleShadowsLayer.transform.matrix = this.planeDeform
				 this.simpleShadowsLayer = objectPool.getInstanceOf(Sprite) as Sprite
				 this.simpleShadowsLayer.scrollRect = this.scrollR
				 this.spriteToDraw.addChild(this.deformedSimpleShadowsLayer)
				 this.deformedSimpleShadowsLayer.addChild(this.simpleShadowsLayer)

				 // Occlusion
				 this.occlusionLayer = objectPool.getInstanceOf(Sprite) as Sprite
				 this.occlusionLayer.mouseEnabled = false
			   this.occlusionLayer.blendMode = BlendMode.ERASE
				 this.occlusionLayer.transform.matrix = this.planeDeform
				 this.occlusionLayer.scrollRect = this.scrollR
				 this.occlusionSpots = new Object
				 if(element is fWall) {
				 		var w:fWall = element as fWall
				 		this.simpleShadowsLayer.y-=w.pixelHeight
				 		this.occlusionLayer.y-=w.pixelHeight*fEngine.DEFORMATION
				 }

				 // Holes
			   this.processHoles(element)
				 this.element.addEventListener(fRenderableElement.SHOW,this.redrawShadowsOnShowHide,false,0,true)
				 this.element.addEventListener(fRenderableElement.HIDE,this.redrawShadowsOnShowHide,false,0,true)
			   
			   // Cache as Bitmap with Timer cache
			   // The cache is disabled while the Plane is being modified and a timer is set to re-enable it
			   // if the plane doesn't change in a while
         this.undoCache()
				 this.cacheTimer = new Timer(100,1)
         this.cacheTimer.addEventListener(TimerEvent.TIMER, this.cacheTimerListener,false,0,true)
         this.cacheTimer.start()

				
			}		
			
			/**
			* This method destroys the assets for this element. It is only called when the element in hidden and fEngine.conserveMemory is set to true
			*/
			public override function destroyAssets():void {

				// Cache
				this.undoCache()
        if(this.cacheTimer) {
        	this.cacheTimer.removeEventListener(TimerEvent.TIMER, this.cacheTimerListener)
       		this.cacheTimer.stop()
       		this.cacheTimer = null
       	}
			  
			  // Holes
				this.element.removeEventListener(fRenderableElement.SHOW,this.redrawShadowsOnShowHide)
				this.element.removeEventListener(fRenderableElement.HIDE,this.redrawShadowsOnShowHide)
			  var element:fPlane = this.element as fPlane
			  var hl:int = element.holes.length
			  for(var i:int=0;i<hl;i++) {
   					element.holes[i].removeEventListener(fHole.OPEN,this.openHole)
				 		element.holes[i].removeEventListener(fHole.CLOSE,this.closeHole)
				 		if(!element.holes[i].open && element.holes[i].block && this.behind) this.behind.removeChild(element.holes[i].block)				 		 	
			  }

				// Maps
				this.bumpMap = null
				this.diffuse = null
				if(this.diffuseData) this.diffuseData.dispose()
				this.diffuseData = null
				if(this.bumpMapData) this.bumpMapData.dispose()
				this.displacer = null
				this.tMatrix = null
				this.tMatrixB = null
				
				// Shadows
				this.resetShadows()

				// Lights
				if(this.lightMasks) {
					var il:int = this.lightMasks.length 
					for(i=0;i<il;i++) {
						if(this.lightMasks[i]) this.lightMasks[i].graphics.clear()
						objectPool.returnInstance(this.lightMasks[i])
						delete this.lightMasks[i]
					}
					this.lightMasks = null
			  }

				if(this.lightShadowsObj) {
					il = this.lightShadowsObj.length
					for(i=0;i<il;i++) {
						fFlash9RenderEngine.recursiveDelete(this.lightShadowsObj[i])
						objectPool.returnInstance(this.lightShadowsObj[i])
						delete this.lightShadowsObj[i]
					}
					this.lightShadowsObj = null
				}
				
				if(this.lightShadowsPl) {
					il = this.lightShadowsPl.length
					for(i=0;i<il;i++) {
						fFlash9RenderEngine.recursiveDelete(this.lightShadowsPl[i])
						objectPool.returnInstance(this.lightShadowsPl[i])
						delete this.lightShadowsPl[i]
					}
					this.lightShadowsPl = null
				}
				
				if(this.lightBumps) {
					il = this.lightBumps.length
					for(i=0;i<il;i++) {
						fFlash9RenderEngine.recursiveDelete(this.lightBumps[i])
						objectPool.returnInstance(this.lightBumps[i])
						delete this.lightBumps[i]
					}
					this.lightBumps = null
				}
				
				if(this.lightClips) {
					il = this.lightClips.length
					for(i=0;i<il;i++) {
						objectPool.returnInstance(this.lightClips[i])
						fFlash9RenderEngine.recursiveDelete(this.lightClips[i])
						delete this.lightClips[i]
					}
					this.lightClips = null
				}
				
				for(var j in this.lightStatuses) {
					var light:fLight =this.lightStatuses[j].light
					if(light) {
		 		  	light.removeEventListener(fLight.INTENSITYCHANGE,this.processLightIntensityChange)
		 		  	light.removeEventListener(fLight.COLORCHANGE,this.processLightIntensityChange)
		 		  	light.removeEventListener(fLight.DECAYCHANGE,this.processLightIntensityChange)
						delete this.lightStatuses[j]
					}
				}
				this.lightStatuses = null

				// Occlusion
				for(j in this.occlusionSpots) {
					fFlash9RenderEngine.recursiveDelete(this.occlusionSpots[j])
					delete this.occlusionSpots[j]
				}
				this.occlusionSpots = null

				fFlash9RenderEngine.recursiveDelete(this.deformedSimpleShadowsLayer)
				fFlash9RenderEngine.recursiveDelete(this.simpleShadowsLayer)
				fFlash9RenderEngine.recursiveDelete(this.occlusionLayer)
				this.deformedSimpleShadowsLayer = null
				this.simpleShadowsLayer = null
				this.occlusionLayer = null

				// Return to object pool
				fFlash9RenderEngine.recursiveDelete(this.baseContainer)
				objectPool.returnInstance(this.baseContainer)
				objectPool.returnInstance(this.behind)
				objectPool.returnInstance(this.infront)
			  objectPool.returnInstance(this.lightC)
			  objectPool.returnInstance(this.simpleHolesC)
				objectPool.returnInstance(this.deformedSimpleShadowsLayer)
				objectPool.returnInstance(this.simpleShadowsLayer)
				objectPool.returnInstance(this.occlusionLayer)

				// References
				this.behind = null
				this.infront = null
			  if(this.finalBitmap) this.finalBitmap.mask = null
			  if(this.finalBitmapMask) this.finalBitmapMask.graphics.clear()
			  this.finalBitmapMask = null
			  
			  this.finalBitmap = null
				if(this.finalBitmapData) this.finalBitmapData.dispose()
				this.finalBitmapData = null
			  this.lightC = null
			  this.simpleHolesC = null
				this.black = null
			  this.environmentC = null
				this.baseContainer = null

			}
			
			// PLANE CACHE
			//////////////
			
			/**
			* Cache on
			*/
			public function doCache():void {
				
				 // Already cached
				 if(this.finalBitmap.parent || this.anyClosedHole) return
				 
				 // Soft shadows on
				 if(fEngine.softShadows>0 && this.canBeSmoothed) {
				 		var blur:BlurFilter = new BlurFilter(fEngine.softShadows,fEngine.softShadows)
				 		var sl:int = this.lightShadowsPl.length
				 		for(var i:int=0;i<sl;i++) {
								if(this.lightShadowsPl[i]) this.lightShadowsPl[i].filters = [blur]
				 		}
				 }
				 
				 // New cache
				 if(this.finalBitmapData) this.finalBitmapData.dispose()
			   this.finalBitmapData = new BitmapData(this.element.bounds2d.width,this.element.bounds2d.height,true,0)
				 
				 // Draw
				 var oMatrix:Matrix = new Matrix()
				 oMatrix.translate(0,-this.diffuse.y)
				 this.finalBitmapData.draw(this.baseContainer, oMatrix,null,null,null,true )
				 
				 // Display
				 this.finalBitmap.bitmapData = this.finalBitmapData
				 this.finalBitmap.y = this.diffuse.y
			   this.spriteToDraw.addChildAt(this.finalBitmap,0)
			   
			   try { this.spriteToDraw.removeChild(this.baseContainer) } catch(e:Error) {}

         this.container.cacheAsBitmap = true

			}
			
			/**
			* Cache off
			*/
			public function undoCache(autoStart:Boolean = false):void {
		   		
		   	 if(!this.diffuse) return

				 // Soft shadows off
				 var sl:int = this.lightShadowsPl.length
				 for(var i:int=0;i<sl;i++) {
						if(this.lightShadowsPl[i]) this.lightShadowsPl[i].filters = []
				 }

		   	 var p:fPlane = this.element as fPlane
				 if(this.finalBitmapData) this.finalBitmapData.dispose()
			   this.spriteToDraw.addChildAt(this.baseContainer,0)
			   try { this.spriteToDraw.removeChild(this.finalBitmap) } catch(e:Error) {}
         		
         this.container.cacheAsBitmap = false

         if(autoStart) this.cacheTimer.start()
         
			}

			/**
			* This listener sets the cache of a Plane back to true when it doesn't change for a while
			*/
			public function cacheTimerListener(event:TimerEvent):void {
       	 this.doCache()
			}

			// REACT TO CHANGES IN SCENE
			////////////////////////////

			/**
			* Renders element visible
			*/
			public override function show():void {
			   this.containerParent.addChild(this.container)
			}
			
			/**
			* Renders element invisible
			*/
			public override function hide():void {
			   try { this.containerParent.removeChild(this.container) } catch(e:Error) {}
			}

			// This redraws shadows when the plane shows/hides
			private function redrawShadowsOnShowHide(e:Event=null):void {
				 var ll:int = this.scene.lights.length
				 for(var j:int=0;j<ll;j++) {
					var light:fLight = this.scene.lights[j]
					if(light && !light.removed && this.element.distanceTo(light.x,light.y,light.z)<light.size) light.render()
				 }
			}
			

			/** 
			* Sets global light
			*/
			public override function renderGlobalLight(light:fGlobalLight):void {
				
				 this.black.graphics.clear()
				 this.black.graphics.beginFill(0x000000,1)
				 this.clipPolygon.draw(this.black.graphics)
				 this.black.graphics.endFill()

				 this.environmentC.graphics.clear()
				 this.environmentC.graphics.beginFill(light.hexcolor,1)
				 this.clipPolygon.draw(this.environmentC.graphics)
				 this.environmentC.graphics.endFill()

				 // Environment
				 this.environmentC.alpha = light.intensity/100
				 this.simpleShadowsLayer.alpha = 1-this.environmentC.alpha

			}
	
			/** 
			* Listens for changes in global light intensity
			*/
			public override function processGlobalIntensityChange(light:fGlobalLight):void {
				
					 this.environmentC.alpha = light.intensity/100
					 this.simpleShadowsLayer.alpha = 1-this.environmentC.alpha
					 this.undoCache(true)
			}

			/**
			* Global light changes color
			*/
			public override function processGlobalColorChange(light:fGlobalLight):void {
					 this.renderGlobalLight(light)
					 this.undoCache(true)
			}

			/**
			* Listens to changes of a light's intensity
			*/
			private function processLightIntensityChange(event:Event):void {
				  var light:fLight = event.target as fLight
					this.redrawLight(light)
					this.undoCache(true)
			}

			/**
			* This listens to the plane receiving a new material
			*/
			private function newMaterial(evt:fNewMaterialEvent):void {
			
			 	 var p:fPlane = evt.target as fPlane

			 	 // Clear projection caches if needed
				 if(fFlash9FloorRenderer.floorProjectionCache.fl==p) fFlash9FloorRenderer.floorProjectionCache.fl = null
				 for(var i in fFlash9FloorRenderer.wallProjectionCache) {
				 	if(int(i.substring(i.indexOf("_")+1))==p.uniqueId) fFlash9FloorRenderer.wallProjectionCache=null
				 }

			 	 // Diffuse
			 	 var d:DisplayObject = p.material.getDiffuse(element,evt.width,evt.height,true)
			 	 if(d) {
 			   	 var nDiffuseData:BitmapData = new BitmapData(element.bounds2d.width,element.bounds2d.height,true,0)
				 	 var oMatrix:Matrix = this.planeDeform.clone()
				 	 oMatrix.translate(0,-Math.round(p.bounds2d.y))
				 	 nDiffuseData.draw(d,oMatrix)
	 			   this.diffuse.bitmapData = nDiffuseData
 				   this.diffuseData.dispose()
 			   	 this.diffuseData = nDiffuseData
 			   	 this.container.visible = true
				 } else {
 			   	 this.diffuse.bitmapData = new BitmapData(1,1,true,0)
 			   	 this.diffuseData = null
 			   	 this.container.visible = false
				 }
 			   
 			   // Holes
 			   while(this.behind.numChildren>0) this.behind.removeChild(this.behind.getChildAt(0))
	   		 this.processHoles(p)
	   		 if(this.canBeSmoothed) for(var n in this.lightShadowsPl) this.lightShadowsPl[n].blendMode = BlendMode.NORMAL
				 else for(n in this.lightShadowsPl) this.lightShadowsPl[n].blendMode = BlendMode.ERASE
				 
	   		 // Redraw lights
	   		 if(this.scene.IAmBeingRendered) {
	   		 	this.redrawLights()
	   		 	this.undoCache(true)
	   		 }
			
			}

			/** 
			*	Shows light
			*/
			private function showLight(light:fLight):void {
			
			   var lClip:Sprite = this.lightClips[light.uniqueId]
			   this.lightC.addChild(lClip)
			 	 this.lightStatuses[light.uniqueId].hidden = false
				
			}
			
			/** 
			*	Hides light
			*/
			private function hideLight(light:fLight):void {
			
			   var lClip:Sprite = this.lightClips[light.uniqueId]
			   this.lightC.removeChild(lClip)
			 	 this.lightStatuses[light.uniqueId].hidden = true
			
			}

			// HOLE MANAGEMENT
			//////////////////

			/**
			* This processes new hole definitions for this plane
			*/
			private function processHoles(element:fPlane):void {
				
			   this.deformedSimpleShadowsLayer.blendMode = BlendMode.NORMAL
			   this.simpleHolesC.blendMode = BlendMode.NORMAL
			   try {
			   		this.deformedSimpleShadowsLayer.removeChild(this.simpleHolesC)
	   		 } catch(e:Error) {}

			   this.anyClosedHole = false
			   var hl:int = element.holes.length
			   for(var i:int=0;i<hl;i++) {
			   		 var hole:fHole = element.holes[i]
   					 hole.addEventListener(fHole.OPEN,this.openHole,false,0,true)
				 		 hole.addEventListener(fHole.CLOSE,this.closeHole,false,0,true)
				 		 if(hole.block) {

		 		 				hole.block.transform.matrix = this.planeDeform
				 		 		if(!hole.open) {
			 		 				this.behind.addChild(hole.block)
		   						this.anyClosedHole = true
				 		 		}

				 		 	 	if(element is fFloor) {
				 		 	 		var p:Point =	fScene.translateCoords(hole.bounds.xrel,hole.bounds.yrel,0)
				 		 		}
								else if(this.element is fWall) {
			 	  				if((this.element as fWall).vertical) {
										p =	fScene.translateCoords(0,hole.bounds.xrel,this.origHeight-hole.bounds.yrel)
			 	  				} else {
										p =	fScene.translateCoords(hole.bounds.xrel,0,this.origHeight-hole.bounds.yrel)
									}
								}
				 		 		hole.block.x = p.x
				 		 		hole.block.y = p.y
				 		 }
			   }
				 this.redrawHoles()
				 
			   if(element.holes.length>0) {
			   		this.deformedSimpleShadowsLayer.addChild(this.simpleHolesC)
			   		//this.deformedSimpleShadowsLayer.blendMode = BlendMode.LAYER
			   		this.simpleHolesC.blendMode = BlendMode.ERASE
				 		this.simpleHolesC.mouseEnabled = false
				 		this.simpleHolesC.mouseChildren = false
				 		
				 } 

				 this.canBeSmoothed = (element.shapePolygon.contours.length==1 && element.holes.length==0)

			}

			/**
			* This method listens to holes being opened
			*/
			private function openHole(event:Event):void {
				
				try {
					var hole:fHole = event.target as fHole
					if(hole.block) {
						this.behind.removeChild(hole.block)
				 		this.anyClosedHole = false
					  var p:fPlane = this.element as fPlane
					  var pl:int = p.holes.length
			   		for(var i:int=0;i<pl;i++) {
				 				 if(!p.holes[i].open && p.holes[i].block) {
			   						this.anyClosedHole = true
				 				 }
			   		}						
						if(this.scene.IAmBeingRendered) this.redrawLights()
					}
				} catch(e:Error) {
					
				}

			}

			/**
			* This method listens to holes beign closed
			*/
			private function closeHole(event:Event):void {
				
				try {
					var hole:fHole = event.target as fHole
					if(hole.block) {
						this.behind.addChild(hole.block)
					  var p:fPlane = this.element as fPlane
					  var pl:int = p.holes.length
			   		for(var i:int=0;i<pl;i++) {
				 				 if(!p.holes[i].open && p.holes[i].block) {
			   						this.anyClosedHole = true
				 				 }
			   		}						
						if(this.scene.IAmBeingRendered) this.redrawLights()
					}
				} catch(e:Error) {
					
				}

			}

			/**
			* Redraws all lights when a hole has been opened/closed
			*/
			private function redrawLights():void {
					this.redrawHoles()
					this.renderGlobalLight(this.element.scene.environmentLight)
					this.redrawShadowsOnShowHide()
				  for(var j in this.lightStatuses) {
						if(!this.lightStatuses[j].hidden) {
							var light:fLight = this.lightStatuses[j].light
							if(light && !light.removed) this.redrawLight(light)
						}
					}

			}

			/**
			* Draws holes into material
			*/
			private function redrawHoles():void {
				
 				 var holes:Array = (this.element as fPlane).holes
				 
				 // Update holes in clipping polygon
				 this.clipPolygon.holes = new Array
				 
 				 var hl:int = holes.length
 				 for(var h:int=0;h<hl;h++) {

					 	if(holes[h].open) {
					 		var hole:fPlaneBounds = holes[h].bounds
						 	var k:int = this.clipPolygon.holes.length
						 	this.clipPolygon.holes[k] = new Array
						 	var tempA:Array = this.clipPolygon.holes[k]
							
				 	  	if(this.element is fFloor) {
				 	  		var p:Point =	fScene.translateCoords(hole.xrel,hole.yrel,0)
				 	  	 	tempA.unshift(p)
				 	  		p =	fScene.translateCoords(hole.xrel+hole.width,hole.yrel,0)
				 	  	 	tempA.unshift(p)
			 	  			p =	fScene.translateCoords(hole.xrel+hole.width,hole.yrel+hole.height,0)
				 	  	 	tempA.unshift(p)
			 	  			p =	fScene.translateCoords(hole.xrel,hole.yrel+hole.height,0)
				 	  	 	tempA.unshift(p)
			 	  			p =	fScene.translateCoords(hole.xrel,hole.yrel,0)
				 	  	 	tempA.unshift(p)
			 	  		}
				 	  	if(this.element is fWall) {
			 	  			if((this.element as fWall).vertical) {
									p =	fScene.translateCoords(0,hole.xrel,this.origHeight-hole.yrel)
				 	  	 		tempA.unshift(p)
				 	  			p =	fScene.translateCoords(0,hole.xrel+hole.width,this.origHeight-hole.yrel)
				 	  	 		tempA.unshift(p)
			 	  				p =	fScene.translateCoords(0,hole.xrel+hole.width,this.origHeight-hole.yrel-hole.height)
				 	  	 		tempA.unshift(p)
			 	  				p =	fScene.translateCoords(0,hole.xrel,this.origHeight-hole.yrel-hole.height)
				 	  	 		tempA.unshift(p)
			 	  				p =	fScene.translateCoords(0,hole.xrel,this.origHeight-hole.yrel)
				 	  	 		tempA.unshift(p)			 	  				
			 	  			} else {
									p =	fScene.translateCoords(hole.xrel,0,this.origHeight-hole.yrel)
				 	  	 		tempA.unshift(p)
				 	  			p =	fScene.translateCoords(hole.xrel+hole.width,0,this.origHeight-hole.yrel)
				 	  	 		tempA.unshift(p)
			 	  				p =	fScene.translateCoords(hole.xrel+hole.width,0,this.origHeight-hole.yrel-hole.height)
				 	  	 		tempA.unshift(p)
			 	  				p =	fScene.translateCoords(hole.xrel,0,this.origHeight-hole.yrel-hole.height)
				 	  	 		tempA.unshift(p)
			 	  				p =	fScene.translateCoords(hole.xrel,0,this.origHeight-hole.yrel)
				 	  	 		tempA.unshift(p)			 	  				
			 	  			}
			 	  		}
			 	  		
			 	  	}
	       }

				 // Erases holes from simple shadows layers
				 this.simpleHolesC.graphics.clear()
				 hl = holes.length
 				 for(h=0;h<hl;h++) {

					 	if(holes[h].open) {
						 	hole = holes[h].bounds
							this.simpleHolesC.graphics.beginFill(0x000000,1)
				 	  	this.simpleHolesC.graphics.moveTo(hole.xrel,hole.yrel-this.origHeight)
				 	  	this.simpleHolesC.graphics.lineTo(hole.xrel+hole.width,hole.yrel-this.origHeight)
			 	  		this.simpleHolesC.graphics.lineTo(hole.xrel+hole.width,hole.yrel+hole.height-this.origHeight)
			 	  		this.simpleHolesC.graphics.lineTo(hole.xrel,hole.yrel+hole.height-this.origHeight)
			 	  		this.simpleHolesC.graphics.lineTo(hole.xrel,hole.yrel-this.origHeight)
			 	  		this.simpleHolesC.graphics.endFill()
			 	  	}
	       }


			}	

			// LIGHT RENDER CYCLE
			/////////////////////

			/**
			* Starts render process
			*/
			public override function renderStart(light:fLight):void {
			
			   // Create light ?
			   if(!this.lightStatuses[light.uniqueId]) this.lightStatuses[light.uniqueId] = new fLightStatus(this.element as fPlane,light)
			   var lightStatus:fLightStatus = this.lightStatuses[light.uniqueId]
				
			   if(!lightStatus.created) {
			      lightStatus.created = true
			      this.addOmniLight(lightStatus)
			      this.lightIn(light)
			   }
			   
			   // Disable cache. Once the render is finished, a timeout is set that will
			   // restore cache if the object doesn't change for a few seconds.
       	 this.cacheTimer.stop()
       	 this.undoCache()
       	 //this.lightBumps[light.uniqueId].cacheAsBitmap = true
       	 
       	 this.lightShadowsPl[light.uniqueId].graphics.clear()
			  
			}

			/**
			* Creates masks and containers for a new light, and updates lightStatus
			*/
			public function addOmniLight(lightStatus:fLightStatus):void {
			
			   var light:fLight = lightStatus.light
			   lightStatus.lightZ = -2000
			
			   // Create container
			   var light_c:Sprite = objectPool.getInstanceOf(Sprite) as Sprite
			   this.lightClips[light.uniqueId] = light_c
				 light_c.blendMode = BlendMode.ADD

				 // Create layer
				 var lay:Sprite = objectPool.getInstanceOf(Sprite) as Sprite
				 light_c.addChild(lay)
				 this.lightBumps[light.uniqueId] = lay
				 
				 // Create mask
				 var msk:Shape = new Shape()
				 lay.addChild(msk)
			   this.lightMasks[light.uniqueId] = msk
				 
				 // Create plane shadow container
			   var shd:Sprite = objectPool.getInstanceOf(Sprite) as Sprite
			   lay.addChild(shd)
			   this.lightShadowsPl[light.uniqueId] = shd
				 var element:fPlane = this.element as fPlane
			   if(!this.canBeSmoothed) shd.blendMode = BlendMode.ERASE

				 // Create object shadow container
			   shd = objectPool.getInstanceOf(Sprite) as Sprite
			   lay.addChild(shd)
			   shd.blendMode = BlendMode.ERASE
			   shd.transform.matrix = this.planeDeform

			   var shd2:Sprite = objectPool.getInstanceOf(Sprite) as Sprite
			   this.lightShadowsObj[light.uniqueId] = shd2
				 shd2.scrollRect = this.scrollR
				 shd.addChild(shd2)

				 if(element is fWall) {
				 		var w:fWall = element as fWall
				 		shd2.y-=w.pixelHeight
				 }

			
			}
			
			/**
			* Redraws light to be at a new distante of plane
			*/
			public function setLightDistance(light:fLight,distance:Number,deform:Number=1):void {
			
			   if(light.size!=Infinity) {
						this.lightStatuses[light.uniqueId].localScale =	Math.cos(Math.asin((distance)/light.size))*deform
			   }
			}

			/** 
			* Sets light to be a a new position in the plane
			*/
			public function setLightCoordinates(light:fLight,p:Point):void {
				this.lightStatuses[light.uniqueId].localPos =	p
			}
			
			/** 
			* Redraws a light
			*/
			public function redrawLight(light:fLight):void {
				
	       if(!this.lightStatuses || !this.lightStatuses[light.uniqueId]) return
	       
	       var lClip:Shape = this.lightMasks[light.uniqueId]
	       lClip.graphics.clear()

			   // Draw light clip
			   if(light.size!=Infinity) {

					  // Gradient setup
					  var radius:Number = this.lightStatuses[light.uniqueId].localScale*light.size
					  
					  if(this.element is fFloor) {
					  	var rh:Number = radius
					  	var rv:Number = radius/1.8
					  }
					  else if(this.element is fWall) {
					  	rh = radius/1.1
					  	rv = radius/1.1
					  }

						if(fEngine.bumpMapping && light.bump && this.bumpMap) radius *= 0.85
				 		
					  var colors:Array = [light.hexcolor, light.hexcolor]
				    var fillType:String = GradientType.RADIAL
				    var alphas:Array = [light.intensity/100, 0]
			  	  var ratios:Array = [254*light.decay/100, 255]
			   	  var spreadMethod:String = SpreadMethod.PAD
			   	  var interpolationMethod:String = "linearRGB"
			   	  var focalPointRatio:Number = 0
				 	  var localPos:Point = this.lightStatuses[light.uniqueId].localPos
				 	  var matr:Matrix = new Matrix()
  			    matr.createGradientBox(radius<<1, radius<<1, 0 ,-radius, -radius)
  			    matr.concat(this.planeDeform)
  			    matr.translate(localPos.x,localPos.y)
			      lClip.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod, interpolationMethod, focalPointRatio);
			   	
				 		// Find and apply minimun drawing area
				 		var minimumArea = new vport()
         		minimumArea.x_min = Math.round(localPos.x-rh)
         		minimumArea.x_max = Math.round(localPos.x+rh)
         		minimumArea.y_min = Math.round(localPos.y-rv)
         		minimumArea.y_max = Math.round(localPos.y+rv)
  					if(fEngine.bumpMapping && light.bump) {
  						if(minimumArea.x_min<this.element.bounds2d.x) minimumArea.x_min = this.element.bounds2d.x
  						if(minimumArea.y_min<this.element.bounds2d.y) minimumArea.y_min = this.element.bounds2d.y
  					}

			  		var polygonToDraw:fPolygon = new fPolygon()
				 		var contours:Array = this.clipPolygon.contours
				 		var cl:int = contours.length
				 		for(var k:int=0;k<cl;k++) polygonToDraw.contours[k] = polygonUtils.clipPolygon(contours[k],minimumArea)
				 		var holes:Array = this.clipPolygon.holes
				 		var hl:int = holes.length 
				 		for(k=0;k<hl;k++) polygonToDraw.holes[k] = polygonUtils.clipPolygon(holes[k],minimumArea)

			   } else {

			  		lClip.graphics.beginFill(light.hexcolor,light.intensity/100)
			  		polygonToDraw = this.clipPolygon
			  		
				 }

				 polygonToDraw.draw(lClip.graphics)
				 lClip.graphics.endFill()
				 
			 	 // Update bumpmap
				 if(fEngine.bumpMapping && light.bump) {
				 	
				 		if(this.firstBump) {
			 	 	   	this.iniBump()
			 	 	   	this.firstBump = false
				 		}
				 		
		 		 		if(this.bumpMap!=null) {
				  		if(light.size!=Infinity) {
				  			var refPoint:Point = new Point(this.element.bounds2d.x-minimumArea.x_min,this.element.bounds2d.y-minimumArea.y_min)
			  			} else refPoint = new Point(0,0)
			  			//trace(lClip.y+" "+this.element.bounds2d+" "+refPoint+" "+minimumArea.y_min)
				 			this.displacer.mapPoint = refPoint
				 			lClip.filters = [this.displacer]
				 		} else lClip.filters = null
				 
				 } else lClip.filters = null

			}


			/** 
			*	Light reaches element
			*/
			public override function lightIn(light:fLight):void {
			
			   // Show container
				 if(this.lightStatuses && this.lightStatuses[light.uniqueId]) this.showLight(light)
				 
				 // Listen to intensity changes
		 		 light.addEventListener(fLight.INTENSITYCHANGE,this.processLightIntensityChange,false,0,true)
		 		 light.addEventListener(fLight.COLORCHANGE,this.processLightIntensityChange,false,0,true)
		 		 light.addEventListener(fLight.DECAYCHANGE,this.processLightIntensityChange,false,0,true)
			   
			}
			
			/** 
			*	Light leaves element
			*/
			public override function lightOut(light:fLight):void {
			
			   // Hide container
			   if(this.lightStatuses[light.uniqueId]) this.hideLight(light)

				 // Stop listening to intensity changes
		 		 //light.removeEventListener(fLight.INTENSITYCHANGE,this.processLightIntensityChange)
		 		 //light.removeEventListener(fLight.COLORCHANGE,this.processLightIntensityChange)
		 		 //light.removeEventListener(fLight.DECAYCHANGE,this.processLightIntensityChange)
		 		 
		 		 this.undoCache(true)
			   
			}

			/**
			* Renders shadows of other elements upon this fElement
			*/
			public override function renderShadow(light:fLight,other:fRenderableElement):void {
			   
			   var msk:Sprite
			   var lightStatus:fLightStatus = this.lightStatuses[light.uniqueId]
			   
			   if(other is fObject) {
			   	
			   	 if(!(other.customData.flash9Renderer as fFlash9ObjectRenderer).eraseShadows) msk = this.simpleShadowsLayer
			   	 else msk = this.lightShadowsObj[light.uniqueId]
			   	 this.renderObjectShadow(light,other as fObject,msk)
			   	 
			   } else {
				 	 
				 	 var pol:fPolygon = this.renderPlaneShadow(light,other)
				 	 if(pol) {
				 	 	 msk = this.lightShadowsPl[light.uniqueId]
				 		 msk.graphics.beginFill(0,1)
				     pol.draw(msk.graphics)
				     msk.graphics.endFill()
				 	 }
				 	 
			   }

			}

			/**
			* Calculates and projects shadows upon this fElement and return the resulting polygon
			*/
			public function renderPlaneShadow(light:fLight,other:fRenderableElement):fPolygon { 
				return null
			}

			/**
			* Ends render
			*/
			public override function renderFinish(light:fLight):void {
				
				 // Create draw shape
				 this.redrawLight(light)
      	 this.cacheTimer.start()
			}


			// OBJECT SHADOW MANAGEMENT
			///////////////////////////


			/** 
			* Resets shadows. This is called when the fEngine.shadowQuality value is changed
			*/
			public override function resetShadows():void {
				 if(this.simpleShadowsLayer) this.simpleShadowsLayer.graphics.clear()
				 this.resetShadowsInt()
			}
			
			public function resetShadowsInt():void {}

			/**
			* Updates shadow of another elements upon this fElement
			*/
			public override function updateShadow(light:fLight,other:fRenderableElement):void {
			   
			   try {
			    
			   	var msk:Sprite
			   	if(other is fObject && !(other.customData.flash9Renderer as fFlash9ObjectRenderer).eraseShadows) {
			   		msk = this.simpleShadowsLayer
					  this.container.cacheAsBitmap = false
			   	}
			   	else {
			   		msk = this.lightShadowsObj[light.uniqueId]
			    	// Disable cache. Once the render is finished, a timeout is set that will
			    	// restore cache if the object doesn't change for a few seconds.
     	  		this.cacheTimer.stop()
			    	if(this.container.cacheAsBitmap==true) this.undoCache()
       	  	
					  // Start cache timer
					  this.cacheTimer.start()

			   	}
				 			
				 	// Render
				  this.renderObjectShadow(light,other as fObject,msk)
				  
				 } catch(e:Error) { }
				 
				 
			}

			/**
			* Calculates and projects shadows of objects upon this fElement
			*/
			public function renderObjectShadow(light:fLight,other:fObject,msk:Sprite):void {	}	


			// OCCLUSION RENDER MANAGEMENT
			//////////////////////////////


			/**
			* Starts acclusion related to one character
			*/
			public override function startOcclusion(character:fCharacter):void {
				
					if(this.occlusionCount==0) {
						this.container.addChild(this.occlusionLayer)
						this.disableMouseEvents()
					}
					this.occlusionCount++
					
					// Create spot if needed
					if(!this.occlusionSpots[character.uniqueId]) {
						var spr:Sprite = objectPool.getInstanceOf(Sprite) as Sprite
						spr.mouseEnabled = false
						spr.mouseChildren = false
						
						var size:Number = (character.radius>character.height) ? character.radius : character.height
						size *= 1.5
						movieClipUtils.circle(spr.graphics,0,0,size,50,0xFFFFFF,character.occlusion)
						this.occlusionSpots[character.uniqueId] = spr
					}
					
					this.occlusionLayer.addChild(this.occlusionSpots[character.uniqueId])
					
			}

			/**
			* Updates acclusion related to one character
			*/
			public override function updateOcclusion(character:fCharacter):void {
					var spr:Sprite = this.occlusionSpots[character.uniqueId]
					if(!spr) return
					var p:Point = new Point(0,-character.height/2)
					p = character.container.localToGlobal(p)
					p = this.occlusionLayer.globalToLocal(p)
					spr.x = p.x
					spr.y = p.y
			}

			/**
			* Stops acclusion related to one character
			*/
			public override function stopOcclusion(character:fCharacter):void {
					if(!this.occlusionSpots[character.uniqueId]) return
					this.occlusionLayer.removeChild(this.occlusionSpots[character.uniqueId])
					this.occlusionCount--
					if(this.occlusionCount==0) {
						this.enableMouseEvents()
						this.container.removeChild(this.occlusionLayer)
					}
			}


			// OTHER
			////////
			
			/**
			* Mouse management
			*/
			public override function disableMouseEvents():void {
				this.container.mouseEnabled = false
				this.spriteToDraw.mouseEnabled = false
			}

			/**
			* Mouse management
			*/
			public override function enableMouseEvents():void {
				this.container.mouseEnabled = true
				this.spriteToDraw.mouseEnabled = true
			}


			/**
			* Creates bumpmapping for this plane
			*/
			public function iniBump():void {

			   // Bump map ?
	       try {
	       	
	       	  var element:fPlane = this.element as fPlane
			 		  var ptt:DisplayObject = element.material.getBump(element,this.origWidth,this.origHeight,true)
						this.bumpMapData = new BitmapData(element.bounds2d.width,element.bounds2d.height)
						this.tMatrix = this.planeDeform.clone()
						this.tMatrix.translate(0,-Math.round(element.bounds2d.y))
						this.bumpMapData.draw(ptt,this.tMatrix)
						
				 		this.bumpMap = new BumpMap(this.bumpMapData)
				 		this.displacer = new DisplacementMapFilter()
				 		this.displacer.componentX = BumpMap.COMPONENT_X
				 		this.displacer.componentY = BumpMap.COMPONENT_Y
				 		this.displacer.mode =	DisplacementMapFilterMode.IGNORE
				 		this.displacer.alpha =	0
				 		this.displacer.scaleX = 120;
				 		this.displacer.scaleY = 120;
				 		this.displacer.mapBitmap = this.bumpMap.outputData
				 		
//				 		var r:Bitmap = new Bitmap(this.bumpMap.outputData)
//				 		var r:Bitmap = new Bitmap(this.bumpMapData)
//				 		this.container.addChild(r)

				 } catch (e:Error) {

				 		this.bumpMapData = null
				 		this.bumpMap = null
				 		this.displacer = null

				 }
			}

			/** @private */
			public function disposePlaneRenderer():void {

				// Assets
				this.destroyAssets()

       	this.clipPolygon = null
				this.spriteToDraw = null
				
				this.disposeRenderer()
				
			}

			/** @private */
			public override function dispose():void {
				this.disposePlaneRenderer()
			}

		}

}
