// AI methods

package com.ice.core.base {
	// Imports
	import com.ice.core.interfaces.IPathfindCriteria;
	import com.ice.core.logic.pathfinder.DefaultPathfindCriteria;
	import com.ice.core.logic.pathfinder.Pathfinder;
	import com.ice.core.logic.sight.LineOfSightSolver;
	import com.ice.util.ds.Point3d;
	
	/**
	 * <p>This object provides access to the AI methods of the engine.</p>
	 *
	 */
	public class AiContainer {
		
		/**
		 * This is the maximum depth pathfinding will reach before failing.
		 */
		public static const MAXSEARCHDEPTH:Number = 200;
		
		// Private properties
		private var _scene:Scene = null;
		
		/**
		 * Constructor for the fAiContainer class
		 *
		 * @param scene The scene associated to this AI
		 *
		 * @private
		 */
		function AiContainer(scene:Scene) {
			_scene = scene;
		}
		
		/** 
		 * <p>This methods returns an array of all the elements that cross an imaginary line between two points, sorted by distance to origin.
		 * This is a CPU-intensive calculation: Try to use it sparingly.</p>
		 * 
		 * @param fromX X coordinate for the origin
		 * @param fromY Y coordinate for the origin
		 * @param fromZ Z coordinate for the origin
		 * @param toX X coordinate for the destiny
		 * @param toY Y coordinate for the destiny
		 * @param toZ Z coordinate for the destiny
		 * @return An array of fCoordinateOccupant elements. If the array is null or empty there's nothing between the origin point and the end point.
		 * If the origin point is outside the scene's limits, the method will return null.
		 */
		public function calculateLineOfSight(fromX:Number, fromY:Number, fromZ:Number, toX:Number, toY:Number, toZ:Number):Array {
			return LineOfSightSolver.calculateLineOfSight(_scene, fromX, fromY, fromZ, toX, toY, toZ);
		}
		
		/**
		 * <p>Finds a path between 2 points, using an AStar search algorythm. It works in 3d. This is a CPU-intensive calculation: If you have
		 * several elements trying to find its way around at the same time, it will impact your performance: try to use it sparingly. If you
		 * want an example of how to make a character walk around your scene using this, download the mynameisponcho sources from the download area.</p>
		 *
		 * <p>I took it from <a href="http://blog.baseoneonline.com/?p=87" target="_blank">here</a>. Thank you!</p>
		 *
		 * <p>TODO: 
		 * <ul>
		 * <li>Accept a character as optional parameter and take its dimensions into account.</li>
		 * <li>Include objects and try to find ways around them.</li>
		 * <li>More precise hole calculations. Now it will try to search through any open hole.</li>
		 * </ul></p>
		 *
		 * @param originx Origin point
		 * @param destinyx Destination point
		 * @param withDiagonals Is diagonal movement allowed for this calculation ?
		 *
		 * @return	An array of 3dPoints describing the resulting path. Null if it fails
		 */
		public function findPath(origin:Point3d, destiny:Point3d, withDiagonals:Boolean = true):Array {
			return Pathfinder.findPathAStar(new DefaultPathfindCriteria(_scene, origin, destiny, withDiagonals));
		}
		
		/**
		 * <p>Finds a path between 2 points, using an AStar search algorythm and a custom find criteria. It works in 3d. This is a CPU-intensive calculation: If you have
		 * several elements trying to find its way around at the same time, it will impact your performance: try to use it sparingly.</p>
		 *
		 * @param criteria An object implementing the IPathfinder interface that contains the find criteria.
		 *
		 * @return	An array of 3dPoints describing the resulting path. Null if it fails
		 */
		public function findPathCustomCriteria(criteria:IPathfindCriteria):Array {
			return Pathfinder.findPathAStar(criteria);
		}
	}
}
