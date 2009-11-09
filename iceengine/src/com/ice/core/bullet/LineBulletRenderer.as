/**
 * base line bullet element class
 */
package com.ice.core.bullet {
	import com.ice.core.elements.Bullet;
	import com.ice.core.elements.Character;
	import com.ice.core.Plane;
	import com.ice.core.RenderableElement;
	import com.ice.core.interfaces.IBulletRenderer;
	
	import flash.display.MovieClip;
	
	// Imports
	
	/**
	 * This renderer renders a bullet as a line
	 */
	public class LineBulletRenderer implements IBulletRenderer {
		
		//Color
		private var color:Number;
		
		//Alpha
		private var alpha:Number;
		
		//Size
		private var size:Number;
		
		//MovieClip definition for plane ricochets
		private var planeRicochetDefinition:String;
		
		//MovieClip definition for character ricochets
		private var characterRicochetDefinition:String;
		
		//MovieClip definition for object ricochets
		private var objectRicochetDefinition:String;
		
		/**
		 * Constructor for the "Line" bullet renderer class
		 * @param color Line color
		 * @param size Line thickness
		 * @param alpha Line alpha
		 * @param planeRicochetDefinition MovieClip definition for plane ricochets
		 * @param characterRicochetDefinition MovieClip definition for character ricochets
		 * @param objectRicochetDefinition MovieClip definition for object ricochets
		 */
		public function LineBulletRenderer(color:Number, size:Number, alpha:Number=1, planeRicochetDefinition:String=null, 
										   characterRicochetDefinition:String=null, objectRicochetDefinition:String=null):void {
			this.color = color;
			this.size = size;
			this.alpha = alpha;
			this.planeRicochetDefinition = planeRicochetDefinition;
			this.characterRicochetDefinition = characterRicochetDefinition;
			this.objectRicochetDefinition = objectRicochetDefinition;
		}
		
		/** @private */
		public function init(bullet:Bullet):void {
			bullet.customData.oldx = bullet.container.x;
			bullet.customData.oldy = bullet.container.y;
			bullet.container.graphics.clear();
		}
		
		/** @private */
		public function update(bullet:Bullet):void {
			bullet.container.graphics.clear();
			bullet.container.graphics.lineStyle(this.size,this.color,this.alpha);
			bullet.container.graphics.lineTo(bullet.customData.oldx - bullet.container.x,bullet.customData.oldy - bullet.container.y);
			bullet.customData.oldx = bullet.container.x;
			bullet.customData.oldy = bullet.container.y;
		}
		
		/** @private */
		public function clear(bullet:Bullet):void {
			bullet.container.graphics.clear();
		}
		
		/** @private */
		public function getRicochet(element:RenderableElement):MovieClip {
			try {
				var clase:Class;
				if(element is Plane) 
					clase = getDefinitionByName(this.planeRicochetDefinition) as Class;
				else if(element is Character) 
					clase = getDefinitionByName(this.characterRicochetDefinition) as Class;
				else if(element is fObject) 
					clase = getDefinitionByName(this.objectRicochetDefinition) as Class;
				return objectPool.getInstanceOf(clase) as MovieClip;
			} catch(er:Error) {
				return null;
			}
			return null;
		}
	}
}
