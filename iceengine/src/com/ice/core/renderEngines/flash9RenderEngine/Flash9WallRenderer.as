// WALL

package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports

		/**
		* This class renders a fWall
		* @private
		*/
		public class Flash9WallRenderer extends Flash9PlaneRenderer {
			
			// Static properties. Render cache
			private static var objectRenderCache:Dictionary = new Dictionary(true)
			
			// Public properties

			/**
			* This is the tranformation matrix for vertical walls
			*/
			public static var verticalMatrix = new Matrix(0.706974983215332,0.35248100757598877,0,fEngine.DEFORMATION,0,0)	
			
			/**
			* This is the tranformation matrix for horizontal walls
			*/
			public static var horizontalMatrix = new Matrix(0.706974983215332,-0.35248100757598877,0,fEngine.DEFORMATION,0,0)

			public var vp:vport

			// Constructor
			function Flash9WallRenderer(rEngine:Flash9RenderEngine,container:fElementContainer,element:fWall):void {
				
				 // Generate Sprites
				 var destination:Sprite = objectPool.getInstanceOf(Sprite) as Sprite
				 container.addChild(destination)

				 // Set specific wall dimensions
				 this.scrollR = new Rectangle(0, -element.pixelHeight, element.pixelSize, element.pixelHeight)
			   if(element.vertical) this.planeDeform = Flash9WallRenderer.verticalMatrix	
				 else this.planeDeform = Flash9WallRenderer.horizontalMatrix

				 // Previous
				 super(rEngine,element,element.pixelSize,element.pixelHeight,destination,container)
			
				 // Clipping viewport
         this.vp = new vport()
         if(element.vertical) {
         		this.vp.x_min = element.y0
         		this.vp.x_max = element.y1
         		this.vp.y_min = element.z
         		this.vp.y_max = element.top
         } else {
         		this.vp.x_min = element.x0
         		this.vp.x_max = element.x1
         		this.vp.y_min = element.z
         		this.vp.y_max = element.top
         }
         
			
			}

			// LIGHTS
			/////////

			/**
			* Render ( draw ) light
			*/
			public override function renderLight(light:fLight):void {
					
					var w:fWall = this.element as fWall
					if(w.vertical) this.renderLightVertical(light)
					else this.renderLightHorizontal(light)

		  }
			
			private function renderLightVertical(light:fLight):void {
			
			   var status:fLightStatus = this.lightStatuses[light.uniqueId]
			   var lClip:Sprite = this.lightClips[light.uniqueId]
			     
			   if(light.size!=Infinity) {
			      
			      // If distance to light changed
			      if(status.lightZ != light.x) {
			      	
			      	 var d:Number = light.x-this.element.x
			      	 this.setLightDistance(light,(d>0)?d:-d)
			         status.lightZ = light.x
			      }
			   }   
			   
			   // Move light
			   this.setLightCoordinates(light,fScene.translateCoords(0,light.y-this.element.y0,-(this.element.z-light.z)))
			
			}
			
			private function renderLightHorizontal(light:fLight):void {
			
			   var status:fLightStatus = this.lightStatuses[light.uniqueId]
			   var lClip:Sprite = this.lightClips[light.uniqueId]
			
			   if(light.size!=Infinity) {
			
			      // If distance to light changed
			      if(status.lightZ != light.y) {
			      	
			      	 var d:Number = light.y-this.element.y
			      	 this.setLightDistance(light,(d>0)?d:-d)
			         status.lightZ = light.y
			      }
			   
			   }
			   
	   	   // Move light
			   this.setLightCoordinates(light,fScene.translateCoords(light.x-this.element.x0,0,-(this.element.z-light.z)))
			
			}

			/**
			* Light leaves element
			*/
			public override function lightOut(light:fLight):void {
			
			   // Hide container
			   if(this.lightStatuses[light.uniqueId]) {
			  	 var lClip:Sprite = this.lightClips[light.uniqueId]
			   	 this.lightC.removeChild(lClip)
			   }
			   
			   // Hide shadows
				 if(Flash9WallRenderer.objectRenderCache[this.element.uniqueId+"_"+light.uniqueId]) {
				 		var cache:Dictionary = Flash9WallRenderer.objectRenderCache[this.element.uniqueId+"_"+light.uniqueId]
				 		for(var i in cache) {
				 			try {
							 	var clip:Sprite = cache[i].shadow
							 	clip.parent.removeChild(clip)
								this.rEngine.returnObjectShadow(cache[i])
								delete cache[i]
				 			} catch(e:Error) {}
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
		  	delete this.lightClips[light.uniqueId]
		  	delete Flash9WallRenderer.objectRenderCache[this.element.uniqueId+"_"+light.uniqueId]
		  	
			}


			// OBJECT SHADOW RENDERING
			//////////////////////////


			/**
			* Delete element shadows upon this wall
			*/
			public override function removeShadow(light:fLight,other:fRenderableElement):void {
			   
					var o:fCharacter = other as fCharacter
					
			 	 	var cache:Dictionary = Flash9WallRenderer.objectRenderCache[this.element.uniqueId+"_"+light.uniqueId]
			 	 	if(cache){
			 	 		var sh:fObjectShadow = cache[other.uniqueId]
			 	 		if(sh) {
			 	 			var clip:Sprite = sh.shadow
			 	 			if(clip && clip.parent) clip.parent.removeChild(clip)
			 	 			this.rEngine.returnObjectShadow(sh)
			 	 		}
			 	 	 	delete cache[other.uniqueId]
			 	 	}
			 	 	
			}

			/** 
			* Resets shadows. This is called when the fEngine.shadowQuality value is changed
			*/
			public override function resetShadowsInt():void {
				for(var i in Flash9WallRenderer.objectRenderCache) {
					var a:Dictionary = Flash9WallRenderer.objectRenderCache[i]
					for(var j in a) {
						 try {
						 	var clip:Sprite = a[j].shadow
						 	clip.parent.removeChild(clip)
							this.rEngine.returnObjectShadow(a[j])
							delete a[j]
						 } catch(e:Error) {
						  //trace("Wall reset error: "+e)	
						 }
					}
					delete Flash9WallRenderer.objectRenderCache[i]
				}
			}

			/**
			* Calculates and projects shadows of objects upon this wall
			*/
			public override function renderObjectShadow(light:fLight,other:fObject,msk:Sprite):void {
				 
			   // Walls don't receive shadows from objects in basic shadow quality
			   // or characters in basic and normal shadow quality
			   var simpleShadows:Boolean = (other.customData.flash9Renderer as Flash9ObjectRenderer).simpleShadows
			   if(simpleShadows) return

				 // Too far away ?
				 if((other.z-this.element.z)>fObject.SHADOWRANGE) return

				 // Calculate projection
				 var element:fWall = this.element as fWall
				 var proj:fObjectProjection
				 if(light.z<other.z) proj = this.rEngine.getObjectSpriteProjection(other,element.top,light.x,light.y,light.z)
				 else proj = this.rEngine.getObjectSpriteProjection(other,element.z,light.x,light.y,light.z)
				 
				 if(element.vertical) {
				 		if(light.x>=other.x) return
				 		var intersect:Point = mathUtils.linesIntersect(element.x,element.y0,element.x,element.y1,proj.origin.x,proj.origin.y,proj.end.x,proj.end.y)
				 		var intersect2:Point = mathUtils.linesIntersect(element.x,element.z,element.x,element.top,proj.origin.x,element.z,light.x,light.z)
				 		var intersect3:Point = mathUtils.linesIntersect(element.x,element.z,element.x,element.top,proj.end.x,element.z,other.x,other.top)
				 } else {
				 		if(light.y<=other.y) return
				 		intersect = mathUtils.linesIntersect(element.x0,element.y,element.x1,element.y,proj.origin.x,proj.origin.y,proj.end.x,proj.end.y)
				 		intersect2 = mathUtils.linesIntersect(element.y,element.z,element.y,element.top,proj.origin.y,element.z,light.y,light.z)
				 		intersect3 = mathUtils.linesIntersect(element.y,element.z,element.y,element.top,proj.end.y,element.z,other.y,other.top)
				 }

				 // If no intersection ( paralel lines ) return
				 if(intersect==null) return
				 
				 // Cache or new Movieclip ?
				 if(!Flash9WallRenderer.objectRenderCache[element.uniqueId+"_"+light.uniqueId]) {
				 		Flash9WallRenderer.objectRenderCache[element.uniqueId+"_"+light.uniqueId] = new Dictionary(true)
				 }
				 var cache = Flash9WallRenderer.objectRenderCache[element.uniqueId+"_"+light.uniqueId]
				 if(!cache[other.uniqueId]) {
				 		cache[other.uniqueId] = this.rEngine.getObjectShadow(other,this.element)
				 		cache[other.uniqueId].shadow.transform.colorTransform = new ColorTransform(0,0,0,1,0,0,0,0)
				 }

				 var distance:Number = (other.z-element.z)/fObject.SHADOWRANGE

				 // Draw
				 var clip:Sprite = cache[other.uniqueId].shadow
				 msk.addChild(clip)
				 clip.alpha = 1-distance
				 
				 if(element.vertical) clip.x = intersect.y-element.y0
				 else clip.x = intersect.x-element.x0

		 		 clip.y = (element.z-intersect2.y)
				 clip.height = (intersect3.y-intersect2.y)*(1+fObject.SHADOWSCALE*distance)
		 		 clip.scaleX = 1+fObject.SHADOWSCALE*distance
				 
			   // Erase shadows ?
			   var eraseShadows:Boolean = (other.customData.flash9Renderer as Flash9ObjectRenderer).eraseShadows

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

			// PLANE SHADOW RENDERING
			/////////////////////////
			
			/**
			* Calculates and projects shadows upon this wall, and returns as polygon (with holes, if necessary)
			*/
			public override function renderPlaneShadow(light:fLight,other:fRenderableElement):fPolygon {
			   if(other is fFloor) return this.renderFloorShadow(light,other as fFloor)
			   if(other is fWall) return this.renderWallShadow(light,other as fWall)
			   return null
			}


			/**
			* Calculates and projects shadows of a floor upon this wall
			*/
			private function renderFloorShadow(light:fLight,other:fFloor):fPolygon {
			
			   var element:fWall = this.element as fWall
				 var ret:fPolygon

		 		 // Project to 2d renderer coordinates
				 if(element.vertical) {
					  var points:fPolygon = fProjectionSolver.calculateFloorProjectionIntoVerticalWall(element,light.x,light.y,light.z,other)
					  ret = this.applyVerticalIsometry(points,other)
				 } else {
				 		points = fProjectionSolver.calculateFloorProjectionIntoHorizontalWall(element,light.x,light.y,light.z,other)
					  ret = this.applyHorizontalIsometry(points,other)
				 }
			
				 return ret

			}
			
			/**
			* Calculates and projects shadows of given wall and light
		  */
			private function renderWallShadow(light:fLight,other:fWall):fPolygon {
			
			   var element:fWall = this.element as fWall
				 var ret:fPolygon
		 		
		 		 // Project to 2d renderer coordinates
				 if(element.vertical) {
					  var points:fPolygon = fProjectionSolver.calculateWallProjectionIntoVerticalWall(element,light.x,light.y,light.z,other)
					  ret = this.applyVerticalIsometry(points,other)
				 } else {
				 		points = fProjectionSolver.calculateWallProjectionIntoHorizontalWall(element,light.x,light.y,light.z,other)
					  ret = this.applyHorizontalIsometry(points,other)
				 }
			
				 return ret

			}

			/**
			* Applies vertical isometric projection to a given Polygon
			*/
			private function applyVerticalIsometry(poly:fPolygon,origin:fPlane):fPolygon {

				 var ret:fPolygon = new fPolygon()
				 
				 // Contours
				 var contours:Array = poly.contours
				 var cl:int = contours.length
				 for(var k:int=0;k<cl;k++) {
				 	
				 		// Clip against this wall
				 		var cont:Array = polygonUtils.clipPolygon(contours[k],this.vp)
				 		var rcont:Array = new Array

				 		// Project to 2d renderer coordinates
				 		var cntl:int = cont.length
				 		for(var i:int=0;i<cntl;i++) {
				 			 var c:Point = cont[i]
				 			 rcont[rcont.length] = fScene.translateCoords(0,c.x-this.element.y0,c.y-this.element.z)
				 		}
				 		ret.contours[k] = rcont
				 
				 }
				 
				 // Holes
				 var holes:Array = poly.holes
				 var hl:int = holes.length 
				 for(k=0;k<hl;k++) {
				 	
				 		if(origin.holes[k].open) {

					 		// Clip against this wall
					 		cont = polygonUtils.clipPolygon(holes[k],this.vp)
					 		rcont = new Array

					 		// Project to 2d renderer coordinates
					 		cntl = cont.length
					 		for(i=0;i<cntl;i++) {
				 				 c = cont[i]
				 				 rcont[rcont.length] = fScene.translateCoords(0,c.x-this.element.y0,c.y-this.element.z)
				 			}
				 			ret.holes[k] = rcont
				 		
				 		}
				 
				 }
				 
				 return ret

			}


			/**
			* Applies horizontal isometric projection to a given Polygon
			*/
			private function applyHorizontalIsometry(poly:fPolygon,origin:fPlane):fPolygon {

				 var ret:fPolygon = new fPolygon()
				 
				 // Contours
				 var contours:Array = poly.contours
				 var cl:int = contours.length
				 for(var k:int=0;k<cl;k++) {
				 	
				 		// Clip against this wall
				 		try {
				 			var cont:Array = polygonUtils.clipPolygon(contours[k],this.vp)
				 			var rcont:Array = new Array
				 		} catch(e:Error) {
				 		
			         trace(contours[k].length)
			         for(var m:int=0;m<contours[k].length;m++) trace(contours[k][m])
			         trace(this.element.id)
      			   trace(this.vp.x_max-this.vp.x_min)
         			 trace(this.vp.y_max-this.vp.y_min)
         			 trace(" ")
				 		
				 		}

				 		// Project to 2d renderer coordinates
				 		var cntl:int = cont.length
				 		for(var i:int=0;i<cntl;i++) {
				 			 var c:Point = cont[i]
				 			 rcont[rcont.length] = fScene.translateCoords(c.x-this.element.x0,0,c.y-this.element.z)
				 		}
				 		ret.contours[k] = rcont
				 
				 }
				 
				 // Holes
				 var holes:Array = poly.holes
				 var hl:int = holes.length 
				 for(k=0;k<hl;k++) {
				 	
				 		if(origin.holes[k].open) {

					 		// Clip against this wall
					 		cont = polygonUtils.clipPolygon(holes[k],this.vp)
					 		rcont = new Array

					 		// Project to 2d renderer coordinates
					 		cntl = cont.length
					 		for(i=0;i<cntl;i++) {
				 				 c = cont[i]
				 				 rcont[rcont.length] = fScene.translateCoords(c.x-this.element.x0,0,c.y-this.element.z)
				 			}
				 			ret.holes[k] = rcont
				 		
				 		}
				 
				 }
				 
				 return ret

			}


			// OTHER
			////////
			

			/**
      * Place asset its proper position
      */
      public override function place():void {
         // Place in position
         var coords:Point = fScene.translateCoords(this.element.x0,this.element.y0,this.element.z)
         this.container.x = coords.x
         this.container.y = coords.y
      }

			/** @private */
			public function disposeWallRenderer():void {

				this.resetShadowsInt()
				this.disposePlaneRenderer()
				
			}

			/** @private */
			public override function dispose():void {
								
				this.planeDeform = null
				this.disposeWallRenderer()
			}		


		}

}