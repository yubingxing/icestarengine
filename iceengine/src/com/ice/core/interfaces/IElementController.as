package com.ice.core.interfaces {

		// Imports

		/**
		* This interface defines methods that any class that is to be used as an element controller must implement.
		* Examples of element controllers: keyboard controller, mouse controller, AI controller, control from socket ( to implement multiplayer ), etc
		*/
		public interface IElementController {

			/** 
			* This is the initialization method
			*
			* @param character The fElement that will be controlled by this class.
			*/
		  function assignElement(element:fElement):void;

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