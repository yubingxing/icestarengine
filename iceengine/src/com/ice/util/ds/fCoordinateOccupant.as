// This object stores an renderable element and a coordinate in this element's local coordinate system
package com.ice.util.ds {
	

		/**
		* This object stores a renderable element and a coordinate in thie engine's coordinate system. Several methods in the
		* engine return this.
	  * 
		* @see org.ffilmation.engine.core.fScene#translateStageCoordsToElements()
		*/
		public class fCoordinateOccupant {
		
			/**
			* Element that occupies the coordinate
			*/
			public var element:fRenderableElement
			
			/** Coordinate in element local coordinates */
			public var coordinate:fPoint3d
			
			/**
			* Constructor for the fCoordinateOccupant class
			*/
			function fCoordinateOccupant(element:fRenderableElement,x:Number,y:Number,z:Number):void {
				 this.element = element
				 this.coordinate = new fPoint3d(x,y,z)
			}
			

			
		}
}

