package com.ice.core.events {

		// Imports
		
		/**
		* <p>The fEventIn event class stores information about an IN event.</p>
		*
		* <p>This event is dispatched whenever a character in the engine moves into a cell
		* where an XML even was defined</p>
		*
		*/
		public class MoveInEvent extends Event {
		
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
		   * Constructor for the fEventIn class.
		   *
			 * @param type The type of the event. Event listeners can access this information through the inherited type property.
			 * 
		   * @param name Name that was given to this event in its XML definition
		   *
		   * @param XML node associated tot he event in the XMl file
		   *
			 */
			 function MoveInEvent(type:String,name:String,xml:XML):void {
			 	
			 		super(type,bubbles,cancelable)
			 		this.name = name
			 		this.xml = xml
		
			 }
			

		}

}



