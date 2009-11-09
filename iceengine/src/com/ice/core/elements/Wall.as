/**
 * Wall 
 */
package com.ice.core.elements {
	import com.ice.core.Plane;
	
	// Imports
	
	/**
	 * <p>Walls are created when the scene is processed</p>
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT.</p>
	 */
	public class Wall extends Plane {
		
		// Private properties
		
		/** @private */
		public var i:int;
		/** @private */
		public var j:int;
		/** @private */
		public var k:int;
		/** @private */
		public var gHeight:int;
		/** @private */
		public var size:int;
		/** @private */
		public var height:Number;
		/** @private */
		public var bounds: fPlaneBounds;
		
		// Public properties
		
		/**
		 * A wall can be either horizontal ( goes along x axis ) or vertical ( goes along y axis )
		 */
		public var vertical:Boolean;	
		
		/**
		 * A wall can be either horizontal ( goes along x axis ) or vertical ( goes along y axis )
		 */
		public var horizontal:Boolean;
		
		/**
		 * Wall length in pixels.
		 */
		public var pixelSize:Number;
		
		/**
		 * Wall height ( real height, position along z-axis )
		 */
		public var pixelHeight:Number;
		
		// Constructor
		/** @private */
		function Wall(defObj:XML,scene:fScene):void {
			
			// Vertical ?
			this.vertical = (defObj.@direction=="vertical");			  // Orientation
			this.horizontal = !this.vertical;	 							 
			
			// Dimensions, parse size and snap to gride
			this.size = int((defObj.@size/scene.gridSize)+0.5);  			 		// Size ( in cells )
			this.pixelSize = this.size*scene.gridSize+1;
			this.gHeight = int((defObj.@height/scene.levelSize)+0.5);
			this.height = this.pixelHeight = scene.levelSize*this.gHeight;
			
			// Previous
			super(defObj,scene,this.pixelSize,this.pixelHeight)
			
			// Specific coordinates
			this.i = int(this.x/scene.gridSize)                  				// Grid coordinates
			this.j = int(this.y/scene.gridSize)
			this.x0 = this.x1 = this.i*scene.gridSize
			this.y0 = this.y1 = this.j*scene.gridSize
			this.k = int(this.z/scene.levelSize)
			this.z = scene.levelSize*this.k
			this.top = this.z + this.height
			
			if(this.vertical) {                                          // Position
				this.x = scene.gridSize*this.i
				this.y = scene.gridSize*(this.j+(this.size/2))
				this.y1 = scene.gridSize*(this.j+this.size)
			} else {
				this.x = scene.gridSize*(this.i+(this.size/2))
				this.x1 = scene.gridSize*(this.i+this.size)
				this.y = scene.gridSize*this.j
			}                                                                 
			
			// Bounds
			this.bounds = new fPlaneBounds(this)
			
			if(this.vertical) {
				var c1:Point = fScene.translateCoords(0,this.pixelSize,0)
				var c2:Point = fScene.translateCoords(0,0,this.pixelHeight)
				this.bounds2d = new Rectangle(0,c2.y,c1.x,c1.y-c2.y)
			} else {
				c1 = fScene.translateCoords(this.pixelSize,0,this.pixelHeight)
				this.bounds2d = new Rectangle(0,c1.y,c1.x,-c1.y)
			}
			
			// Screen area
			this.screenArea = this.bounds2d.clone()
			this.screenArea.offsetPoint(fScene.translateCoords(this.x0,this.y0,this.z))
			
		}
		
		// Methods
		
		// Is this wall in front of other plane ? Note that a false return value doesn not imply the opposite: None of the planes
		// may be in front of each other
		/** @private */
		public override function inFrontOf(p:Plane):Boolean {
			
			if(!this.vertical) {
				
				// If I am horizontal
				if(p is Wall) {
					
					var wall:Wall = p as Wall
					if(wall.vertical) {
						if(this.j>wall.j && this.i<wall.i && (this.k+this.gHeight)>wall.k) return true
						return false
					} else {
						if(this.j>wall.j && this.i<(wall.i+wall.size)) return true
						return false
					}
				} else {
					var floor:Floor = p as Floor
					if( (this.i<(floor.i+floor.gWidth) && this.j>floor.j && (this.k+this.gHeight)>floor.k)
						//|| (this.j>=(floor.j+floor.gDepth) && this.i<(floor.i+floor.gWidth))
						//|| (this.j>floor.j && (this.i+this.size)<=floor.i)
					) return true
					return false
				}
				
			} else {
				
				// If I am vertical
				if(p is Wall) {
					
					wall = p as Wall
					if(wall.vertical) {
						if(this.i<wall.i && (this.j+this.size)>wall.j) return true
						return false
					} else {
						if(this.i<(wall.i+wall.size) && (this.j+this.size)>wall.j && (this.k+this.gHeight)>wall.k) return true
						return false
					}
				} else {
					floor = p as Floor
					if( (this.i<(floor.i+floor.gWidth) && (this.j+this.size)>floor.j && (this.k+this.gHeight)>floor.k) 
						//|| (this.i<=floor.i && (this.j+this.size)>floor.j)
						//|| (this.i>floor.i && this.i<(floor.i+floor.gWidth) && this.j>=(floor.j+floor.gDepth))
					) return true
					return false
				}
			}
			
			
		}
		
		/** @private */
		public override function distanceTo(x:Number,y:Number,z:Number):Number {
			
			if(this.vertical) {
				var d2d:Number = mathUtils.distancePointToSegment(new Point(this.x,this.y0),new Point(this.x,this.y1),new Point(x,y))
			} else {
				d2d = mathUtils.distancePointToSegment(new Point(this.x0,this.y),new Point(this.x1,this.y),new Point(x,y))
			}
			if(z>this.top) {
				var dz:Number = z-this.top
			} else if(z<this.z) {
				dz = this.z-z
			} else {
				dz = 0			  
			}
			
			return Math.sqrt(dz*dz + d2d*d2d)
			
		}
		
		/** @private */
		public function disposeWall():void {
			
			this.bounds = null
			this.disposePlane()
			
		}
		
		/** @private */
		public override function dispose():void {
			this.disposeWall()
		}		
		
		
	}
	
}