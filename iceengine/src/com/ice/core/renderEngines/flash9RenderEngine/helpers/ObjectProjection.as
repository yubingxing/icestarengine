package com.ice.core.renderEngines.flash9RenderEngine.helpers {
	
	// Imports
	
	/**
	 * @private
	 * Contains projection information for a given object
	 */
	public class ObjectProjection {
		
		// Public properties
		
		/**
		 * The four Points that enclose the objects projection 
		 */
		public var polygon:Array
		
		/** 
		 * The length of the object's projection
		 */
		public var size:Number
		
		/**
		 * Origin point for projection
		 */
		public var origin:Point
		
		/**
		 * End point for projection
		 */
		public var end:Point
		
		// Constructor
		function ObjectProjection():void {
			this.size = 0
		}
	}
} 
