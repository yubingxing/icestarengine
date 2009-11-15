// This is the default pathfind criteria
package com.ice.core.interfaces {
	import com.ice.util.ds.Cell;
	import com.ice.util.ds.Point3d;
	
	// Imports
	
	/**
	 * This interface defines the methods that any class that is to be used as pathFind criteria must implement
	 */
	public interface IPathfinder  {
		
		/**
		 * This method return the origin point for this search
		 * @return The origin point
		 */
		function getOrigin():Point3d;
		
		/**
		 * This method return the destiny point for this search
		 * @return The destiny point
		 */
		function getDestiny():Point3d;
		
		/**
		 * This method return the origin cell for this search
		 * @return The origin cell
		 */
		function getOriginCell():Cell;
		
		/**
		 * This method return the destiny cell for this search
		 * @return The destiny cell
		 */
		function getDestinyCell():Cell;
		
		/**
		 * Returns a n heuristic value for any cell in the scene. The engine works with cell precision: any point inside the same cell
		 * as the destination point has to be considered the destination point.
		 *
		 *	@param cell The cell for which we must calculate its heuristic
		 * @return The heuristic score for this cell. A value of 0 indicates that we reached our objective
		 */
		function getHeuristic(cell:Cell):Number;
		
		/**
		 * Returns a weighed list of a cells's accessible neighbours. This method updates each cell in the returned list, setting
		 * its "cost" temporal property with the cost associated to move from the input cell into that cell.
		 * 
		 * @return An array of Cells.
		 */
		function getAccessibleFrom(cell:Cell):Array;
		
	}
	
	
	
}