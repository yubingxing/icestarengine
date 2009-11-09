// BULLET LOGIC
package com.ice.core.scene.logic {
	
	
	// Imports
	
	
	/**
	 * This class stores static methods related to bullets in the scene
	 * @private
	 */
	public class fBulletSceneLogic {	
		
		
		// Main render method for bullets
		public static function renderBullet(scene:fScene,bullet:fBullet):void {
			
			// Move character to its new position
			scene.renderEngine.updateBulletPosition(bullet)
			// Update custom render
			if(bullet.customData.bulletRenderer) bullet.customData.bulletRenderer.update(bullet)
			
		}
		
		// Process bullets shooting things
		public static function processShot(evt:fShotEvent):void {
			
			// A bullet shots something. Is there a ricochet defined ?
			var b:fBullet = evt.bullet
			var r:MovieClip = b.customData.bulletRenderer.getRicochet(evt.element)
			
			if(r) {
				
				b.disable()
				b.customData.bulletRenderer.clear(b)
				b.container.addChild(r)
				r.addEventListener(Event.ENTER_FRAME,fBulletSceneLogic.waitForRicochet,false,0,true)
				
				// Decide rotation of ricochet clip
				if(evt.element is fObject) {
					var o:fObject = evt.element as fObject
					r.rotation = 45+mathUtils.getAngle(o.x,o.y,b.x,b.y)
				} 
				else if(evt.element is fWall) {
					var w:fWall = evt.element as fWall
					if(w.vertical) {
						if(b.speedx>0) r.rotation = -120
						else r.rotation = 60
					} else {
						if(b.speedy>0) r.rotation = -60
						else r.rotation = 120
					}
					
				}
				
			} else b.scene.removeBullet(b)
			
		}
		
		
		// Waits for a ricochet to end
		public static function waitForRicochet(evt:Event):void {
			
			var ricochet:MovieClip = evt.target as MovieClip
			if(ricochet.currentFrame==ricochet.totalFrames) {
				ricochet.removeEventListener(Event.ENTER_FRAME,fBulletSceneLogic.waitForRicochet)
				var m:fElementContainer = ricochet.parent as fElementContainer
				var bullet:fBullet = m.fElement as fBullet
				ricochet.parent.removeChild(ricochet)
				objectPool.returnInstance(ricochet)
				bullet.scene.removeBullet(bullet)
			}
			
		}
		
		
		
	}
	
}
