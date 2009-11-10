package com.ice.helpers {
	
		// Imports
		import org.ffilmation.engine.core.*
		import org.ffilmation.engine.elements.*

		/** 
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* This object contains wall information of a fCell. We store if there are any walls and floors touching the cell. This information
		*	will then be used to speed up collision tests
		*
		*/
		public class CellWalls {
		
				/**
				* Stores up wall
				*/
				public var up:fRenderableElement
				
				/**
				* Stores down wall
				*/
				public var down:fRenderableElement

				/**
				* Stores left wall
				*/
				public var left:fRenderableElement

				/**
				* Stores right wall
				*/
				public var right:fRenderableElement

				/**
				* Stores top wall
				*/
				public var top:fRenderableElement

				/**
				* Stores bottom wall
				*/
				public var bottom:fRenderableElement
				
				/** 
				* Stores list of objects
				*/
				public var objects:Array

				/**
				* Constructor
				*/
				public function CellWalls():void {
					
					this.up = null
					this.down = null
					this.left = null
					this.right = null
					this.top = null
					this.bottom = null
					this.objects = new Array
					
				}
				
				public function dispose():void {
					
					this.up = null
					this.down = null
					this.left = null
					this.right = null
					this.top = null
					this.bottom = null
					if(this.objects) {
						var ol:int = this.objects.length
						for(var i:int=0;i<ol;i++) delete this.objects[i]
						this.objects = null
					}					
				}

		}
		
}