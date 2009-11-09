package com.ice.core.logic.collision {

		/** 
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* Stores information for a collision test.
		*
	  */
		public class fCollision	{

				/** 
				* X component
				*/
		    public var x:Number

				/**
				* Y component
				*/
		    public var y:Number

				/**
				* Z component
				*/
		    public var z:Number

		    /**
		    * Constructor for this class
		    */
		    public function fCollision(x:Number,y:Number,z:Number) {
			    this.x = x
			    this.y = y
			    this.z = z
		    }
		
		
		}

}
