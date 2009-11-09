package com.ice.core.renderEngines.flash9RenderEngine.helpers {
	
		// Imports

		/**
		* @private
		* Caches projection information for a given object and projection point
	  */
		public class fObjectProjectionCache {

			// Public properties
	    public var projection:fObjectProjection
			public var floorz:Number
			public var x:Number
			public var y:Number
			public var z:Number
			
			// Constructor
			function fObjectProjectionCache():void {
			
			}
			
			/**
			* Test values against cache key
			*/
			public function test(floorz:Number,x:Number,y:Number,z:Number):Boolean {
					return (floorz==this.floorz && x==this.x && y==this.y && z==this.z)
			}

			/**
			* Updates values 
			*/
			public function update(floorz:Number,x:Number,y:Number,z:Number,proj:fObjectProjection):void {
					this.floorz = floorz
					this.x = x
					this.y = y
					this.z = z
					this.projection = proj
			}

			/** Frees memory */
			public function dispose():void {
					this.projection = null
			}

		}
		
} 
