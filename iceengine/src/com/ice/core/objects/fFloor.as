package com.ice.core.objects {
	
		// Imports

		/**
		* <p>Arbitrary-sized tiles that form each floor in your scene</p>
		*
		* <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT.<br>
		* Floors are created when the scene is processed</p>
		*
		*/
		public class fFloor extends fPlane {
		
			// Private properties
			
			/** @private */
			public var gWidth:int
			/** @private */
			public var gDepth:int
			/** @private */
			public var i:int
			/** @private */
			public var j:int
			/** @private */
			public var k:int
			
			// Public properties

			/**
			* Floor width in pixels. Size along x-axis
			*/
			public var width:Number
			
			/**
			* Floor depth in pixels. Size along y-axis
			*/
			public var depth:Number

			/** @private */
	    public var bounds:fPlaneBounds
			   
			// Constructor
			/** @private */
			function fFloor(defObj:XML,scene:fScene):void {
			
			   // Dimensions, parse size and snap to gride
			   this.gWidth = int((defObj.@width/scene.gridSize)+0.5)
			   this.gDepth = int((defObj.@height/scene.gridSize)+0.5)
			   this.width = scene.gridSize*this.gWidth
			   this.depth = scene.gridSize*this.gDepth
			   
			   // Previous
				 super(defObj,scene,this.width,this.depth)
			   
			   // Specific coordinates
			   this.i = int((defObj.@x/scene.gridSize)+0.5)
			   this.j = int((defObj.@y/scene.gridSize)+0.5)
			   this.k = int((defObj.@z/scene.levelSize)+0.5)
			   this.x0 = this.x = this.i*scene.gridSize
			   this.y0 = this.y = this.j*scene.gridSize
			   this.top = this.z = this.k*scene.levelSize
			   this.x1 = this.x0+this.width
			   this.y1 = this.y0+this.depth
			   
			   // Bounds
			   this.bounds = new fPlaneBounds(this)
			   var c1:Point = fScene.translateCoords(this.width,0,0)
			   var c2:Point = fScene.translateCoords(this.width,this.depth,0)
			   var c3:Point = fScene.translateCoords(0,this.depth,0)
			   this.bounds2d = new Rectangle(0,c1.y,c2.x,c3.y-c1.y)

			   // Screen area
			   this.screenArea = this.bounds2d.clone()
				 this.screenArea.offsetPoint(fScene.translateCoords(this.x,this.y,this.z))

			}


			// Is this floor in front of other plane ? Note that a false return value does not imply the opposite: None of the planes
			// may be in front of each other
			/** @private */
			public override function inFrontOf(p:fPlane):Boolean {
				
					if(p is fWall) {
						  var wall:fWall = p as fWall
						  if(wall.vertical) {
								if( (this.i<wall.i && (this.j+this.gDepth)>wall.j && this.k>wall.k) 
								    //|| ((this.j+this.gDepth)>wall.j && (this.i+this.gWidth)<=wall.i)
								    //|| (this.i<=wall.i && (this.j+this.gDepth)>wall.j && this.k>=(wall.k+wall.gHeight)) 
								    ) return true
								return false
			     		} else {
								if( (this.i<(wall.i+wall.size) && (this.j+this.gDepth)>wall.j && this.k>wall.k)
								    //|| (this.i<(wall.i+wall.size) && this.j>=wall.j)
								    //|| (this.i<(wall.i+wall.size) && (this.j+this.gDepth)>wall.j && this.k>=(wall.k+wall.gHeight))
								    ) return true
								return false
			     		}
			    } else {
			     		var floor:fFloor = p as fFloor		
			     		if ( (this.i<(floor.i+floor.gWidth) && (this.j+this.gDepth)>floor.j && this.k>floor.k) 
			     		      || ((this.j+this.gDepth)>floor.j && (this.i+this.gWidth)<=floor.i)
			     		      || (this.i>=floor.i && this.i<(floor.i+floor.gWidth) && this.j>=(floor.j+floor.gDepth)) 
			     		    ) return true
			     		return false
			    }
					
			}

			/** @private */
			public override function distanceTo(x:Number,y:Number,z:Number):Number {
			
				 // Easy case
				 if(x>=this.x && x<=this.x+this.width && y>=this.y && y<=this.y+this.depth) return ((this.z-z)>0) ? (this.z-z) : -(this.z-z)
				 
				 var d2d:Number
				 if(y<this.y) {
				 	  d2d = mathUtils.distancePointToSegment(new Point(this.x,this.y),new Point(this.x+width,this.y),new Point(x,y))
				 }
				 else if(y>(this.y+this.depth)) {
				 	  d2d = mathUtils.distancePointToSegment(new Point(this.x,this.y+this.depth),new Point(this.x+width,this.y+this.depth),new Point(x,y))
				 } else {
				 	
				 		if(x<this.x) d2d = mathUtils.distancePointToSegment(new Point(this.x,this.y),new Point(this.x,this.y+this.depth),new Point(x,y))
				 		else if(x>this.x+this.width) d2d = mathUtils.distancePointToSegment(new Point(this.x+this.width,this.y),new Point(this.x+this.width,this.y+this.depth),new Point(x,y))
				 	  else d2d = 0
				 }

				 var dz:Number = z-this.z
			   return Math.sqrt(dz*dz + d2d*d2d)
			
			}

			/** @private */
			public function disposeFloor():void {

	    	this.bounds = null
				this.disposePlane()
				
			}

			/** @private */
			public override function dispose():void {
				this.disposeFloor()
			}		

			
		}
}
