package com.ice.core.renderEngines.flash9RenderEngine {
	
		// Imports

		/**
		* This stores render messages that reach an element before it is rendered.
		* When the element is created (scrolls into view) these messages are processed
		* to sync what it is rendered to the object's state.
		* @private
		*/
		public class RenderMessageQueue {
			
			/** The array of messages */
			private var messages:Array
			
			// Constructor
			public function RenderMessageQueue():void {
				this.reset()
			}
			
			/** 
			* This method adds a render message to the list. It checks if this message invalidates older messages,
			* so when the element is rendered, only the relevant messages are waiting to be procesed.
			*/
			public function addMessage(message:int,target:fElement,target2:fElement=null,dontStore:Boolean=false):void {
				
				// Clear previous messages if they are invalidated by this one
				var l:int = this.messages.length
				var invalidationList:Array = AllRenderMessages.invalidations[message]
				for(var i:int=0;i<l;i++) {
					var m:RenderMessage = this.messages[i]
					if(m.target==target && m.target2==target2 && invalidationList.indexOf(m.message)>=0) {
						// Invalidate message
						//trace(m.message+" is invalidated by "+message)
						this.messages[i].dispose()
						this.messages.splice(i,1)
						i--
						l--
					}
				}
				
				// Add message if message is relevant to the render itself
				if(!dontStore) this.messages[this.messages.length] = new RenderMessage(message,target,target2)
			}
			
			/**
			* Retrieves pending messages
			*/
			public function getMessages():Array {
				return this.messages
			}
			
			/**
			* Resets render messages
			*/
			public function reset():void {
				this.dispose()
				this.messages = new Array
			}

			// Clears resources
			public function dispose():void {
				
				if(this.messages) {
					var l:int = this.messages.length
					for(var i:int=0;i<l;i++) {
						this.messages[i].dispose()
						this.messages[i] = null
					}
					this.messages = null
			  }
			}
			
		
		}
		
}
