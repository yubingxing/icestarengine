package com.ice.core.base {
	// Imports
	import flash.display.Sprite;
	
	/**
	 * <p>The elementContainer is the root displayObject for a renderable Element while the scene is being rendered.</p>
	 */
	public class ElementContainer extends Sprite {
		
		/**
		 * The ID for this element.
		 * Using this, you will be able to access the element from an Event listener attached to the container.
		 */
		public var elementId:String;
		
		/**
		 * A pointer to the element this container represents.
		 * Using this, you will be able to access the element from an Event listener attached to the container.
		 */
		public var element:RenderableElement;
	}
}
