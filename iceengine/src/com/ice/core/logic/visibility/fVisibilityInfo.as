package com.ice.core.logic.visibility {


		/**
		* @private
		* fVisibilityInfo provides information about an objects visibility from a given point
		*/
		public class fVisibilityInfo {
		
				// Public variables
				public var obj:fRenderableElement
				public var distance:Number
				
				// Constructor
				public function fVisibilityInfo(obj:fRenderableElement,distance:Number):void {
				
						this.obj = obj
						this.distance = distance
				
				}
			 
		}
		
		
}

