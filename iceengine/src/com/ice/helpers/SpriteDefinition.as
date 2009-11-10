package com.ice.helpers {
	
		// Imports
		import flash.utils.*
		
		/**
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* Container object for a sprite definition
	  */
		public class SpriteDefinition {

			// Public properties
			public var angle:Number
			
			public var sprite:Class

			public var shadow:Class

			// Constructor
			function SpriteDefinition(angle:Number,sprite:Class,shadow:Class):void {
			
			   this.angle = angle
			   this.sprite = sprite
			   this.shadow = shadow
			}

		}
		
} 
