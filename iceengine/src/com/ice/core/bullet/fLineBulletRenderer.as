package com.ice.core.bullet {
	import com.ice.core.interfaces.fEngineBulletRenderer;

		// Imports
		
		/**
		* This renderer renders a bullet as a line
		*/
		public class fLineBulletRenderer implements fEngineBulletRenderer {
			
			//Color
			private var color:Number
			
			//Alpha
			private var alpha:Number

			//Size
			private var size:Number
			
			//MovieClip definition for plane ricochets
			private var planeRicochetDefinition:String

			//MovieClip definition for character ricochets
			private var characterRicochetDefinition:String

			//MovieClip definition for object ricochets
			private var objectRicochetDefinition:String
			
			/**
			* Constructor for the "Line" bullet renderer class
			* @param color Line color
			* @param size Line thickness
			* @param alpha Line alpha
			* @param planeRicochetDefinition MovieClip definition for plane ricochets
			* @param characterRicochetDefinition MovieClip definition for character ricochets
			* @param objectRicochetDefinition MovieClip definition for object ricochets
			*/
			public function fLineBulletRenderer(color:Number,size:Number,alpha:Number=1,planeRicochetDefinition:String=null,characterRicochetDefinition:String=null,objectRicochetDefinition:String=null):void {
		  	this.color = color
		  	this.size = size
		  	this.alpha = alpha
		  	this.planeRicochetDefinition = planeRicochetDefinition
		  	this.characterRicochetDefinition = characterRicochetDefinition
		  	this.objectRicochetDefinition = objectRicochetDefinition
			}

		  /** @private */
		  public function init(bullet:fBullet):void {
		  	bullet.customData.oldx = bullet.container.x
		  	bullet.customData.oldy = bullet.container.y
		  	bullet.container.graphics.clear()
		  }

		  /** @private */
			public function update(bullet:fBullet):void {
		  	bullet.container.graphics.clear()
		  	bullet.container.graphics.lineStyle(this.size,this.color,this.alpha)
		  	bullet.container.graphics.lineTo(bullet.customData.oldx - bullet.container.x,bullet.customData.oldy - bullet.container.y)
		  	bullet.customData.oldx = bullet.container.x
		  	bullet.customData.oldy = bullet.container.y
			}

		  /** @private */
			public function clear(bullet:fBullet):void {
	  		bullet.container.graphics.clear()
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
