// Character class
package com.ice.core.logic.projection {
	
		// Imports

		/** 
		* This class calculates projections from one element into other elements. The results are used mainly to render shadows but can
		* also be applied to visibility calculations.
		* @private
		*/
		public class ProjectionSolver {

			/** 
			* This method calculates the projection of any element into an imaginary plane at a given Z
			* @return An Array of Points
			*/
			public static function calculateProjection(originx:Number,originy:Number,originz:Number,element:fRenderableElement,destinyZ:Number):fPolygon {
				
				if(element is fFloor) return ProjectionSolver.calculateFloorProjection(originx,originy,originz,(element as fFloor),destinyZ)
				if(element is fWall) return ProjectionSolver.calculateWallProjection(originx,originy,originz,(element as fWall),destinyZ,element.scene)
				if(element is fObject) return ProjectionSolver.calculateObjectProjection(originx,originy,originz,element as fObject,destinyZ)
				return null
					
			}

			// PROJECTIONS INTO FLOORS
			//////////////////////////
			
			/** 
			* This method calculates the projection of a floor into an imaginary plane at a given Z
			* @return An Polygon
			*/
			public static function calculateFloorProjection(x:Number,y:Number,z:Number,floor:fFloor,destinyZ:Number):fPolygon {

				 // Simplest test
				 if(floor.z>=z) return new fPolygon()
			
				 // Project all points in all contours in Polygon
				 var ret:Array = []
				 var contours:Array = floor.shapePolygon.contours
				 var cl:int = contours.length
				 for(var i:int=0;i<cl;i++) {
						var contour:Array = contours[i]
						ret[ret.length] = ProjectionSolver.projectFloorPointsIntoFloor(contour,x,y,z,destinyZ,floor.x,floor.y,floor.z)
				 }
				 
				 // Project all holes
				 var retHoles:Array = []
				 var holes:Array = floor.holes
				 var hl:int = holes.length
				 for(i=0;i<hl;i++) {
				 	  //if(holes[i].open) {
							var bounds:fPlaneBounds = holes[i].bounds
							contour = [new Point(bounds.x0,bounds.y0),new Point(bounds.x0,bounds.y1),new Point(bounds.x1,bounds.y1),new Point(bounds.x1,bounds.y0)]
							retHoles[retHoles.length] = ProjectionSolver.projectFloorPointsIntoFloor(contour,x,y,z,destinyZ,0,0,floor.z)
					  //}
				 }

 				 // Polygon
			   var p:fPolygon = new fPolygon()
			   p.contours = ret
			   p.holes = retHoles
			   return p
			   
			}
			
			// Project array of points into this floor
			private static function projectFloorPointsIntoFloor(points:Array,x:Number,y:Number,z:Number,destinyZ:Number,offx:Number,offy:Number,offz:Number):Array {
				
 			   var dz:Number = 1+(offz-destinyZ)/(z-offz)

				 var retContour:Array = []
				 var pol:int = points.length
				 for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx+points[j].x
						var py:Number = offy+points[j].y
						var pz:Number = offz
						
						// Project point
			   	  var pLeft:Number = x+(px-x)*dz
			   	  var pUp:Number = y+(py-y)*dz
			   
			   	  retContour[retContour.length] = (new Point(pLeft, pUp))

				 }
					
				 return retContour	
				
			}


			/** 
			* This method calculates the projection of a wall into an imaginary plane at a given Z
			* @return A polygon
			*/
			public static function calculateWallProjection(x:Number,y:Number,z:Number,wall:fWall,destinyZ:Number,scene:fScene):fPolygon {

				 // Simplest test
				 if(wall.z>=z) return new fPolygon()
				 
				 var ret:Array = []
				 var retHoles:Array = []
				 var contours:Array = wall.shapePolygon.contours
				 			
			   if(wall.vertical) {
			
						if(wall.x==x) return new fPolygon()
						
						// Project all points in all contours in Polygon
					  var cl:int = contours.length
						for(var i:int=0;i<cl;i++) {
							var contour:Array = contours[i]
							ret[ret.length] = ProjectionSolver.projectVerticalPointsIntoFloor(contour,x,y,z,destinyZ,wall.x,wall.y0,wall.z,scene)
						}
						
						// Project all holes in Polygon
						var holes:Array = wall.holes
					  var hl:int = holes.length
				    for(i=0;i<hl;i++) {
				 	  	//if(holes[i].open) {
								var bounds:fPlaneBounds = holes[i].bounds
								contour = [new Point(bounds.y0,bounds.z),new Point(bounds.y1,bounds.z),new Point(bounds.y1,bounds.top),new Point(bounds.y0,bounds.top)]
								retHoles[retHoles.length] = ProjectionSolver.projectVerticalPointsIntoFloor(contour,x,y,z,destinyZ,wall.x,0,0,scene)
							//}
						}
			
			   } else {
			   	
						if(wall.y==y) return new fPolygon()
			
						// Project all points in all contours in Polygon
					  cl = contours.length
				    for(i=0;i<cl;i++) {
							contour = contours[i]
							ret[ret.length] = ProjectionSolver.projectHorizontalPointsIntoFloor(contour,x,y,z,destinyZ,wall.x0,wall.y,wall.z,scene)
						}

						// Project all holes in Polygon
						holes = wall.holes
				    hl = holes.length
				    for(i=0;i<hl;i++) {
					 	  //if(holes[i].open) {
								bounds = holes[i].bounds
								contour = [new Point(bounds.x0,bounds.top),new Point(bounds.x1,bounds.top),new Point(bounds.x1,bounds.z),new Point(bounds.x0,bounds.z)]
								retHoles[retHoles.length] = ProjectionSolver.projectHorizontalPointsIntoFloor(contour,x,y,z,destinyZ,0,wall.y,0,scene)
							//}
						}

			   }
			   
			   // Polygon
			   var p:fPolygon = new fPolygon()
			   p.contours = ret
			   p.holes = retHoles
			   return p
			
			}

			private static function projectVerticalPointsIntoFloor(points:Array,x:Number,y:Number,z:Number,destinyZ:Number,offx:Number,offy:Number,offz:Number,scene:fScene):Array {

					var retContour:Array = []
				  var pol:int = points.length
				  for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx
						var py:Number = offy+points[j].x
						var pz:Number = offz+points[j].y
						if(pz<destinyZ) pz = destinyZ
						
						// Project point
						if(pz<z) {
								var dz:Number = 1+(pz-destinyZ)/(z-pz)
			    			var pLeft:Number = x+(px-x)*dz
			    	}
			    	else {
			    			if(px<x) pLeft = 0
			    			if(px>x) pLeft = scene.width
						}
			      
		     		var pt:Point = mathUtils.linesIntersect(x,y,px,py,pLeft,1,pLeft,-1)
		     		if(pt) retContour[retContour.length] = (new Point(pLeft, pt.y))

					}
					
					return retContour

			}

			private static function projectHorizontalPointsIntoFloor(points:Array,x:Number,y:Number,z:Number,destinyZ:Number,offx:Number,offy:Number,offz:Number,scene:fScene):Array {

					var retContour:Array = []
				  var pol:int = points.length
				  for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx+points[j].x
						var py:Number = offy
						var pz:Number = offz+points[j].y
						if(pz<destinyZ) pz = destinyZ
						
						// Project point
						if(pz<z) {
								var dz:Number = 1+(pz-destinyZ)/(z-pz)
								var pUp:Number = y+(py-y)*dz
			    	}
			    	else {
			    			if(py<y) pUp = 0
			    			if(py>y) pUp = scene.depth
						}
			      
			      var pt:Point = mathUtils.linesIntersect(x,y,px,py,1,pUp,-1,pUp)
		     		if(pt) retContour[retContour.length] = (new Point(pt.x, pUp))

					}
												
					return retContour

			}

			/** 
			* This method calculates the projection of an object into an imaginary plane at a given Z
			* @return An Array of Points
			*/
			public static function calculateObjectProjection(x:Number,y:Number,z:Number,obj:fObject,destinyZ:Number):fPolygon {

				 var zbase:Number = obj.z
				 var ztop:Number = obj.top
				 var r:Number = obj.radius
				 var height:Number = obj.height
				 
				 // Get 2D vector from point to object
				 var vec:fVector = new fVector(obj.x-x,obj.y-y)
				 vec.normalize()
				 
				 var dist:Number = mathUtils.distance(x,y,obj.x,obj.y)
				 
				 // Calculate projection from coordinates to base of
				 var dzI:Number = (zbase-destinyZ)/(z-zbase)
				 var projSizeI:Number = dist*dzI

				 // Calculate projection from coordinates to top of object
				 if(ztop<z) {
				 		var dzF:Number = (ztop-destinyZ)/(z-ztop)
				 		var projSizeF:Number = dist*dzF
			
					  // Projection size
						var projSize:Number = projSizeF-projSizeI
						if(projSize>fObject.MAXSHADOW*height || projSize<=0) projSize=fObject.MAXSHADOW*height

				 } else {
				 		projSize=fObject.MAXSHADOW*height
				 }

				 // Calculate origin point
				 var origin:Point = new Point(obj.x+vec.x*projSizeI,obj.y+vec.y*projSizeI)
				 
				 // Get perpendicular vector
				 var perp:fVector = vec.getPerpendicular() 
         
				 // Get first 2 points
				 var p1:Point = new Point(origin.x+r*perp.x,origin.y+r*perp.y)
				 var p2:Point = new Point(origin.x-r*perp.x,origin.y-r*perp.y)
				 
				 // Use normalized direction vector and use to find the 2 other points				 
				 var p3:Point = new Point(p2.x+vec.x*projSize,p2.y+vec.y*projSize)
				 var p4:Point = new Point(p1.x+vec.x*projSize,p1.y+vec.y*projSize)
				 				 
				 var ret:Array = [p1,p2,p3,p4]

			   // Projection must be closed
			   ret[ret.length] = (ret[0])


			   // Polygon
			   var p:fPolygon = new fPolygon()
			   p.contours[0] = ret
			   return p
			   
			}


			// PROJECTIONS INTO WALLS
			//////////////////////////


			/** 
			* This method calculates the projection of a floor into an horizontal wall
			* @return A polygon
			*/
			public static function calculateFloorProjectionIntoHorizontalWall(target:fWall,x:Number,y:Number,z:Number,floor:fFloor):fPolygon {
			   
				 // Project all points in all contours in Polygon
				 var ret:Array = []
				 var contours:Array = floor.shapePolygon.contours
				 var cl:int = contours.length
				 for(var i:int=0;i<cl;i++) {
						var contour:Array = contours[i]
						ret[ret.length] = ProjectionSolver.projectFloorPointsIntoHorizontalWall(contour,x,y,z,target.y,floor.x,floor.y,floor.z)
				 }
				 
				 // Project all holes
				 var retHoles:Array = []
				 var holes:Array = floor.holes
				 var hl:int = holes.length
				 for(i=0;i<hl;i++) {
				 	  //if(holes[i].open) {
							var bounds:fPlaneBounds = holes[i].bounds
							contour = [new Point(bounds.x0,bounds.y0),new Point(bounds.x0,bounds.y1),new Point(bounds.x1,bounds.y1),new Point(bounds.x1,bounds.y0)]
							retHoles[retHoles.length] = ProjectionSolver.projectFloorPointsIntoHorizontalWall(contour,x,y,z,target.y,0,0,floor.z)
						//}
				 }

 				 // Polygon
			   var p:fPolygon = new fPolygon()
			   p.contours = ret
			   p.holes = retHoles
			   return p
			   
			}
				 
			private static function projectFloorPointsIntoHorizontalWall(points:Array,x:Number,y:Number,z:Number,destinyY:Number,offx:Number,offy:Number,offz:Number):Array {

				 var retContour:Array = []
				 var pol:int = points.length
				 for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx+points[j].x
						var py:Number = offy+points[j].y
						var pz:Number = offz
						if(py>y) py=y-1
						
						// Project point
						var pt1:Point = mathUtils.linesIntersect(y,z,py,pz,destinyY,1,destinyY,-1)
			   	  var pt2:Point = mathUtils.linesIntersect(x,y,px,py,1,destinyY,-1,destinyY)
			   	  if(pt1 && pt2) retContour[retContour.length] = (new Point(pt2.x, pt1.y))

				 }
					
				 return retContour	

			}
			
			/** 
			* This method calculates the projection of a floor into a vertical wall
			* @return An Array of Points
			*/
			public static function calculateFloorProjectionIntoVerticalWall(target:fWall,x:Number,y:Number,z:Number,floor:fFloor):fPolygon {
			
				 // Project all points in all contours in Polygon
				 var ret:Array = []
				 var contours:Array = floor.shapePolygon.contours
				 var cl:int = contours.length
				 for(var i:int=0;i<cl;i++) {
						var contour:Array = contours[i]
						ret[ret.length] = ProjectionSolver.projectFloorPointsIntoVerticalWall(contour,x,y,z,target.x,floor.x,floor.y,floor.z)
				 }
				 
				 // Project all holes
				 var retHoles:Array = []
				 var holes:Array = floor.holes
				 var hl:int = holes.length
				 for(i=0;i<hl;i++) {
				 	  //if(holes[i].open) {
							var bounds:fPlaneBounds = holes[i].bounds
							contour = [new Point(bounds.x0,bounds.y0),new Point(bounds.x0,bounds.y1),new Point(bounds.x1,bounds.y1),new Point(bounds.x1,bounds.y0)]
							retHoles[retHoles.length] = ProjectionSolver.projectFloorPointsIntoVerticalWall(contour,x,y,z,target.x,0,0,floor.z)
						//}
				 }

 				 // Polygon
			   var p:fPolygon = new fPolygon()
			   p.contours = ret
			   p.holes = retHoles
			   return p
			   
			}

			private static function projectFloorPointsIntoVerticalWall(points:Array,x:Number,y:Number,z:Number,destinyX:Number,offx:Number,offy:Number,offz:Number):Array {

				 var retContour:Array = []
				 var pol:int = points.length
				 for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx+points[j].x
						var py:Number = offy+points[j].y
						var pz:Number = offz
						if(px<x) px=x+1
						if(px>destinyX) px = destinyX-1
						
						// Project point
						var pt1:Point = mathUtils.linesIntersect(x,z,px,pz,destinyX,1,destinyX,-1)
			   	  var pt2:Point = mathUtils.linesIntersect(x,y,px,py,destinyX,-1,destinyX,1)
			   	  if(pt1 && pt2) retContour[retContour.length] = (new Point(pt2.y, pt1.y))


				 }
					
				 return retContour	

			}


			/** 
			* This method calculates the projection of a wall into an horizontal wall
			* @return An Array of Points
			*/
			public static function calculateWallProjectionIntoHorizontalWall(target:fWall,x:Number,y:Number,z:Number,wall:fWall):fPolygon {
			
				 var ret:Array = []
				 var retHoles:Array = []
				 var contours:Array = wall.shapePolygon.contours
				 			
			   if(wall.vertical) {
			
						if(wall.x==x) return new fPolygon()
						
						// Project all points in all contours in Polygon
				    var cl:int = contours.length
				    for(var i:int=0;i<cl;i++) {
							var contour:Array = contours[i]
							ret[ret.length] = ProjectionSolver.projectVerticalWallPointsIntoHorizontalWall(contour,x,y,z,target.y,wall.x,wall.y0,wall.z)
						}
						
						// Project all holes in Polygon
						var holes:Array = wall.holes
				    var hl:int = holes.length
				    for(i=0;i<hl;i++) {
					 	  //if(holes[i].open) {
								var bounds:fPlaneBounds = holes[i].bounds
								contour = [new Point(bounds.y0,bounds.z),new Point(bounds.y1,bounds.z),new Point(bounds.y1,bounds.top),new Point(bounds.y0,bounds.top)]
								retHoles[retHoles.length] = ProjectionSolver.projectVerticalWallPointsIntoHorizontalWall(contour,x,y,z,target.y,wall.x,0,0)
							//}
						}
			
			   } else {
			   	
						if(wall.y==y) return new fPolygon()
			
						// Project all points in all contours in Polygon
				    cl = contours.length
				    for(i=0;i<cl;i++) {
							contour = contours[i]
							ret[ret.length] = ProjectionSolver.projectHorizontalWallPointsIntoHorizontalWall(contour,x,y,z,target.y,wall.x0,wall.y,wall.z)
						}

						// Project all holes in Polygon
						holes = wall.holes
				    hl = holes.length
				    for(i=0;i<hl;i++) {
					 	  //if(holes[i].open) {
								bounds = holes[i].bounds
								contour = [new Point(bounds.x0,bounds.top),new Point(bounds.x1,bounds.top),new Point(bounds.x1,bounds.z),new Point(bounds.x0,bounds.z)]
								retHoles[retHoles.length] = ProjectionSolver.projectHorizontalWallPointsIntoHorizontalWall(contour,x,y,z,target.y,0,wall.y,0)
							//}
						}

			   }
			   
			   // Polygon
			   var p:fPolygon = new fPolygon()
			   p.contours = ret
			   p.holes = retHoles
			   return p
			
			}

			private static function projectHorizontalWallPointsIntoHorizontalWall(points:Array,x:Number,y:Number,z:Number,destinyY:Number,offx:Number,offy:Number,offz:Number):Array {

				 var retContour:Array = []
				 var pol:int = points.length
				 for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx+points[j].x
						var py:Number = offy
						var pz:Number = offz+points[j].y
						if(py>y) py=y-1
						
						// Project point
						var pt1:Point = mathUtils.linesIntersect(y,z,py,pz,destinyY,1,destinyY,-1)
			   	  var pt2:Point = mathUtils.linesIntersect(x,y,px,py,1,destinyY,-1,destinyY)
			   	  if(pt1 && pt2) retContour[retContour.length] = (new Point(pt2.x, pt1.y))

				 }
					
				 return retContour	

			}

			private static function projectVerticalWallPointsIntoHorizontalWall(points:Array,x:Number,y:Number,z:Number,destinyY:Number,offx:Number,offy:Number,offz:Number):Array {

				 var retContour:Array = []
				 var pol:int = points.length
				 for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx
						var py:Number = offy+points[j].x
						var pz:Number = offz+points[j].y
						if(py>y) py=y-1
						
						// Project point
						var pt1:Point = mathUtils.linesIntersect(y,z,py,pz,destinyY,1,destinyY,-1)
			   	  var pt2:Point = mathUtils.linesIntersect(x,y,px,py,1,destinyY,-1,destinyY)
			   	  if(pt1 && pt2) retContour[retContour.length] = (new Point(pt2.x, pt1.y))


				 }
					
				 return retContour	

			}


			/** 
			* This method calculates the projection of a wall into a vertical wall
			* @return An Array of Points
			*/
			public static function calculateWallProjectionIntoVerticalWall(target:fWall,x:Number,y:Number,z:Number,wall:fWall):fPolygon {
			   
				 var ret:Array = []
				 var retHoles:Array = []
				 var contours:Array = wall.shapePolygon.contours
				 			
			   if(wall.vertical) {
			
						if(wall.x==x) return new fPolygon()
						
						// Project all points in all contours in Polygon
				    var cl:int = contours.length
				    for(var i:int=0;i<cl;i++) {
							var contour:Array = contours[i]
							ret[ret.length] = ProjectionSolver.projectVerticalWallPointsIntoVerticalWall(contour,x,y,z,target.x,wall.x,wall.y0,wall.z)
						}
						
						// Project all holes in Polygon
						var holes:Array = wall.holes
				    var hl:int = holes.length
				    for(i=0;i<hl;i++) {
					 	  //if(holes[i].open) {
			 					var bounds:fPlaneBounds = holes[i].bounds
								contour = [new Point(bounds.y0,bounds.z),new Point(bounds.y1,bounds.z),new Point(bounds.y1,bounds.top),new Point(bounds.y0,bounds.top)]
								retHoles[retHoles.length] = ProjectionSolver.projectVerticalWallPointsIntoVerticalWall(contour,x,y,z,target.x,wall.x,0,0)
							//}
						}
			
			   } else {
			   	
						if(wall.y==y) return new fPolygon()
			
						// Project all points in all contours in Polygon
				    cl = contours.length
				    for(i=0;i<cl;i++) {
							contour = contours[i]
							ret[ret.length] = ProjectionSolver.projectHorizontalWallPointsIntoVerticalWall(contour,x,y,z,target.x,wall.x0,wall.y,wall.z)
						}

						// Project all holes in Polygon
						holes = wall.holes
				    hl = holes.length
				    for(i=0;i<hl;i++) {
					 	  //if(holes[i].open) {
								bounds = holes[i].bounds
								if(bounds.x0<target.x) {
									contour = [new Point(bounds.x0,bounds.top),new Point(bounds.x1,bounds.top),new Point(bounds.x1,bounds.z),new Point(bounds.x0,bounds.z)]
									retHoles[retHoles.length] = ProjectionSolver.projectHorizontalWallPointsIntoVerticalWall(contour,x,y,z,target.x,0,wall.y,0)
								}
							//}
						}

			   }
			   
			   // Polygon
			   var p:fPolygon = new fPolygon()
			   p.contours = ret
			   p.holes = retHoles
			   return p
				 
			}

			private static function projectHorizontalWallPointsIntoVerticalWall(points:Array,x:Number,y:Number,z:Number,destinyX:Number,offx:Number,offy:Number,offz:Number):Array {

				 var retContour:Array = []
				 var pol:int = points.length
				 for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx+points[j].x
						var py:Number = offy
						var pz:Number = offz+points[j].y
						if(px<x) px = x+1
						if(px>destinyX) px = destinyX-1
						
						// Project point
						var pt1:Point = mathUtils.linesIntersect(x,z,px,pz,destinyX,1,destinyX,-1)
			   	  var pt2:Point = mathUtils.linesIntersect(x,y,px,py,destinyX,-1,destinyX,1)
			   	  if(pt1 && pt2) retContour[retContour.length] = (new Point(pt2.y, pt1.y))

				 }
					
				 return retContour	

			}

			private static function projectVerticalWallPointsIntoVerticalWall(points:Array,x:Number,y:Number,z:Number,destinyX:Number,offx:Number,offy:Number,offz:Number):Array {

				 var retContour:Array = []
				 var pol:int = points.length
				 for(var j:int=0;j<pol;j++) {
						
						// Point in space
						var px:Number = offx
						var py:Number = offy+points[j].x
						var pz:Number = offz+points[j].y
						if(px<x) px=x+1
						if(px>destinyX) px = destinyX-1
						
						// Project point
						var pt1:Point = mathUtils.linesIntersect(x,z,px,pz,destinyX,1,destinyX,-1)
			   	  var pt2:Point = mathUtils.linesIntersect(x,y,px,py,destinyX,-1,destinyX,1)
			   	  if(pt1 && pt2) retContour[retContour.length] = (new Point(pt2.y, pt1.y))

				 }
					
				 return retContour	

			}



		}

}
