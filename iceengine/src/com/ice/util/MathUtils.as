package org.ffilmation.utils  {

		// Imports
		import flash.geom.Point
		
		/** 
		* This class provides various useful math methods
	  */
		public class MathUtils {
		
			// Angle between two points
			public static function getAngle(x1:Number, y1:Number, x2:Number, y2:Number, dist:Number=0):Number {
			   var ret:Number = Math.atan2(y2-y1,x2-x1)
				 if(ret<0) ret += 2*Math.PI
				 return ret*180/Math.PI
			}
			
			/** 
			* Distance between two points
			*/
			public static function distance(x1:Number,y1:Number,x2:Number,y2:Number):Number {
			   var dx:Number = x1-x2
			   var dy:Number = y2-y1
			   return Math.sqrt(dx*dx + dy*dy)
			}
			
			/**
			* Distance between two points (3d)
			*/
			public static function distance3d(x1:Number,y1:Number,z1:Number,x2:Number,y2:Number,z2:Number):Number {
			   var dx:Number = x1-x2
			   var dy:Number = y2-y1
			   var dz:Number = z2-z1
			   return Math.sqrt(dx*dx + dy*dy + dz*dz)
			}
			
			/**
			* Distance between a Point and a segment
			* source: http://www.codeguru.com/forum/showthread.php?t=194400
			*/
			public static function distancePointToSegment(SegA:Point,SegB:Point,point:Point):Number {
				
				var ax:Number = SegA.x
				var ay:Number = SegA.y
				var bx:Number = SegB.x
				var by:Number = SegB.y
				var cx:Number = point.x
				var cy:Number = point.y

				var r_numerator:Number = (cx-ax)*(bx-ax) + (cy-ay)*(by-ay)
				var r_denomenator:Number = (bx-ax)*(bx-ax) + (by-ay)*(by-ay)
				var r:Number = r_numerator / r_denomenator
				
				var s:Number =  ((ay-cy)*(bx-ax)-(ax-cx)*(by-ay) ) / r_denomenator
				
				if ( (r >= 0) && (r <= 1) ) {
					if(s<0) return -s*Math.sqrt(r_denomenator)
					return s*Math.sqrt(r_denomenator)
				}
				else {
				
					var dist1:Number = (cx-ax)*(cx-ax) + (cy-ay)*(cy-ay)
					var dist2:Number = (cx-bx)*(cx-bx) + (cy-by)*(cy-by)
					if (dist1 < dist2) {
						return Math.sqrt(dist1)
					}	else {
						return Math.sqrt(dist2)
					}
			
				}
				

			}

			/**
			* Finds out if a segment an a circle intersect and if so, return the intersection points<br>
			* source: http://keith-hair.net/blog/2008/08/05/line-to-circle-intersection-data/#more-23
			* @return An lineCircleIntersectionResult with the results of the calculation
			* 
			**/
			public static function segmentIntersectCircle(A : Point, B : Point, C : Point, r : Number ):lineCircleIntersectionResult {
				
				var result:lineCircleIntersectionResult = new lineCircleIntersectionResult()
				result.inside = false
				result.tangent = false
				result.intersects = false
				result.enter=null
				result.exit=null
				
				var a : Number = (B.x - A.x) * (B.x - A.x) + (B.y - A.y) * (B.y - A.y)
				var b : Number = 2 * ((B.x - A.x) * (A.x - C.x) +(B.y - A.y) * (A.y - C.y))
				var cc : Number = C.x * C.x + C.y * C.y + A.x * A.x + A.y * A.y - 2 * (C.x * A.x + C.y * A.y) - r * r
				var deter : Number = b * b - 4 * a * cc
				
				if (deter <= 0 ) {
					result.inside = false
				} else {
					var e : Number = Math.sqrt (deter)
					var u1 : Number = ( - b + e ) / (2 * a )
					var u2 : Number = ( - b - e ) / (2 * a )
					if ((u1 < 0 || u1 > 1) && (u2 < 0 || u2 > 1)) {
						if ((u1 < 0 && u2 < 0) || (u1 > 1 && u2 > 1)) {
							result.inside = false
						} else {
							result.inside = true
						}
					} else {
						if (0 <= u2 && u2 <= 1) {
							result.enter = Point.interpolate (A, B, 1 - u2)
						}
						if (0 <= u1 && u1 <= 1) {
							result.exit = Point.interpolate (A, B, 1 - u1)
						}
						result.intersects = true;
						if (result.exit != null && result.enter != null && result.exit.equals(result.enter)) {
							result.tangent = true;
						}
					}
				}
				
				return result
				
			}


			/**
			* Find out if two segments intersect and if so, retrieve the point 
			* of intersection.<br>
			* Source: http://vision.dai.ed.ac.uk/andrewfg/c-g-a-faq.html
			* @return the Point of intersection
			*/
			public static function segmentsIntersect(xa:Number, ya:Number, xb:Number, yb:Number, xc:Number, yc:Number, xd:Number, yd:Number):Point {

        //trace("Intersect "+xa+","+ya+" "+xb+","+yb+" -> "+xc+","+yc+" "+xd+","+yd)
        var result:Point

        var ua_t:Number = (xd-xc)*(ya-yc)-(yd-yc)*(xa-xc)
        var ub_t:Number = (xb-xa)*(ya-yc)-(yb-ya)*(xa-xc)
        var u_b:Number = (yd-yc)*(xb-xa)-(xd-xc)*(yb-ya)

        if (u_b!=0)  {

            var ua:Number = ua_t/u_b;
            var ub:Number = ub_t/u_b;

            if (ua>=0 && ua<=1 && ub>=0 && ub<=1) {
                result = new Point(xa+ua*(xb-xa),ya+ua*(yb-ya))
            } else result = null
        }
        else result = null

        return result
			
			}
			
			/**
			* Find out if two lines intersect and if so, retrieve the point 
			* of intersection.<br>
			* Source: http://members.shaw.ca/flashprogramming/wisASLibrary/wis/math/geom/intersect2D/Intersect2DLine.as
			* @return the Point of intersection
			*/
			public static function linesIntersect(xa:Number,ya:Number, xb:Number, yb:Number, xc:Number, yc:Number, xd:Number, yd:Number):Point {
	    
        var result:Point

        var ua_t:Number = (xd-xc)*(ya-yc)-(yd-yc)*(xa-xc)
        var ub_t:Number = (xb-xa)*(ya-yc)-(yb-ya)*(xa-xc)
        var u_b:Number = (yd-yc)*(xb-xa)-(xd-xc)*(yb-ya)

        if (u_b!=0)  {
            var ua:Number = ua_t/u_b;
            var ub:Number = ub_t/u_b;
            result = new Point(xa+ua*(xb-xa),ya+ua*(yb-ya))
        }
        else result = null
        return result
		}

	}

}