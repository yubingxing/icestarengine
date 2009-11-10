// LIGHT LOGIC
package com.ice.core.scene.logic {
	
	
	// Imports
	
	
	/**
	 * This class stores static methods related to lights in the scene
	 * @private
	 */
	public class LightSceneLogic {	
		
		// Process a light changing its dimensions
		public static function processNewLightDimensions(scene:fScene,light:fOmniLight):void {
			LightSceneLogic.processNewCellOmniLight(scene,light)
			LightSceneLogic.renderOmniLight(scene,light)
		}
		
		// Process New cell for Omni lights
		public static function processNewCellOmniLight(scene:fScene,light:fOmniLight,forceReset:Boolean = false):void {
			
			// Init
			var cell:fCell = light.cell
			var x:Number, y:Number,z:Number
			var nEl:int = light.nElements
			var tempElements:Array
			
			try {
				x = cell.x
				y = cell.y
				z = cell.z
			} catch (e:Error) {
				x = light.x
				y = light.y
				z = light.z
			}
			
			// Hide light from elements no longer within range
			for(var i2:int=0;i2<nEl;i2++) scene.renderEngine.lightOut(light.elementsV[i2].obj,light)
			
			if(cell==null) {
				// fLight outside grid
				light.elementsV = fVisibilitySolver.calcAffectedByLight(scene,light.x,light.y,light.z,light.size)
				tempElements = light.elementsV
				
			} 
			else {
				// fLight enters new cell
				if(!light.cell.lightAffectedElements || light.cell.lightRange<light.size) scene.getAffectedByLight(light.cell,light.size)
				light.elementsV = light.cell.lightAffectedElements
				tempElements = light.elementsV
			}
			
			// Count elements close enough
			var nElements:int
			var ele:fShadowedVisibilityInfo
			var shadowArray:Array
			var shLength:int
			
			nEl = tempElements.length
			for(nElements=0;nElements<nEl && tempElements[nElements].distance<light.size;nElements++);
			light.nElements = nElements
			
			for(i2=0;i2<nElements;i2++) {
				
				ele = tempElements[i2]
				if(ele.distance<light.size) scene.renderEngine.lightIn(ele.obj,light)
				
				// Calculate how many shadow containers are within range
				
				shadowArray = ele.shadows
				shLength = shadowArray.length
				
				for(var var2:int=0;var2<shLength && shadowArray[var2].distance<light.size;var2++);
				tempElements[i2].withinRange = var2
			}
			
			// Characters			   
			var chLength:int = scene.characters.length
			var character:fCharacter
			var cache:fCharacterShadowCache
			var el:fRenderableElement
			
			for(i2=0;i2<chLength;i2++) {
				
				character = scene.characters[i2]
				
				// Shadow info already exists ?
				try {
					cache = character.cell.characterShadowCache[light.counter]||new fCharacterShadowCache(light)
				} catch(e:Error) {
					cache = new fCharacterShadowCache(light)
				}
				
				// Is character within range ?
				if(character.distanceTo(x,y,z)<light.size) {
					
					cache.withinRange = true
					
					// Add light
					scene.renderEngine.lightIn(character,light)
					
					if(!forceReset && cache.character==character && cache.cell==light.cell) {
						
						// Cache is still valid, no need to update
						
					} else {
						
						// Cache is outdated. Update it
						cache.clear()
						cache.cell = light.cell
						cache.character = character
						
						if(fEngine.characterShadows) { 
							
							for(var i:int=0;i<nElements;i++) {
								el = tempElements[i].obj
								
								// Shadows of scene character upon other elements
								if(fCoverageSolver.calculateCoverage(character,el,x,y,z) == fCoverage.SHADOWED) {
									cache.addElement(el)
								}
								
								// Shadows of other elements upon scene character
								//if(fCoverageSolver.calculateCoverage(el,character,x,y,z) == fCoverage.SHADOWED) character.renderShadow(light,el)
							}
							
						} 
						
					}
					
				} else {
					
					cache.withinRange = false
					cache.clear()
					
					// Remove light
					scene.renderEngine.lightOut(character,light)
					
				}
				
				// Update cache
				character.vLights[light.counter] = light.vCharacters[character.counter] = cache
				if(character.cell) character.cell.characterShadowCache[light.counter] = cache
				
			}
			
		}		
		
		
		// Main render method for omni lights
		public static function renderOmniLight(scene:fScene,light:fOmniLight):void {
			
			if(scene.prof) scene.prof.begin( "Render light:"+light.id, true )
			
			// Step 1: Init
			var x:Number = light.x, y:Number = light.y, z:Number = light.z, nElements:Number = light.nElements, tempElements:Array = light.elementsV, el:fRenderableElement,others:Array,withinRange:Number
			
			// Step 2: render Start
			for(var i2:Number=0;i2<nElements;i2++) scene.renderEngine.renderStart(tempElements[i2].obj,light)
			
			// Step 3: render light and shadows 
			for(i2=0;i2<nElements;i2++) {
				el = tempElements[i2].obj
				others = tempElements[i2].shadows
				withinRange = tempElements[i2].withinRange
				
				if(scene.prof) scene.prof.begin( "Element: "+el.id)	
				scene.renderEngine.renderLight(el,light)
				
				// Shadow from statics
				for(var i3:Number=0;i3<withinRange;i3++) {
					if(others[i3].obj._visible) scene.renderEngine.renderShadow(el,light,others[i3].obj)
				}
				
				if(scene.prof) scene.prof.end( "Element: "+el.id)	
				
				
			}
			
			// Step 4: Render characters
			var character:fCharacter, elements:Array, idChar:Number,len:Number, cache:fCharacterShadowCache           
			
			len = light.vCharacters.length
			for(idChar=0;idChar<len;idChar++) {
				cache = light.vCharacters[idChar]
				if(cache && cache.withinRange) {
					character = cache.character
					elements = cache.elements
					if(scene.prof) scene.prof.begin( "Character: "+character.id)
					
					scene.renderEngine.renderStart(character,light)
					scene.renderEngine.renderLight(character,light)
					scene.renderEngine.renderFinish(character,light)
					
					var ell:int = elements.length
					for(i2=0;i2<ell;i2++) {
						try {
							if(character._visible) scene.renderEngine.renderShadow(elements[i2],light,character)
						} catch(e:Error) {
							
						}
					}
					if(scene.prof) scene.prof.end( "Character: "+character.id)
					
				}
				
			}
			
			// Step 5: End render
			for(i2=0;i2<nElements;i2++) scene.renderEngine.renderFinish(tempElements[i2].obj,light)
			
			if(scene.prof) scene.prof.end( "Render light:"+light.id)
			
			
		}
		
		
		
	}
	
}
