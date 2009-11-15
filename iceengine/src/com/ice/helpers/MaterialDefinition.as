package com.ice.helpers {
	// Imports
	
	/**
	 * @private
	 * THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
	 * FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
	 *
	 * This object stores a material definition loaded from a definition XML
	 */
	public class MaterialDefinition extends ResourceDefinition {
		
		// Public vars
		public var type:String = "";			// This is the type of material. @see fEngineMaterialTypes
		
		// Constructor
		public function MaterialDefinition(data:XML, basepath:String):void {
			super(data, basepath);
			this.type = data.@type;
		}
	}
} 
