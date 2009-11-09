package com.ice.core.logic.collision.models {

		// Imports

		/**
		* This interface defines methods that any class that is to be used as a collision model in the engine must implement.<br>
		* A collision model is a matematical representation of an object's geometry that is used to manage collisions.
		* For example, a box is a good collision model for a car, and a cilinder is a good collision model for people.<br>
		* Collision models need to be simple geometry so the engine can solve collisions fast.
		* @private
		*/
		public interface EngineCollisionModel {

			/** 
			* Sets new orientation for this model
			*
			* @param orientation: In degrees, rotation along z-axis that is to be applied to the model. This corresponds to the
			* current orientation of the object who's shape is represented by this model 
			*
			*/
		  function set orientation(orientation:Number):void;
		  function get orientation():Number;

			/** 
			* Sets new height for this model
			*
			* @param height: New height
			*/
		  function set height(height:Number):void;
		  function get height():Number;
		  
		  /**
		  * Returns radius of an imaginary cilinder that encloses all points in this model. The engine uses this value for internal optimizations
		  *
		  * @return The desired radius
		  */
		  function getRadius():Number;

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
		  function testPoint(x:Number,y:Number,z:Number):Boolean;

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
		  function testSegment(x1:Number,y1:Number,z1:Number,x2:Number,y2:Number,z2:Number):fPoint3d;
		  
		  /**
		  * Returns an array of points defining the polygon that represents this model from a "top view", ignoring the size along z-axis
		  * of this collision model
		  *
			* @return An array of Points		  
		  */
		  function getTopPolygon():Array;

		}

}