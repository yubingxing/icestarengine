// OCCLUSION PARSER
package com.ice.core.scene.initialize {
	
	// Imports
	
	/**
	 * <p>The fSceneOcclusionParser class contains static methods that fill the scene's grid with oclusion information of planes and objects.</p>
	 * @private
	 */
	public class fSceneOcclusionParser {		
		
		/** Updates an scene's grid with occlusion information from its elements */
		public static function calculate(scene:fScene):void {
			
			// Update grid with object occlusion information
			var ol:int = scene.objects.length
			for(var n:Number=0;n<ol;n++) {
				var ob:fObject = scene.objects[n]
				var obz:int = ob.z/scene.levelSize
				var obi:int = ob.x/scene.gridSize
				var obj:int = ob.y/scene.gridSize
				var height:int = ob.height/scene.levelSize
				var rad:int = int((ob.radius/scene.gridSize)+0.5)
				
				var realPos:Point = fScene.translateCoords(ob.x,ob.y,ob.z)
				var bounds:Rectangle = ob.bounds2d.clone()
				bounds.x += realPos.x
				bounds.y += realPos.y
				
				var cnt:int = 0
				do {
					
					var some:Boolean = false
					for(var i:int=-rad;i<=rad;i++) {
						
						var row:int = obi+i
						var col:int = obj+i
						var z:int = obz
						var inside:Boolean = true
						
						do {
							
							try {
								var cell:fCell = scene.getCellAt(row,col,z)
							} catch(e:Error) {
								cell = null
							}
							
							if(cell) {
								var candidate:Point = fScene.translateCoords(cell.x,cell.y,cell.z)
								if(bounds.contains(candidate.x,candidate.y)) {
									cell.elementsInFront[cell.elementsInFront.length] = ob
									some = true
								} else inside = false
							}
							z++
							
						} while(cell && inside)			   			  
						
					}
					cnt++
					if(cnt%2==0) obi++
					else obj--
					
				} while(some)
				
			}
			
			// Wall occlusion
			var wl:int = scene.walls.length 
			for(n=0;n<wl;n++) {
				var wa:fWall = scene.walls[n]
				obz = wa.z/scene.levelSize
				obi = ((wa.vertical)?(wa.x):(wa.x0))/scene.gridSize
				obj = ((wa.vertical)?(wa.y0):(wa.y))/scene.gridSize
				height = wa.gHeight
				
				for(var j:int=0;j<obz+height;j++) {
					
					for(i=0;i<wa.size;i++) {
						
						if(wa.vertical) {
							row = obi+j
							col = obj-j+i
						} else {
							row = obi+j+i
							col = obj-j-1
						}
						
						for(z = 0;z<obz+height;z++) {
							try {
								cell = scene.getCellAt(row,col,z)
								cell.elementsInFront[cell.elementsInFront.length] = wa
							} catch(e:Error) {}
						}
						
					}
					
				} 
				
			}
			
			
			// Floor
			var fl:int = scene.floors.length 
			for(n=0;n<fl;n++) {
				var flo:fFloor = scene.floors[n]
				obz = flo.z/scene.levelSize
				obi = flo.i
				obj = flo.j
				
				if(obj!=0) {
					
					var width:Number = flo.gWidth
					var depth:Number = flo.gDepth
					var loops:Number = obz
					for(;loops>0;loops--) {
						for(i=obi;i<obi+width+6+loops;i++) {
							for(j=obj-6-loops;j<obj+depth;j++) {
								try {
									cell = scene.getCellAt(i,j,obz-loops)
									cell.elementsInFront[cell.elementsInFront.length] = flo
								} catch(e:Error) {}
							}
						}
					}
					
				}
				
			}
			
		}
		
	}
	
}
