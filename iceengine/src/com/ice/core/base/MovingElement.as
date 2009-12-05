/**
 * 基础对象类 
 */
package com.ice.core.base {
	import com.ice.core.events.MoveEvent;
	import com.ice.core.interfaces.IElementController;
	import com.ice.util.MathUtils;
	import com.ice.util.ds.Cell;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	// Imports
	
	/**
	 * <p>The fElement class defines the basic structure of anything in a filmation Scene</p>
	 *
	 * <p>All elements ( walls, floors, lights, cameras, etc ) inherit from fElement.</p>
	 *
	 * <p>The fElement provides basic position and movement functionality</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT</p>
	 */
	public class MovingElement extends EventDispatcher {
		
		// This counter is used to generate unique element Ids for elements that don't have a specific Id in their XML definition
		/** @private */
		private static var count:Number = 0;
		
		/**
		 * The string identifier of this element. Use it as input parameter to the scene's .all Array
		 */
		public var id:String;
		
		/**
		 * This is the XML node from the scene XML that generated this element. It is useful if you want to add
		 * custom attributes to specific instances of your elements, and access them later from your app. For example,
		 * you could add descriptions to objects, and then display those descriptions when the user rollOvers that object.
		 */
		public var xmlObj:XML;
		
		/**
		 * Unique ID. This is automatically assigned and used internally in hashTables and such
		 * @private
		 */
		public var uniqueId:int;
		
		/** 
		 * X coordinate fot this element
		 */
		public var x:Number;
		
		/** 
		 * Y coordinate for this element
		 */
		public var y:Number;
		
		/** 
		 * Z coordinate for this element
		 */
		public var z:Number;
		
		/**
		 * A reference to the cell where the element currently is
		 * @private
		 */
		public var cell:Cell;
		
		/**
		 * A reference to the scene where this element belongs
		 * @private
		 */
		public var scene:Scene;
		
		/**
		 * As elements are not defined as "dynamic", this property can be used to store extra info about this element at run-time.
		 */
		public var customData:Object;
		
		
		/**
		 * The fElement.MOVE constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>elementmove</code> event.
		 * The event is dispatched when the element moves. Allows elements to track and follow other elements
		 * 
		 * @eventType elementmove
		 */
		public static const MOVE:String = "elementmove";
		
		/**
		 * The fElement.NEWCELL constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>elementnewcell</code> event.
		 * The event is dispatched when the element moves into a new cell.
		 * 
		 */
		public static const NEWCELL:String = "elementnewcell";
		
		// Private.
		// This is the destination of this element, when following another element
		private var _destX:Number;	
		private var _destY:Number;
		private var _destZ:Number;
		
		// This is the offset of this element, when following another element
		private var _offX:Number;	
		private var _offY:Number;
		private var _offZ:Number;
		
		// How fast we fall into the destination point
		private var _elasticity:Number;
		
		// Controller
		private var _controller:IElementController = null;
		
		
		/*
		* Contructor for the fElement class.
		*
		* @param defObj: XML definition for this element. The XML attributes that will be parsed are ID,X,Y and Z
		*
		* @param scene: the scene where this element will be reated
		*/
		
		public function get offx():Number
		{
			return _offX;
		}
		
		public function get offy():Number
		{
			return _offY;
		}
		
		public function get offz():Number
		{
			return _offZ;
		}
		
		function MovingElement(defObj:XML,scene:Scene):void {
			
			// Id
			this.xmlObj = defObj;
			var temp:XMLList= defObj.@id;
			
			this.uniqueId = count++;
			if(temp.length()==1) 
				this.id = temp.toString();
			else 
				this.id = "Element_"+this.uniqueId;
			
			// Reference to container scene
			this.scene = scene;
			
			// Current cell position
			this.cell = null;                          
			
			// Basic coordinates
			this.x = new Number(defObj.@x[0]); 
			this.y = new Number(defObj.@y[0]);   
			this.z = new Number(defObj.@z[0]);
			if(isNaN(this.x)) this.x = 0;
			if(isNaN(this.y)) this.y = 0;
			if(isNaN(this.z)) this.z = 0;
			
			this.customData = new Object();
		}
		
		/**
		 * Assigns a controller to this element
		 * @param controller: any controller class that implements the IElementController interface
		 */
		public function set controller(controller:IElementController):void {
			if(this._controller!=null) 
				this._controller.enabled = false;
			this._controller = controller;
			if(this._controller) 
				this._controller.assignElement(this);
		}
		
		/**
		 * Retrieves controller from this element
		 * @return controller: the class that is currently controlling the the fElement
		 */
		public function get controller():IElementController {
			return this._controller;
		}
		
		
		/**
		 * Moves the element to a given position
		 * 
		 * @param x: New x coordinate
		 *
		 * @param y: New y coordinate
		 *
		 * @param z: New z coordinate
		 *
		 */
		public function moveTo(x:Number, y:Number, z:Number):void {
			
			// Last position
			var dx:Number = this.x;
			var dy:Number = this.y;
			var dz:Number = this.z;
			
			// Set new coordinates			   
			this.x = x;
			this.y = y;
			this.z = z;
			
			// Check if element moved into a different cell
			var cell:Cell = this.scene.translateToCell(x, y, z);
			if(this.cell == null || cell == null || cell != this.cell) {
				this.cell = cell;
				dispatchEvent(new Event(NEWCELL));
			}
			// Dispatch event
			this.dispatchEvent(new MoveEvent(MOVE, this.x - dx, this.y - dy, this.z - dz));
		}
		
		
		/**
		 * Makes element follow target element
		 * 
		 * @param target: The filmation element to be followed
		 *
		 * @param _elasticity: How strong is the element attached to what is following. 0 Means a solid bind. The bigger the number, the looser the bind.
		 *
		 */
		public function follow(target:MovingElement, _elasticity:Number = 0):void {
			_offX = target.x - this.x;
			_offY = target.y - this.y;	
			_offZ = target.z - this.z;
			_elasticity = 1 + _elasticity;
			target.addEventListener(MOVE, moveListener, false, 0, true);
		}
		
		/**
		 * Stops element from following another element
		 * 
		 * @param target: The filmation element to be followed
		 *
		 */
		public function stopFollowing(target:MovingElement):void {
			target.removeEventListener(MOVE, moveListener);
		}
		
		// Listens for another element's movements
		/** @private */
		public function moveListener(event:MoveEvent):void {
			if(_elasticity == 1) 
				this.moveTo(event.target.x - _offX, event.target.y - _offY, event.target.z - _offZ);
			else {
				_destX = event.target.x - _offX;
				_destY = event.target.y - _offY;
				_destZ = event.target.z - _offZ;
				Engine.stage.addEventListener('enterFrame', followListener, false, 0, true);
			}
		}
		
		/** Tries to catch up with the followed element
		 * @private
		 */
		public function followListener(event:Event) {
			var dx:Number = _destX - this.x;
			var dy:Number = _destY - this.y;		
			var dz:Number = _destZ - this.z;
			try {
				this.moveTo(this.x + dx / _elasticity, this.y + dy / _elasticity, this.z + dz / _elasticity);
			} catch(e:Error) {
			}
			
			// Stop ?
			if(dx < 1 && dx > -1 && dy < 1 && dy > -1 && dz < 1 && dz > -1) {
				Engine.stage.removeEventListener('enterFrame', this.followListener);
			}
		} 
		
		/**
		 * Returns the distance of this element to the given coordinate
		 *
		 * @return distance
		 */
		public function distanceTo(x:Number, y:Number, z:Number):Number {
			return MathUtils.distance3d(x, y, z, this.x, this.y, this.z);
		}
		
		// Clean resources
		
		/** @private */
		public function disposeElement():void {
			this.xmlObj	= null;
			this.cell = null;
			this.scene = null;
			this._controller = null;
			if(Engine.stage) 
				Engine.stage.removeEventListener('enterFrame', followListener);
		}
		
		/** @private */
		public function dispose():void {
			this.disposeElement();
		}
	}
}
