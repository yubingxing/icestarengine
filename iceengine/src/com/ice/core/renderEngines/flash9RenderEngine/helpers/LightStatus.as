package com.ice.core.renderEngines.flash9RenderEngine.helpers {
	
		// Imports

		/**
		* @private
		* Keeps track of several variables of one light in one plane
		*/
		public class LightStatus {

			// Public properties
	    public var element:fPlane
			public var light:fLight
			
			public var created:Boolean
			public var lightZ:Number
			public var localPos:Point = new Point()
			public var localScale:Number = 0
			public var hidden:Boolean = false
			
			// Constructor
			function LightStatus(element:fPlane,light:fLight):void {
			
			   // References
			   this.element = element
			   this.light = light
			
			   // Status
			   this.created = false              // Indicates if all containers have already been created
			   this.lightZ = 0                	 // Light's last z position
			
			}

		}

}
