// Character class
package com.ice.core.logic.coverage {
	
		// Imports
		
		/** 
		* This class calculates coverage between elements.
		* Seen from a given coordinate, elements A and B can be related in 3 ways:
		* 	1. Element A totally covers element B
		* 	2. Element A partially covers element B
		* 	3. Element A doesn't cover element B
		* These results can be applied to shadow optimization and visibility tests to see if an element is visible from a given coordinate
		*
		* @private
		*/
		public class CoverageSolver {

			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			* @see org.ffilmation.engine.logicSolvers.coverageSolver.fCoverage
			*/
			public static function calculateCoverage(from:fRenderableElement,to:*,x:Number,y:Number,z:Number):int {
				
				try {
					
					if(from is fFloor) {
						if(to is fFloor) return CoverageSolver.calculateCoverageFloorFloor(from,to as fFloor,x,y,z)
						if(to is fWall) {
							var w:fWall = to as fWall
							if(w.vertical) return CoverageSolver.calculateCoverageFloorVerticalWall(from,w,x,y,z)
							else return CoverageSolver.calculateCoverageFloorHorizontalWall(from,w,x,y,z)
						}
						if(to is fObject) return CoverageSolver.calculateCoverageFloorObject(from,to as fObject,x,y,z)
					}
					if(from is fWall) {
						if(to is fFloor) return CoverageSolver.calculateCoverageWallFloor(from,to as fFloor,x,y,z)
						if(to is fWall) {
							w = to as fWall
							if(w.vertical) return CoverageSolver.calculateCoverageWallVerticalWall(from,w,x,y,z)
							else return CoverageSolver.calculateCoverageWallHorizontalWall(from,w,x,y,z)
						}
						if(to is fObject) return CoverageSolver.calculateCoverageWallObject(from,to as fObject,x,y,z)
					}
					if(from is fObject) {
						if(to is fFloor) return CoverageSolver.calculateCoverageObjectFloor(from as fObject,to as fFloor,x,y,z)
						if(to is fWall) {
							w = to as fWall
							if(w.vertical) return CoverageSolver.calculateCoverageObjectVerticalWall(from as fObject,w,x,y,z)
							else return CoverageSolver.calculateCoverageObjectHorizontalWall(from as fObject,w,x,y,z)
						}
						if(to is fObject) return CoverageSolver.calculateCoverageObjectObject(from as fObject,to as fObject,x,y,z)
					}
					
			  } catch(e:Error) {
			  	trace("Coverage warning:"+e)
			   	return Coverage.SHADOWED
			  }

				return Coverage.NOT_SHADOWED
			
			}
			
			
			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageFloorFloor(from:Object,to:fFloor,x:Number,y:Number,z:Number):int {

			   var len:int
			   
			   if(from.z>to.z && from.z<z) {
			     
			      var dz:Number = 1+(from.z-to.z)/(z-from.z)
			      
			      var pLeft:Number = x+(from.x-x)*dz
			      if(pLeft>(to.x+to.width)) return Coverage.NOT_SHADOWED
			
			      var pUp:Number = y+(from.y-y)*dz
			   		if(pUp>(to.y+to.depth)) return Coverage.NOT_SHADOWED
			
			      var pDown:Number = y+(from.y+from.depth-y)*dz
			   		if(pDown<to.y) return Coverage.NOT_SHADOWED
			
			      var pRight:Number = x+(from.x+from.width-x)*dz
					  if(pRight<to.x) return Coverage.NOT_SHADOWED
						
			      if(pUp<=to.y && pDown>=(to.y+to.depth) && pLeft<=to.x && pRight>=(to.x+to.width)) {
			      	
			      	  // Test holes
			      	  if(from is fFloor) {
			      	  	len = from.holes.length
			      	  	for(var h:int=0;h<len;h++) {
			      	  		if(CoverageSolver.calculateCoverageFloorFloor(from.holes[h].bounds,to,x,y,z)!=Coverage.NOT_SHADOWED) return Coverage.SHADOWED
			      	    }
			      	  }
			      	
			      		return Coverage.COVERED
			      }
			      else return Coverage.SHADOWED
			   }   
			   else return Coverage.NOT_SHADOWED
			
			}
			

			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageWallFloor(from:Object,to:fFloor,x:Number,y:Number,z:Number):int {

			   if(from.top<=to.z || from.z>=z) return Coverage.NOT_SHADOWED
			   
			   if(from.vertical) {
			
			      if(from.x<=x) {
			
			         if(from.x<=to.x) return Coverage.NOT_SHADOWED
			
			         if(from.top<z) {
			   				  var dz:Number = 1+(from.top-to.z)/(z-from.top)
			         	  var pLeft:Number = -1+x+(from.x-x)*dz
			     	      if(pLeft>(to.x+to.width)) return Coverage.NOT_SHADOWED
							 }
							 else pLeft = to.x
			
			         if(from.y0>(to.y+to.depth)) {
			         		var pUp:Number = mathUtils.linesIntersect(x,y,from.x,from.y0,pLeft,1,pLeft,-1).y-1
			         		if(pUp>(to.y+to.depth)) return Coverage.NOT_SHADOWED
			         }
			         if(from.y1<to.y) {
			         		var pDown:Number = mathUtils.linesIntersect(x,y,from.x,from.y1,pLeft,1,pLeft,-1).y+1
			         		if(pDown<to.y) return Coverage.NOT_SHADOWED
							 }				 
							 
							 if(from.z>to.z) {
						 	 		var dzb:Number = 1+(from.z-to.z)/(z-from.z)
									var pRight:Number = 1+x+(from.x-x)*dzb
								  if(pRight<to.x) return Coverage.NOT_SHADOWED
			         }
			
			         return Coverage.SHADOWED
			
			      } else {
			
			         if(from.x>=(to.x+to.width)) return Coverage.NOT_SHADOWED
			
			         if(from.top<z) {
			   				  dz = 1+(from.top-to.z)/(z-from.top)
			   	        pLeft = 1+x+(from.x-x)*dz
			            if(pLeft<to.x) {
			            	return Coverage.NOT_SHADOWED
			            }
			         }
			         else pLeft = to.x+to.width
			         
			         if(from.y0>(to.y+to.depth)) {
			         		pUp = mathUtils.linesIntersect(x,y,from.x,from.y0,pLeft,1,pLeft,-1).y-1
			         		if(pUp>(to.y+to.depth)) {
			         			return Coverage.NOT_SHADOWED
			         		}
			         }
			         
			         if(from.y1<to.y) {
			         		pDown = mathUtils.linesIntersect(x,y,from.x,from.y1,pLeft,1,pLeft,-1).y+1
			         		if(pDown<to.y) {
			         			return Coverage.NOT_SHADOWED
			         		}
	         		 }
			
							 if(from.z>to.z) {
						 	 		dzb = 1+(from.z-to.z)/(z-from.z)
									pRight = -1+x+(from.x-x)*dzb
								  if(pRight>(to.x+to.width)) return Coverage.NOT_SHADOWED
							 }
							 
			         return Coverage.SHADOWED
			
			      }
			
			   } else {
			   
			      if(from.y<y) {
			
			         if(from.y<=to.y) return Coverage.NOT_SHADOWED
			
			         if(from.top<z) {
			   				  dz = 1+(from.top-to.z)/(z-from.top)
					        pUp = -1+y+(from.y-y)*dz
			            if(pUp>(to.y+to.depth)) return Coverage.NOT_SHADOWED
			         }
			         else pUp = to.y         
			
							 if(from.x0>(to.x+to.width)) {
			         		pLeft = mathUtils.linesIntersect(x,y,from.x0,from.y,1,pUp,-1,pUp).x-1
			         		if(pLeft>(to.x+to.width)) return Coverage.NOT_SHADOWED
			         }
			         if(from.x1<to.x) {
			         		pRight = mathUtils.linesIntersect(x,y,from.x1,from.y,1,pUp,-1,pUp).x+1
			         		if(pRight<to.x) return Coverage.NOT_SHADOWED
							 }
							
							 if(from.z>to.z) {
						 	 		dzb = 1+(from.z-to.z)/(z-from.z)
									pDown = 1+y+(from.y-y)*dzb
								  if(pDown<to.y) return Coverage.NOT_SHADOWED
							 }
			
			         return Coverage.SHADOWED
			
			      } else {
			
			         if(from.y>=(to.y+to.depth)) return Coverage.NOT_SHADOWED
			
			         if(from.top<z) {
			   				 dz = 1+(from.top-to.z)/(z-from.top)
				         pUp = 1+y+(from.y-y)*dz
			  	       if(pUp<to.y) return Coverage.NOT_SHADOWED
							 }
							 else pUp = to.y+to.depth				 
			
							 if(from.x0>(to.x+to.width)) {
			         		pLeft = mathUtils.linesIntersect(x,y,from.x0,from.y,1,pUp,-1,pUp).x-1
			         		if(pLeft>(to.x+to.width)) return Coverage.NOT_SHADOWED
			         }
			         if(from.x1<to.x) {
			         		pRight = mathUtils.linesIntersect(x,y,from.x1,from.y,1,pUp,-1,pUp).x+1
			         		if(pRight<to.x) return Coverage.NOT_SHADOWED
							 }
			
							 if(from.z>to.z) {
						 	 		dzb = 1+(from.z-to.z)/(z-from.z)
									pDown = -1+y+(from.y-y)*dzb
								  if(pDown>(to.y+to.depth)) return Coverage.NOT_SHADOWED
							 }
			
			         return Coverage.SHADOWED
			         
			      }
			
			   }

			
			}

			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageObjectFloor(from:fObject,to:fFloor,x:Number,y:Number,z:Number):int {

			   // Simple cases
			   if(from.top<=to.z || from.z>=z) return Coverage.NOT_SHADOWED
			   if(from.y<to.y && y>from.y) return Coverage.NOT_SHADOWED
			   if(from.y>(to.y+to.depth) && y<from.y) return Coverage.NOT_SHADOWED
			   if(from.x<to.x && x>from.x) return Coverage.NOT_SHADOWED
			   if(from.x>(to.x+to.width) && x<from.x) return Coverage.NOT_SHADOWED
				 
				 // Get projection
				 var poly1:Array = fProjectionSolver.calculateProjection(x,y,z,from,to.z).contours[0]
				 if(poly1==null) return Coverage.NOT_SHADOWED
				 
				 // Check Collision
				 var polyClip = [ new Point(to.x,to.y),
				 							    new Point(to.x+to.width,to.y),
				 							    new Point(to.x+to.width,to.y+to.depth),
				 							    new Point(to.x,to.y+to.depth) ]
				 							     
				 var result:Boolean = polygonUtils.checkPolygonCollision(poly1,polyClip)
				
				 if(result) return Coverage.SHADOWED
				 else return Coverage.NOT_SHADOWED
			
			}


			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageFloorHorizontalWall(from:Object,to:fWall,x:Number,y:Number,z:Number):Number {
			
				 var len:int
				 
				 // If floor is above wall
				 if(from.z>to.z && from.z<z) {
			   
				   var dz:Number = 1+(from.z-to.z)/(z-from.z)
				   var pUp:Number = y+(from.y-y)*dz
			     var pDown:Number = y+(from.y+from.depth-y)*dz
				   var pLeft:Number = x+(from.x-x)*dz
				   var pRight:Number = x+(from.x+from.width-x)*dz
				   
			   	 if((to.y<pUp && from.y>=to.y) || (to.y>pDown && (from.y+from.depth)<=to.y) || (to.x0>pRight && (from.x+from.width)<=to.x0) || (to.x1<pLeft && from.x>=to.x1)) {
			     
			  	     // Outside range
				       return Coverage.NOT_SHADOWED
			     
			   	 } else {
			     
					 		if(mathUtils.segmentsIntersect(x,z,pLeft,to.z,to.x0,to.top,to.x1,to.top) ||
					 		   mathUtils.segmentsIntersect(x,z,pRight,to.z,to.x0,to.top,to.x1,to.top) ||
					 		   mathUtils.segmentsIntersect(x,z,pRight,to.z,to.x0,to.top,to.x0,to.z) ||
					 		   mathUtils.segmentsIntersect(x,z,pLeft,to.z,to.x1,to.z,to.x1,to.top) ||
					 		   mathUtils.segmentsIntersect(y,z,pUp,to.z,to.y,to.top+2,to.y,to.z) ||
					 		   mathUtils.segmentsIntersect(y,z,pDown,to.z,to.y,to.top+2,to.y,to.z)) {
					 		   	return Coverage.SHADOWED
					 		}
					 		else {
			     
			       	  // Test holes
			       	  if(from is fFloor) {
			       	  	len = from.holes.length
			       	  	for(var h:int=0;h<len;h++) {
			       	  		if(CoverageSolver.calculateCoverageFloorHorizontalWall(from.holes[h].bounds,to,x,y,z)!=Coverage.NOT_SHADOWED) return Coverage.SHADOWED
			       	  	}
			       	  }
					 			return Coverage.COVERED
					 		}
				   }
			
				 }
			
				 // If floor is below wall
				 if(from.z<to.z && from.z>z) {
				 	
				 } 
			
				 return Coverage.NOT_SHADOWED
			
			
			}
			
			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageFloorVerticalWall(from:Object,to:fWall,x:Number,y:Number,z:Number):Number {
			   
				 var len:int
				 
				 // If floor is above wall
				 if(from.z>to.z && from.z<z) {
			
				   var dz:Number = 1+(from.z-to.z)/(z-from.z)
			   	 var pUp:Number = y+(from.y-y)*dz
			   	 var pDown:Number = y+(from.y+from.depth-y)*dz
			   	 var pLeft:Number = x+(from.x-x)*dz
			     var pRight:Number = x+(from.x+from.width-x)*dz
			
			
			      if((to.y0>pDown && (from.y+from.depth)<=to.y0) || (to.y1<pUp && from.y>=to.y1) || (to.x>pRight && (from.x+from.width)<=to.x) || (to.x<pLeft && from.x>=to.x)) {
			
			         // Outside range
			         return Coverage.NOT_SHADOWED
			
			      } else {
			
						   if(mathUtils.segmentsIntersect(y,z,pUp,to.z,to.y0,to.top,to.y1,to.top) ||
						      mathUtils.segmentsIntersect(y,z,pDown,to.z,to.y0,to.top,to.y1,to.top) ||
						      mathUtils.segmentsIntersect(y,z,pUp,to.z,to.y1,to.z,to.y1,to.top) ||
						      mathUtils.segmentsIntersect(y,z,pDown,to.z,to.y0,to.z,to.y0,to.top) ||
							    mathUtils.segmentsIntersect(x,z,pRight,to.z,to.x,to.top+2,to.x,to.z) ||
							    mathUtils.segmentsIntersect(x,z,pLeft,to.z,to.x,to.top+2,to.x,to.z)) {
							    	return Coverage.SHADOWED
							 }
						   else {
			
			      	  // Test holes
			      	  if(from is fFloor) {
			      	  	len = from.holes.length
			      	  	for(var h:int=0;h<len;h++) {
			      	  		if(CoverageSolver.calculateCoverageFloorVerticalWall(from.holes[h].bounds,to,x,y,z)!=Coverage.NOT_SHADOWED) return Coverage.SHADOWED
			      	  	}
			      	  }
			
						   	return Coverage.COVERED
						   }
			
			      }
				 }
			
				 // If floor is below wall
				 if(from.z<to.z && from.z>z) {
				 	
				 } 
			
				 return Coverage.NOT_SHADOWED
			
			}
			
			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageWallHorizontalWall(from:Object,to:fWall,x:Number,y:Number,z:Number):Number {
			
				 if(from.top<=to.z) return Coverage.NOT_SHADOWED

			   var dz:Number = 1+(from.top-to.z)/(z-from.top)
			
			   if(from.vertical) {               
			
			      if(from.y1>to.y && from.y0<=(y) && ((from.x>x && from.x<to.x1) || (from.x<x && from.x>to.x0))) { 
			
						   if(from.top<z) {
				  			  var pUp:Number = y+(from.y0-y)*dz
			   	  			if(pUp>=to.y) return Coverage.NOT_SHADOWED
						   }      	
			
			         var inter:Number = mathUtils.linesIntersect(x,y,from.x,from.y0,to.x0,to.y,to.x1,to.y).x
			
			         if((inter>=to.x0 && inter<=to.x1) || 
			            mathUtils.segmentsIntersect(x,y,to.x0,to.y,from.x,from.y0,from.x,from.y1) || 
			            mathUtils.segmentsIntersect(x,y,to.x1,to.y,from.x,from.y0,from.x,from.y1)) {
			            
			            return Coverage.SHADOWED
			         }  
			      }
			
			   } else {
			   	
			      if(from.y>to.y && from.y<=(y)) { 
			
						   if(from.top<z) {
				  			  pUp = y+(from.y-y)*dz
			   	  			if(pUp>=to.y) return Coverage.NOT_SHADOWED
						   }      	
			
			         inter = mathUtils.linesIntersect(x,y,from.x0,from.y,to.x0,to.y,to.x1,to.y).x
			
			         if((inter>to.x0 && inter<to.x1) || 
			            mathUtils.segmentsIntersect(x,y,to.x0,to.y,from.x0,from.y,from.x1,from.y) || 
			            mathUtils.segmentsIntersect(x,y,to.x1,to.y,from.x0,from.y,from.x1,from.y)) {
			            
			            return Coverage.SHADOWED
			         }  
			      }
			
			   }
			
			   return Coverage.NOT_SHADOWED
			
			}
			
			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageWallVerticalWall(from:Object,to:fWall,x:Number,y:Number,z:Number):Number {
			
				 if(from.top<=to.z) return Coverage.NOT_SHADOWED

			   var dz:Number = 1+(from.top-to.z)/(z-from.top)
			
			   if(from.vertical) {               
			
			      if(from.x<to.x && from.x>(x)) { 
			      	
						   if(from.top<z) {
				  			  var pRight:Number = x+(from.x-x)*dz
			   	  			if(pRight<=to.x) return Coverage.NOT_SHADOWED
						   }      	
						   
			         var inter:Number = mathUtils.linesIntersect(x,y,from.x,from.y0,to.x,to.y0,to.x,to.y1).y
			
			         if((inter>to.y0 && inter<to.y1) || 
			            mathUtils.segmentsIntersect(x,y,to.x,to.y0,from.x,from.y0,from.x,from.y1) || 
			            mathUtils.segmentsIntersect(x,y,to.x,to.y1,from.x,from.y0,from.x,from.y1)) {
			            
			            return Coverage.SHADOWED
			         }  
			      }
			
			   } else {
			      
			
			      if(from.x0<to.x && from.x1>(x) && ((from.y>y && from.y<to.y1) || (from.y<y && from.y>to.y0))) {
			
						   if(from.top<z) {
				  			  pRight = x+(from.x1-x)*dz
			   	  			if(pRight<=to.x) return Coverage.NOT_SHADOWED
						   }      	
			
			         inter = mathUtils.linesIntersect(x,y,from.x0,from.y,to.x,to.y0,to.x,to.y1).y
			
			         if((inter>to.y0 && inter<to.y1) || 
			            mathUtils.segmentsIntersect(x,y,to.x,to.y0,from.x0,from.y,from.x1,from.y) || 
			            mathUtils.segmentsIntersect(x,y,to.x,to.y1,from.x0,from.y,from.x1,from.y)) {
			            
			            return Coverage.SHADOWED
			         }  
			      }
			
			   }
			  
			   return Coverage.NOT_SHADOWED
			
			}

			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageObjectHorizontalWall(from:fObject,to:fWall,x:Number,y:Number,z:Number):Number {

			   // Simple cases
			   if(from.y<to.y && y>from.y) return Coverage.NOT_SHADOWED
			   if(from.y>to.y && y<from.y) return Coverage.NOT_SHADOWED

				 // Get projection polygon
				 var poly1:Array = fProjectionSolver.calculateProjection(x,y,z,from,to.z).contours[0]
				 if(poly1==null) return Coverage.NOT_SHADOWED
				 
				 // Check fCollision
				 var result:Boolean = ((mathUtils.segmentsIntersect(to.x0,to.y,to.x1,to.y,from.x,from.y,(poly1[2].x+poly1[3].x)/2,(poly1[2].y+poly1[3].y)/2)!=null) ||
				 											 (mathUtils.segmentsIntersect(to.x0,to.y,to.x1,to.y,poly1[0].x,poly1[0].y,poly1[3].x,poly1[3].y)!=null) ||
				 											 (mathUtils.segmentsIntersect(to.x0,to.y,to.x1,to.y,poly1[1].x,poly1[1].y,poly1[2].x,poly1[2].y)!=null))
				                      
				 if(result) return Coverage.SHADOWED
				 else return Coverage.NOT_SHADOWED

	  	}
	  
			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageObjectVerticalWall(from:fObject,to:fWall,x:Number,y:Number,z:Number):Number {

			   // Simple cases
			   if(from.x<to.x && x>from.x) return Coverage.NOT_SHADOWED
			   if(from.x>to.x && y<from.x) return Coverage.NOT_SHADOWED
				 
				 // Get projection polygon
				 var poly1:Array = fProjectionSolver.calculateProjection(x,y,z,from,to.z).contours[0]
				 if(poly1==null) return Coverage.NOT_SHADOWED
				 
				 // Check fCollision
				 var result:Boolean = ((mathUtils.segmentsIntersect(to.x,to.y0,to.x,to.y1,from.x,from.y,(poly1[2].x+poly1[3].x)/2,(poly1[2].y+poly1[3].y)/2)!=null) ||
				                       (mathUtils.segmentsIntersect(to.x,to.y0,to.x,to.y1,poly1[0].x,poly1[0].y,poly1[3].x,poly1[3].y)!=null) ||
				                       (mathUtils.segmentsIntersect(to.x,to.y0,to.x,to.y1,poly1[1].x,poly1[1].y,poly1[2].x,poly1[2].y)!=null))
				
				 if(result) return Coverage.SHADOWED
				 else return Coverage.NOT_SHADOWED

	  	}

			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageFloorObject(from:Object,to:fObject,x:Number,y:Number,z:Number):Number {
					return Coverage.NOT_SHADOWED
			}

			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageWallObject(from:Object,to:fObject,x:Number,y:Number,z:Number):Number {
					return Coverage.NOT_SHADOWED
			}

			/** 
			* This method calculates coverage from one point and between two given renderable elements
			* @return A Coverage value.
			*/
			private static function calculateCoverageObjectObject(from:fObject,to:fObject,x:Number,y:Number,z:Number):Number {
					return Coverage.NOT_SHADOWED
			}

		}

}
