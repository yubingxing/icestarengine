package com.ice.core.materials {

		// Imports
		
		/**
		* This is the class for the Fence material. Keep in mind that holes have an impact in performace of the collision an light algorythms
		* and therefore, this material has to be used with moderation.
		*
		* <p>This class is automatically selected when you define a material as "fence" in your XMLs. You don't need to use
		* it or worry about how it works</p>
		* @private
		*/
		public class FenceMaterial implements fEngineMaterial {
			
			// Private vars
			private var definition:fMaterialDefinition	// Definition data
			
			private	var width:Number										// Door size and position
			private	var gap:Number
			private	var irregular:Number
			private var blocks:Array = new Array
			
			// Constructor
			public function FenceMaterial(definition:fMaterialDefinition):void {
				this.definition = definition
				
				
				// Retrieve door data
				this.width = new Number(this.definition.xmlData.width)
				this.gap = new Number(this.definition.xmlData.gap)
				this.irregular = new Number(this.definition.xmlData.irregular)
				
			}

			/**
			* Frees all allocated resources for this material. It is called when the scene is destroyed and we want to free as much RAM as possible
			*/
			public function dispose():void {
				this.definition = null
				
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
				
				var ret:Shape = new Shape

				// Draw base
				var tile:fMaterial = fMaterial.getMaterial(this.definition.xmlData.base,element.scene)
				var base:BitmapData = new BitmapData(width,height,true,0x000000)
				base.draw(tile.getDiffuse(element,width,height))

				// Retrieve shape
				var nHoles:int = int(width/(this.width+this.gap))
				var offset:Number = width-(nHoles*this.width)-(nHoles-1)*this.gap
				var n:Number = offset+this.gap
				var i:int=0
				ret.graphics.beginBitmapFill(base,new Matrix(),true,true)
				ret.graphics.drawRect(0,0,offset,height)

				do {
					var hs:Number = this.blocks[element.uniqueId][i]*height
					ret.graphics.drawRect(n,hs,this.width,height-hs)
					n+=this.width+this.gap
					i++
				} while(n<width-this.width)

				ret.graphics.drawRect(n,0,width-n,height)
				ret.graphics.endFill()
				
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
				var ret:Shape = new Shape

				// Draw base
				var tile:fMaterial = fMaterial.getMaterial(this.definition.xmlData.base,element.scene)
				var base:BitmapData = new BitmapData(width,height,true,0x000000)
				base.draw(tile.getBump(element,width,height))

				// Retrieve shape
				var nHoles:int = int(width/(this.width+this.gap))
				var offset:Number = width-(nHoles*this.width)-(nHoles-1)*this.gap
				var n:Number = offset+this.gap
				var i:int=0
				ret.graphics.beginBitmapFill(base,new Matrix(),true,true)
				ret.graphics.drawRect(0,0,offset,height)

				do {
					var hs:Number = this.blocks[element.uniqueId][i]*height
					ret.graphics.drawRect(n,hs,this.width,height-hs)
					n+=this.width+this.gap
					i++
				} while(n<width-this.width)

				ret.graphics.drawRect(n,0,width-n,height)
				ret.graphics.endFill()
				
				return ret
			}

			/** 
			* Retrieves an array of holes (if any) of this material. These holes will be used to render proper lights and calculate collisions
			* and bullet impacts
			*
			* @param element: Element where the holes will be applied
			* @param width: Requested width
			* @param height: Requested height
			*
			* @return An array of Rectangle objects, one for each hole. Positions and sizes are relative to material origin of coordinates
			*
			*/
			public function getHoles(element:fRenderableElement,width:Number,height:Number):Array {
				
/*			var nHoles:int = int(width/(this.width+this.gap))
				var ret:Array = new Array
				var offset:Number = width-(nHoles*this.width)-(nHoles-1)*this.gap
				
				// Base holes
				for(var i:Number=0;i<nHoles;i++) ret[ret.length] = new Rectangle(offset+(this.width+this.gap)*i,0,this.gap,height)
				
				// Iregularity
				var t:Array = this.blocks[element.uniqueId] = new Array
				var n:Number = offset+this.gap
				do {
					if(this.irregular!=0) {
						var hs:Number = Math.random()*this.irregular/100
						ret[ret.length] = new Rectangle(n,0,this.width,hs*height)
					} else hs = 0					
					t[t.length] = hs
					n+=this.width+this.gap
				} while(n<width-this.width)
				
				return ret 
				*/
				
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
				
				var nHoles:int = int(width/(this.width+this.gap))
				var ret:Array = new Array
				var offset:Number = width-(nHoles*this.width)-(nHoles-1)*this.gap
				
				// Iregularity
				var t:Array = this.blocks[element.uniqueId] = new Array
				var n:Number = offset+this.gap
				
				ret[ret.length] = [new Point(0,0),new Point(offset,0),new Point(offset,height),new Point(0,height)]
				do {
					var hs:Number = Math.random()*this.irregular/100
					var h:Number = hs*height
					ret[ret.length] = [new Point(n,h),new Point(n+this.width,h),new Point(n+this.width,height),new Point(n,height)]
					t[t.length] = hs
					n+=this.width+this.gap
					
				} while(n<width-this.width)

				ret[ret.length] = [new Point(n,0),new Point(width,0),new Point(width,height),new Point(n,height)]
				
				return ret
			}

			/**
			* Retrieves the graphic element that is to be used to block a given hole when it is closed
			*
			* @param index The hole index, as returned by the getHoles() method
			* @return A Movieclip that will used to close the hole. If null is returned, the hole won't be "closeable".
			*/
			public function getHoleBlock(element:fRenderableElement,index:Number):MovieClip {
				
				return null
				
			}


		}

}