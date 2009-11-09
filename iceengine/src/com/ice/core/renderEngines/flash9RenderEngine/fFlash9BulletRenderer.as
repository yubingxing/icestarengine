// Basic renderable element class

package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports

		/**
		* This class renders an fBullet. Note that this simply will create and move an empty Sprite. Bullets use custom renderes that draw
		* into this empty Sprite
		* @private
		*/
		public class fFlash9BulletRenderer extends fFlash9ElementRenderer {
			
			// Constructor
			/** @private */
			function fFlash9BulletRenderer(rEngine:fFlash9RenderEngine,container:fElementContainer,element:fBullet):void {
				
				 // Previous
				 super(rEngine,element,container,container)

			}

			/**
			* Place asset its proper position
			*/
			public override function place():void {

			   // Place in position
			   var coords:Point = fScene.translateCoords(this.element.x,this.element.y,this.element.z)
			   this.container.x = coords.x
			   this.container.y = coords.y
			   
			}

		}
		
		
}