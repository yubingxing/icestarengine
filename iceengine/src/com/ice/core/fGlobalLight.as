// GLOBAL LIGHT

package com.ice.core {

		// Imports

		/**
		* <p>The fGlobalLight class contains information about the global light of a scene. The global light is the minimum
		* amount of lighting any element will get.</p>
		*
		* <p>Scenes without global lighting will show elements as 100% black if they are not affected by a direct light.</p>
		*
		* <p>The fGlobaLight doesn't cast shadows. The sun in NOT a fGlobalLight, it is a spot light of infinity radius</p>
		*
		* <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT.<br>
		* Use the scene's environmentLight property to change the global light of a scene</p>
    *		
		* @see org.ffilmation.engine.core.fScene#environmentLight
		*/
		public class fGlobalLight extends fLight {
		
			// Constructor
			/** @private */
			function fGlobalLight(defObj:XML,scene:fScene):void {

			   this.addEventListener(fLight.INTENSITYCHANGE,this.newIntensity,false,0,true)
			   this.addEventListener(fLight.COLORCHANGE,this.newIntensity,false,0,true)

			   super(defObj,scene)

			}
			
			// Methods
			/** @private */
			public function newIntensity(e:Event):void {
				
 			   var pc:Number = this.intensity/100

				 this.color = new ColorTransform( 
			                     fLight.NOLIGHT.ra+(this.lightColor.redMultiplier-fLight.NOLIGHT.ra)*pc,
			                     fLight.NOLIGHT.ga+(this.lightColor.greenMultiplier-fLight.NOLIGHT.ga)*pc,
			                     fLight.NOLIGHT.ba+(this.lightColor.blueMultiplier-fLight.NOLIGHT.ba)*pc,
			                     1,
			                     fLight.NOLIGHT.rb+(this.lightColor.redOffset-fLight.NOLIGHT.rb)*pc,
			                     fLight.NOLIGHT.gb+(this.lightColor.greenOffset-fLight.NOLIGHT.gb)*pc,
			                     fLight.NOLIGHT.bb+(this.lightColor.blueOffset-fLight.NOLIGHT.bb)*pc,
			                     0)

			}
			
			/** @private */
			public function disposeGlobalLight():void {
			   this.removeEventListener(fLight.INTENSITYCHANGE,this.newIntensity)
			   this.removeEventListener(fLight.COLORCHANGE,this.newIntensity)
				 this.disposeLight()
			}

			/** @private */
			public override function dispose():void {
				 this.disposeGlobalLight()
			}


		}

}
