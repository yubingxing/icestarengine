// COLLISION PARSER
package com.ice.core.scene.initialize {
	
		// Imports
		
		/**
		* <p>The fSceneCollisionParser class contains static methods that fill the scene's grid with collision information of planes and objects.</p>
		* @private
		*/
		public class fSceneCollisionParser {		


			/** Updates an scene's grid with collision information from its elements */
			public static function calculate(scene:fScene):void {

		  	 // Update grid with object collision information
		  	 var ol:int = scene.objects.length
			   for(var j:Number=0;j<ol;j++) {
			   		var ob:fObject = scene.objects[j]
			   		var rz:int = ob.z/scene.levelSize
			   		var obi:int = ob.x/scene.gridSize
			   		var obj:int = ob.y/scene.gridSize
			   		var height:int = ob.height/scene.levelSize
			   		var rad:int = 1+int((ob.radius/scene.gridSize))
			   		
			   		for(var n:int=obj-rad;n<=obj+rad;n++) {
			   			for(var i:int=obi-rad;i<=(obi+rad);i++) {
			   				for(var k:int=rz;k<=(rz+height);k++) {
			   					try {
			   						var cell:fCell = scene.getCellAt(i,n,k)
			   						cell.walls.objects[cell.walls.objects.length] = ob
			   					} catch(e:Error) {
			   						//trace("Warning: "+ob.id+" extends out of bounds.")
			   					}
			   			  }
			   			}
			   	  }

			   }

				 // Update grid with floor collision information
				 var fll:int = scene.floors.length 
			   for(j=0;j<fll;j++) {
			   		var fl:fFloor = scene.floors[j]
			   		rz = fl.z/scene.levelSize
			   		for(i=fl.i;i<(fl.i+fl.gWidth);i++) {
			   			for(k=fl.j;k<(fl.j+fl.gDepth);k++) {
			   				cell = scene.getCellAt(i,k,rz)
			   				if(cell) cell.walls.bottom = fl
			   				if(rz>0) {
			   					cell = scene.getCellAt(i,k,rz-1)
			   					if(cell) cell.walls.top = fl
			   				}
			   		  }
			   		}
			   }
			   
				 // Update grid with wall collision information
				 var wll:int = scene.walls.length 
			   for(j=0;j<wll;j++) {
			   		var wl:fWall = scene.walls[j]
			   		height = wl.height/scene.levelSize
			   		rz = wl.z/scene.levelSize
			   		if(wl.vertical) {
			   			for(i=wl.j;i<(wl.j+wl.size);i++) {
			   				for(k=rz;k<(rz+height);k++) {
			   					
		   						cell = scene.getCellAt(wl.i,i,k)
		   						if(cell) cell.walls.left = wl
			   					if(wl.i>0) {
			   						cell = scene.getCellAt(wl.i-1,i,k)
			   						if(cell) cell.walls.right = wl
			   					}
			   				}
			   			}
			   		} else {
			   			for(i=wl.i;i<(wl.i+wl.size);i++) {
			   				for(k=rz;k<(rz+height);k++) {
		   						cell = scene.getCellAt(i,wl.j,k)
		   						if(cell) cell.walls.up = wl
			   					if(wl.j>0) {
			   						cell = scene.getCellAt(i,wl.j-1,k)
			   						if(cell) cell.walls.down = wl
			   					}
			   				}
			   			}
			   		}
				 }
				 
				 // End wall loop
				 

			}

	}

}			