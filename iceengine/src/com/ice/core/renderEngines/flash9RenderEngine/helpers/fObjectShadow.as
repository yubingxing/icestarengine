package com.ice.core.renderEngines.flash9RenderEngine.helpers {
	
		// Imports
		
		/**
		* @private
		* Container object for an object Shadow
	  */
		public class fObjectShadow {

			// Public properties
			public var shadow:Sprite
			public var clip:MovieClip
			public var request:fRenderableElement
			public var object:fObject

			// Constructor
			function fObjectShadow():void {
			}

			public function dispose():void {
				 this.shadow = null
				 this.clip = null
				 this.request = null
			   this.object = null
			}

		}
		
} 
