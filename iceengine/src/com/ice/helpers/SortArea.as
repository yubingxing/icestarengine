package com.ice.helpers {
	
		// Imports
		import flash.utils.*
		import org.ffilmation.utils.rtree.*

		/**
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* This object defines an area that shares a common zSort value. Each plane generates several of these areas. Then
		* to assign a zIndex to a given cell, these areas a searched to see where the cell belongs.
	  */
		public class SortArea {

			// Geometry
			public var i:int
			public var j:int
			public var k:int
			public var width:int
			public var depth:int
			public var height:int
			
			// Value
			public var zValue:int

			// Constructor
			public function SortArea(i:int,j:int,k:int,width:int,depth:int,height:int,zValue:int):void {
				
			   this.i = i
			   this.j = j
			   this.k = k
			   this.width = width
			   this.depth = depth
			   this.height = height
			   this.zValue = zValue
			   
			}
			
			// Tests a coordinate against this area
			public function isPointInside(i:int,j:int,k:int):Boolean {
				if(i<this.i || i>this.i+this.width) return false
				if(j<this.j || j>this.j+this.depth) return false
				if(k<this.k || k>this.k+this.height) return false
				return true
			}
			
			public function getCube():fCube {
				return new fCube(this.i+0.1,this.j+0.1,this.k+0.1,this.i+this.width-0.1,this.j+this.depth-0.1,this.k+this.height-0.1)
			}
			

		}
		
} 
