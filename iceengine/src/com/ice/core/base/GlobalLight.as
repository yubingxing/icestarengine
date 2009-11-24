// GLOBAL LIGHT

package com.ice.core.base {
	import flash.events.Event;

	// Imports
	
	/**
	 * <p>The GlobalLight class contains information about the global light of a scene. The global light is the minimum
	 * amount of lighting any element will get.</p>
	 *
	 * <p>Scenes without global lighting will show elements as 100% black if they are not affected by a direct light.</p>
	 *
	 * <p>The fGlobaLight doesn't cast shadows. The sun in NOT a GlobalLight, it is a spot light of infinity radius</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT.<br>
	 * Use the scene's environmentLight property to change the global light of a scene</p>
	 *		
	 * @see com.ice.core.base.Scene#environmentLight
	 */
	public class GlobalLight extends Light {
		
		// Constructor
		/** @private */
		function GlobalLight(defObj:XML, scene:Scene):void {
			this.addEventListener(Light.INTENSITYCHANGE, newIntensity, false, 0, true);
			this.addEventListener(Light.COLORCHANGE, newIntensity, false, 0, true);
			
			super(defObj, scene);
		}
		
		// Methods
		/** @private */
		public function newIntensity(e:Event):void {
			
			var pc:Number = this.intensity / 100;
			
			this.color = new ColorTransform( 
				Light.NOLIGHT.ra + (this.lightColor.redMultiplier - Light.NOLIGHT.ra) * pc,
				Light.NOLIGHT.ga + (this.lightColor.greenMultiplier - Light.NOLIGHT.ga) * pc,
				Light.NOLIGHT.ba + (this.lightColor.blueMultiplier - Light.NOLIGHT.ba) * pc,
				1,
				Light.NOLIGHT.rb + (this.lightColor.redOffset - Light.NOLIGHT.rb) * pc,
				Light.NOLIGHT.gb + (this.lightColor.greenOffset - Light.NOLIGHT.gb) * pc,
				Light.NOLIGHT.bb + (this.lightColor.blueOffset - Light.NOLIGHT.bb) * pc,
				0);
		}
		
		/** @private */
		public function disposeGlobalLight():void {
			this.removeEventListener(Light.INTENSITYCHANGE, newIntensity);
			this.removeEventListener(Light.COLORCHANGE, newIntensity);
			this.disposeLight();
		}
		
		/** @private */
		public override function dispose():void {
			this.disposeGlobalLight();
		}
	}
}
