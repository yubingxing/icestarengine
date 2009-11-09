package com.ice.core.events {
	
	// Imports
	
	/**
	 * <p>The fMoveEvent event class stores information about a move event.</p>
	 *
	 * <p>This event is dispatched whenever an element in the engine changes position.
	 * This allows the engine to track objects and rerender the scene, as well as programming
	 * reactions such as one element following another</p>
	 *
	 */
	public class fMoveEvent extends Event {
		
		// Public
		
		/**
		 * The increment of the x coordinate that corresponds to this movement. Equals new position - last position
		 */
		public var dx:Number
		
		/**
		 * The increment of the y coordinate that corresponds to this movement. Equals new position - last position
		 */
		public var dy:Number
		
		/**
		 * The increment of the z coordinate that corresponds to this movement. Equals new position - last position
		 */
		public var dz:Number
		
		
		// Constructor
		
		/**
		 * Constructor for the fMoveEvent class.
		 *
		 * @param type The type of the event. Event listeners can access this information through the inherited type property.
		 * 
		 * @param dx The increment of the x coordinate that corresponds to this movement
		 *
		 * @param dy The increment of the y coordinate that corresponds to this movement
		 *
		 * @param dz The increment of the z coordinate that corresponds to this movement
		 *
		 *
		 */
		function fMoveEvent(type:String,dx:Number,dy:Number,dz:Number):void {
			super(type)
			this.dx = dx
			this.dy = dy
			this.dz = dz
		}
	}
}



