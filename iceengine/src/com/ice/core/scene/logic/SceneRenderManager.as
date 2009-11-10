// RENDER AND ZSORT LOGIC
package com.ice.core.scene.logic {
	
	// Imports
	
	/**
	 * This class manages which elements are visible inside the viewport, zSorts them, and calls
	 * methods from the render engine to create/destroy their graphic assets
	 * @private
	 */
	public class SceneRenderManager {	
		
		// Properties
		private var scene:fScene												// Reference to the scene being managed
		private var range:Number												// The range of visible elements for the current viewport size
		private var depthSortArr:Array									// Array of elements for depth sorting
		private var elementsV:Array											// An array of the elements currently visible
		private var charactersV:Array										// An array of the characters currently visible
		private var emptySpritesV:Array									// An array of emptySprites currently visible
		private var cell:fCell													// The cell where the camera is
		private var renderEngine:fEngineRenderEngine		// A reference to the render engine
		
		// Constructor
		public function SceneRenderManager(scene:fScene):void {
			this.scene = scene
			this.renderEngine = this.scene.renderEngine
		}
		
		// Receives the viewport size for this scene
		public function setViewportSize(width:Number,height:Number):void {
			this.range = Math.sqrt(width*width+height*height)*0.5//(2*fEngine.DEFORMATION)
			if(this.range<=0) this.range = Infinity
			else this.range += 2*this.scene.gridSize
			
		}
		
		// This method is called when the scene is to be rendered and its render engine is ready
		public function initialize():void {
			this.depthSortArr = new Array
			this.elementsV = new Array          
			this.charactersV = new Array
			this.emptySpritesV = new Array
		}
		
		// Process new cell for cameras. It is only called when the scene is being rendered, so it can assume that
		// assets do exist
		public function processNewCellCamera(cam:fCamera):void {
			
			// Init
			this.cell = cam.cell
			var x:Number, y:Number,z:Number
			var tempElements:Array
			
			try {
				x = this.cell.x
				y = this.cell.y
				z = this.cell.z
			} catch (e:Error) {
				x = cam.x
				y = cam.y
				z = cam.z
			}
			
			if(this.cell==null) {
				// Camera outside grid
				tempElements = fVisibilitySolver.calcVisibles(this.scene,x,y,z,this.range)
			} 
			else {
				// Camera enters new cell
				if(!this.cell.visibleElements || this.cell.visibleRange<this.range) this.scene.getVisibles(this.cell,this.range)
				tempElements = this.cell.visibleElements
			}
			
			var anyChanges:Boolean = false
			
			// Step 1: static elements
			
			// Update list of elements close enough
			var newElementsV = []
			var nEl:int = tempElements.length
			for(var nElements:int=0;nElements<nEl && tempElements[nElements].distance<this.range;nElements++) {
				
				var visInfo:fVisibilityInfo = tempElements[nElements]
				newElementsV[newElementsV.length] = visInfo.obj
				visInfo.obj.willBeVisible = true
			}			   
			
			// Hide elements no longer within range (if they where visible) 
			nEl = this.elementsV.length
			for(i2=0;i2<nEl;i2++) {
				var ele:fRenderableElement = this.elementsV[i2]
				if(!ele.willBeVisible && ele._visible) {
					
					// Remove asset
					this.renderEngine.hideElement(ele)
					this.removeFromDepthSort(ele)
					anyChanges = true
					ele.isVisibleNow = false
					
				}
			}
			
			// Show elements that are now within camera range and are visible
			for(var i2:int=0;i2<nElements;i2++) {
				ele = newElementsV[i2]
				ele.willBeVisible = false
				if(!ele.isVisibleNow && ele._visible) {
					
					// Add asset
					this.renderEngine.showElement(ele)
					this.addToDepthSort(ele)
					ele.isVisibleNow = true
					anyChanges = true
					
				}
			}
			
			// Update list
			this.elementsV = newElementsV
			
			////////////////////
			
			
			// Step 2: Characters			   
			
			var chLength:int = scene.characters.length
			var character:fCharacter
			
			var newV:Array = []
			for(i2=0;i2<chLength;i2++) {
				// Is character within range ?
				character = scene.characters[i2]
				if(character.distance2d(x,y,z)<this.range) {
					newV[newV.length] = character
					character.willBeVisible = true
				}
			}
			
			// Hide characters no longer within range (if they where visible) 
			nEl = this.charactersV.length
			for(i2=0;i2<nEl;i2++) {
				character = this.charactersV[i2]
				if(!character.willBeVisible && character._visible) {
					
					// Remove asset
					this.renderEngine.hideElement(character)
					this.removeFromDepthSort(character)
					anyChanges = true
					character.isVisibleNow = false
					
				}
			}
			
			// Show characters that are now within camera range and are visible
			nElements = newV.length
			for(i2=0;i2<nElements;i2++) {
				character = newV[i2]
				character.willBeVisible = false
				if(!character.isVisibleNow && character._visible) {
					
					// Add asset
					this.renderEngine.showElement(character)
					this.addToDepthSort(character)
					character.isVisibleNow = true
					anyChanges = true
					
				}
			}
			
			// Update list
			this.charactersV = newV
			
			
			/////////////
			
			
			// Step 3: Empty Sprites
			
			var esLength:int = scene.emptySprites.length
			var spr:fEmptySprite
			
			newV = []
			for(i2=0;i2<esLength;i2++) {
				// Is sprite within range ?
				spr = scene.emptySprites[i2]
				if(spr.distance2d(x,y,z)<this.range) {
					newV[newV.length] = spr
					spr.willBeVisible = true
				}
			}
			
			// Hide sprites no longer within range (if they where visible) 
			nEl = this.emptySpritesV.length
			for(i2=0;i2<nEl;i2++) {
				spr = this.emptySpritesV[i2]
				if(!spr.willBeVisible && spr._visible) {
					
					// Remove asset
					this.renderEngine.hideElement(spr)
					this.removeFromDepthSort(spr)
					anyChanges = true
					spr.isVisibleNow = false
					
				}
			}
			
			// Show sprites that are now within camera range and are visible
			nElements = newV.length
			for(i2=0;i2<nElements;i2++) {
				spr = newV[i2]
				spr.willBeVisible = false
				if(!spr.isVisibleNow && spr._visible) {
					
					// Add asset
					this.renderEngine.showElement(spr)
					this.addToDepthSort(spr)
					spr.isVisibleNow = true
					anyChanges = true
					
				}
			}
			
			// Update list
			this.emptySpritesV = newV
			
			
			////////////
			
			
			// Redo depth sort if needed
			if(anyChanges) this.depthSort()
			
			
		}
		
		// Process
		public function processNewCellCharacter(character:fCharacter):void {
			
			// If visible, we place it
			if(character._visible) {
				
				var x:Number, y:Number,z:Number
				try {
					x = this.cell.x
					y = this.cell.y
					z = this.cell.z
				} catch (e:Error) {
					x = 0
					y = 0
					z = 0
				}
				
				// Inside range ?
				if(character.distance2d(x,y,z)<this.range) {
					
					// Create if it enters the screen
					if(!character.isVisibleNow) {
						
						this.charactersV[this.charactersV.length] = character
						this.renderEngine.showElement(character)
						this.addToDepthSort(character)
						character.isVisibleNow = true
						
					}
					
				} else {
					
					// Destroy if it leaves the screen
					if(character.isVisibleNow) {
						
						var pos:int = this.charactersV.indexOf(character)
						this.charactersV.splice(pos,1)
						this.renderEngine.hideElement(character)
						this.removeFromDepthSort(character)          
						character.isVisibleNow = false
						
					}
				}
				
			}
			
			// Change depth of object
			if(character.cell!=null) character.setDepth(character.cell.zIndex)
			
		}		
		
		// Process new cells for empty sprites
		public function processNewCellEmptySprite(spr:fEmptySprite):void {
			
			// If visible, we place it
			if(spr._visible) {
				
				var x:Number, y:Number,z:Number
				if(this.cell) {
					x = this.cell.x
					y = this.cell.y
					z = this.cell.z
				} else {
					x = 0
					y = 0
					z = 0
				}
				
				// Inside range ?
				if(spr.distance2d(x,y,z)<this.range) {
					
					// Create if it enters the screen
					if(!spr.isVisibleNow) {
						
						this.emptySpritesV[this.emptySpritesV.length] = spr
						this.renderEngine.showElement(spr)
						this.addToDepthSort(spr)
						spr.isVisibleNow = true
						
					}
					
				} else {
					
					// Destroy if it leaves the screen
					if(spr.isVisibleNow) {
						
						var pos:int = this.emptySpritesV.indexOf(spr)
						this.emptySpritesV.splice(pos,1)
						this.renderEngine.hideElement(spr)
						this.removeFromDepthSort(spr)          
						spr.isVisibleNow = false
						
					}
				}
				
			}
			
			// Change depth of object
			spr.updateDepth()
			
		}		
		
		
		
		
		
		// Process New cell for Bullets
		public function processNewCellBullet(bullet:fBullet):void {
			
			// If it goes outside the scene, destroy it
			if(bullet.cell==null) {
				this.scene.removeBullet(bullet)
				return
			}
			
			// If visible, we place it
			if(bullet._visible) {
				
				var x:Number, y:Number,z:Number
				try {
					x = this.cell.x
					y = this.cell.y
					z = this.cell.z
				} catch (e:Error) {
					x = 0
					y = 0
					z = 0
				}
				
				// Inside range ?
				if(bullet.distance2d(x,y,z)<this.range) {
					
					// Create if it enters the screen
					if(!bullet.isVisibleNow) {
						
						this.renderEngine.showElement(bullet)
						this.addToDepthSort(bullet)
						bullet.isVisibleNow = true
						
					}
					
				} else {
					
					// Destroy if it leaves the screen
					if(bullet.isVisibleNow) {
						
						this.renderEngine.hideElement(bullet)
						this.removeFromDepthSort(bullet)          
						bullet.isVisibleNow = false
						
					}
				}
				
			}
			
			bullet.setDepth(bullet.cell.zIndex)
			
		}
		
		// Listens to elements made visible and adds assets to display list if they are within display range
		public function showListener(evt:Event):void {
			this.addedItem(evt.target as fRenderableElement)
			
		}
		
		// Adds an element to the render logic
		public function addedItem(ele:fRenderableElement):void {
			
			var x:Number, y:Number,z:Number
			
			try {
				x = this.cell.x
				y = this.cell.y
				z = this.cell.z
			} catch (e:Error) {
				x = 0
				y = 0
				z = 0
			}
			
			if(!ele.isVisibleNow && ele._visible && ele.distance2d(x,y,z)<this.range) {
				
				this.renderEngine.showElement(ele)
				this.addToDepthSort(ele)
				ele.isVisibleNow = true
				if(ele is fCharacter) this.charactersV[this.charactersV.length] = ele as fCharacter
				else this.elementsV[this.elementsV.length] = ele
				
				// Redo depth sort
				this.depthSort() 
			}
		}
		
		// Listens to elements made invisible and removes assets to display list if they were within display range
		public function hideListener(evt:Event):void {
			this.removedItem(evt.target as fRenderableElement)
		}
		
		// Removes an element from the render logic
		public function removedItem(ele:fRenderableElement,destroyingScene:Boolean = false):void {
			
			if(ele.isVisibleNow) {
				
				ele.isVisibleNow = false
				if(ele is fCharacter) {
					var ch:fCharacter = ele as fCharacter
					var pos:int = this.charactersV.indexOf(ch)
					if(pos>=0) {
						this.charactersV.splice(pos,1)
						this.renderEngine.hideElement(ele)
						this.removeFromDepthSort(ele)          
					}
				} else {
					pos = this.elementsV.indexOf(ele)
					if(pos>=0) {
						this.elementsV.splice(pos,1)
						this.renderEngine.hideElement(ele)
						this.removeFromDepthSort(ele)          
					}
				}
				
				// Redo depth sort
				if(!destroyingScene) this.depthSort() 
				
			}
			
		}
		
		// Adds an element to the depth sort array
		public function addToDepthSort(item:fRenderableElement):void {				
			
			if(this.depthSortArr.indexOf(item)<0) {
				this.depthSortArr.push(item)
				item.addEventListener(fRenderableElement.DEPTHCHANGE,this.depthChangeListener,false,0,true)
			}
			
		}
		
		// Removes an element from the depth sort array
		public function removeFromDepthSort(item:fRenderableElement):void {				
			
			this.depthSortArr.splice(this.depthSortArr.indexOf(item),1)
			item.removeEventListener(fRenderableElement.DEPTHCHANGE,this.depthChangeListener)
			
		}
		
		// Listens to renderable elements changing their depth
		public function depthChangeListener(evt:Event):void {
			
			var el:fRenderableElement = evt.target as fRenderableElement
			var oldD:int = el.depthOrder
			this.depthSortArr.sortOn("_depth", Array.NUMERIC)
			var newD:int = this.depthSortArr.indexOf(el)
			if(newD!=oldD) {
				el.depthOrder = newD
				this.scene.container.setChildIndex(el.container, newD)
			}
			
		}
		
		// Depth sorts all elements currently displayed
		public function depthSort():void {
			
			var ar:Array = this.depthSortArr
			ar.sortOn("_depth", Array.NUMERIC)
			var i:int = ar.length
			if(i==0) return
			var p:Sprite = this.scene.container
			
			while(i--) {
				p.setChildIndex(ar[i].container, i)
				ar[i].depthOrder = i
			}
			
		}
		
		// Frees resources
		public function dispose():void {	
			if(this.depthSortArr) {
				var il:int = this.depthSortArr.length
				for(var i:int=0;i<il;i++) delete this.depthSortArr[i]
			}
			this.depthSortArr = null
			if(this.elementsV) {
				il = this.elementsV.length
				for(i=0;i<il;i++) delete this.elementsV[i]
			}
			this.elementsV = null
			if(this.charactersV) {
				il = this.charactersV.length
				for(i=0;i<il;i++) delete this.charactersV[i]
			}
			this.charactersV = null
			if(this.emptySpritesV) {
				il = this.emptySpritesV.length
				for(i=0;i<il;i++) delete this.emptySpritesV[i]
			}
			this.emptySpritesV = null
			this.cell = null
		}
		
	}
	
}
