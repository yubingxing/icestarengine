package com.ice.core.events {
	import com.ice.core.RenderableElement;
	import com.ice.core.elements.Bullet;
	import com.ice.util.ds.fPoint3d;
	
	import flash.events.Event;
	
	// Imports
	
	/**
	 * <p>The fShotEvent event class stores information about a shot event. This event is dispatched when a 
	 * bullet collides with an element in the scene. Both the bullet and the element will dispatch
	 * the event, so you can capture it where it suits you the most.</p>
	 *
	 * If the element is solid, the event will have a fBullet.SHOT type. If it isn't the vent will be of type fBullet.SHOT_THROUGH
	 *
	 */
	public class ShotEvent extends Event {
		
		// Public
		
		/** The element of the scene that gets shot */
		public var element:RenderableElement;
		
		/** The bullet */
		public var bullet:Bullet;
		
		/** Coordinate of impact, in scene coordinates */
		public var coordinate:fPoint3d;
		
		
		/**
		 * Constructor for the fShotEvent class.
		 *
		 * @param type The type of the event. Event listeners can access this information through the inherited type property.
		 * 
		 * @param bullet The bullet that shot the element.
		 *
		 * @param victim The element of the scene that was shot.
		 *
		 */
		function ShotEvent(type:String, bullet:Bullet, element:RenderableElement, coordinate:fPoint3d):void {
			super(type);
			this.bullet = bullet;
			this.element = element;
			this.coordinate = coordinate;
		}
	}
}



