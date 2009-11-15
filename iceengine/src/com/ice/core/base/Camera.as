// CAMERA

package com.ice.core.base {
	
	// Imports
	
	/**
	 * <p>The Camera defines which part of the scene is shown.
	 * Use the scene's setCamera method to asign any camera to the scene, and then move the camera</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS ELEMENT DIRECTLY.<br>
	 * Use scene.createCamera() to add new cameras to the scene</p>
	 *
	 * @see org.ffilmation.engine.core.fScene#createCamera()
	 * @see org.ffilmation.engine.core.fScene#setCamera()
	 *
	 */
	public class Camera extends MovingElement {
		
		// Constants
		private static var count:Number = 0;
		
		/**
		 * Constructor for the Camera class
		 *
		 * @param scene The scene associated to this camera
		 *
		 * @private
		 */
		function Camera(scene:Scene) {
			
			var myId:String = "Camera_" + (Camera.count++);
			
			// Previous
			super(<camera id={myId}/>, scene);			 
		}
	}
}

