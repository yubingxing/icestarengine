package com.ice.core.bullet {
	
	// Imports
	
	/**
	 * This renderer renders a bullet as a single color pixel
	 */
	public class fPixelBulletRenderer implements fEngineBulletRenderer {
		
		// All bullets can share this
		private var pixelBitmapData:BitmapData
		
		//Size
		private var size:Number
		
		//Alpha
		private var alpha:Number
		
		//MovieClip definition for plane ricochets
		private var planeRicochetDefinition:String
		
		//MovieClip definition for character ricochets
		private var characterRicochetDefinition:String
		
		//MovieClip definition for object ricochets
		private var objectRicochetDefinition:String
		
		/**
		 * Constructor for the "Pixel" bullet renderer class
		 * @param color Color of the pixel to be drawn as bullet
		 * @param size Size of the pixel
		 * @param alpha Alpha value
		 * @param planeRicochetDefinition MovieClip definition for plane ricochets
		 * @param characterRicochetDefinition MovieClip definition for character ricochets
		 * @param objectRicochetDefinition MovieClip definition for object ricochets
		 */
		public function fPixelBulletRenderer(color:Number,size:Number,alpha:Number=1,planeRicochetDefinition:String=null,characterRicochetDefinition:String=null,objectRicochetDefinition:String=null):void {
			this.pixelBitmapData = new BitmapData(size,size,false,color)
			this.size = size
			this.alpha = alpha
			this.planeRicochetDefinition = planeRicochetDefinition
			this.characterRicochetDefinition = characterRicochetDefinition
			this.objectRicochetDefinition = objectRicochetDefinition
		}
		
		/** @private */
		public function init(bullet:fBullet):void {
			bullet.customData.pixelBitmap = new	Bitmap(this.pixelBitmapData)
			bullet.container.addChild(bullet.customData.pixelBitmap)
			bullet.customData.pixelBitmap.alpha = this.alpha
			bullet.customData.pixelBitmap.x = bullet.customData.pixelBitmap.y = -Math.round(this.size/2)
		}
		
		/** @private */
		public function update(bullet:fBullet):void {
		}
		
		/** @private */
		public function clear(bullet:fBullet):void {
			bullet.container.removeChild(bullet.customData.pixelBitmap)
			bullet.customData.pixelBitmap = null
		}
		
		/** @private */
		public function getRicochet(element:fRenderableElement):MovieClip {
			
			try {
				
				var clase:Class
				if(element is fPlane) clase = getDefinitionByName(this.planeRicochetDefinition) as Class
				else if(element is fCharacter) clase = getDefinitionByName(this.characterRicochetDefinition) as Class
				else if(element is fObject) clase = getDefinitionByName(this.objectRicochetDefinition) as Class
				return objectPool.getInstanceOf(clase) as MovieClip
				
			} catch(e:Error) {
				return null
			}
			
			return null
			
		}
		
		
	}
	
}
