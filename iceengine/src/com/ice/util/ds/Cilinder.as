package com.ice.util.ds {

		/**
		* Geometric representation of a cilinder. It is used as base for collisionModels and shadowModels
		* @private
		*/
		public class Cilinder {
			
			// Public vars

			/**
			* Radius of this cilinder
			*/
			public var _radius:Number
			
			/**
			* Height of this cilinder
			*/
			public var _height:Number

			// Constructor
			public function Cilinder(radius:Number,height:Number):void {
				 
				 this._radius = radius
				 this._height = height
				 
			}
			
		}

}