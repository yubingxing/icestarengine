package com.demos.test.controllers {

	// Imports
	
	/** This class controls the forest scene
	* @private
	*/
	public class forest implements fEngineSceneController {
		
		  public var scene:fScene	
		
		  // Constructor
		  public function forest():void {
		  	
		  }
	
			public function assignScene(scene:fScene):void {
				
				this.scene = scene
				
				this.scene.createOmniLight("light_poncho",0,0,0,200,"#ddffdd",50,00,true)

				// Look for all Money Bags and add a light above each of them
				for(var i:Number=0;i<this.scene.objects.length;i++) {
					var obj:fObject = this.scene.objects[i]
					if(obj.definitionID=="MNIP_MoneyBag") {
						this.scene.createOmniLight("light_"+obj.id,obj.x,obj.y,obj.z+25,300,"#ffffff",100,0,true)
						obj.addEventListener(fRenderableElement.HIDE,this.hideListener)
					}
				}
				
			}

			public function enable():void {

				// Follow Poncho
				this.scene.all["light_poncho"].moveTo(this.scene.all["Poncho"].x-20,this.scene.all["Poncho"].y-20,this.scene.all["Poncho"].z+10)
				this.scene.all["light_poncho"].follow(this.scene.all["Poncho"])
			}

			public function disable():void {
				this.scene.all["light_poncho"].stopFollowing(this.scene.all["Poncho"])
			}
	
			private function hideListener(evt:Event):void {
				
				// Delete corresponding light
				this.scene.removeOmniLight(this.scene.all["light_"+evt.target.id])
			}
	
	
	
	}


}