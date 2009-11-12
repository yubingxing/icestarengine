/**
 * 基础对象类 
 */
package com.ice.core {
	import com.ice.core.events.MoveEvent;
	import com.ice.core.interfaces.IElementController;
	import com.ice.util.ds.Cell;
	
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
	public class Element extends EventDispatcher {
		
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
		private var destx:Number;	
		private var desty:Number;
		private var destz:Number;
		
		// This is the offset of this element, when following another element
		private var _offx:Number;	
		private var _offy:Number;
		private var _offz:Number;
		
		// How fast we fall into the destination point
		private var elasticity:Number;
		
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
			return _offx;
		}
		
		public function get offy():Number
		{
			return _offy;
		}
		
		public function get offz():Number
		{
			return _offz;
		}
		
		function Element(defObj:XML,scene:Scene):void {
			
			// Id
			this.xmlObj = defObj;
			var temp:XMLList= defObj.@id;
			
			this.uniqueId = Element.count++;
			if(temp.length()==1) 
				this.id = temp.toString();
			else 
				this.id = "fElement_"+this.uniqueId;
			
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
				this._controller.disable();
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
		public function moveTo(x:Number,y:Number,z:Number):void {
			
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
				dispatchEvent(new Event(Element.NEWCELL));
			}
			// Dispatch event
			this.dispatchEvent(new MoveEvent(Element.MOVE,this.x-dx,this.y-dy,this.z-dz));
		}
		
		
		/**
		 * Makes element follow target element
		 * 
		 * @param target: The filmation element to be followed
		 *
		 * @param elasticity: How strong is the element attached to what is following. 0 Means a solid bind. The bigger the number, the looser the bind.
		 *
		 */
		public function follow(target:Element, elasticity:Number=0):void {
			this._offx = target.x-this.x;
			this._offy = target.y-this.y;	
			this._offz = target.z-this.z;
			this.elasticity = 1+elasticity;
			target.addEventListener(Element.MOVE, this.moveListener, false, 0, true);
		}
		
		/**
		 * Stops element from following another element
		 * 
		 * @param target: The filmation element to be followed
		 *
		 */
		public function stopFollowing(target:Element):void {
			target.removeEventListener(Element.MOVE, this.moveListener);
		}
		
		// Listens for another element's movements
		/** @private */
		public function moveListener(evt:fMoveEvent):void {
			if(this.elasticity == 1) 
				this.moveTo(evt.target.x - this._offx, evt.target.y - this._offy, evt.target.z - this._offz);
			else {
				this.destx = evt.target.x - this._offx;
				this.desty = evt.target.y - this._offy;
				this.destz = evt.target.z - this._offz;
				Engine.stage.addEventListener('enterFrame', this.followListener, false, 0, true);
			}
		}
		
		/** Tries to catch up with the followed element
		 * @private
		 */
		public function followListener(evt:Event) {
			var dx:Number = this.destx - this.x;
			var dy:Number = this.desty - this.y;		
			var dz:Number = this.destz - this.z;
			try {
				this.moveTo(this.x + dx / this.elasticity, this.y + dy / this.elasticity, this.z + dz / this.elasticity);
			} catch(e:Error) {
			}
			
			// Stop ?
			if(dx < 1 && dx > -1 && dy < 1 && dy > -1 && dz < 1 && dz > -1) {
				Engine.stage.removeEventListener('enterFrame',this.followListener);
			}
		} 
		
		
		/**
		 * Returns the distance of this element to the given coordinate
		 *
		 * @return distance
		 */
		public function distanceTo(x:Number, y:Number, z:Number):Number {
			return mathUtils.distance3d(x, y, z, this.x, this.y, this.z);
		}
		
		// Clean resources
		
		/** @private */
		public function disposeElement():void {
			this.xmlObj	= null;
			this.cell = null;
			this.scene = null;
			this._controller = null;
			if(Engine.stage) 
				Engine.stage.removeEventListener('enterFrame', this.followListener);
		}
		
		/** @private */
		public function dispose():void {
			this.disposeElement();
		}
	}
}
