package com.ice.core.interfaces {

		// Imports

		/**
		* This interface defines methods that any class that is to be used as a bullet renderer must implement.
		*/
		public interface fEngineBulletRenderer {

			/** 
			* This is the initialization method
			*
			* @param bullet The bullet object that we need to initialize
			*/
		  function init(bullet:fBullet):void;

			/** 
			* This method updates the drawing of the bullet. The engine already moves the bullet's sprite to its new position.
			* So if the bullet doesn't change its appearance, updating is not needed
			*
			* @param bullet The bullet object that is to be updated
			*/
			function update(bullet:fBullet):void;

			/** 
			* When the bullet dissapears, this is called
			*
			* @param bullet The bullet object that is to cleared
			*/
			function clear(bullet:fBullet):void;
			
			/**
			* When the bullet shots something, the engine looks for a ricochet definition.
			* A ricochet is a MovieClip for the "impact" itself. If the renderer returns a MovieClip, the scene shows it and waits
			* until the animation finishes in order to remove the bullet. If nothing is returned, the engine ignores the ricochet
			* and the bullet is removed immediately
			*
			* @param target The element for which a ricochet is requested
			* @return A movieclip. The animation for the ricochet needs to be in the timeline of the movieclip, as the engine will wait
			* for this timeline to reach its end before removing the bullet. The engine assumes that the origin of the animation is in the clip's 0,0 and it grows upward.
			* The MovieClip will be rotated to match the diection of the impact
			*/
			function getRicochet(element:fRenderableElement):MovieClip;

		}

}
