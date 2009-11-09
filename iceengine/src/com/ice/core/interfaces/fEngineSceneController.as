package com.ice.core.interfaces {

		// Imports

		/**
		* This interface defines methods that any class that is to be used as an scene controller must implement.
		* An scene controller is used to program specific behaviours associated to an scene.
		*/
		public interface fEngineSceneController {

			/** 
			* This is the initialization method
			*
			* @param character The fElement that will be controlled by this class.
			*/
		  function assignScene(scene:fScene):void;

			/** 
			* This is used to enable the controller. In complex applications, you will want to enable / disable controllers as you enter / leave scenes,
			* when you trigger a cutscene, pause your game, go to the Options menu, etc etc
			*/
			function enable():void;

			/** 
			* This is used to disable the controller. In complex applications, you will want to enable / disable controllers as you enter / leave scenes,
			* when you trigger a cutscene, pause your game, go to the Options menu, etc etc
			*/
			function disable():void;

		}

}