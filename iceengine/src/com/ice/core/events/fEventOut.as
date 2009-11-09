package com.ice.core.events {

		// Imports
		
		/**
		* <p>The fEventIn event class stores information about an OUT event.</p>
		*
		* <p>This event is dispatched whenever a character in the engine moves outside a cell
		* where an XML event was defined</p>
		*
		*/
		public class fEventOut extends Event {
		
			 // Public
			 
			 /**
			 * Stores name of event
			 */
			 public var name:String
				
			 /**
			 * Stores XML of event
			 */
			 public var xml:XML
			 
		
			 // Constructor

			 /**
		   * Constructor for the fEventOut class.
		   *
			 * @param type The type of the event. Event listeners can access this information through the inherited type property.
			 * 
		   * @param name Name that was given to this event in its XML definition
		   *
		   * @param XML node associated tot he event in the XMl file
		   *
			 */
			 function fEventOut(type:String,name:String,xml:XML):void {
			 	
			 		super(type)
			 		this.name = name
			 		this.xml = xml
		
			 }
			

		}

}



