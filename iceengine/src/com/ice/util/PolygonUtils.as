package org.ffilmation.utils {

		// Imports
		import flash.geom.Point

		/** 
		* This class provides several polygon algorythms
		* @private
	  */
		public class PolygonUtils {

			// Temporary variables
			private static var Cp_start:Point = null				/* The start point of the line */
			private static var M_code:Number = 0
			private static var Cp_end:Point = null 				/* The end point of the line */
			private static var D_code:Number = 0
			
			// These are two look_up tables  used in finding the turning point
			// Tcc is used to compute a correct  offset, while Cra gives an index in the Clip_region array, for the turning coordinates.
			private static var Tcc:Array = [0,-3,-6,1,3,0,1,0,6,1,0,0,1,0,0,0]
			private static var Cra:Array = [-1,-1,-1,3,-1,-1,2,-1,-1,1,-1,-1,0,-1,-1,-1]
			

			/**
			* Checks if polygon A is intersects polygon B.
			*
			* As seen on: http://www.codeproject.com/cs/media/PolygonCollision.asp
			*
			* @param polygonA An array of points defining polygon A
			*
			* @param polygonB An array of points defining polygon B
			*
			*/
			public static function checkPolygonCollision(polygonA:Array, polygonB:Array):Boolean {

			    // Generate arrays of edges
			    var pALength:int = polygonA.length, pBLength:int = polygonB.length, edgesA:Array = new Array(),edgesB:Array = new Array()

			    for(var i:int=1;i<pALength;i++) {
			    	edgesA[int(i-1)] = new fVector(polygonA[i].x-polygonA[int(i-1)].x,polygonA[i].y-polygonA[int(i-1)].y)
			    }
			    edgesA[int(i-1)] = new fVector(polygonA[i-1].x-polygonA[0].x,polygonA[i-1].y-polygonA[0].y)
			    
			    for(i=1;i<pBLength;i++) {
			    	edgesB[int(i-1)] = new fVector(polygonB[i].x-polygonB[int(i-1)].x,polygonB[i].y-polygonB[int(i-1)].y)
			    }
			    edgesB[int(i-1)] = new fVector(polygonB[i-1].x-polygonB[0].x,polygonB[i-1].y-polygonB[0].y)

			    var edgeCountA:int = edgesA.length, edgeCountB:int = edgesB.length, edge:fVector, result:Boolean = true, total:int = edgeCountA + edgeCountB
	        var axis:fVector, boundA:polygonProjection, boundB:polygonProjection

			    // Loop through all the edges of both polygons
			    for (var edgeIndex:int = 0; edgeIndex < total; edgeIndex++) {
			        if (edgeIndex < edgeCountA) {
			            edge = edgesA[edgeIndex]
			        } else {
			            edge = edgesB[int(edgeIndex - edgeCountA)]
			        }
			
			        // Find the axis perpendicular to the current edge
			        axis = edge.getPerpendicular()
			        axis.normalize()
			
			        // Find the projection of the polygon on the current axis
			        boundA = PolygonUtils.ProjectPolygon(axis, polygonA)
			        boundB = PolygonUtils.ProjectPolygon(axis, polygonB)
			
			        // Check if the polygon projections are currentlty intersecting
			        if (PolygonUtils.IntervalDistance(boundA.min, boundA.max, boundB.min, boundB.max) > 0) result = false
			
			        // If the polygons are not intersecting, exit the loop
			        if (!result) break;
			
			    }
			
			    return result;
			}
			
			
			/*
			* Calculate the distance between [minA, maxA] and [minB, maxB]
			* The distance will be negative if the intervals overlap
			*/
			private static function IntervalDistance(minA:Number, maxA:Number, minB:Number, maxB:Number):Number {
			    if (minA < minB) {
			        return minB - maxA;
			    } else {
			        return minA - maxB;
			    }
			}
			
			
			/*
			* Calculate the projection of a polygon on an axis
			* and returns it as a [min, max] interval
			*/
			private static function ProjectPolygon(axis:fVector,polygon:Array):polygonProjection {
				
			    var ret:polygonProjection = new polygonProjection()

			    // To project a point on an axis use the dot product
			    var dotProduct:Number = axis.dotProduct(new fVector(polygon[0].x,polygon[0].y))
			    ret.min = dotProduct
			    ret.max = dotProduct

			    var pl:int = polygon.length
			    for (var i:int = 0; i < pl; i++) {
			        dotProduct = axis.dotProduct(new fVector(polygon[i].x,polygon[i].y))
			        if (dotProduct < ret.min) {
			            ret.min = dotProduct
			        } else {
			            if (dotProduct> ret.max) {
			                ret.max = dotProduct
			            }
			        }
			    }
			    
			    return ret
			}


			/**
			*	The clipPolygon() function accepts an array of vertices as input and clips the polygon edges against a rectangular clip region.
			*	Turning points are generated when necessary to keep the polygon structure and ensure a correct visualization.
			*	The function generates the resulting polygons in an output array of points.
			*
			* As seen on 	http://www.chez.com/pmaillot/2dpclip/2dpclip.htm
			*/
			public static function clipPolygon(polygon:Array,viewport:vport):Array {
			 
				var nin:int = polygon.length
				var out:Array = new Array()
			
				if(nin==0) return []
				
				// Make sure poly is closed
				if(!polygon[nin-1].equals(polygon[0])) {
					polygon[nin] = polygon[0]
					nin++
				}
				
				// Viewport
			
				var Clip_region:Array = [
							new Point(viewport.x_min,viewport.y_max),
							new Point(viewport.x_max,viewport.y_max),
							new Point(viewport.x_min,viewport.y_min),
							new Point(viewport.x_max,viewport.y_min)
				]
			
				// Temporary data used in the case of a 2-2 bit
			
				var Cp_t_start:Point = new Point(0,0)
				var Cp_t_end:Point = new Point(0,0)
			  var Cp_A_point:Point = new Point(0,0)
			
				var A_code:Number;
			
				// Compute the first point' status.
				// If visible, then store the first point in the output array.
			
				PolygonUtils.Cp_start = new Point(polygon[0].x,polygon[0].y)
			
				if (PolygonUtils.clipPolygonStep1(viewport)!=0) {
					out[out.length] = PolygonUtils.Cp_start;
				}
			
				// Next polygon's points... We build a vector from the "start" point to the "end" point.
				// Clip the line with a standard 2D line clipping method.
			
				var i:int,j:Number
				for (i = 1; i < nin; i++) {
			
					PolygonUtils.Cp_end = new Point(polygon[i].x,polygon[i].y)
					j = PolygonUtils.clipPolygonStep2(viewport)
			
					// If the line is visible, then store the computed point(s), and jump to the basic turning point test.
					if(j & 1) {
						if (j & 2) {
							out[out.length] = PolygonUtils.Cp_start;
						}
						out[out.length] = PolygonUtils.Cp_end;
					} else {
			
					// Here the line has been rejected... Apply the polygon clipping.
			
						// Begin with a 2bit end point.
			    	
						if (PolygonUtils.D_code & 0x100) {
			
							if (!((PolygonUtils.M_code& ~0x100) & (PolygonUtils.D_code& ~0x100))) {
			    	
								// If the start point is also a 2bit... Need some more information to make a decision! So do mid-point subdivision.
			    	
								if (PolygonUtils.M_code & 0x100) {
			    	
									j = 1;
									Cp_t_start = PolygonUtils.Cp_start
									Cp_t_end = PolygonUtils.Cp_end
			    	
									var maxLoops:int = 10
									while (j && maxLoops>0) {
										
										maxLoops--
			    	
										Cp_A_point.x = (Cp_t_start.x + Cp_t_end.x) >> 1;
										Cp_A_point.y = (Cp_t_start.y + Cp_t_end.y) >> 1;
			    	
									  A_code = PolygonUtils.spaceCode(Cp_A_point,viewport)
			    	
									  if (A_code & 0x100) {
			    	
											if (A_code == PolygonUtils.D_code) {
			    	
												Cp_t_end = Cp_A_point;
			    	
											} else {
			    	
												if (A_code == PolygonUtils.M_code) Cp_t_start = Cp_A_point
												else j = 0
			    	
											}
			    	
										} else {
			    	
											if (A_code & PolygonUtils.D_code) A_code = PolygonUtils.M_code + PolygonUtils.Tcc[A_code & ~0x100]
											else A_code = PolygonUtils.D_code + PolygonUtils.Tcc[A_code & ~0x100]
										  j = 0
			    	
										}
			    	
									}
			    	
								} else {
			
									// This is for a 1 bit start point (2bit end point).
									A_code = PolygonUtils.D_code + PolygonUtils.Tcc[PolygonUtils.M_code]
			
								}
			  	
								out[out.length] = Clip_region[PolygonUtils.Cra[A_code & ~0x100]]
			    	
							}
			    	
						} else {
			    	
							// Here we have a 1bit end point.
							
							if (PolygonUtils.M_code & 0x100) {
								if (!(PolygonUtils.M_code & PolygonUtils.D_code)) PolygonUtils.D_code = PolygonUtils.M_code + PolygonUtils.Tcc[PolygonUtils.D_code]
							} else {
								PolygonUtils.D_code |= PolygonUtils.M_code
								if (PolygonUtils.Tcc[PolygonUtils.D_code] == 1) PolygonUtils.D_code |= 0x100
							}
			    	
						}
			
					}
			
					// The basic turning point test...
			
					if (PolygonUtils.D_code & 0x100) {
						out[out.length] = Clip_region[PolygonUtils.Cra[PolygonUtils.D_code & ~0x100]]
					}
			
					// Copy the current point as the next starting point.
					PolygonUtils.Cp_start = new Point(polygon[i].x,polygon[i].y)
					PolygonUtils.M_code = PolygonUtils.D_code
					
				}
			
				// Close output polygon
				if (out.length>0) out[out.length] = out[0];
			
				// Return
				return out
			
			}
			
			
			/*
			* clipPolygonStep1() performs a simple coding of the first point of the polygon.
			* This function returns SEGM if the point is inside the clipping region, NOSEGM if the point is outside.
			*/
			private static function clipPolygonStep1(viewport:vport):int {
				PolygonUtils.M_code = PolygonUtils.spaceCode(PolygonUtils.Cp_start,viewport)
				if(PolygonUtils.M_code == 0)	return 1
				else return 0
			
			}
			
			/*
			*
			* clipPolygonStep2() performs the clipping of a line coded in the two structures polygonUtils.Cp_start and polygonUtils.Cp_end which respectively represent
			* the start and end point of one polygon edge. clipPolygonStep2() provides the following information:
			*
			*		- The returned status, NOSEGM, SEGM, SEGM | CLIP, which represents the visibility characteristic of the edge.
			*
			*		- polygonUtils.M_code and polygonUtils.D_code, which are the computed codes of the start and end point of the edge, respectively.
			*
			*		- polygonUtils.Cp_start and polygonUtils.Cp_end contain the clipped line coordinates at the end of the algorithm.
			*
			*/
			private static function clipPolygonStep2(viewport:vport):int {
				
				// Calculate end code
				PolygonUtils.D_code = PolygonUtils.spaceCode(PolygonUtils.Cp_end,viewport)
			
				// Totally in ?
				if(PolygonUtils.M_code == 0 && PolygonUtils.D_code == 0)	return 1
				
				// Clip line
				var ret:line = PolygonUtils.clipLine(PolygonUtils.Cp_start.x,PolygonUtils.Cp_start.y,PolygonUtils.Cp_end.x,PolygonUtils.Cp_end.y,viewport)
				
				// Totally out ?
				if(ret == null) return 0
				
				// Clipped line
				PolygonUtils.Cp_start.x = ret.x1
				PolygonUtils.Cp_start.y = ret.y1
				PolygonUtils.Cp_end.x = ret.x2
				PolygonUtils.Cp_end.y = ret.y2		
			
				return 1 | 2
			}
			
			
			/*
			*  The function spaceCode() returns the code associated with a given point.
			*  The returned code can be a single value, or a "OR" between a single value and a flag that indicates a 2bit code.
			*/
			private static function spaceCode(point_to_code:Point,viewport:vport):int {
			
				if (point_to_code.x < viewport.x_min) {
					if (point_to_code.y < viewport.y_min) return (6 | 0x100)
					if (point_to_code.y > viewport.y_max) return (12 | 0x100)
					return (4);
				}
			
				if (point_to_code.x > viewport.x_max) {
					if (point_to_code.y < viewport.y_min) return (3 | 0x100)
					if (point_to_code.y > viewport.y_max) return (9 | 0x100)
					return (1);
				}
			
				if (point_to_code.y < viewport.y_min) return (2)
				if (point_to_code.y > viewport.y_max) return (8)
				return (0)
			
			}
			
			/*
			*
			* 2D Liang-Barsky Line Clipping Algorithm
			*
			*/
			public static function clipLine(x1:Number,y1:Number,x2:Number,y2:Number,viewport:vport):line {
			
			  var us:Point = new Point(0,1)
			
				var ret:line = new line(x1,y1,x2,y2)
				ret.x1 = x1
				ret.x2 = x2
				ret.y1 = y1
				ret.y2 = y2
			
			  var dx:Number =(x2-x1)
			  var dy:Number =(y2-y1)
			
			  var p1:Number =(-dx)
			  var p2:Number =dx
			  var p3:Number =(-dy)
			  var p4:Number =dy
			
			  var q1:Number =(x1-viewport.x_min)
			  var q2:Number =(viewport.x_max-x1)
			  var q3:Number =(y1-viewport.y_min)
			  var q4:Number =(viewport.y_max-y1)
			
			  if(PolygonUtils.clipLineCheck(p1,q1,us) && PolygonUtils.clipLineCheck(p2,q2,us) && PolygonUtils.clipLineCheck(p3,q3,us) && PolygonUtils.clipLineCheck(p4,q4,us)) {
			  	
					if(us.y<1) {
					   ret.x2=(x1+(us.y*dx))
					   ret.y2=(y1+(us.y*dy))
					}
			
			    if(us.x>0)	{
					   ret.x1+=(us.x*dx)
					   ret.y1+=(us.x*dy)
					}
			
					return ret
			
			  }
			
				return null
			
			}
			
			
			private static function clipLineCheck(p:int,q:int,us:Point):int {
			
				var flag:Number = 1
			
			  var r:Number = q/p
			
			  if(p<0) {
				  if(r>us.y)
						flag=0;
				  else if(r>us.x)	us.x=r;
				}
			  else if(p>0) {
			  	if(r<us.x)
						flag=0;
			    else if(r<us.y)	us.y=r;
				}
			  else {
				  if(q<0)	flag=0;
				}
			
			  return flag;
			
			}
	

	}

}


 