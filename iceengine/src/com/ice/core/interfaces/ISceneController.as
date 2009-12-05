package com.ice.core.interfaces {
	import com.ice.core.base.Scene;
	
	// Imports
	
	/**
	 * This interface defines methods that any class that is to be used as an scene controller must implement.
	 * An scene controller is used to program specific behaviours associated to an scene.
	 */
	public interface ISceneController {
		
		/** 
		 * This is the initialization method
		 *
		 * @param character The fElement that will be controlled by this class.
		 */
		function assignScene(scene:Scene):void;
		
		/** 
		 * This is used to enable/disable the controller. In complex applications, you will want to enable / disable controllers as you enter / leave scenes,
		 * when you trigger a cutscene, pause your game, go to the Options menu, etc etc
		 */
		function set enabled(value:Boolean):void;
	}
}