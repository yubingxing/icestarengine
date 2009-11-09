// CHARACTER LOGIC
package com.ice.core.scene.logic {
	
	
	// Imports
	
	
	/**
	 * This class stores static methods related to characters in the scene
	 * @private
	 */
	public class fCharacterSceneLogic {	
		
		
		// Process New cell for Characters
		public static function processNewCellCharacter(scene:fScene,character:fCharacter,forceReset:Boolean = false):void {
			
			// Init
			var light:fOmniLight, elements:Array, nEl:int, distL:Number, range:Number,x:Number, y:Number, z:Number
			var cache:fCharacterShadowCache, oldCache:fCharacterShadowCache, elementsV:Array, el:fPlane
			var s:Number, len:int,i:int,i2:int
			
			// Count lights close enough
			var ll:int = scene.lights.length
			for(i2=0;i2<ll;i2++) {
				
				light = scene.lights[i2]
				
				// Shadow info already already exists ?
				try {
					cache = character.cell.characterShadowCache[light.counter]||new fCharacterShadowCache(light)
				} catch(e:Error) {
					cache = new fCharacterShadowCache(light)
				}
				
				// Range
				distL = light.distanceTo(character.x,character.y,character.z)
				range = character.shadowRange
				
				// Is character within range ?
				if(distL<light.size) {
					
					cache.withinRange = true
					
					// Add light
					scene.renderEngine.lightIn(character,light)
					
					if(light.cell) {
						x = light.cell.x
						y = light.cell.y
						z = light.cell.z
					} else {
						x = light.x
						y = light.y
						z = light.z
					}
					
					if(!forceReset && cache.character==character && cache.cell==light.cell) {
						
						// Cache is still valid, no need to update
						
					} else {
						
						
						// Cache is outdated. Update it
						cache.clear()
						cache.cell = light.cell
						cache.character = character
						
						if(fEngine.characterShadows) {
							
							// Add visibles from foot
							if(!character.cell.lightAffectedElements || character.cell.lightRange<range) scene.getAffectedByLight(character.cell,range)
							elementsV = character.cell.lightAffectedElements
							nEl = elementsV.length
							for(i=0;i<nEl && elementsV[i].distance<range;i++) {
								
								try {
									el = elementsV[i].obj
									// Shadows of scene character upon other elements
									if(fCoverageSolver.calculateCoverage(character,el,x,y,z) == fCoverage.SHADOWED) cache.addElement(el)
								} catch(e:Error) {
								}
								
							}
							
							// Add visibles from top
							try {
								var topCell:fCell = scene.translateToCell(character.x,character.y,character.top)
								if(!topCell.lightAffectedElements  || topCell.lightRange<range) scene.getAffectedByLight(topCell,range)
								elementsV = topCell.lightAffectedElements
								nEl = elementsV.length
								for(i=0;i<nEl && elementsV[i].distance<range;i++) {
									
									try {
										el = elementsV[i].obj
										// Shadows of scene character upon other elements
										if(fCoverageSolver.calculateCoverage(el,character,x,y,z) == fCoverage.SHADOWED) cache.addElement(el)
									} catch(e:Error) {
									}
									
								}
							} catch(e:Error) {
								
							}
							
						}
						
					}
					
				} else {
					
					cache.withinRange = false
					cache.clear()
					
					// And remove light
					if(scene.IAmBeingRendered) scene.renderEngine.lightOut(character,light)
					
				}
				
				// Delete shadows from scene character that are no longer visible
				oldCache = character.vLights[light.counter]
				if(oldCache!=null) {
					elements = oldCache.elements
					nEl = elements.length
					for(var i3:Number=0;i3<nEl;i3++) {
						if(cache.elements.indexOf(elements[i3])<0) {
							scene.renderEngine.removeShadow(elements[i3],light,character)
						}
					}
				}
				
				// Update cache
				character.vLights[light.counter] = light.vCharacters[character.counter] = character.cell.characterShadowCache[light.counter] = cache
				
			}
			
			// Update occlusion for scene character
			var oldOccluding:Array = character.currentOccluding
			var newOccluding:Array = new Array
			try {
				var newOccluding2:Array = character.cell.elementsInFront
				var nol:int = newOccluding2.length
				for(var n:int=0;n<nol;n++) if(newOccluding.indexOf(newOccluding2[n])<0) newOccluding[newOccluding.length] = newOccluding2[n]
				newOccluding2 = scene.translateToCell(character.x,character.y,character.top).elementsInFront
				nol = newOccluding2.length
				for(n=0;n<nol;n++) if(newOccluding.indexOf(newOccluding2[n])<0) newOccluding[newOccluding.length] = newOccluding2[n]
			} catch(e:Error){}
			
			var ool:int = oldOccluding.length
			for(i=0;i<ool;i++) {
				// Disable occlusions no longer needed
				if(newOccluding.indexOf(oldOccluding[i])<0) scene.renderEngine.stopOcclusion(oldOccluding[i],character)
			}
			
			if(character.occlusion>=100) return
				nol = newOccluding.length
			for(i=0;i<nol;i++) {
				// Enable new occlusions				 	
				if(oldOccluding.indexOf(newOccluding[i])<0) scene.renderEngine.startOcclusion(newOccluding[i],character)
			}
			
			character.currentOccluding = newOccluding
			
			
		}
		
		
		// Main render method for characters
		public static function renderCharacter(scene:fScene,character:fCharacter):void {
			
			
			if(scene.prof) scene.prof.begin("Render char:"+character.id, true )
			
			var light:fOmniLight, elements:Array, nEl:int, len:int, cache:fCharacterShadowCache 
			
			// Move character to its new position
			scene.renderEngine.updateCharacterPosition(character)
			
			// Render all lights and shadows
			len = character.vLights.length
			for(var i:int=0;i<len;i++) {
				
				cache =  character.vLights[i]
				if(!cache.light.removed && cache.withinRange) {
					
					// Start
					light = cache.light as fOmniLight
					scene.renderEngine.renderStart(character,light)
					scene.renderEngine.renderLight(character,light)
					
					// Update shadows for scene character
					elements = cache.elements
					nEl = elements.length
					if(fEngine.characterShadows) for(var i2:Number=0;i2<nEl;i2++) {
						try {
							if(scene.prof) {
								scene.prof.begin("S: "+light.id+" "+elements[i2].id)
								scene.renderEngine.updateShadow(elements[i2],light,character)
								if(scene.prof) scene.prof.end("S: "+light.id+" "+elements[i2].id)
							} else {
								scene.renderEngine.updateShadow(elements[i2],light,character)
							}
						} catch(e:Error) {
							
						}
						
					}
					
					// End
					scene.renderEngine.renderFinish(character,light)
					
				}
				
				
			}
			
			// Update occlusion
			if(character.currentOccluding.length>0) {
				
				if(scene.prof) scene.prof.begin("Occlusion")
				var ocl:int = character.currentOccluding.length 
				for(i=0;i<ocl;i++) scene.renderEngine.updateOcclusion(character.currentOccluding[i],character)
				if(scene.prof) scene.prof.end("Occlusion")
				
			}
			
			if(scene.prof) scene.prof.end("Render char:"+character.id)
			
			
		}
		
		
		
	}
	
}
