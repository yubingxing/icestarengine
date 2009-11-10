package com.ice.core.materials {

		// Imports
		
		/**
		* This class creates a material by "Tiling" an image in the imported libraries
		*
		* <p>This class is automatically selected when you define a material as "tile" in your XMLs. You don't need to use
		* it or worry about how it works</p>
		* @private
		*/
		public class TileMaterial implements fEngineMaterial {
			
			// Private vars
			private var definition:fMaterialDefinition	// Definition data
			private var image:BitmapData								// The etxture itself
			
			// Constructor
			public function TileMaterial(definition:fMaterialDefinition):void {
				this.definition = definition
				var clase:Class = getDefinitionByName(this.definition.xmlData.diffuse) as Class
				this.image = new clase(0,0) as BitmapData
			}
			
			/**
			* Frees all allocated resources for this material. It is called when the scene is destroyed and we want to free as much RAM as possible
			*/
			public function dispose():void {
				this.definition = null
				if(this.image) this.image.dispose()
				this.image = null
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
				
				var temp:Shape = new Shape
				var matrix:Matrix = new Matrix()
				if(element is fFloor) matrix.translate(-element.x,-element.y)
				if(element is fWall) {
					var tempw:fWall = element as fWall
					if(tempw.vertical) matrix.translate(-element.y,-element.z)
					else matrix.translate(-element.x,-element.z)
				}

				temp.graphics.beginBitmapFill(this.image,matrix,true,true)
				temp.graphics.drawRect(0,0,width,height)
				temp.graphics.endFill()

			  return temp
			  
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
				var ret:Sprite = new Sprite
				var clase:Class = getDefinitionByName(this.definition.xmlData.bump) as Class
				var image:BitmapData = new clase(0,0) as BitmapData
				ret.graphics.beginBitmapFill(image,null,true,true)
				ret.graphics.drawRect(0,0,width,height)
				ret.graphics.endFill()
				return ret
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