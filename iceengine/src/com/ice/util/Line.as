package com.ice.util {


		/** 
		* A line definition, 2 points
		* @private
	  */
		public class Line	{

				/** 
				* First point x component
				*/
		    public var x1:Number;

				/** 
				* First point y component
				*/
		    public var y1:Number;

				/**
				* Second point x component
				*/
		    public var x2:Number;

				/**
				* Second point y component
				*/
		    public var y2:Number;

		    /**
		    * Constructor for this class
		    */
		    public function Line(x1:Number,y1:Number,x2:Number,y2:Number):void {
		    	this.x1 = x1
		    	this.y1 = y1
		    	this.x2 = x2
		    	this.y2 = y2
		    }
		
		}

}
