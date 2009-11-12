package com.ice.core.events {
	import flash.events.Event;
	
	// Imports
	
	/**
	 * <p>The fMoveEvent event class stores information about a move event.</p>
	 *
	 * <p>This event is dispatched whenever an element in the engine changes position.
	 * This allows the engine to track objects and rerender the scene, as well as programming
	 * reactions such as one element following another</p>
	 *
	 */
	public class MoveEvent extends Event {
		/**
		 *  The <code>MoveEvent.MOVE</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>move</code> event.
		 *
		 *	<p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>oldX</code></td><td>The previous x coordinate of the object, in pixels.</td></tr>
		 *     <tr><td><code>oldY</code></td><td>The previous y coordinate of the object, in pixels.</td></tr>
		 * 	   <tr><td><code>oldZ</code></td><td>The previous Z coordinate of the object, in pixels.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType move
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const MOVE:String = "move";
		// Public
		/**
		 * The increment of the x coordinate that corresponds to this movement. Equals new position - last position
		 */
		public var oldX:Number;
		
		/**
		 * The increment of the y coordinate that corresponds to this movement. Equals new position - last position
		 */
		public var oldY:Number;
		
		/**
		 * The increment of the z coordinate that corresponds to this movement. Equals new position - last position
		 */
		public var oldZ:Number;
		
		
		
		// Constructor
		
		/**
		 * Constructor for the fMoveEvent class.
		 *
		 * @param type The type of the event. Event listeners can access this information through the inherited type property.
		 * 
		 * @param oldX The increment of the x coordinate that corresponds to this movement
		 *
		 * @param oldY The increment of the y coordinate that corresponds to this movement
		 *
		 * @param oldZ The increment of the z coordinate that corresponds to this movement
		 *
		 *
		 */
		function MoveEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
						   oldX:Number = NaN, oldY:Number = NaN, oldZ:Number = NaN):void {
			super(type, bubbles, cancelable);
			this.oldX = oldX;
			this.oldY = oldY;
			this.oldZ = oldZ;
		}
		
		override public function clone() : Event {
			return new MoveEvent(type, bubbles, cancelable, oldX, oldY, oldZ);
		}
	}
}



