package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports

		/**
		* This is ffilmation's default flash9 isometric renderer
		* @private
		*/
		public class fFlash9RenderEngine implements fEngineRenderEngine {
		
				// Private properties
				
				/** The scene rendered by this renderer */
				private var scene:fScene
				
				/** The Sprite where this scene will be drawn  */
				private var container:Sprite

				/** An array of all elementRenderers in this scene. An elementRenderer is a class that renders an specific element, for example a wallRenderer is associated to a fWall	*/
				private var renderers:Array
				
		  	/** Viewport width */
		  	private var viewWidth:Number = 0

		  	/** Viewport height */
		  	private var viewHeight:Number = 0

				
				/**
				* Class constructor
				*/
				public function fFlash9RenderEngine(scene:fScene,container:Sprite):void {
						
					// Init items
					this.scene = scene
					this.container = container
					this.renderers = new Array
					
				}
				
				/**
				* This method is called when the scene is to be displayed.
				*/
				public function initialize():void {
		  	 	 
					this.scene.environmentLight.addEventListener(fLight.COLORCHANGE,this.processGlobalColorChange,false,0,true)
					this.scene.environmentLight.addEventListener(fLight.INTENSITYCHANGE,this.processGlobalIntensityChange,false,0,true)
					this.scene.environmentLight.addEventListener(fLight.RENDER,this.processGlobalIntensityChange,false,0,true)

				}

				/**
				* This method initializes the render engine for an element in the scene.
				*/
				public function initRenderFor(element:fRenderableElement):fElementContainer {
					
					var renderer:fFlash9ElementRenderer = this.createRendererFor(element)
					return element.customData.flash9Renderer.container
		  	 	 
				}

				/**
				* This method removes an element from the render engine
				*/
				public function stopRenderFor(element:fRenderableElement):void {
					
		  	 	// Delete renderer
		  	 	element.customData.flash9Renderer = null
		  	 	this.renderers[element.uniqueId].dispose() 
		  	 	delete this.renderers[element.uniqueId]
		  	 	
		  	 	// Free graphics
		  	 	fFlash9RenderEngine.recursiveDelete(element.container)
		  	 	objectPool.returnInstance(element.container)
		  	 	
				}

				/**
				* This method returns the asset from the library that was used to display the element.
				* It gets written as the "flashClip" property of the element.
				*/
				public function getAssetFor(element:fRenderableElement):MovieClip {
					return element.customData.flash9Renderer.flashClip
				}

				/**
				* This method updates the position of a character's sprite
				*/
				public function updateCharacterPosition(char:fCharacter):void {
					char.customData.flash9Renderer.place()
				}

				/**
				* This method updates the position of an epmty Sprite's sprite
				*/
				public function updateEmptySpritePosition(spr:fEmptySprite):void {
					spr.customData.flash9Renderer.place()
				}

				/**
				* This method updates the position of a bullet's sprite
				*/
				public function updateBulletPosition(bullet:fBullet):void {
					bullet.customData.flash9Renderer.place()
				}

			  /**
			  * This method renders an element visible
			  **/
			  public function showElement(element:fRenderableElement):void {
			  	var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(!r.assetsCreated) {
			  		r.createAssets()
			  		r.renderGlobalLight(this.scene.environmentLight)
			  		r.assetsCreated = true
			  	}
			  	
			  	r.screenVisible = true
			  	this.applyPendingRenderMessages(element)
					r.show()
					
					// Dispatch creation event
					element.dispatchEvent(new Event(fRenderableElement.ASSETS_CREATED))
										
			  }
			  
			  // This method applies pending render messages
			  private function applyPendingRenderMessages(element:fRenderableElement):void {
			  	var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	var messages:Array = r.renderMessages.getMessages()
			  	var l:int = messages.length
			  	for(var i:int=0;i<l;i++) {
			  		var messageObj:fRenderMessage = messages[i]
			  		var messageType:int = messageObj.message
			  		try {
			  			switch(messageType) {
								case fAllRenderMessages.LIGHT_IN: r.lightIn(messageObj.target as fLight); break;
								case fAllRenderMessages.LIGHT_OUT: r.lightOut(messageObj.target as fLight); break;
								case fAllRenderMessages.LIGHT_RESET: r.lightReset(messageObj.target as fLight); break;
								case fAllRenderMessages.RENDER_START: r.renderStart(messageObj.target as fLight); break;
								case fAllRenderMessages.RENDER_LIGHT: r.renderLight(messageObj.target as fLight); break;
								case fAllRenderMessages.RENDER_SHADOW: r.renderShadow(messageObj.target as fLight,messageObj.target2 as fRenderableElement); break;
								case fAllRenderMessages.RENDER_FINISH: r.renderFinish(messageObj.target as fLight); break;
								case fAllRenderMessages.UPDATE_SHADOW: r.updateShadow(messageObj.target as fLight,messageObj.target2 as fRenderableElement); break;
								case fAllRenderMessages.REMOVE_SHADOW: r.removeShadow(messageObj.target as fLight,messageObj.target2 as fRenderableElement); break;
								case fAllRenderMessages.GLOBAL_INTESITY_CHANGE: r.processGlobalIntensityChange(messageObj.target as fGlobalLight); break;
								case fAllRenderMessages.GLOBAL_COLOR_CHANGE: r.processGlobalColorChange(messageObj.target as fGlobalLight); break;
								case fAllRenderMessages.START_OCCLUSION: r.startOcclusion(messageObj.target as fCharacter); break;
								case fAllRenderMessages.UPDATE_OCCLUSION: r.updateOcclusion(messageObj.target as fCharacter); break;
								case fAllRenderMessages.STOP_OCCLUSION: r.stopOcclusion(messageObj.target as fCharacter); break;
			  			}
			  	  } catch(e:Error) {
			  	  	
			  	  } 
			  	}        
                   
			  	// Clear pending
			  	if(!fEngine.conserveMemory) r.renderMessages.reset()
				}          
                   
			  /**        
			  * This method renders an element invisible
			  **/        
			  public function hideElement(element:fRenderableElement):void {
			  	var r:fFlash9ElementRenderer = element.customData.flash9Renderer
					r.hide()
			  	r.screenVisible = false
					/*if(fEngine.conserveMemory && r.assetsCreated) {
						r.destroyAssets()
						r.assetsCreated = false
						// Dispatch destruction event
						element.dispatchEvent(new Event(fRenderableElement.ASSETS_DESTROYED))
					}*/
			  }

			  /**
			  * This method enables mouse events for an element
			  **/
			  public function enableElement(element:fRenderableElement):void {
					element.customData.flash9Renderer.enableMouseEvents()
			  }

			  /**
			  * This method disables mouse events for an element
			  **/
			  public function disableElement(element:fRenderableElement):void {
					element.customData.flash9Renderer.disableMouseEvents()
			  }

				/**
				* When a moving light reaches an element, this method is executed
				*/
				public function lightIn(element:fRenderableElement,light:fOmniLight):void {
			  	var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.lightIn(light)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.LIGHT_IN,light)
				}

				/**
				* When a moving light moves out of an element, this method is executed
				*/
				public function lightOut(element:fRenderableElement,light:fOmniLight):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.lightOut(light)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.LIGHT_OUT,light,null,true)

				}

				/**
				* When a light is to be reset ( new size )
				*/
				public function lightReset(element:fRenderableElement,light:fOmniLight):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.lightReset(light)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.LIGHT_RESET,light)
				}

				/**
				* This is the renderStart call.
				*/
				public function renderStart(element:fRenderableElement,light:fOmniLight):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.renderStart(light)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.RENDER_START,light)
				}
				
				/**
				* This is the renderLight call.
				*/
				public function renderLight(element:fRenderableElement,light:fOmniLight):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.renderLight(light)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.RENDER_LIGHT,light)
				}

				/**
				* This is the renderShadow call.
				*/
				public function renderShadow(element:fRenderableElement,light:fOmniLight,shadow:fRenderableElement):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.renderShadow(light,shadow)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.RENDER_SHADOW,light,shadow)
				}

				/**
				* This is the renderFinish call.
				*/
				public function renderFinish(element:fRenderableElement,light:fOmniLight):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.renderFinish(light)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.RENDER_FINISH,light)
				}
		
				/**
				* This is the updateShadow call.
				*/
				public function updateShadow(element:fRenderableElement,light:fOmniLight,shadow:fRenderableElement):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.updateShadow(light,shadow)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.UPDATE_SHADOW,light,shadow)
				}

				/**
				* When an element is removed or hidden, or moves out of another element's range, its shadows need to be removed too
				*/
				public function removeShadow(element:fRenderableElement,light:fOmniLight,shadow:fRenderableElement):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.removeShadow(light,shadow)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.REMOVE_SHADOW,light,shadow,true)
				}

				/**
				* When the quality settings for the engine's shadows are changed, this method is called so old shadows are removed.
				* There is no need for the renderer to redraw all shadows in this method: The engine rerenders the whole scene after
				* this has been executed.
				*/
				public function resetShadows():void {
					for(var i in this.renderers) if(this.renderers[i].assetsCreated) this.renderers[i].resetShadows()
				}

				/**
				* Updates the render to show a given camera's position
				*/
				public function setCameraPosition(camera:fCamera):void {

					if(this.viewWidth>0 && this.viewHeight>0) {
						var p:Point = fScene.translateCoords(camera.x,camera.y,camera.z)
						var rect:Rectangle = new Rectangle()
						rect.width = this.viewWidth
						rect.height = this.viewHeight
						rect.x = Math.round(-this.viewWidth/2+p.x)
						rect.y = Math.round(-this.viewHeight/2+p.y)
						this.container.scrollRect = rect
					} else {
						this.container.scrollRect = null
					}

				}
				
				/**
				* Updates the viewport size. This call will be immediately followed by a setCameraPosition call
				* @see org.ffilmation.engine.interfaces.fRenderEngine#setCameraPosition
				*/
				public function setViewportSize(width:Number,height:Number):void {
					
					this.viewWidth = width
					this.viewHeight = height
				}

				/**
				* Starts acclusion related to one character
				* @param element Element where occlusion is applied
				* @param character Character causing the occlusion
				*/
				public function startOcclusion(element:fRenderableElement,character:fCharacter):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.startOcclusion(character)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.START_OCCLUSION,character)
				}
				
				/**
				* Updates acclusion related to one character
				* @param element Element where occlusion is applied
				* @param character Character causing the occlusion
				*/
				public function updateOcclusion(element:fRenderableElement,character:fCharacter):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.updateOcclusion(character)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.UPDATE_OCCLUSION,character)
				}
      	
				/**
				* Stops acclusion related to one character
				* @param element Element where occlusion is applied
				* @param character Character causing the occlusion
				*/
				public function stopOcclusion(element:fRenderableElement,character:fCharacter):void {
					var r:fFlash9ElementRenderer = element.customData.flash9Renderer
			  	if(r.screenVisible) r.stopOcclusion(character)
			  	if(!r.screenVisible || fEngine.conserveMemory) r.renderMessages.addMessage(fAllRenderMessages.STOP_OCCLUSION,character,null,true)
				}

				/**
				* This method returns the element under a Stage coordinate, and a 3D translation of the 2D coordinates passed as input.
				*/
				public function translateStageCoordsToElements(x:Number,y:Number):Array {
					
					var found:Array = []
					var ret:Array = []
					for(var i in this.renderers) {
						
							var el:fRenderableElement = null
							if(this.renderers[i].container) el = this.renderers[i].container.fElement
							
							if(el!=null && found.indexOf(el)<0 && el.container.hitTestPoint(x,y,true)/*&& this.currentOccluding.indexOf(el)<0*/) {
								
									// Avoid repeated results
									found[found.length] = el
        	
									// Get local coordinate
									var p:Point = new Point(x,y)
									if(el is fPlane) {
										
										var r:fFlash9PlaneRenderer = (el.customData.flash9Renderer as fFlash9PlaneRenderer)
										p = r.deformedSimpleShadowsLayer.globalToLocal(p)
										
										if(r.scrollR.containsPoint(p)) {
											
											// Push data
											if(el is fFloor) ret[ret.length] = (new fCoordinateOccupant(el,el.x+p.x,el.y+p.y,el.z))
											if(el is fWall) {
												var w:fWall = el as fWall
												if(w.vertical) ret[ret.length] = (new fCoordinateOccupant(w,w.x,w.y0+p.x,w.z-p.y))
												else ret[ret.length] = (new fCoordinateOccupant(w,w.x0+p.x,w.y,w.z-p.y))
											}
											
										}
										
									}
									
									if(el is fObject) {
										p = el.container.globalToLocal(p)
										ret[ret.length] = (new fCoordinateOccupant(el,el.x+p.x,el.y,el.z-p.y))
									}
									
							}
							
					}
					
					// Sort elements by depth, closest to camera first
					var sortOnDepth:Function = function(a:fCoordinateOccupant, b:fCoordinateOccupant):Number {
					    if(a.element._depth > b.element._depth) return 1
					    else if(a.element._depth < b.element._depth) return -1
					    else return 0
					}
					ret.sort(sortOnDepth)
					
					// Return
					if(ret.length==0) return null
					else return ret

				}

				/** 
				* Frees all allocated resources. This is called when the scene is hidden or destroyed.
				*/
				public function dispose():void {
					
					// Stop listeners
					this.scene.environmentLight.removeEventListener(fLight.COLORCHANGE,this.processGlobalColorChange)
					this.scene.environmentLight.removeEventListener(fLight.INTENSITYCHANGE,this.processGlobalIntensityChange)
					this.scene.environmentLight.removeEventListener(fLight.RENDER,this.processGlobalIntensityChange)
					
					// Delete resources
					for(var i in this.renderers) {
		  	 		this.renderers[i].element.customData.flash9Renderer = null						
		  	 		this.renderers[i].dispose()
		  	 		if(this.renderers[i].element) {
		  	 			fFlash9RenderEngine.recursiveDelete(this.renderers[i].element.container)
		  	 			objectPool.returnInstance(this.renderers[i].element.container)
		  	 		}
						delete this.renderers[i]
					}
					this.renderers = new Array
					fFlash9RenderEngine.recursiveDelete(this.container)
				}
				
				
				// INTERNAL
				
				/**
				* This method retrieves the projected Sprite corresponding to a given element and floor size
				* @private
				*/
				public function getObjectSpriteProjection(element:fObject,floorz:Number,x:Number,y:Number,z:Number):fObjectProjection {
					return element.customData.flash9Renderer.getSpriteProjection(floorz,x,y,z)
				}

				/**
				* This method retrieves the Sprite representing the shadow of a given fObject
				* @private
				*/
				public function getObjectShadow(element:fObject,request:fRenderableElement):fObjectShadow {
					return element.customData.flash9Renderer.getShadow(request)
				}
				
				/**
				* This method returns an unused shadow to the pool
				* @private
				*/
				public function returnObjectShadow(sh:fObjectShadow):void {
					sh.object.customData.flash9Renderer.returnShadow(sh)
				}


				/**
				* This event listener is executed when the global light changes its intensity
				*/
				private function processGlobalIntensityChange(evt:Event):void {
					for(var i in this.renderers) {
						if(this.renderers[i].screenVisible) this.renderers[i].processGlobalIntensityChange(evt.target as fGlobalLight)
						if(!this.renderers[i].screenVisible || fEngine.conserveMemory) this.renderers[i].renderMessages.addMessage(fAllRenderMessages.GLOBAL_INTESITY_CHANGE,evt.target as fGlobalLight)
					}
				}
		
				/**
				* This event listener is executed when the global light changes its color
				*/
				private function processGlobalColorChange(evt:Event):void {
					for(var i in this.renderers) {
						if(this.renderers[i].screenVisible) this.renderers[i].processGlobalColorChange(evt.target as fGlobalLight)
						if(!this.renderers[i].screenVisible || fEngine.conserveMemory) this.renderers[i].renderMessages.addMessage(fAllRenderMessages.GLOBAL_COLOR_CHANGE,evt.target as fGlobalLight)
					}
				}

				/**
				* Creates the renderer associated to a renderableElement. The renderer is created if it doesn't exist.
				*/
				private function createRendererFor(element:fRenderableElement):fFlash9ElementRenderer {
					
					//Create renderer if it doesn't exist
					if(!this.renderers[element.uniqueId]) {

				 		var spr:fElementContainer = objectPool.getInstanceOf(fElementContainer) as fElementContainer
		   	 		this.container.addChild(spr)			   

						if(element is fFloor) element.customData.flash9Renderer = new fFlash9FloorRenderer(this,spr,element as fFloor)
						else if(element is fWall) element.customData.flash9Renderer = new fFlash9WallRenderer(this,spr,element as fWall)
						else if(element is fObject) element.customData.flash9Renderer = new fFlash9ObjectRenderer(this,spr,element as fObject)
						else if(element is fBullet) element.customData.flash9Renderer = new fFlash9BulletRenderer(this,spr,element as fBullet)
						else element.customData.flash9Renderer = new fFlash9ElementRenderer(this,element,element.flashClip,spr)
						
						this.renderers[element.uniqueId] = element.customData.flash9Renderer
						
					}
					
					// Return it
					return this.renderers[element.uniqueId]
					
				}

				// Recursively deletes all DisplayObjects in the container hierarchy
				public static function recursiveDelete(d:DisplayObjectContainer):void {
					
						if(!d) return
						if(d.numChildren!=0) do {
							var c:DisplayObject = d.getChildAt(0)
							if(c!=null) {
								c.cacheAsBitmap = false
								if(c is DisplayObjectContainer) fFlash9RenderEngine.recursiveDelete(c as DisplayObjectContainer)
								if(c is MovieClip) (c as MovieClip).stop()
								if(c is Bitmap) {
									var b:Bitmap = c as Bitmap
									if(b.bitmapData) b.bitmapData.dispose()
								}
								if(c is Shape) (c as Shape).graphics.clear()
								d.removeChild(c)
							}
						} while(d.numChildren!=0 && c!=null)
						
						if(d is Sprite) (d as Sprite).graphics.clear()
						
					
				}				


		}
		
}
