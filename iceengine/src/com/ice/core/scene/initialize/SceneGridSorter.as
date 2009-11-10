// GRID SORTER
package com.ice.core.scene.initialize {
	
	// Imports
	
	/**
	 * The grid sorter performs zSorting of a given scene. zSorting is a cpu-intensive calculation that needs to be split into several cycles.
	 * 
	 * @private
	 */
	public class SceneGridSorter extends EventDispatcher {
		
		/**
		 * An string describing the process of zSorting.
		 * Events dispatched by the grid sorter contain this String as a description of what is happening
		 */
		public static const SORTDESCRIPTION:String = "Z Sorting scene"
		
		
		// Simple sort functions
		public static function sortHorizontals(one:fWall,two:fWall):Number {
			if(one.j>two.j || (one.j==two.j && one.i>two.i)) return -1
			else return 1
		}
		
		public static function sortVerticals(one:fWall,two:fWall):Number {
			if(one.i<two.i || (one.i==two.i && one.j>two.j)) return -1
			else return 1
		}
		
		public static function sortFloors(onef:fFloor,twof:fFloor):Number {
			if(onef.j>twof.j || (onef.j==twof.j && onef.k<twof.k)) return -1
			else return 1
		}
		
		// Private properties
		private var scene:fScene
		private var sortCubes:Array
		private var allVerticals:Array
		private var allHorizontals:Array
		private var serializedSortCubes:Array
		private var cubeBeingProcessed:int
		private var myTimer:Timer
		
		// Constructor
		public function SceneGridSorter(s:fScene):void {
			this.scene = s				
		}
		
		// Create grid for this scene ( only where there are floors )
		public function createGrid():void {
			
			this.scene.grid = new Array
			this.scene.allUsedCells = new Array
			var fl:int = this.scene.floors.length
			for(var fi=0;fi<fl;fi++) {
				var f:fFloor = this.scene.floors[fi]
				if(f.k==0) {
					var fl2:int = (f.i+f.gWidth)
					for(var i:int = f.i;i<fl2;i++) {
						if(!this.scene.grid[i]) this.scene.grid[i] = new Array
						var temp:Array = this.scene.grid[i]
						var fl3:int = (f.j+f.gDepth)
						for(var j:int = f.j;j<fl3;j++) {
							temp[j] = new Array
						}
					}
				}
			}
			
		}
		
		// Start zSorting algorythm.
		public function start():void {
			
			// Create cubes
			this.sortCubes = new Array
			this.serializedSortCubes = new Array
			this.allVerticals = new Array
			this.allHorizontals = new Array
			
			var cwidth:int = Math.ceil(this.scene.width/this.scene.sortCubeSize)
			var cdepth:int = Math.ceil(this.scene.depth/this.scene.sortCubeSize)
			var cheight:int = Math.ceil(this.scene.height/this.scene.sortCubeSize)
			if(cwidth==0) cwidth=1
			if(cdepth==0) cdepth=1
			if(cheight==0) cheight=1
			
			for(var i:int=0;i<cwidth;i++) {
				this.sortCubes[i] = new Array
				for(var j:int=0;j<cdepth;j++) {
					this.sortCubes[i][j] = new Array
					for(var k:int=0;k<cheight;k++) {
						var n:fSortCube = new fSortCube()
						n.i = i
						n.j = j
						n.k = k
						n.zIndex = ((((((cwidth-i+1)+(j*cwidth+2)))*cheight)+k))/(cwidth*cdepth*cheight)
						n.walls = []
						n.floors = []
						this.sortCubes[i][j][k] = n
						this.serializedSortCubes.push(n)
					}
				}
			}
			
			// Assign walls and floors to their cubes
			for(i=0;i<this.scene.walls.length;i++) {
				var w:fWall = this.scene.walls[i]
				this.sortCubes[Math.floor((w.x+2)/this.scene.sortCubeSize)][Math.floor((w.y+2)/this.scene.sortCubeSize)][Math.floor((w.z+2)/this.scene.sortCubeSize)].walls.push(w)
				if(w.vertical) this.allVerticals[this.allVerticals.length] = w
				else this.allHorizontals[this.allHorizontals.length] = w
			}
			
			for(i=0;i<this.scene.floors.length;i++) {
				var f:fFloor = this.scene.floors[i]
				this.sortCubes[Math.floor((f.x+2)/this.scene.sortCubeSize)][Math.floor((f.y+2)/this.scene.sortCubeSize)][Math.floor((f.z+2)/this.scene.sortCubeSize)].floors.push(f)
			}
			
			this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,0,SceneGridSorter.SORTDESCRIPTION,0,SceneGridSorter.SORTDESCRIPTION))
			
			
			// Process first cube
			this.cubeBeingProcessed = 0
			this.zSortCube()
			
		}
		
		// zSort all planes in current sort cube (see http://ericlin2.tripod.com/walls/wallt.html)
		// Ok so after 3 different crappy homebrewed algorythms I google isometric plane sort and found a simple loop that
		// beats all my previous attempts in both speed and consistency...
		private function zSortCube():void {
			
			// Init
			var cube:fSortCube = this.serializedSortCubes[this.cubeBeingProcessed]
			var sortArray:Array = new Array
			
			// Add walls to list
			var vl:int = cube.walls.length
			for(var i:int=0;i<vl;i++) {
				sortArray[sortArray.length] = cube.walls[i]
			}
			
			// Add floors to list. Floors at z=0 are skipped ( will be behind everything )
			var fl:int = cube.floors.length 
			for(i=0;i<fl;i++) {
				var f:fFloor = cube.floors[i]
				if(f.k!=0) {
					sortArray[sortArray.length] = f
				} else {
					f.setZ(-this.scene.floors.length+this.scene.computeZIndex(f.i,f.j+f.gDepth-1,f.k))
				}
			}
			
			// z Sort loop
			var buffer = []
			var sl:int = sortArray.length
			for (i=0;i<sl;i++) {
				
				var plane:fPlane = sortArray[i]
				var insertPos:int = 0
				var inserted:Boolean = false
				
				// We start placing it at the back of the stack and we move it forward until we find one that is effectively in front of the new one
				var bl:int = buffer.length
				for(var j:int=0;j<bl;j++) {
					var elt:fPlane = buffer[j]
					if (!inserted) {
						
						// Search for some plane in front, otherwise insert it in the last position of the array
						if(elt.inFrontOf(plane)) {
							insertPos = j
							inserted = true
							buffer.splice(j, 0, plane)
							j++
							// Increase j index, because we inserted the plane					
						}
					} else {
						
						// After insertion, the new plane should be in behind the rest of planes in the buffer
						// We need to enforce this and move the remaining planes to the back of the queue if necessary
						if(!elt.inFrontOf(plane)) {
							for(var k:int=j-1;k>=insertPos;k--) {
								var elt2:fPlane = buffer[k]
								if(elt.inFrontOf(elt2)) {
									break
								}
							}
							buffer.splice(j, 1)
							buffer.splice(k+1, 0, elt)
						}
					}
				}
				
				// Insert as topmost plane
				if(!inserted) buffer.push(plane)
			}
			
			// End sort
			sl = buffer.length
			for(i=0;i<sl;i++) (buffer[i] as fPlane).setZ((i+1)/(sl+2))
			
			// Next step
			this.myTimer = new Timer(20, 1)
			this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.zSortCubeComplete)
			this.myTimer.start()
			
		}
		
		
		// When a cube has been sorted
		private function zSortCubeComplete(event:TimerEvent):void {
			
			event.target.removeEventListener(TimerEvent.TIMER_COMPLETE, this.zSortCubeComplete)
			
			// Update status
			this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,100*this.cubeBeingProcessed/this.serializedSortCubes.length,SceneGridSorter.SORTDESCRIPTION,100*this.cubeBeingProcessed/this.serializedSortCubes.length,SceneGridSorter.SORTDESCRIPTION))
			
			// Is there another cube to process ?
			this.cubeBeingProcessed++
			if(this.cubeBeingProcessed<this.serializedSortCubes.length) this.zSortCube()
			else this.zSortComplete()
			
		}
		
		
		// End zort (all cubes have been sorted)
		private function zSortComplete():void {
			
			// Create one single array with everything, applying sortCube depth offsets
			var sortArray:Array = new Array
			for(i=0;i<this.serializedSortCubes.length;i++) {
				var cube:fSortCube = this.serializedSortCubes[i]
				for(j=0;j<cube.walls.length;j++) {
					w = cube.walls[j]
					w.setZ((10*cube.zIndex)+w.zIndex)
					sortArray[sortArray.length] = w
				}
				for(j=0;j<cube.floors.length;j++) {
					f = cube.floors[j]
					if(f.k!=0) {
						f.setZ((10*cube.zIndex)+f.zIndex)
						sortArray[sortArray.length] = f
					}
				}
			}
			
			// Normalize zIndexes
			sortArray.sortOn("zIndex",Array.NUMERIC)
			var sl:int = sortArray.length
			for(var i:int=0;i<sl;i++) (sortArray[i] as fPlane).setZ(i+1)
			
			// Generate sort areas for the scene
			var sortAreas:Array = new Array
			var tree:fRTree = new fRTree()
			
			var area:fSortArea = new fSortArea(0,0,0,this.scene.gridWidth,this.scene.gridDepth,this.scene.gridHeight,0)
			//tree.addCube(area.getCube(),sortAreas.length)
			sortAreas[sortAreas.length] = area
			
			var vl:int = this.allVerticals.length 
			for(i=0;i<vl;i++) {
				var w:fWall = this.allVerticals[i]
				area = new fSortArea(0,w.j,0,w.i-1,this.scene.gridDepth-w.j,this.scene.gridHeight,w.zIndex)
				//tree.addCube(area.getCube(),sortAreas.length)
				sortAreas[sortAreas.length] = area
			}
			
			var hl:int = this.allHorizontals.length
			for(i=0;i<hl;i++) {
				w = this.allHorizontals[i]
				area = new fSortArea(0,w.j,0,w.i+w.size-1,this.scene.gridDepth-w.j,this.scene.gridHeight,w.zIndex)
				//tree.addCube(area.getCube(),sortAreas.length)
				sortAreas[sortAreas.length] = area
			}
			
			var fl:int = this.scene.floors.length 
			for(i=0;i<fl;i++) {
				var f:fFloor = this.scene.floors[i]
				if(f.k!=0) {
					area = new fSortArea(f.i,f.j,f.k,f.gWidth-1,f.gDepth-1,this.scene.gridHeight-f.k,f.zIndex)
					//tree.addCube(area.getCube(),sortAreas.length)
					sortAreas[sortAreas.length] = area
					
					area = new fSortArea(0,f.j,0,f.i-1,this.scene.gridDepth-f.j,this.scene.gridHeight,f.zIndex)
					//tree.addCube(area.getCube(),sortAreas.length)
					sortAreas[sortAreas.length] = area
					
					area = new fSortArea(f.i,f.j+f.gDepth,0,f.gWidth-1,this.scene.gridDepth-f.j-f.gDepth,this.scene.gridHeight,f.zIndex)
					//tree.addCube(area.getCube(),sortAreas.length)
					sortAreas[sortAreas.length] = area
				}
			}
			
			// Split sortAreas per row, for faster lookups
			sortAreas.sortOn("zValue",Array.DESCENDING | Array.NUMERIC)
			
			this.scene.sortAreas = new Array
			
			var sw:int = this.scene.gridWidth 
			for(i=0;i<sw;i++) {
				var temp:Array = new Array
				var sal:int = sortAreas.length 
				for(j=0;j<sal;j++) {
					var s:fSortArea = sortAreas[j]
					if(i>=s.i && i<=(s.i+s.width)) temp[temp.length] = s
				}
				this.scene.sortAreas[i] = temp
			}
			
			//this.scene.sortAreas = sortAreas
			//this.scene.sortAreasRTree = tree
			
			// Set depth of objects and characters and finish zSort
			var ol:int = this.scene.objects.length
			for(var j:int=0;j<ol;j++) (this.scene.objects[j] as fObject).updateDepth()
			
			var cl:int = this.scene.characters.length
			for(j=0;j<cl;j++) (this.scene.characters[j] as fCharacter).updateDepth()
			
			// Dispose resources
			this.scene = null
			this.allVerticals = null
			this.allHorizontals = null
			this.sortCubes = null
			this.serializedSortCubes = null
			
			// Events
			this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,100,SceneGridSorter.SORTDESCRIPTION,100,SceneGridSorter.SORTDESCRIPTION))
			this.dispatchEvent(new Event(Event.COMPLETE))
			
		}
		
	}
	
	
}