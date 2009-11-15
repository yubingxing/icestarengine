// LIGHT

package com.ice.core.base {
	
		// Imports


		/**
		* <p>The fLight is an abstract definition of a light that contains generic information such as
		* intensity, size, decay and color. To create a new type of light you must extend this class</p>
		*
		* <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT</p>
		*/
		public class Light extends MovingElement {
		
			// Constants
			/** @private */
			public static const NOLIGHT:Object = { ra:0, ga:0, ba:0, aa:1, rb: 0,gb: 0, bb: 0, ab:0 }
			
			/** An string specifying the color of the light in HTML format, example: #ffeedd */
			private var _hexcolor:uint

			/** Radius of the sphere that identifies the light */
			private var _size:Number

			/** Intensity of the light goes from 0 to 100	*/
			private var _intensity:Number

			/** From 0 to 100 marks the distance along the lights's radius from where intensity stars to fade. A 0 decay defines a solid light */
			private var _decay:Number

			// Public properties

			/** Determines if this light will be rendered with bumpmapping.
			* Please note that for the bumpMapping to work in a given surface,
			* the surface will need a bumpMap definition and bumpMapping must be enabled in the engine's global parameters
			*/
			public var bump:Boolean

			/** @private */
			public var elementsV:Array
			/** @private */
			public var nElements:int
			/** @private */
			public var vCharacters:Array
			
			/** @private */
			public var lightColor:ColorTransform
			/** @private */
			public var color:ColorTransform
			
			/** @private */
			public var removed:Boolean = false
			
			/**
 			* The fLight.RENDER constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>lightrender</code> event.
 			* The event is dispatched when the light is rendered
 			*/
 			public static const RENDER:String = "lightrender"
 			
			/**
 			* The fLight.INTENSITYCHANGE constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>lightintensitychange</code> event.
 			* The event is dispatched when the light changes its intensity
 			*/
			public static const INTENSITYCHANGE:String = "lightintensitychange"
			
			/**
 			* The fLight.COLORCHANGE constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>lightcolorchange</code> event.
 			* The event is dispatched when the light changes its color
 			*/
			public static const COLORCHANGE:String = "lightcolorchange"

			/**
 			* The fLight.SIZECHANGE constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>lightsizechange</code> event.
 			* The event is dispatched when the light changes its size
 			*/
			public static const SIZECHANGE:String = "lightsizechange"

			/**
 			* The fLight.DECAYCHANGE constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>lightdecaychange</code> event.
 			* The event is dispatched when the light changes its decay
 			*/
			public static const DECAYCHANGE:String = "lightdecaychange"


			// Constructor
			/** @private */
			function Light(defObj:XML,scene:Scene) {
			
				 // Previous
				 super(defObj,scene)			 
				 
				 // Current color
			   this.color = null                        
				 
				 // BumpMapped light ?
			   this.bump = (defObj.@bump[0]=="true")

			   // Size
			   var temp:XMLList = defObj.@["size"]
			   if(temp.length()>0) {
			   	this._size = new Number(temp[0])   
			   	if(this._size == 0) this._size = Infinity
			   }
			   else this._size = Infinity
			
			   // fLight color
			   temp = defObj.@color
			   if(temp.length()>0) {

			      // Color transform object (100% light)
			      var col:String = temp.toString()
			  	 	this.hexcolor = parseInt(col.substring(1),16)
			                                            
			   } else {
						// Defaults to white light			   
			  	 	this.hexcolor = 0xffffff
			   }                   

				 // Intensity ( percentage from black to this.lightColor ) 
			   temp = defObj.@intensity
			   if(temp.length()>0) this._intensity = new Number(temp)
			   else this._intensity = 0

				 // Decay ( where does start to fade ) 
			   temp = defObj.@decay
			   if(temp.length()>0) this._decay = new Number(temp)
			   else this._decay = 0
					
			   // fLight status
			   this.elementsV = null                     // Current array of visible elements
			   this.nElements = 0                     	 // Current number of visible elements
				 this.vCharacters = new Array							 // Current array of afected characters
			
			   // Init
			   this.intensity = this._intensity
			   
			}
			
			/** Intensity of the light goes from 0 to 100	*/
			public function get intensity():Number {
			   return this._intensity
			}

			/** @private */
			public function set intensity(percent:Number):void {
			   this._intensity = Math.max(0,Math.min(percent,100))
			   this.dispatchEvent(new Event(Light.INTENSITYCHANGE))
			}
			

			/** An hexdecimal number specifying the color of the light, example: 0xffeedd */
			public function get hexcolor():uint {
			   return this._hexcolor
			}

			/** @private */
			public function set hexcolor(color:uint):void {

			   this._hexcolor = color
		   	
		     var r:uint=(this._hexcolor >> 16) & 0xFF
	       var g:uint=(this._hexcolor >> 8) & 0xFF
			   var b:uint=this._hexcolor & 0xFF
			   
			   this.lightColor = new ColorTransform(r/255,g/255,b/255,1,0,0,0,0)

			   this.dispatchEvent(new Event(Light.COLORCHANGE))

			}
			
			/** Radius of the sphere that identifies the light, a value of 0 creates a light of Infinite size (ex: The Sun) */
			public function get size():Number {
			   return this._size
			}

			/** @private */
			public function set size(s:Number):void {
			   this._size = Math.max(0,s)
				 if(this._size == 0) this._size = Infinity			   
			   this.dispatchEvent(new Event(Light.SIZECHANGE))
			}
			

			/** From 0 to 100 marks the distance along the lights's radius from where intensity stars to fade. A 0 decay defines a solid light */
			public function get decay():Number {
			   return this._decay
			}

			/** @private */
			public function set decay(d:Number):void {
			   this._decay = Math.max(0,Math.min(d,100))
			   this.dispatchEvent(new Event(Light.DECAYCHANGE))
			}
			

			/**
			* Renders the light
			*/
			public function render():void {
				this.cell = this.scene.translateToCell(this.x,this.y,this.z)
				this.dispatchEvent(new Event(Light.RENDER))
			}
			
			/** @private */
			public function disposeLight():void {

				var l:int = this.elementsV.length
				for(var i:Number=0;i<l;i++) this.elementsV[i] = null
				this.elementsV = null
				l = this.vCharacters.length
				for(i=0;i<l;i++) this.vCharacters[i] = null
				this.vCharacters = null
				this.lightColor = null
				this.color = null
				this.disposeElement()
				
			}

			/** @private */
			public override function dispose():void {
				this.disposeLight()
			}



		}
}

