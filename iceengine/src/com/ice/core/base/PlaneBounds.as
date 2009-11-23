// Bounds
package com.ice.core.base {
	import com.ice.core.elements.Floor;
	import com.ice.core.elements.Wall;
	
	/**
	 * @private
	 * Stores auxiliar data about planes and holes that the render engine uses internally
	 * This data is basically a bounding box for the element
	 */
	public class PlaneBounds {
		
		// Imports
		
		// Public properties
		public var x:Number;
		public var y:Number;
		public var xrel:Number;
		public var yrel:Number;
		public var z:Number;
		public var x0:Number;
		public var x1:Number;
		public var y0:Number;
		public var y1:Number;
		public var top:Number;
		public var width:Number;
		public var height:Number;
		public var depth:Number;
		public var vertical:Boolean;
		public var holes:Array;
		
		// Constructor. If a wall of floor is passed, the data is filled automatically
		public function PlaneBounds(element:Object = null):void {
			
			// Is it a Floor ?
			if(element is Floor) {
				var floor:Floor = element as Floor;
				this.x = floor.x;
				this.y = floor.y;
				this.z = floor.z;
				this.x0 = floor.x;
				this.x1 = floor.x + floor.width;
				this.y0 = floor.x;
				this.y1 = floor.x + floor.depth;
				this.width = floor.width;
				this.depth = floor.depth;
			}
			
			// Is it a Wall ?
			if(element is Wall) {
				var wall:Wall = element as Wall;
				this.top = wall.top;
				this.z = wall.z;
				if(wall.vertical) {
					this.vertical = true;
					this.x = wall.x;
					this.y = wall.y;
					this.x0 = wall.x;
					this.x1 = wall.x;
					this.y0 = wall.y0;
					this.y1 = wall.y1;
				} else {
					this.vertical = false;
					this.x = wall.x;
					this.y = wall.y;
					this.x0 = wall.x0;
					this.x1 = wall.x1;
					this.y0 = wall.y;
					this.y1 = wall.y;
				}
			}
		}
	}
}