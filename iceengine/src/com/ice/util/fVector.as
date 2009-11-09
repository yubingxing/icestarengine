package com.ice.util {


		/** 
		* A 2d fVector class
		* @private
	  */
		public class fVector	{

				/** 
				* X component
				*/
		    public var x:Number;

				/**
				* Y component
				*/
		    public var y:Number;

		    /**
		    * Constructor for this class
		    */
		    public function fVector(vx:Number,vy:Number) {
			    x = vx;
			    y = vy;
		    }
		
		    /**
		     * Generates a string from this vector. Useful to debug
		     * @return A string containing 2d class properties.
		    **/
		    public function toString():String {
			    return ("["+x+","+y+"]")
		    }
		
		    /**
		     * Calculates the dot product of this and given vectors
		     * @param The second vector vector.
		     * @return  returns the dot product of this instance and 'V'.
		    **/
		    public function dotProduct(V:fVector):Number {
			    return (x*V.x)+(y*V.y)
		    }
		
		
		    /**
		     * Calculates normal of this instance vector
		     * @return returns normal of this instance.
		    **/
		    public function norm():Number  {
			    return Math.sqrt((x*x)+(y*y))
		    }
		
		
		    /**
		     * Returns the unit vector of this instance.
		     * @return A new fVector object populated with this instance's unit vector.
		    **/
		    public function unitfVector():fVector  {
			    var unit:fVector
			    var norm:Number = this.norm()
		      unit = new fVector(x,y)
			    unit.x /= norm;
			    unit.y /= norm;
			    return unit;
		    }
		
		
		    /**
		     * Normalizes this instance.
		    **/
		    public function normalize(): void  {
			    var norm:Number = this.norm()
			    x /= norm;
			    y /= norm;
		    }
		
		    /**
		     * Returns angle between this instance and given parameter
		     * @param Another vector
		     * @return the angle between this instance and the parameter
		    **/
		    public function anglefVector(V:fVector):Number  {
			    return this.dotProduct(V)/(this.norm()*V.norm());
		    }
		
		
		    /**
		     * Defines perpendicular direction vector of this instance.
		     * @return A perpendicular direction vector of this instance.
		    **/
		    public function getPerpendicular():fVector  {
		        return new fVector(-y,x)
		    }
		
		}

}
