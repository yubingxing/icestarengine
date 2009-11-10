package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports

		/**
		* This is the basic flash 9 element renderer. All renderes inherit from this
		* @private
		*/
		public class Flash9ElementRenderer {
		
			/** The element this class renders */
			public var element:fRenderableElement			

			/** The engine for this renderer */
			public var rEngine:Flash9RenderEngine

			/** The scene where the rendering occurs */
			public var scene:fScene			

			/** The container for the element */
			public var container:fElementContainer

			/** The graphic asset for this element */
			public var flashClip:MovieClip

			/** The graphic asset that is displayed for this element */
			public var containerToPaint:DisplayObject

			/** Storing this allows us to show/hide the element */
			public var containerParent:DisplayObjectContainer
			
			/** Are the assets for this plane already created ? */
			public var assetsCreated:Boolean = false
			
			/** This stores render messages that reached the element before it was created, so when it is created it can be synched to the current state */
			public var renderMessages:RenderMessageQueue
			
			/** Is the element visible ( not logically but in terms of render visibility */
			public var screenVisible:Boolean = false

			// Constructor
			/** @private */
			function Flash9ElementRenderer(rEngine:Flash9RenderEngine,element:fRenderableElement,libraryMovieClip:DisplayObject,spriteToShowHide:fElementContainer):void {
				
				 // Pointer to element
				 this.element = element
				 this.scene = element.scene
				 this.rEngine = rEngine
				 
				 // Main container
				 this.containerToPaint = libraryMovieClip
				 if(libraryMovieClip is MovieClip) this.flashClip = (libraryMovieClip as MovieClip)
				 this.container = spriteToShowHide
				 
				 // The container comes attached from the engine only so we can store the reference to the parent
				 this.containerParent = this.container.parent
				 this.containerParent.removeChild(this.container)
				 
				 // Move asset to appropiate position
				 this.place()
				 
				 // Create message queue
				 this.renderMessages = new RenderMessageQueue()
				 
			}

			/**
			* This method creates the assets for this element. It is only called when the element in shown and the assets don't exists
			*/
			public function createAssets():void {}

			/**
			* This method destroys the assets for this element. It is only called when the element in hidden and fEngine.conserveMemory is set to true
			*/
			public function destroyAssets():void {}

			/**
			* Place asset its proper position
			*/
			public function place():void {

			   // Place in position
			   var coords:Point = fScene.translateCoords(this.element.x,this.element.y,this.element.z)
			   this.container.x = Math.floor(coords.x)
			   this.container.y = Math.floor(coords.y)
			   
			}

			/**
			* Mouse management
			*/
			public function disableMouseEvents():void {
				this.container.mouseEnabled = false
			}

			/**
			* Mouse management
			*/
			public function enableMouseEvents():void {
				this.container.mouseEnabled = true
			}

			/**
			* Renders element visible
			*/
			public function show():void {
			   this.containerParent.addChild(this.container)
			}
			
			/**
			* Renders element invisible
			*/
			public function hide():void {
			   this.containerParent.removeChild(this.container)
			}
			
			/** 
			* Sets global light
			*/
			public function renderGlobalLight(light:fGlobalLight):void {
			}

			/** 
			* Global light changes intensity
			*/
			public function processGlobalIntensityChange(light:fGlobalLight):void {
			}

			/**
			* Global light changes color
			*/
			public function processGlobalColorChange(light:fGlobalLight):void {
			}



			/** 
			*	Light reaches element
			*/
			public function lightIn(light:fLight):void {
			}
			
			/**
			* Light leaves element
			*/
		  public function lightOut(light:fLight):void {
			}
			
			/**
			* Light is to be reset
			*/
		  public function lightReset(light:fLight):void {
		  	this.lightOut(light)
			}


			/**
			* Render start
			*/
			public function renderStart(light:fLight):void {
			
			
			}
			
			/**
			* Render ( draw ) light
			*/
			public function renderLight(light:fLight):void {
			
			
			}
			
			/**
			* Renders shadows of other elements upon this element
			*/
			public function renderShadow(light:fLight,other:fRenderableElement):void {
			   
			
			}

			/**
			* Updates shadow of a moving element into this element
			*/
			public function updateShadow(light:fLight,other:fRenderableElement):void {
			   
			
			}

			/**
			* Removes shadow from another element
			*/
			public function removeShadow(light:fLight,other:fRenderableElement):void {
			
			}

			/**
			* Ends render
			*/
			public function renderFinish(light:fLight):void {
			
			}

			/**
			* Starts acclusion related to one character
			*/
			public function startOcclusion(character:fCharacter):void {
			}

			/**
			* Updates acclusion related to one character
			*/
			public function updateOcclusion(character:fCharacter):void {
			}

			/**
			* Stops acclusion related to one character
			*/
			public function stopOcclusion(character:fCharacter):void {
			}

			/** 
			* Resets shadows. This is called when the fEngine.shadowQuality value is changed
			*/
			public function resetShadows():void {
			}

			/**
			* Frees resources
			*/
			public function disposeRenderer():void {

				// Remove dependencies
				this.containerToPaint = null
				Flash9RenderEngine.recursiveDelete(this.container)
				this.container = null
				this.containerParent = null
				this.element = null
				this.scene = null
				this.rEngine = null
				this.flashClip = null
				this.renderMessages.dispose()
				this.renderMessages = null
				
			}

			public function dispose():void {
				this.disposeRenderer()
			}



		}

}
