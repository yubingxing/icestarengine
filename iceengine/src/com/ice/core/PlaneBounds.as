// Bounds
package com.ice.core {
	
		/**
		* @private
		* Stores auxiliar data about planes and holes that the render engine uses internally
		* This data is basically a bounding box for the element
		*/
		public class PlaneBounds {
			
			// Imports
			
			// Public properties
			public var x:Number
			public var y:Number
			public var xrel:Number
			public var yrel:Number
			public var z:Number
			public var x0:Number
			public var x1:Number
			public var y0:Number
			public var y1:Number
			public var top:Number
			public var width:Number
			public var height:Number
			public var depth:Number
			public var vertical:Boolean
			public var holes:Array
			
			// Constructor. If a wall of floor is passed, the data is filled automatically
			public function PlaneBounds(element:Object=null):void {
				
				// Is it a Floor ?
				if(element is fFloor) {
					var f:fFloor = element as fFloor
			    this.x = f.x
			    this.y = f.y
			    this.z = f.z
			    this.x0 = f.x
			    this.x1 = f.x+f.width
			    this.y0 = f.x
			    this.y1 = f.x+f.depth
			    this.width = f.width
			    this.depth = f.depth
				}
			
				// Is it a Wall ?
				if(element is fWall) {
					var w:fWall = element as fWall
			    this.top = w.top
			    this.z = w.z
				  if(w.vertical) {
				  	 this.vertical = true
				  	 this.x = w.x
				  	 this.y = w.y
				  	 this.x0 = w.x
				  	 this.x1 = w.x
				  	 this.y0 = w.y0
				  	 this.y1 = w.y1
				  } else {
				     this.vertical = false
				  	 this.x = w.x
				  	 this.y = w.y
				  	 this.x0 = w.x0
				  	 this.x1 = w.x1
				  	 this.y0 = w.y
				  	 this.y1 = w.y
			    }
				}


			}
		
		}
		
		
}