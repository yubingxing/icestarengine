package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports

		/**
		* This stores a render message
		* @private
		*/
		public class RenderMessage {
		
				public var message:int
				public var target:fElement
				public var target2:fElement
				
				// Constructor
				public function RenderMessage(message:int,target:fElement,target2:fElement=null):void {
					this.message = message
					this.target = target
					this.target2 = target2
				}
				
				public function dispose():void {
					this.target = null
					this.target2 = null
				}
			
		}
		
}
