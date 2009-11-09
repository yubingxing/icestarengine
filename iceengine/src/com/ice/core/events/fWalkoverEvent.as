package com.ice.core.events {

		// Imports
		
		/**
		* <p>The fWalkoverEvent event class stores information about a Walkover event.</p>
		*
		* <p>This event is dispatched when a character in the engine walks over a non-solid object in the scene. This is useful to collect items, for example.
		* </p>
		*
		*/
		public class fWalkoverEvent extends Event {
		
			 // Public
			 
			 /**
			 * The element of the scene we walk over
			 */
			 public var victim:fRenderableElement
			 
		
			 // Constructor

			 /**
		   * Constructor for the fWalkoverEvent class.
		   *
			 * @param type The type of the event. Event listeners can access this information through the inherited type property.
			 * 
		   * @param victim The element of the scene we collide against
		   *
			 */
			 function fWalkoverEvent(type:String,victim:fRenderableElement):void {
			 	
			 		super(type)
			 		this.victim = victim
		
			 }
			

		}

}



