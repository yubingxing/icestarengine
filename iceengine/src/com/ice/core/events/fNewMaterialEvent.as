package com.ice.core.events {

		// Imports
		
		/**
		* <p>The fNewMaterial event class stores information about a NEWMATERIAL event.</p>
		*
		* <p>This event is by a plane when it gets assigned a new material using the assignMaterial() method</p>
		* @see org.ffilmation.engine.core.fPlane#assignMaterial()
		*/
		public class fNewMaterialEvent extends Event {
		
			 // Public
			 
			 /** Stores id of the new material
			 * @private
			 */
			 public var id:String
			 
			 /** Width of the plane where the material was assigned
			 * @private */
			 public var width:Number

			 /** Height of the plane where the material was assigned
			 * @private */
			 public var height:Number
			 
				
			 // Constructor

			 /**
		   * Constructor for the fNewMaterial class.
		   *
			 * @param type The type of the event. Event listeners can access this information through the inherited type property.
			 * 
		   * @param id Id for the new material
		   *
		   * @param width Width of the plane where the material was assigned
		   *
		   * @param height Height of the plane where the material was assigned
		   *
			 */
			 function fNewMaterialEvent(type:String,id:String,width:Number=1,height:Number=-1):void {
			 	
			 		super(type)
			 		this.id = id
			 		this.width = width
			 		this.height = height
		
			 }
			

		}

}



