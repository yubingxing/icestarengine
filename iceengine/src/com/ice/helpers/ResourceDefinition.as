package com.ice.helpers {
	
		// Imports
		import flash.utils.*
		
		/**
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* This object stores a generec resource definition loaded from a definition XML
	  */
		public class ResourceDefinition  {

			// Public vars
			public var xmlData:XML				// The complete XML node as it was retrieved
			public var basepath:String		// The absolute path to the XML where this definition was found. The editor uses this to resolve dependencies
			
			// Constructor
			public function ResourceDefinition(data:XML,basepath:String):void {
			   this.xmlData = data
			   this.basepath = basepath
			}

		}
		
} 
