package com.ice.core.materials {

		// Imports
		
		/**
		* This class creates a material by stacking several layers of "tile" materials, using a perlin noise funcion as alpha mask for each layer
		*
		* <p>This class is automatically selected when you define a material as "perlin" in your XMLs. You don't need to use
		* it or worry about how it works</p>
		* @private
		*/
		public class fPerlinMaterial implements fEngineMaterial {
			
			// Setup
			
			/** Precision of the noise. The bigger the number the less accurate the noise. 1 means pixel precision but makes the noise way
			slower to calculate and it's not worth it */
			public static const NOISE_PRECISION:int = 10
			
			// Private vars
			private var definition:fMaterialDefinition	// Definition data
			private var element:fRenderableElement			// The element where this material is applied. In perlin materials you need to know
																									// its coordinates so the material moves seamlessly between planes
																									
			private var baseMaterial:fMaterial					// Base material
			private var materialLayers:Array						// Material for each layer
			private var materialNoises:Array						// Noise for each layer
			
			// Constructor
			public function fPerlinMaterial(definition:fMaterialDefinition):void {

				this.definition = definition

				this.materialLayers = new Array
				this.materialNoises = new Array
				this.baseMaterial = fMaterial.getMaterial(this.definition.xmlData.base)
				
				var layers:XMLList = this.definition.xmlData.child("layer")
				for(var i:Number=0;i<layers.length();i++) {
				  this.materialLayers[i] = fMaterial.getMaterial(layers[i].material)
					this.materialNoises[i] = new fNoiseDefinition(layers[i].noise[0])
				}

			}
			
			/**
			* Frees all allocated resources for this material. It is called when the scene is destroyed and we want to free as much RAM as possible
			*/
			public function dispose():void {
				this.definition = null
				
				this.materialLayers = null
				this.materialNoises = null
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
				
				var temp:Sprite = new Sprite
				var tDatas:Array = new Array
				
				var precision:int = fPerlinMaterial.NOISE_PRECISION

				// Draw base
				temp.addChild(this.baseMaterial.getDiffuse(element,width,height))
				
				// Draw layers, if any
				var ml:int = this.materialLayers.length
				for(var i:int=0;i<ml;i++) {
					
					var layer:BitmapData = new BitmapData(width,height,true,0x00000000)
					var diffuse:DisplayObject = this.materialLayers[i].getDiffuse(element,width,height)
					layer.draw(diffuse)
					var msk2:BitmapData = new BitmapData(width,height,false,0x000000)
					try {
						var msk:BitmapData = new BitmapData(width/precision,height/precision,false,0x000000)
						var n:fNoiseDefinition = this.materialNoises[i]
						n.drawNoise(msk,BitmapDataChannel.RED,element.x/precision,element.y/precision,1/precision)
						var mat:Matrix = new Matrix()
						mat.scale(precision,precision)
						msk2.draw(msk,mat)
						msk.dispose()
					} catch(e:Error) {
						throw new Error("Filmation Engine Exception: Attempt to use a nonexistent noise definition ")
					}
					layer.copyChannel(msk2,new Rectangle(0, 0, width,height),new Point(0,0),BitmapDataChannel.RED, BitmapDataChannel.ALPHA)
					msk2.dispose()
					tDatas[tDatas.length] = layer
					temp.addChild(new Bitmap(layer))
					
				}
				
				// Merge layers
			  msk = new BitmapData(width,height)
				msk.draw(temp)
				var dl:int = tDatas.length 
				for(i=0;i<dl;i++) {
					tDatas[i].dispose()
					tDatas[i] = null
				}
				return new Bitmap(msk)
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
				
				var temp:Sprite = new Sprite
				var tDatas:Array = new Array
				
				var precision:int = fPerlinMaterial.NOISE_PRECISION

				// Draw base
				temp.addChild(this.baseMaterial.getBump(element,width,height))
				
				// Draw layers, if any
				var ml:int = this.materialLayers.length
				for(var i:int=0;i<ml;i++) {
					
					var layer:BitmapData = new BitmapData(width,height,true,0x00000000)
					var diffuse:DisplayObject = this.materialLayers[i].getBump(element,width,height)
					layer.draw(diffuse)
					var msk2:BitmapData = new BitmapData(width,height,false,0x000000)
					try {
						var msk:BitmapData = new BitmapData(width/precision,height/precision,false,0x000000)
						var n:fNoiseDefinition = this.materialNoises[i]
						n.drawNoise(msk,BitmapDataChannel.RED,element.x/precision,element.y/precision,1/precision)
						var mat:Matrix = new Matrix()
						mat.scale(precision,precision)
						msk2.draw(msk,mat)
						msk.dispose()
					} catch(e:Error) {
						throw new Error("Filmation Engine Exception: Attempt to use a nonexistent noise definition ")
					}
					layer.copyChannel(msk2,new Rectangle(0, 0, width,height),new Point(0,0),BitmapDataChannel.RED, BitmapDataChannel.ALPHA)
					msk2.dispose()
					tDatas[tDatas.length] = layer
					temp.addChild(new Bitmap(layer))
					
				}
				
				// Merge layers
			  msk = new BitmapData(width,height)
				msk.draw(temp)
				var dl:int = tDatas.length 
				for(i=0;i<dl;i++) {
					tDatas[i].dispose()
					tDatas[i] = null
				}
				return new Bitmap(msk)
				
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