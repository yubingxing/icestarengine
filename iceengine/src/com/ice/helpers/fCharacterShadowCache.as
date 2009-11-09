package com.ice.helpers {

		import org.ffilmation.engine.core.*
		import org.ffilmation.engine.elements.*
		import org.ffilmation.engine.helpers.*
		import org.ffilmation.engine.datatypes.*

		/**
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* fCharacterShadowCache caches information of elements shadowed by a given character and light
		*/
		public class fCharacterShadowCache {
		
				// Public variables
				public var light:fLight
				public var character:fCharacter
				public var cell:fCell
				public var withinRange:Boolean
				public var elements:Array
				
				// Constructor
				public function fCharacterShadowCache(light:fLight):void {
				
						this.light = light
						this.character = null
						this.elements = new Array
						this.cell = null
						this.withinRange = false

				}
				
				public function clear():void {
						this.elements = new Array
				}

				public function addElement(el:fRenderableElement):void {
						if(this.elements.indexOf(el)<0) this.elements[this.elements.length] = el
				}
			 
		}
		
		
}

