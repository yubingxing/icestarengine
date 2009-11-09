package com.ice.core.events {

		// Imports
		
		/**
		* <p>The fCollideEvent event class stores information about a collision event.</p>
		*
		* <p>This event is dispatched when a character in the engine collides whith another solid element in the scene
		* </p>
		*
		*/
		public class fCollideEvent extends Event {
		
			 // Public
			 
			 /**
			 * The element of the scene we collide against
			 */
			 public var victim:fRenderableElement
			 
		
			 // Constructor

			 /**
		   * Constructor for the fMoveEvent class.
		   *
			 * @param type The type of the event. Event listeners can access this information through the inherited type property.
			 * 
		   * @param victim The element of the scene we collide against. If Null the event was triggered by an attemp to move a character autside the scene's limits
		   *
			 */
			 function fCollideEvent(type:String,victim:fRenderableElement):void {
			 	
			 		super(type)
			 		this.victim = victim
		
			 }
			

		}

}



