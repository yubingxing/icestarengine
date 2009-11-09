package com.ice.core.interfaces {

		// Imports

		/**
		* This interface defines methods that any class that is to be used as a material in the engine must implement
		*/
		public interface IMaterial {

			/**
			* Constructor
			* @param definition The material definition that created this class
			*/
			public function IMaterial(definition:fMaterialDefinition);

			/** 
			* Retrieves the diffuse map for this material. If you write custom classes, make sure they return the proper size.
			* 0,0 of the returned DisplayObject corresponds to the top-left corner of material
			*
			* @param element The element( wall or floor ) where this map will be applied
			* @param width: Requested width
			* @param height: Requested width
			*
			* @return A DisplayObject (either Bitmap or MovieClip) that will be display onscreen
			*
			*/
		  function getDiffuse(element:fRenderableElement,width:Number,height:Number):DisplayObject;

			/** 
			* Retrieves the bump map for this material. If you write custom classes, make sure they return the proper size
			* 0,0 of the returned DisplayObject corresponds to the top-left corner of material
			*
			* @param element The element( wall or floor ) where this map will be applied
			* @param width: Requested width
			* @param height: Requested height
			*
			* @return A DisplayObject (either Bitmap or MovieClip) that will used as BumpMap. If it is a MovieClip, the first frame will we used
			*
			*/
			function getBump(element:fRenderableElement,width:Number,height:Number):DisplayObject;

			/** 
			* Retrieves an array of holes (if any) of this material. These holes will be used to render proper lights and calculate collisions
			* and bullet impacts
			*
			* @param element The element( wall or floor ) where the holes will be applied
			* @param width: Requested width
			* @param height: Requested height
			*
			* @return An array of Rectangle objects, one for each hole. Positions and sizes are relative to material origin of coordinates
			*
			*/
			function getHoles(element:fRenderableElement,width:Number,height:Number):Array;
			
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
			function getContours(element:fRenderableElement,width:Number,height:Number):Array;

			/**
			* Retrieves the graphic element that is to be used to block a given hole when it is closed
			*
			* @param element The element( wall or floor ) where the block will be applied
			* @param index The hole index, as returned by the getHoles() method
			* @return A MovieClip that will used to close the hole. If null is returned, the hole won't be "closeable".
			*/
			function getHoleBlock(element:fRenderableElement,index:Number):MovieClip;
			
			/**
			* Frees all allocated resources for this material. It is called when the scene is destroyed and we want to free as much RAM as possible
			*/
			function dispose():void;
			

		}

}