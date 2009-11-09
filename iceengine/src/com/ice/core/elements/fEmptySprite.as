// EmptySprite class
package com.ice.core.elements {
	
	// Imports
	
	/** 
	 * <p>This is an empty container that you can use to add user-controlled graphic elements to the scene. Sprites can be moved and
	 * are depthsorted, but don't collide, are not affected by lights, etc.</p>
	 *
	 * <p>The fEmptySprite class is useful to handle captions, rollovers and other interface elements that need to be placed in the proper
	 * depth and position, but are not part of the environment itself.</p>
	 *
	 * <p>Also note that the flashClip property for this element is always null, unless you set in manually to something of your convenience.</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT.<br>
	 * Use scene.createEmptySprite() to add new Sprites to an scene.</p>
	 *
	 * @see org.ffilmation.engine.core.fScene#createEmptySprite()
	 */
	public class fEmptySprite extends fRenderableElement implements fMovingElement {
		
		// Constructor
		/** @private */
		function fEmptySprite(defObj:XML,scene:fScene):void {
			
			// Previous
			super(defObj,scene)
			
		}
		
		/**
		 * Updates zIndex of this object so it displays with proper depth inside the scene
		 * @private
		 */
		public function updateDepth():void {
			
			var c:fCell = (this.cell==null)?(this.scene.translateToCell(this.x,this.y,this.z)):(this.cell)
			if(c) {
				var nz:Number = c.zIndex
				this.setDepth(nz)
			} else {
				// This tries to deduce if we are in front of everything or behind everything
				if(this.x>this.scene.width || this.y<0 || this.z<0) this.setDepth(-Infinity)
				else this.setDepth(Infinity)
			}
			
		}
		
	}
	
	
}