package com.ice.core.materials {

		// Imports
		
		/**
		* This material renders planes invisible. Invisible planes are solid, you collide against them, they block bullets, etc.
		* @private
		*/
		public class fInvisibleMaterial implements fEngineMaterial {
			
			// Constructor
			public function fInvisibleMaterial(definition:fMaterialDefinition):void {
			}
			
			/**
			* Frees all allocated resources for this material. It is called when the scene is destroyed and we want to free as much RAM as possible
			*/
			public function dispose():void {
			}

			/** 
			* Retrieves the diffuse map for this material. If you write custom classes, make sure they return the proper size.
			* 0,0 of the returned DisplayObject corresponds to the top-left corner of material
			*
			* @param element: Element where this map is to be applied
			* @param width: Requested width
			* @param height: Requested height
			*
			* @return A DisplayObject (either Bitmap or MovieClip) that will be display onscreen
			*
			*/
			public function getDiffuse(element:fRenderableElement,width:Number,height:Number):DisplayObject {
				return null
			}

			/** 
			* Retrieves the bump map for this material. If you write custom classes, make sure they return the proper size
			* 0,0 of the returned DisplayObject corresponds to the top-left corner of material
			*
			* @param element: Element where this map is to be applied
			* @param width: Requested width
			* @param height: Requested height
			*
			* @return A DisplayObject (either Bitmap or MovieClip) that will used as BumpMap. If it is a MovieClip, the first frame will we used
			*
			*/
			public function getBump(element:fRenderableElement,width:Number,height:Number):DisplayObject {
				return null
			}

			/** 
			* Retrieves an array of holes (if any) of this material. These holes will be used to render proper lights and calculate collisions
			* and bullet impatcs
			*
			* @param element: Element where the holes will be applied
			* @param width: Requested width
			* @param height: Requested height
			*
			* @return An array of Rectangle objects, one for each hole. Positions and sizes are relative to material origin of coordinates
			*
			*/
			public function getHoles(element:fRenderableElement,width:Number,height:Number):Array {
				return []
			}

			/** 
			* Retrieves an array of contours that define the shape of this material. Every contours is an Array of Points
			*
			* @param element The element( wall or floor ) where the holes will be applied
			* @param width: Requested width
			* @param height: Requested height
			*
			* @return An array of arrays of points, one for each contour. Positions and sizes are relative to material origin of coordinates
			*
			*/
			public function getContours(element:fRenderableElement,width:Number,height:Number):Array {
				return [ [new Point(0,0),new Point(width,0),new Point(width,height),new Point(0,height)] ]
			}

			/**
			* Retrieves the graphic element that is to be used to block a given hole when it is closed
			*
			* @param index The hole index, as returned by the getHoles() method
			* @return A MovieClip that will used to close the hole. If null is returned, the hole won't be "closeable".
			*/
			public function getHoleBlock(element:fRenderableElement,index:Number):MovieClip {
				return null
			}


		}

}