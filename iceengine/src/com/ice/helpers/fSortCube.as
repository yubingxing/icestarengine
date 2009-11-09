package com.ice.helpers {
	
		// Imports
		import flash.utils.*
		
		/**
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* Huge scenes are split into cubes for faster depthSorting. This datatype helps the process
	  */
		public class fSortCube {

			public var i:int
			public var j:int
			public var k:int
			public var zIndex:Number
			public var walls:Array
			public var floors:Array

		}
		
} 
