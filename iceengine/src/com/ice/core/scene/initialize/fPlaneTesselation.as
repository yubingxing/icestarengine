// PLANE TESSELATION
package com.ice.core.scene.initialize {
	
		// Imports
		
		/**
		* This class provides method to tesselate planes. Tesselation is used to split the scene's geometry into
		* smaller pieces more convenient to the engine's internal calculation.
		* 
		* @private
		*/
		public class fPlaneTesselation {
			
			/**
			* This method tesselates a floor using an imaginary grid
			*
			* @param f The floor to be tesselated
			* @cubesize The size of the imaginary grid that is used to split the floor
			* @return An array of floors
			*/
			public static function tesselateFloor(f:fFloor,cubeSize:int):Array {
				
				var toBeXTested:Array = []
				var toBeReturned:Array = []
				
				// Split along Y axis
				var startCube:int = Math.floor((f.y+2)/cubeSize)
				var endCube:int = Math.floor((f.y+f.depth-2)/cubeSize)
				if(startCube!=endCube) {
					
					var splitY:int = (startCube+1)*cubeSize
					var xml1:XML = f.xmlObj.copy()
					xml1.@height = splitY-f.y
					xml1.@id+="_upSplit"
					if(xml1.@height>=(f.scene.gridSize/2)) toBeXTested[toBeXTested.length] = new fFloor(xml1,f.scene)

					var xml2:XML = f.xmlObj.copy()
					xml2.@y = splitY
					xml2.@id+="_downSplit"
					xml2.@height = f.y+f.depth-splitY
					if(xml2.@height>=(f.scene.gridSize/2)) toBeXTested[toBeXTested.length] = new fFloor(xml2,f.scene)
					
					f.dispose()
					
				} else {
					toBeXTested[toBeXTested.length] = f
				}

				// Split along X axis
				var l:int = toBeXTested.length
				for(var i:int=0;i<l;i++) {
					
					f = toBeXTested[i]
					startCube = Math.floor((f.x+2)/cubeSize)
					endCube = Math.floor((f.x+f.width-2)/cubeSize)
					if(startCube!=endCube) {
						
						var splitX:int = (startCube+1)*cubeSize
						xml1 = f.xmlObj.copy()
						xml1.@width = splitX-f.x
						xml1.@id+="_leftSplit"
						if(xml1.@width>=(f.scene.gridSize/2)) toBeReturned[toBeReturned.length] = new fFloor(xml1,f.scene)
        	
						xml2 = f.xmlObj.copy()
						xml2.@x = splitX
						xml2.@id+="_rightSplit"
						xml2.@width = f.x+f.width-splitX
						if(xml2.@width>=(f.scene.gridSize/2)) toBeReturned[toBeReturned.length] = new fFloor(xml2,f.scene)
						
						f.dispose()
						
					} else {
						toBeReturned[toBeReturned.length] = f
					}
					
				}

				return toBeReturned				
				
				
			}


			/**
			* This method tesselates a wall using an imaginary grid
			*
			* @param w The wall to be tesselated
			* @cubesize The size of the imaginary grid that is used to split the floor
			* @return An array of floors
			*/
			public static function tesselateWall(w:fWall,cubeSize:int):Array {

				var toBeZTested:Array = []
				var toBeReturned:Array = []
				
				if(w.vertical) {
					
					// Split along Y axis
					var startCube:int = Math.floor((w.y0+2)/cubeSize)
					var endCube:int = Math.floor((w.y1-2)/cubeSize)
					if(startCube!=endCube) {
						
						var splitY:int = (startCube+1)*cubeSize
						var xml1:XML = w.xmlObj.copy()
						xml1.@size = splitY-w.y0
						xml1.@id+="_upSplit"
						if(xml1.@size>=(w.scene.gridSize/2)) toBeZTested[toBeZTested.length] = new fWall(xml1,w.scene)
						
						var xml2:XML = w.xmlObj.copy()
						xml2.@y = splitY
						xml2.@id+="_downSplit"
						xml2.@size = w.y1-splitY
						if(xml2.@size>=(w.scene.gridSize/2)) toBeZTested[toBeZTested.length] = new fWall(xml2,w.scene)
						
						w.dispose()
						
					} else {
						toBeZTested[toBeZTested.length] = w
					}

				} else {

					// Split along X axis
					startCube = Math.floor((w.x0+2)/cubeSize)
					endCube = Math.floor((w.x1-2)/cubeSize)
					if(startCube!=endCube) {
						
						var splitX:int = (startCube+1)*cubeSize
						xml1 = w.xmlObj.copy()
						xml1.@size = splitX-w.x0
						xml1.@id+="_leftSplit"
						if(xml1.@size>=(w.scene.gridSize/2)) toBeZTested[toBeZTested.length] = new fWall(xml1,w.scene)

						xml2 = w.xmlObj.copy()
						xml2.@x = splitX
						xml2.@id+="_rightSplit"
						xml2.@size = w.x1-splitX
						if(xml2.@size>=(w.scene.gridSize/2)) toBeZTested[toBeZTested.length] = new fWall(xml2,w.scene)
						
						w.dispose()
						
					} else {
						toBeZTested[toBeZTested.length] = w
					}
				
				
				}
				
				// Split along Z axis
				var l:int = toBeZTested.length
				for(var i:int=0;i<l;i++) {
					
					w = toBeZTested[i]
					startCube = Math.floor((w.z+2)/cubeSize)
					endCube = Math.floor((w.top-2)/cubeSize)
					if(startCube!=endCube) {
						
						var splitZ:int = (startCube+1)*cubeSize
						xml1 = w.xmlObj.copy()
						xml1.@height = splitZ-w.z
						xml1.@id+="_lowerSplit"
						if(xml1.@height>=(w.scene.levelSize/2)) toBeReturned[toBeReturned.length] = new fWall(xml1,w.scene)
        	
						xml2 = w.xmlObj.copy()
						xml2.@z = splitZ
						xml2.@id+="_upperSplit"
						xml2.@height = w.top-splitZ
						if(xml2.@height>=(w.scene.levelSize/2)) toBeReturned[toBeReturned.length] = new fWall(xml2,w.scene)
						
						w.dispose()
						
					} else {
						toBeReturned[toBeReturned.length] = w
					}
					
				}

				return toBeReturned
				
			}
			
			
		}
		
}
