package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports

		/**
		* This class renders an fFloor
		* @private
		*/
		public class Flash9FloorRenderer extends Flash9PlaneRenderer {
		
			// Static properties and Render cache
			public static var floorProjectionCache:fFloorProjectionCache = new fFloorProjectionCache()
			public static var wallProjectionCache:Dictionary = new Dictionary(true)
			private static var objectProjectionCache:Dictionary = new Dictionary(true)
			//public static var matrix:Matrix = new Matrix(0.7071075439453125,-0.35355377197265625,0.7071075439453125,0.35355377197265625,0,0)
			public static var matrix:Matrix = new Matrix(0.5253219888177297,-0.4254517622670592,0.8509035245341184,0.26266099440886487,0,0)
			public var vp:vport
			
			// Constructor
			function Flash9FloorRenderer(rEngine:Flash9RenderEngine,container:fElementContainer,element:fFloor):void {
			
				 // Generate sprite
				 var destination:Sprite = objectPool.getInstanceOf(Sprite) as Sprite
				 container.addChild(destination)
			   
				 // Set specific wall dimensions
			   this.scrollR = new Rectangle(0, 0, element.width, element.depth)
				 this.planeDeform = new Matrix() //fFlash9FloorRenderer.matrix
				 this.planeDeform.rotate(-45*Math.PI/180)
				 this.planeDeform.scale(1.0015,0.501)
				 
			   // Previous
				 super(rEngine,element,element.width,element.depth,destination,container)
				 
				 // Clipping viewport
         this.vp = new vport()
         this.vp.x_min = element.x
         this.vp.x_max = element.x+element.width
         this.vp.y_min = element.y
         this.vp.y_max = element.y+element.depth
                        				 
			
			}

			// LIGHTS
			/////////
			
			
			/**
			* Render ( draw ) light
			*/
			public override function renderLight(light:fLight):void {
			
			   var status:fLightStatus = this.lightStatuses[light.uniqueId]
			   var lClip:Sprite = this.lightClips[light.uniqueId]
				
			   if(status.lightZ != light.z) {
			      status.lightZ = light.z
			      var d:Number = light.z-this.element.z
			      this.setLightDistance(light,(d>0)?d:-d)
			   }    
			
			   // Move light
	   	   this.setLightCoordinates(light,fScene.translateCoords(light.x-this.element.x,light.y-this.element.y,0))
			
			}

			/**
			* Light leaves element
			*/
			public override function lightOut(light:fLight):void {
			
			   // Hide container
			   if(this.lightStatuses && this.lightStatuses[light.uniqueId]) {
			  	 var lClip:Sprite = this.lightClips[light.uniqueId]
			   	 this.lightC.removeChild(lClip)
			   }

			   // Hide shadows
				 if(Flash9FloorRenderer.objectProjectionCache[this.element.uniqueId+"_"+light.uniqueId]) {
				 		var cache:Dictionary = Flash9FloorRenderer.objectProjectionCache[this.element.uniqueId+"_"+light.uniqueId]
				 		for(var i in cache) {
							try {				 		
			 	 				var clip:Sprite = cache[i].shadow
			 	 				if(clip.parent.parent) clip.parent.parent.removeChild(clip.parent)
			 	 				this.rEngine.returnObjectShadow(cache[i])
			 	 				delete cache[i]
				 			} catch(e:Error) {	}	
				 		}		   
				 }
			   
		 		 this.undoCache(true)


			}

			/**
			* Light is to be reset
			*/
		  public override function lightReset(light:fLight):void {
		  	
		  	this.lightOut(light)
		  	delete this.lightStatuses[light.uniqueId]
		  	Flash9RenderEngine.recursiveDelete(this.lightClips[light.uniqueId])
		  	delete this.lightClips[light.uniqueId]
		  	delete Flash9FloorRenderer.objectProjectionCache[this.element.uniqueId+"_"+light.uniqueId]
		  	
			}
			
			
			// OBJECT SHADOW RENDERING
			//////////////////////////


			/** 
			* Resets shadows. This is called when the fEngine.shadowQuality value is changed
			*/
			public override function resetShadowsInt():void {
				for(var i in Flash9FloorRenderer.objectProjectionCache) {
					var a:Dictionary = Flash9FloorRenderer.objectProjectionCache[i]
					for(var j in a) {
						 try {
						 	var clip:Sprite = a[j].shadow
						 	clip.parent.parent.removeChild(clip.parent)
							this.rEngine.returnObjectShadow(a[j])
			 	 			delete a[j]
						 } catch (e:Error) {
						  //trace("Floor reset error: "+e)	
						 }
					}
					delete Flash9FloorRenderer.objectProjectionCache[i]
				}
			}

			/**
			* Calculates and projects shadows of objects upon this floor
			*/
			public override function renderObjectShadow(light:fLight,other:fObject,msk:Sprite):void {
			   
				 // Too far away ?
				 if((other.z-this.element.z)>fObject.SHADOWRANGE) return

				 // Get projection
				 var proj:fObjectProjection = this.rEngine.getObjectSpriteProjection(other,this.element.z,light.x,light.y,light.z)
				 
				 if(proj==null) {
				 	var clip:Sprite = cache[other.uniqueId].shadow
				 	try { msk.removeChild(clip.parent) } catch(e:Error) {}
				 	return
				 }

			   // Simple shadows ?
			   var simpleShadows:Boolean = (other.customData.flash9Renderer as Flash9ObjectRenderer).simpleShadows
			   var eraseShadows:Boolean = (other.customData.flash9Renderer as Flash9ObjectRenderer).eraseShadows

				 // Cache or new Movieclip ?
				 if(!Flash9FloorRenderer.objectProjectionCache[this.element.uniqueId+"_"+light.uniqueId]) {
				 		Flash9FloorRenderer.objectProjectionCache[this.element.uniqueId+"_"+light.uniqueId] = new Dictionary(true)
				 }
				 var cache:Dictionary = Flash9FloorRenderer.objectProjectionCache[this.element.uniqueId+"_"+light.uniqueId]
				 if(!cache[other.uniqueId]) {
				 		cache[other.uniqueId] = this.rEngine.getObjectShadow(other,this.element)
				 		if(!simpleShadows) cache[other.uniqueId].shadow.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,0)
				 }
				 
				 var distance:Number = (other.z-this.element.z)/fObject.SHADOWRANGE

				 // Draw
				 clip = cache[other.uniqueId].shadow
				 msk.addChild(clip.parent)
				 clip.alpha = 1-distance
				 
				 // Rotate and deform
		 		 clip.parent.x = proj.origin.x-this.element.x
				 clip.parent.y = proj.origin.y-this.element.y
				 if(!simpleShadows) {
				 		clip.height = proj.size*(1+fObject.SHADOWSCALE*distance)
				 		clip.scaleX = 1+fObject.SHADOWSCALE*distance
				 		clip.parent.rotation = 90+mathUtils.getAngle(light.x,light.y,other.x,other.y)
				 }
				 
				 // Adjust alpha if necessary
				 if(light.size!=Infinity && !eraseShadows) {
				 		var distToLight:Number = mathUtils.distance(light.x,light.y,other.x,other.y)
				 		var distToLightBorder:Number = -distToLight+(this.lightStatuses[light.uniqueId].localScale*light.size)
				 	  if(distToLightBorder<clip.height) {
				 	  	var fade:Number = 1-((clip.height-distToLightBorder)/clip.height)
				 	  	clip.alpha *= fade
				 	  }
				 }


			}
			
			/**
			* Delete character shadows upon this floor
			*/
			public override function removeShadow(light:fLight,other:fRenderableElement):void {
			   
					var o:fCharacter = other as fCharacter
			   	
			 	 	var cache:Dictionary = Flash9FloorRenderer.objectProjectionCache[this.element.uniqueId+"_"+light.uniqueId]
			 	 	if(cache) {
			 	 		var sh:fObjectShadow = cache[other.uniqueId]
			 	 		if(sh) {
			 	 			var clip:Sprite = sh.shadow
			 	 			if(clip && clip.parent && clip.parent.parent) clip.parent.parent.removeChild(clip.parent)
	 	 		 	 		this.rEngine.returnObjectShadow(sh)
	 	 		 		}
			 	 		delete cache[other.uniqueId]
			 	 	}

			}

			
			// PLANE SHADOW RENDERING
			/////////////////////////

			/**
			* Calculates and projects shadows upon this floor, and returns as polygon (with holes, if necessary)
			*/
			public override function renderPlaneShadow(light:fLight,other:fRenderableElement):fPolygon {
			   if(other is fFloor) return this.renderFloorShadow(light,other as fFloor)
			   if(other is fWall) return this.renderWallShadow(light,other as fWall)
			   return null
			}

			/**
			* Calculates and projects shadows of another floor upon this floor
			*/
			private function renderFloorShadow(light:fLight,other:fFloor):fPolygon {
			   
			   // Read cache or write cache ?
			   if(Flash9FloorRenderer.floorProjectionCache.x!=light.x || Flash9FloorRenderer.floorProjectionCache.y!=light.y
			      || Flash9FloorRenderer.floorProjectionCache.z!=light.z || Flash9FloorRenderer.floorProjectionCache.fl!=other ) {
			   	
					  // New Key
			   		Flash9FloorRenderer.floorProjectionCache.x = light.x 	
			   		Flash9FloorRenderer.floorProjectionCache.y = light.y 	
			   		Flash9FloorRenderer.floorProjectionCache.z = light.z 	
			   		Flash9FloorRenderer.floorProjectionCache.fl = other
			
			   		// New value
			   		Flash9FloorRenderer.floorProjectionCache.points = fProjectionSolver.calculateFloorProjection(light.x,light.y,light.z,other,this.element.z)
			
			   }
			
				 // Deform
				 var ret:fPolygon = this.applyIsometry(Flash9FloorRenderer.floorProjectionCache.points,other)
				 
				 return ret

			}

			/**
			* Calculates and draws the shadow of a given wall from a given light
			*/
			private function renderWallShadow(light:fLight,wall:fWall):fPolygon {
			   
				 var cache:fWallProjectionCache = Flash9FloorRenderer.wallProjectionCache[this.element.uniqueId+"_"+wall.uniqueId]
				 if(!cache) cache = Flash9FloorRenderer.wallProjectionCache[this.element.uniqueId+"_"+wall.uniqueId] = new fWallProjectionCache()
				 	
			   // Update cache ?
			   if(cache.x!=light.x || cache.y!=light.y || cache.z!=light.z) {
			   	
					  // New Key
			   		cache.x=light.x 	
			   		cache.y=light.y 	
			   		cache.z=light.z 	
			
			   		// New value
			   		cache.points = fProjectionSolver.calculateWallProjection(light.x,light.y,light.z,wall,this.element.z,this.scene)
			
				 }
				 
				 // Deform
				 var ret:fPolygon = this.applyIsometry(cache.points,wall)
				 
				 return ret
				 
			}
			
			/**
			* Applies isometric projection to a given Polygon
			*/
			private function applyIsometry(poly:fPolygon,origin:fPlane):fPolygon {
				
				 var ret:fPolygon = new fPolygon()
				 
				 // Contours
				 var contours:Array = poly.contours
				 var cl:int = contours.length
				 for(var k:int=0;k<cl;k++) {
				 	
				 		// Clip against this Floor
				 		var cont:Array = polygonUtils.clipPolygon(contours[k],this.vp)
				 		var rcont:Array = new Array

				 		// Project to 2d renderer coordinates
				 		var cntl:int = cont.length
				 		for(var i:int=0;i<cntl;i++) {
				 			 var c:Point = cont[i]
				 			 rcont[rcont.length] = fScene.translateCoords(c.x-this.element.x,c.y-this.element.y,0)
				 		}
				 		ret.contours[k] = rcont
				 
				 }
				 
				 // Holes
				 var holes:Array = poly.holes
				 var hl:int = holes.length 
				 for(k=0;k<hl;k++) {
				 	
				 		if(origin.holes[k].open) {
				 			
				 			// Clip against this Floor
				 			cont = polygonUtils.clipPolygon(holes[k],this.vp)
				 			rcont = new Array

				 			// Project to 2d renderer coordinates
				 			cntl = cont.length
				 			for(i=0;i<cntl;i++) {
				 			 	c = cont[i]
				 			 	rcont[rcont.length] = fScene.translateCoords(c.x-this.element.x,c.y-this.element.y,0)
				 			}
				 			ret.holes[k] = rcont

				 		}
				 
				 }
				 
				 
				 return ret
				
			}


			// OTHER
			////////


			/** @private */
			public function disposeFloorRenderer():void {


				this.resetShadowsInt()
       	this.planeDeform = null
				this.disposePlaneRenderer()
				
			}

			/** @private */
			public override function dispose():void {
				this.disposeFloorRenderer()
			}		

			
		}
}
