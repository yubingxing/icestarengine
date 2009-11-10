package com.ice.core.logic.visibility {

		// Imports

		/**
		* @private
		* fShadowedVisibilityInfo provides information about an objects visibility from a given point and shadows affecting it
		*/
		public class ShadowedVisibilityInfo extends VisibilityInfo {
		
				// Public variables
				public var shadows:Array
				public var withinRange:Number
				
				// Constructor
				public function ShadowedVisibilityInfo(obj:fRenderableElement,distance:Number):void {
				
						super(obj,distance)
						this.shadows = new Array
				
				}
				
				public function addShadow(shadow:VisibilityInfo):void {
					
						this.shadows[this.shadows.length] = shadow
					
				}
			 
		}
		
		
}

