package com.ice.util.ds {

		/**
		* Geometric representation of a box. It is used as base for collisionModels and shadowModels
		* @private
		*/
		public class fBox {
			
			// Public vars

			/**
			* size along x-axis
			*/
			public var _width:Number
			
			/**
			* size along y-axis
			*/
			public var _depth:Number

			/**
			* size along z-axis
			*/
			public var _height:Number

			// Constructor
			public function fBox(width:Number,depth:Number,height:Number):void {
				 
				 this._width = width
				 this._depth = depth
				 this._height = height
				 
			}
			
	 }

}