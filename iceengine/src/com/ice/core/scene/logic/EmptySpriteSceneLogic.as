// EMPTY SPRITE LOGIC
package com.ice.core.scene.logic {
	
	
	// Imports
	
	
	/**
	 * This class stores static methods related to emptySprites in the scene
	 * @private
	 */
	public class EmptySpriteSceneLogic {	
		
		
		// Process New cell for EmptySprites
		public static function processNewCellEmptySprite(scene:fScene,spr:fEmptySprite,forceReset:Boolean = false):void {
			
		}
		
		// Main render method for EmptySprites
		public static function renderEmptySprite(scene:fScene,spr:fEmptySprite):void {
			
			// Move EmptySprites to its new position
			scene.renderEngine.updateEmptySpritePosition(spr)
			
		}
		
		
	}
	
}
