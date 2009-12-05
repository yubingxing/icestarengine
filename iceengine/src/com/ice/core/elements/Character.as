// Character class
package com.ice.core.elements {
	import com.ice.core.base.Light;
	import com.ice.core.base.MovingElement;
	import com.ice.core.base.Scene;
	import com.ice.core.events.CollideEvent;
	import com.ice.core.events.MoveEvent;
	import com.ice.core.events.MoveInEvent;
	import com.ice.core.events.ProcessEvent;
	import com.ice.core.interfaces.IMovingElement;
	import com.ice.core.logic.collision.CollisionSolver;
	import com.ice.util.ds.Cell;
	
	// Imports
	
	
	/** 
	 * <p>A Character is a dynamic object in the scene. Characters can move and rotate, and can be added and
	 * removed from the scene at any time. Live creatures and vehicles are the most common
	 * uses for the fCharacter class.</p>
	 *
	 * <p>There are other uses for fCharacter: If you want a chair to be "moveable", for example, you
	 * will have to make it a fCharacter.</p>
	 *
	 * <p>You can add the parameter dynamic="true" to the XML definition for any object you want to be able to move
	 * later. This will force the engine to make that object a Character.</p>
	 *
	 * <p>The main reason of having different classes for static and dynamic objects is that static objects can be
	 * added to the light rendering cache along with floors and walls, whereas dynamic objects (characters) can't.</p>
	 *
	 * <p>Don't use this class to implement bullets. Use the fBullet class.</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS ELEMENT DIRECTLY.<br>
	 * Use scene.createCharacter() to add new characters to an scene.</p>
	 *
	 * @see org.ffilmation.engine.core.Scene#createCharacter()
	 *
	 */
	public class Character extends MovingElement implements IMovingElement {
		
		// Constants
		
		/**
		 * The fCharacter.COLLIDE constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>charactercollide</code> event.
		 * The event is dispatched when the character collides with another element in the scene
		 * 
		 * @eventType charactercollide
		 */
		public static const COLLIDE:String = "charactercollide";
		
		/**
		 * The fCharacter.WALKOVER constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>characterwalkover</code> event.
		 * The event is dispatched when the character walks over a non-solid object of the scene
		 * 
		 * @eventType characterwalkover
		 */
		public static const WALKOVER:String = "characterwalkover";
		
		/**
		 * The fCharacter.EVENT_IN constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>charactereventin</code> event.
		 * The event is dispatched when the character enters a cell where an event was defined
		 * 
		 * @eventType charactereventin
		 */
		public static const EVENT_IN:String = "charactereventin";
		
		/**
		 * The fCharacter.EVENT_OUT constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>charactereventout</code> event.
		 * The event is dispatched when the character leaves a cell where an event was defined
		 * 
		 * @eventType charactereventout
		 */
		public static const EVENT_OUT:String = "charactereventout";
		
		
		// Public properties
		
		/**
		 * This value goes from 0 to 100 and indicates the alpha strenght of the "hole" that is opened in planes that cover this character
		 * "Cover" means literally, onscreen. This allows you to see what you are doing behind a wall. The default "100" value disables this effect
		 */
		public var occlusion:Number = 100;
		
		// Private properties
		
		/**
		 * Elements currently being occluded by this character
		 * @private
		 */
		public var currentOccluding:Array;
		
		/** 
		 * Numeric counter for fast Array lookups
		 * @private
		 */
		public var counter:int;
		
		/** 
		 * Array of render cache. For each light in the scene, a list of elements that are shadowed by this character at its current position
		 * @private
		 */
		public var vLights:Array;
		
		/**
		 * Array of cells the character occupies
		 * @private
		 */
		public var occupiedCells:Array;
		
		
		// Constructor
		/** @private */
		function Character(defObj:XML, scene:Scene):void {
			
			// Previous
			super(defObj, scene);
			
			// Characters are animated always
			this.animated = true;
			
			// Lights
			this.vLights = [];
			
			// Occlusion
			this.currentOccluding = [];
			
			// Counter
			this.counter = this.scene.characters.length;
			
			// Occupied cells
			this.occupiedCells = [];
			if(!this.scene.ready)
				this.scene.addEventListener(Scene.LOADCOMPLETE, this.onSceneLoaded, false, 0, true);
			else
				this.updateOccupiedCells();
		}
		
		
		/**
		 * Moves a character into a new position, ignoring collisions
		 * 
		 * @param x: New x coordinate
		 *
		 * @param y: New y coordinate
		 *
		 * @param z: New z coordinate
		 *
		 */
		public function teleportTo(x:Number, y:Number, z:Number):void {
			var s:Boolean = this.solid;
			this.solid = false;
			this.moveTo(x, y, z);
			this.solid = s;
		}
		
		
		/*
		* Characters can be moved
		* 
		* @param x: New x coordinate
		*
		* @param y: New y coordinate
		*
		* @param z: New z coordinate
		*
		*/
		/** @private */
		public override function moveTo(x:Number, y:Number, z:Number):void {
			
			// Last position
			var lx:Number = this.x;
			var ly:Number = this.y;
			var lz:Number = this.z;
			
			// Movement
			var dx:Number = x - lx;
			var dy:Number = y - ly;
			var dz:Number = z - lz;
			
			if(dx == 0 && dy == 0 && dz == 0) 
				return
			
			try {
				
				// Set new coordinates			   
				this.x = x
				this.y = y
				this.z = z
				
				var radius:Number = this.radius;
				var height:Number = this.height;
				
				this.top = this.z + height;
				
				// Check for collisions against other fRenderableElements.
				// collisionSolver.solveCharacterCollisions() tests a character's collisions at its current position, generates collision events (if any)
				// and moves the character into a valid position if necessary.
				if(this.solid) 
					CollisionSolver.solveCharacterCollisions(this, dx, dy, dz);
				
				// Check if element moved into a different cell
				var cell:Cell = this.scene.translateToCell(this.x,this.y,this.z)
				
				if(cell!=this.cell || this.cell == null) {
					
					// Check for XML events in cell we leave
					if(this.cell!=null) {
						var k:Number = this.cell.events.length
						for(var i:Number=0;i<k;i++) {
							var evt:fCellEventInfo = this.cell.events[i]
							if(cell.events.indexOf(evt)<0) dispatchEvent(new fEventOut(Character.EVENT_OUT,evt.name,evt.xml))
						}
					}
					
					var lastCell:Cell = this.cell;
					this.cell = cell;
					this.updateOccupiedCells();
					dispatchEvent(new Event(MovingElement.NEWCELL))
					
					// Check for XML events in new cell
					if(this.cell != null && lastCell != null) {
						k = this.cell.events.length;
						for(i = 0; i < k; i++) {
							evt = this.cell.events[i];
							if(lastCell.events.indexOf(evt)<0) 
								dispatchEvent(new MoveInEvent(Character.EVENT_IN, evt.name, evt.xml));
						}
					}
				}
				
				// Dispatch move event
				if(this.x != lx || this.y != ly || this.z != lz) 
					dispatchEvent(new MoveEvent(MovingElement.MOVE, this.x - lx, this.y - ly, this.z - lz));
				
			} catch(e:Error) {
				// This means we tried to move outside scene limits
				this.x = lx;
				this.y = ly;
				this.z = lz;
				dispatchEvent(new CollideEvent(Character.COLLIDE, null));
			}
		}
		
		/** @private */
		public function disposeCharacter():void {
			
			var ll:int = this.scene.lights.length;
			for(var j:int = 0; j < ll; j++) {
				var light:Light = this.scene.lights[j];
				if(light)
					light.vCharacters[this.counter] = null;
			}
			
			for(var i in this.vLights) 
				delete this.vLights[i];
			ll = this.currentOccluding.length;
			for(i = 0; i < ll; i++) 
				delete this.currentOccluding[i];
			this.currentOccluding = null;
			this.vLights = null;
			
			// Clear out the old cells
			this.clearOccupiedCells();
			
			this.disposeObject();
			
		}
		
		/** @private */
		public override function dispose():void {
			this.disposeCharacter();
		}		
		
		private function onSceneLoaded(evt:ProcessEvent):void {
			this.updateOccupiedCells();
		}
		
		// Assigns a new list of occupied cells to this character. Thnx to Alex Stone
		private function updateOccupiedCells():void {
			
			// Retrieve new list of occupied cells
			var theCell:Cell = this.scene.translateToCell(this.x, this.y, this.z);
			var cells:Array = [];
			var cellRadius:int = int((this.radius / this.scene.gridSize) + 0.5);
			
			// Loop ranges
			var i1:int = theCell.i - cellRadius;
			if(i1 < 0)
				i1 = 0;
			var i2:int = theCell.i + cellRadius;
			var j1:int = theCell.j - cellRadius;
			if(j1 < 0) 
				i1 = 0;
			var j2:int = theCell.j + cellRadius;
			var k2:Number = (this.top / this.scene.levelSize);
			
			for(var i:int = i1; i <= i2; i++) {
				for(var j:int = j1; j <= j2; j++) {
					for(var k:int = theCell.k; k <= k2; k++) {
						var newCell:Cell = this.scene.getCellAt(i,j,k);
						if(newCell) 
							cells[cells.length] = newCell;
					}
				}
			}
			
			// Clear out the old cells
			this.clearOccupiedCells();
			
			// Update new cells
			this.occupiedCells = cells;
			var forEach:Function = function(item:*, index:int, array:Array) {
				item.charactersOccupying[item.charactersOccupying.length] = this;
			}
			this.occupiedCells.forEach(forEach, this);
		}
		
		private function clearOccupiedCells():void {
			
			var filter:Function = function(item:*, index:int, array:Array) {
				if(item == this) {
					return false;
				}
				return true;
			}
			var forEach:Function  = function(item:*, index:int, array:Array) {
				item.charactersOccupying.filter(filter, this);
			}
			this.occupiedCells.forEach(forEach, this);
			this.occupiedCells = null;
		}
	}	
}