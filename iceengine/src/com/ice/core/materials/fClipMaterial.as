package com.ice.core.materials {

		// Imports
		
		/**
		* <p>This class creates a material from a MovieClip or image exported in any SWF you import into the scene.
		* The clip/image is scaled to fit the requested dimensions. If you want it to tile, use the fTileMaterial instead.</p>
		*
		* <p>If you use a movieClip, place your "hole" definition clips only in the first frame. After reading the holes
		* the class will gotoAndStop(2) the clip. In frame 2 you should have what you want to be visible as well as clips
		* for doors and windows. See examples and tutorials for further info on holes, doors and windows</p>
		*
		* <p>This class is automatically selected when you define a material as "clip" in your XMLs. You don't need to use
		* it or worry about how it works</p>
		* @private
		*/
		public class fClipMaterial implements fEngineMaterial {
			
			// Private vars
			private var definition:fMaterialDefinition	// Definition data
			
			private var base:DisplayObject							// Base clip for this material
			private var origw:Number
			private var origh:Number
			
			// Constructor
			public function fClipMaterial(definition:fMaterialDefinition):void {
				 this.definition = definition
				 
	       var clase:Class = getDefinitionByName(this.definition.xmlData.diffuse) as Class
	       
				 this.base = new clase()
				 this.origw = this.base.width
				 this.origh = this.base.height
			}
			
			/**
			* Frees all allocated resources for this material. It is called when the scene is destroyed and we want to free as much RAM as possible
			*/
			public function dispose():void {
				this.definition = null
				this.base = null
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
	       var clase:Class = getDefinitionByName(this.definition.xmlData.diffuse) as Class
	       var ret:MovieClip = new clase() as MovieClip
				 ret.width = width
				 ret.height = height
				 ret.gotoAndStop(2)
				 return ret
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
				
	       var clase:Class = getDefinitionByName(this.definition.xmlData.bump) as Class
	       var ret:MovieClip = new clase() as MovieClip
				 ret.width = width
				 ret.height = height
				 ret.gotoAndStop(2)
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
				
				 var temp:Array = new Array
				 var px = width/this.origw
				 var py = height/this.origh
				 
				 // Check for hole definitions ( in texture frame 1 )
				 if(this.base is MovieClip) {
				 	
				 	  var b:MovieClip = this.base as MovieClip
				 		b.gotoAndStop(1)
				 		for(var c:Number=0;c<b.numChildren;c++) {
				 			  var mcontainer:DisplayObject = b.getChildAt(c) 
				 			  if(mcontainer is fHoleClip) {
				 			  	temp[temp.length] = new Rectangle(px*mcontainer.x,py*(mcontainer.y-mcontainer.height),px*mcontainer.width,py*mcontainer.height)
				 			  }
				 		}
				 }
				 
				 // Return array of rectangles
				 return temp
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