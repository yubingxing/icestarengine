package com.ice.core.elements {
	// Imports
	import com.ice.core.base.Light;
	import com.ice.core.base.Scene;
	
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	
	/**
	 * <p>Spot light definition. Behaves as an Omni light in 3dMax. A point projecting light in all directions</p>
	 *
	 * <p>Projects into planes as a circle</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS ELEMENT DIRECTLY.
	 * Use scene.createOmniLight() to add new lights to a scene.</p>
	 *
	 * @see org.ffilmation.engine.core.Scene#createOmniLight()
	 */
	public class OmniLight extends Light {
		
		/** @private */
		public static var counter:int = 0;
		
		/** 
		 * Numeric counter for fast Array lookups
		 * @private
		 */
		public var counter:int;
		
		/**
		 * Contructor
		 *
		 * @param defObj And XML defining the light
		 * @param scene The scene where the light will be
		 *
		 * @private
		 */
		function OmniLight(defObj:XML, scene:Scene) {
			
			this.addEventListener(Light.INTENSITYCHANGE, this.newIntensity, false, 0, true);
			this.addEventListener(Light.COLORCHANGE, this.newIntensity, false, 0, true);
			
			super(defObj, scene);
			
			// Counter
			this.counter = this.scene.lights.length;
		}
		
		/** @private	*/
		public function newIntensity(e:Event):void {
			var pc:Number = this.intensity / 100;
			
			this.color = new ColorTransform(this.lightColor.redMultiplier, this.lightColor.greenMultiplier, this.lightColor.blueMultiplier, pc,
				this.lightColor.redOffset, this.lightColor.greenOffset, this.lightColor.blueOffset, 0);
			
		}
		
		/** @private */
		public function disposeOmniLight():void {
			this.removeEventListener(Light.INTENSITYCHANGE, this.newIntensity);
			this.removeEventListener(Light.COLORCHANGE, this.newIntensity);
			this.disposeLight();
		}
		
		/** @private */
		public override function dispose():void {
			this.disposeOmniLight();
		}
	}
}
