package com.ice.core.materials {
	import flash.display.Sprite;

		// Imports
		
		/**
		* This class adds windows to any wall. This is a fast way of creating nicer buildings with little effort
		*
		* <p>This class is automatically selected when you define a material as "window" in your XMLs. You don't need to use
		* it or worry about how it works</p>
		* @private
		*/
		public class WindowMaterial implements fEngineMaterial {
			
			// Private vars
			private var definition:fMaterialDefinition	// Definition data
			
			private	var wwidth:Number										// Windows dimensions
			private	var wheight:Number
			private	var windows:Array
			private	var position:Number
			private	var framesize:Number
			private	var separation:Number
			private	var geometryW:int
			private	var geometryH:int
			private	var hDivisionSize:Number
			private	var vDivisionSize:Number
			
			// Constructor
			public function WindowMaterial(definition:fMaterialDefinition):void {
				this.definition = definition
				
				// Retrieve window data
				this.wwidth = new Number(this.definition.xmlData.width)
				this.wheight = new Number(this.definition.xmlData.height)
				this.position = new Number(this.definition.xmlData.position)
				this.framesize = new Number(this.definition.xmlData.framesize)
				this.separation = new Number(this.definition.xmlData.separation)
				
				var t:String = this.definition.xmlData.geometry
				try { this.geometryW = new Number(t.split("x")[0]) } catch(e:Error) { this.geometryW = 1}
				try { this.geometryH = new Number(t.split("x")[1]) } catch(e:Error) { this.geometryH = 1}

				// Subdivisions in frame
				this.hDivisionSize = (this.wwidth-(this.geometryW-1)*this.framesize)/this.geometryW
				this.vDivisionSize = (this.wheight-(this.geometryH-1)*this.framesize)/this.geometryH
				
			}
			
			/**
			* Frees all allocated resources for this material. It is called when the scene is destroyed and we want to free as much RAM as possible
			*/
			public function dispose():void {
				this.definition = null
				
			}
			

			private function calcWindows(width:Number,height:Number) {

				// Count how many windows fit in
				var nWindows:int = Math.floor(width/(this.wwidth+this.separation+this.framesize))
				
				// Calculate window vertical position
				var range:Number = (height - this.wheight) >> 1;
				var vPosition:Number = Math.round((height >> 1) + (-range * this.position / 100) - (this.wheight >> 1));
				
				// Generate window array
				this.windows = [];
				for(var j:Number = 1; j <= nWindows; j++) {
					this.windows[this.windows.length] = new Rectangle(j * width / (nWindows + 1) - (this.wwidth >> 1), vPosition, this.wwidth, this.wheight);
				}
				
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
				
				var ret:Sprite = new Sprite
				var temp:Sprite = new Sprite
				
				this.calcWindows(width,height)

				// Draw base
				var tile:fMaterial = fMaterial.getMaterial(this.definition.xmlData.base,element.scene)
				var base:BitmapData = new BitmapData(width,height,true,0x000000)
				base.draw(tile.getDiffuse(element,width,height))
				
				temp.graphics.beginBitmapFill(base,null,true,true)
				temp.graphics.moveTo(0,0)
				temp.graphics.lineTo(width,0)
				temp.graphics.lineTo(width,height)
				temp.graphics.lineTo(0,height)
				temp.graphics.lineTo(0,0)
				
				var wl:int = this.windows.length
				for(var j:int=0;j<wl;j++) {
					
					var window:Rectangle = this.windows[j]
					
					temp.graphics.moveTo(window.x,window.y)
					temp.graphics.lineTo(window.x,window.y+window.height)
					temp.graphics.lineTo(window.x+window.width,window.y+window.height)
					temp.graphics.lineTo(window.x+window.width,window.y)
					temp.graphics.lineTo(window.x,window.y)
					
				}

				temp.graphics.endFill()				


				// Draw frame, if any
				var framesize:Number = new Number(this.definition.xmlData.framesize)
				if(framesize>0 && this.definition.xmlData.frame) {
					tile = fMaterial.getMaterial(this.definition.xmlData.frame,element.scene)
					var base2:BitmapData = new BitmapData(width,height,true,0x000000)
					base2.draw(tile.getDiffuse(element,width,height))
					
					var temp2:Sprite = new Sprite
					wl = this.windows.length 
					for(j=0;j<wl;j++) {
						
						window = this.windows[j]
					
						temp2.graphics.beginBitmapFill(base2,null,true,true)
						temp2.graphics.moveTo(window.x-this.framesize,window.y-this.framesize)
						temp2.graphics.lineTo(window.x-this.framesize,window.y+window.height+this.framesize)
						temp2.graphics.lineTo(window.x+window.width+this.framesize,window.y+window.height+this.framesize)
						temp2.graphics.lineTo(window.x+window.width+this.framesize,window.y-this.framesize)
						temp2.graphics.lineTo(window.x-this.framesize,window.y-this.framesize)
						
						// Draw subdivisions in frame
						for(var k:Number=0;k<this.geometryW;k++) {
							for(var k2:Number=0;k2<this.geometryH;k2++) {
								temp2.graphics.moveTo(window.x+k*(this.framesize+this.hDivisionSize),window.y+k2*(this.framesize+this.vDivisionSize))
								temp2.graphics.lineTo(window.x+k*(this.framesize+this.hDivisionSize)+this.hDivisionSize,window.y+k2*(this.framesize+this.vDivisionSize))
								temp2.graphics.lineTo(window.x+k*(this.framesize+this.hDivisionSize)+this.hDivisionSize,window.y+k2*(this.framesize+this.vDivisionSize)+this.vDivisionSize)
								temp2.graphics.lineTo(window.x+k*(this.framesize+this.hDivisionSize),window.y+k2*(this.framesize+this.vDivisionSize)+this.vDivisionSize)
								temp2.graphics.lineTo(window.x+k*(this.framesize+this.hDivisionSize),window.y+k2*(this.framesize+this.vDivisionSize))
							}
						}	
						temp2.graphics.endFill()
					
					}
					
					// Use a dropShadow filter to add some thickness to the frame
					var angle:Number = 225
					if(element is fWall && (element as fWall).vertical) angle=315
					
					var fil = new DropShadowFilter(3,angle,0,1,5,5,1,BitmapFilterQuality.HIGH)
					temp2.filters = [fil]
					
				}


				// Merge layers
			  var msk:BitmapData = new BitmapData(width,height,true,0x000000)
				msk.draw(temp)
				msk.draw(temp2)
				ret.addChild(new Bitmap(msk,"auto",true))

				base.dispose()
				base2.dispose()
				
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
				
				var base:fMaterial = fMaterial.getMaterial(this.definition.xmlData.base,element.scene)
				return base.getBump(element,width,height)
				
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
				
				this.calcWindows(width,height)

				var holes:Array = new Array
				var wl:int = this.windows.length
				for(var j:int=0;j<wl;j++) {
					
					var window:Rectangle = this.windows[j]
				
					// Push subdivisions in frame
					for(var k:Number=0;k<this.geometryW;k++) {
						for(var k2:Number=0;k2<this.geometryH;k2++) {
							holes[holes.length] = new Rectangle(window.x+k*(this.framesize+this.hDivisionSize),window.y+k2*(this.framesize+this.vDivisionSize),this.hDivisionSize,this.vDivisionSize)
						}
					}	
				
				}
				return holes
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