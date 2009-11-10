package com.ice.core.renderEngines.flash9RenderEngine.helpers {
	
		// Imports

		/**
		* @private
		* Keeps track of several variables of one light in one object
	  */
		public class LightWeight {

			// Public properties
	    public var element:fObject
			public var light:fLight
			
			// Private properties
			private var weight:Number

			// Constructor
			function LightWeight(element:fObject,light:fLight):void {
			
			   // References
			   this.element = element
			   this.light = light
			
			   // Status
			   this.weight = 1
			   
			   this.updateWeight()
			   
			}

			// Retrieves weiged color transform
		  public function getTransform():ColorTransform {
					
				 var per = this.weight*light.color.alphaMultiplier
				 var ret = new ColorTransform(light.color.redMultiplier*per,light.color.greenMultiplier*per,light.color.blueMultiplier*per,1,
				                              light.color.redOffset*per,light.color.greenOffset*per,light.color.blueOffset*per,0)		  	
				 return ret                             
		  	
		  }

			// Calculates weight
			public function updateWeight():void {
				
				 // New weight
				 var dist:Number = this.element.distanceTo(this.light.x,this.light.y,this.light.z)
				 var angle:Number = mathUtils.getAngle(this.element.x,this.element.y,this.light.x,this.light.y)

				 if(angle>225 || angle<45) {
				 		this.weight = 0
				 } else {
				 		if(angle>180) this.weight = (225-angle)/45
				 		else if(angle<90) this.weight = ((45-angle)/45)
				 		this.weight = 1
				 }

				 if(light.size!=Infinity) this.weight*=(1-(dist/light.size))

			}
		
		}

}
