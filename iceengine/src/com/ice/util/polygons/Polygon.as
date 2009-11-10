// POLYGON DEFINITION
package com.ice.util.polygons {

		// Imports

		/**
		* <p>A Polygon is an array of contours and one of holes. Both a "contour" and a "hole" are arrays of Points.
		* Both contours and holes must be in the same winding order ( either clockwise or counter-clockwise ) for the algorythms to work.
		*/
		public class Polygon {
			
			/** The solid contours in this polygon */			
			public var contours:Array

			/** The holes in this polygon */			
			public var holes:Array
			
			/** @private */
			public function Polygon():void {
				this.contours = new Array
				this.holes = new Array
			}
			
			/** 
			* Returns if a point is inside the polygon.
			*
			* @param x: X coordibate for the point to be tested
			* @param y: Y coordibate for the point to be tested
			* @return A Boolean value
			*/
			public function isPointInside(x:Number, y:Number):Boolean {
			   
			   var i:int, j:int
			   var any:Boolean = false
			   
			   var cl:int = this.contours.length
			   for(var c:int=0;!any && c<cl;c++) {
			   	
			   		var contour:Array = this.contours[c]
			  		var ret:Boolean = false
			  		
			   		// Test every contour
			   		var cnl:int = contour.length
			   		for (i = 0, j = cnl-1; i < cnl; j = i++) {
			   			var p1:Point = contour[i]
			   			var p2:Point = contour[j]
			   		  if ((((p1.y <= y) && (y < p2.y)) || ((p2.y <= y) && (y < p1.y))) && (x < (p2.x - p1.x) * (y - p2.y) / (p2.y - p1.y) + p1.x))  ret = !ret
			   		}
			   		any = ret
			   					   
			   }
			   
			   if(!any) return false
			   
			   // If we are here, point is inside one of the contours, now we must see if any of the holes matches too
			   var hl:int = this.holes.length 
			   for(c=0;c<hl;c++) {
			   	
			   		var hole:Array = this.holes[c]
			  		ret = false
			  		
			   		// Test every hole
			   		var hnl:int = hole.length
			   		for (i = 0, j = hnl-1; i < hnl; j = i++) {
			   			p1 = hole[i]
			   			p2 = hole[j]
			   		  if ((((p1.y <= y) && (y < p2.y)) || ((p2.y <= y) && (y < p1.y))) && (x < (p2.x - p1.x) * (y - p2.y) / (p2.y - p1.y) + p1.x))  ret = !ret
			   		}
			   
			   		// Inside a hole !
			   		if(ret) return false
			   }
			   
			   // We are not inside any hole
			   return true
			}
			

			/** 
			* Draws the polygon into the supplied graphics object
			* Does not clear(), beginFill() or endFill() so it can be used in any context
			*
			* @param canvas: Where polygon is to be drawn
			*/
			public function draw(canvas:Graphics):void {
			
				var cl:int = this.contours.length
				for(var i:int=0;i<cl;i++) {
					var points:Array = this.contours[i]
					var np:int = points.length
					if(np>=3) {
						canvas.moveTo(points[0].x,points[0].y)
						for(var j:int=1;j<np;j++) canvas.lineTo(points[j].x,points[j].y)
					}
				}
				var hl:int = this.holes.length 
				for(i=0;i<hl;i++) {
					points = this.holes[i]
					np = points.length-1
					if(np>=2) {
						canvas.moveTo(points[np].x,points[np].y)
						for(j=np-1;j>=0;j--) canvas.lineTo(points[j].x,points[j].y)
					}
				}
				
			}
						
		}

}