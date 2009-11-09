package com.ice.core {
	
		// Imports
	  
		/**
		* <p>The fHole class stores information about holes in a plane. Doors and windows are fHoles.
		* The class allows to open and close holes dynamically. However, they can't be created or removed.
		* The holes in any plane are defined by its material.
		*
		* @see org.ffilmation.engine.core.fPlane#holes
		*
		*/
		public class Hole extends EventDispatcher {
			
			// Constants

			/**
 			* The fHole.OPEN constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>holeopen</code> event.
 			* The event is dispatched when the hole is successfully open
 			* 
 			* @eventType holeopen
 			*/
 		  public static const OPEN:String = "holeopen"
			
			/**
 			* The fHole.CLOSE constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>holeclose</code> event.
 			* The event is dispatched when the hole is successfully closed
 			* 
 			* @eventType holeclose
 			*/
 		  public static const CLOSE:String = "holeclose"

			// Properties
			private var _open:Boolean
			
			/**
			* @private
			*/
			public var bounds:PlaneBounds

			/**
			* This is the element, if any, that is to be displayed when the hole is closed. If the material didn't provide the block, this property will be null
			* Use this property, for example, to attach a Mouse Event to a door so it can be opened when clicked.
			*/
			public var block:MovieClip
			
			/**
			* This is the index of this hole in the Array of holes of the fPlane. 
			*/
			public var index:Number
			
			/** @private */
			public function Hole(index:Number,bounds:PlaneBounds,block:MovieClip):void {
				this._open = true
				this.index = index
				this.block = block
				this.bounds = bounds
				this.open = false
			}			
			
			/**
			* Use this property to open/close a hole in your fPlane. The status of a hole affects
			* both the rendering algorythm and the collision algorythm. Please note that if
			* the material definition does not provide the graphic element (a door, for example) to "fill" the closed
			* fHole, attempts to set this property to false won't work
			*
			* @see org.ffilmation.engine.interfaces.fEngineMaterial#getHoleBlock()
			*/
			public function get open():Boolean {
				return this._open
			}

			/** @private */
			public function set open(v:Boolean):void {
				if(v==true) {
					this._open = true
					this.dispatchEvent(new Event(Hole.OPEN))
				}
				if(v==false && this.block!=null) {
					this._open = false
					this.dispatchEvent(new Event(Hole.CLOSE))
				}
			}
		
		}
		
		
}