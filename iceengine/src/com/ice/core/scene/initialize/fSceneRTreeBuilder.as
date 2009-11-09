// COLLISION PARSER
package com.ice.core.scene.initialize {
	
	// Imports
	
	/**
	 * <p>The fSceneRTreeBuilder class contains static methods that build the scene's RTrees</p>
	 * @private
	 */
	public class fSceneRTreeBuilder {		
		
		
		/** Builds an scene's Rtrees */
		public static function buildTrees(scene:fScene):void {
			
			// Create rTrees for all static elements
			var allStatic2d:Array = []
			var tree2D:fRTree = new fRTree()
			var allStatic3d:Array = []
			var tree3D:fRTree = new fRTree()
			
			var l:int = scene.floors.length
			for(var i:int=0;i<l;i++) {
				var f:fFloor = scene.floors[i]
				
				tree3D.addCube(new fCube(f.x,f.y,f.z,f.x+f.width,f.y+f.depth,f.z),allStatic3d.length)
				allStatic3d[allStatic3d.length] = f
				
				tree2D.addCube(new fCube(f.screenArea.left,f.screenArea.top,0,f.screenArea.right,f.screenArea.bottom,0),allStatic2d.length)
				allStatic2d[allStatic2d.length] = f
			}
			
			l = scene.walls.length
			for(i=0;i<l;i++) {
				var w:fWall = scene.walls[i]
				
				if(w.vertical) tree3D.addCube(new fCube(w.x,w.y0,w.z,w.x,w.y1,w.top),allStatic3d.length)
				else tree3D.addCube(new fCube(w.x0,w.y,w.z,w.x1,w.y,w.top),allStatic3d.length)
				allStatic3d[allStatic3d.length] = w
				
				tree2D.addCube(new fCube(w.screenArea.left,w.screenArea.top,0,w.screenArea.right,w.screenArea.bottom,0),allStatic2d.length)
				allStatic2d[allStatic2d.length] = w
			}
			
			l = scene.objects.length
			for(i=0;i<l;i++) {
				var o:fObject = scene.objects[i]
				
				var r:Number = o.radius
				var h:Number = o.height
				tree3D.addCube(new fCube(o.x-r,o.y-r,o.z,o.x+r,o.y+r,o.z+h),allStatic3d.length)
				allStatic3d[allStatic3d.length] = o
				
				tree2D.addCube(new fCube(o.screenArea.left,o.screenArea.top,0,o.screenArea.right,o.screenArea.bottom,0),allStatic2d.length)
				allStatic2d[allStatic2d.length] = o
			}
			
			scene.allStatic2D = allStatic2d
			scene.allStatic2DRTree = tree2D
			
			scene.allStatic3D = allStatic3d
			scene.allStatic3DRTree = tree3D
			
		}
		
	}
	
}			