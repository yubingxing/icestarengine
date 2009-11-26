package com.ice.core.logic.collision.models {

		// Imports
		
		/**
		* This is a cilinder-shaped collision model. It is automatically assigned when the object's XML definition uses the CILINDER Tag
		* @private
		*/
		public class CilinderCollisionModel extends fCilinder implements ICollisionModel {
			
			// Private vars
			private var definitionXML:XML
			private var _orientation:Number
			private var topView:Array
			
			// Constructor
			public function CilinderCollisionModel(definitionXML:XML):void {
				 
				 this.definitionXML = definitionXML
				 
				 // Parent
				 super(new Number(this.definitionXML.@radius[0]),new Number(this.definitionXML.@height[0]))
				 
				 // Orientation
				 this._orientation = 0
				 
				 // Precalc top view
				 this.topView = new Array
				 for(var i:Number=0;i<360;i+=20) {
				 		var angle:Number = i*Math.PI/180
				 		this.topView[this.topView.length] = new Point(this._radius*Math.cos(angle),this._radius*Math.sin(angle))
				 }
				 
			}

			/** 
			* Sets new orientation for this model
			*
			* @param orientation: In degrees, rotation along z-axis that is to be applied to the model. This corresponds to the
			* current orientation of the object who's shape is represented by this model 
			*
			*/
		  public function set orientation(orientation:Number):void {
		  	this._orientation = orientation
		  }
		  public function get orientation():Number {
		  	return this._orientation
		  }
		  

			/** 
			* Sets new height for this model
			*
			* @param height: New height
			*/
		  public function set height(height:Number):void {
				this._height = height
			}
		  public function get height():Number {
		  	return this._height
			}
			
		  /**
		  * Returns radius of an imaginary cilinder that encloses all points in this model. The engine uses this value for internal optimizations
		  *
		  * @return The desired radius
		  */
		  public function getRadius():Number {
		  	return this._radius
		  }

			/** 
			* Test if given point is inside the bounds of this collision model.
			*
			* @param x: Coordinate of tested point
			* @param y: Coordinate of tested point
			* @param z: Coordinate of tested point
			*
			* @return Boolean value indicating if the point is inside
			*
			*/
		  public function testPoint(x:Number,y:Number,z:Number):Boolean {
		  	return ((z>=0) && (z<=this._height) && (mathUtils.distance(0,0,x,y)<this._radius))
		  }
		  
			/** 
			* Test if given segment intersects with this collision model, and return the point of intersection if any
			*
			* @param x1: Origin point
			* @param y1: Origin point
			* @param z1: Origin point
			* @param x2: Destiny point
			* @param y2: Destiny point
			* @param z2: Destiny point
			*
			* @return Intersection coordinate, or null if there wasn't any
			*
			*/
		  public function testSegment(x1:Number,y1:Number,z1:Number,x2:Number,y2:Number,z2:Number):fPoint3d {
		  	
		  	
		  	var r:lineCircleIntersectionResult = mathUtils.segmentIntersectCircle(new Point(x1,y1),new Point(x2,y2),new Point(0,0),this._radius)
		  	if(r.intersects==false) return null
		  	else {
		  		
		  		if(r.inside) {
		  			if(x1==x2) inter1 = mathUtils.linesIntersect(-1,z1,-2,z2,0,0,0,this._height)
		  			else inter1 = mathUtils.linesIntersect(x1,z1,x2,z2,x1,0,x2,this._height)
		  		} else if(r.enter) {
		  			if(x1==x2) var inter1:Point = mathUtils.linesIntersect(-1,z1,-2,z2,r.enter.x,0,r.enter.x,this._height)
		  			else inter1 = mathUtils.linesIntersect(x1,z1,x2,z2,r.enter.x,0,r.enter.x,this._height)
		  			if(inter1) return new fPoint3d(r.enter.x,r.enter.y,inter1.y)
		  		} else {
		  			if(x1==x2) inter1 = mathUtils.linesIntersect(-1,z1,-2,z2,r.exit.x,0,r.exit.x,this._height)
		  			else inter1 = mathUtils.linesIntersect(x1,z1,x2,z2,r.exit.x,0,r.exit.x,this._height)
		  			if(inter1) return new fPoint3d(r.exit.x,r.exit.y,inter1.y)
		  		}
		  	}
		  	return null

		  }

		  /**
		  * Returns an array of points defining the polygon that represents this model from a "top view", ignoring the size along z-axis
		  * of this collision model
		  *
			* @return An array of Points		  
		  */
		  public function getTopPolygon():Array {
		  	return this.topView
		  }

		}
	
}