// Noise

package com.ice.helpers {
	
		// Imports
		import flash.display.*
		import flash.geom.*
		import flash.filters.*
		import flash.utils.*

		/**
		* This object stores a perlin noise definition that was loaded from a definition file. Noise definitions are
		* used internally by Perlin materials 
		*
		* @private
		*
    * @example Here's an example of a noise definition in a definition XML
    *
	  * <listing version="3.0">
    * &lt;noiseDefinition name="Ground_noise_1"&gt;
    *
    *   &lt;seed&gt;0&lt;/seed&gt;
    *   &lt;baseX&gt;500&lt;/baseX&gt;
    *   &lt;baseY&gt;500&lt;/baseY&gt;
    *   &lt;octaves&gt;2&lt;/octaves&gt;
		*	  &lt;fractal&gt;true&lt;/fractal&gt;
		*
		* &lt;/noiseDefinition&gt;
	  * </listing>
		*
	  * <p><b>seed</b>: The random seed number to use. If you keep all other parameters the same, you can generate
	  * different pseudo-random results by varying the random seed value. The Perlin noise function creates the
	  * same results each time from the same random seed. Use 0 if you want the engine to pick a random one each time</p>
	  * 
	  * <p><b>baseX</b>: Frequency to use in the x direction.</p>
	  * 
	  * <p><b>baseY</b>: Frequency to use in the y direction.</p>
	  * 
	  * <p><b>octaves</b>: Number of octaves or individual noise functions to combine to create this noise.
	  * Larger numbers of octaves create noise with greater detail. Larger numbers of octaves also require more processing time.</p>
	  * 
	  * <p><b>fractal</b>: If the value is true, the method generates fractal noise; otherwise, it generates turbulence.
	  * An image with turbulence has visible discontinuities in the gradient that can make it better approximate
	  * sharper visual effects like flames and ocean waves.</p>
	  * 
		* @see org.ffilmation.engine.materials.fPerlinMaterial
		*/
		public class NoiseDefinition {
		
			private var seed:int

			private var baseX:Number
			private var baseY:Number
	    private var octaves:uint
	         
			private var fractal:Boolean
			
			/**
			* Constructor for the fNoise class
			*
			* @param definitionXML Definition for this noise as it was found in a definition XML
		  *
			* @private
			*/
			function NoiseDefinition(definitionXML:XML):void {
			
				 // Make sure this noise has a proper definition
				 try {

				 		var s:int = parseInt(definitionXML.seed)
				 		if(s!=0) this.seed = s
				 		else this.seed = Math.round(10000*Math.random())
				 		
				 		this.baseX = new Number(definitionXML.baseX)
				 		this.baseY = new Number(definitionXML.baseY)
				 		this.octaves = parseInt(definitionXML.octaves)
				 		this.fractal = (definitionXML.fractal!="false")
				 		
				 } catch (e:Error) {
				 		throw new Error("Filmation Engine Exception: An invalid noise definition was found: '"+definitionXML.@name+"'")
				 }
				 
			}
			
			/**
			* Draws this noise into a bitmpaData.
			*
			* @param bmap The BitmapData where the noise is to be drawn
			
			* @param channels A number that can be a combination of any of the four color channel values (BitmapDataChannel.RED, BitmapDataChannel.BLUE, BitmapDataChannel.GREEN, and BitmapDataChannel.ALPHA). You can use the logical OR operator (|) to combine channel values.
			
			* @param offx Horizontal offset that will be applied to the noise
			
			* @param offy Vertical offset that will be applied to the noise
			*
			* @param scale Scale to apply to thwe noise's size
			*
			*/
			public function drawNoise(bmap:BitmapData,channels:uint,offx:Number,offy:Number,scale:Number=1):void {			
			
				// Generate offfset array
				var offsets = new Array
				for(var i:Number=0;i<this.octaves;i++) offsets[offsets.length] = new Point(offx,offy)
				
				// Draw
				bmap.perlinNoise(this.baseX*scale, this.baseY*scale, this.octaves, this.seed, false, this.fractal, channels, false, offsets)

				// Sharpen noise
				var sharpen = [11,0,0,0,-1295,0,11,0,0,-1295,0,0,11,0,-1295,0,0,0,1,0]
				var sharp:ColorMatrixFilter = new ColorMatrixFilter(sharpen)
				bmap.applyFilter(bmap,new Rectangle(0, 0, bmap.width,bmap.height),new Point(0,0),sharp)
			
			}
		
			/**
			* Returns the intensity ( from 0 to 1 ) of the perlin noise at a given coordinate. 
			*
			* @param x Test coordinate X
			*
			* @param y Test coordinate Y
			*
			* @return A Number from 0 ( noise does not cover that coordinate at all ) and 1 ( noise fully covers that coordinate)
			*
			*/
			public function getIntensityAt(x:Number,y:Number):Number {
				
				var bmap:BitmapData = new BitmapData(1,1)
				var offsets = new Array
				for(var i:Number=0;i<this.octaves;i++) offsets[offsets.length] = (new Point(x,y))

				bmap.perlinNoise(this.baseX, this.baseY, this.octaves, this.seed, false, this.fractal, BitmapDataChannel.RED, false, offsets)
				
				var ret:Number = new Number(bmap.getPixel(0,0)/0xff0000)
				bmap.dispose()
				return ret
				
			}

			
		}
}

