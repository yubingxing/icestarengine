package com.ice.util {

		// Imports
		import flash.geom.Point
		
		/** This class stores the result of a collision between a line and a circle
		*/
		public class LineCircleIntersectionResult {
		
			public var enter:Point					// Intersection Point entering the circle
			public var exit:Point			  		// Intersection Point exiting the circle
			public var inside:Boolean   		// Boolean indicating if the points of the line are inside the circle.<br>
			public var tangent:Boolean			// Boolean indicating if line intersect at one point of the circle.<br>
			public var intersects:Boolean		// Boolean indicating if there is an intersection of the points and the circle.<br>
		
		}
		
}