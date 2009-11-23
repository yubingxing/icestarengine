/**
 * 基础渲染对象类 
 */
package com.ice.core.base {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	// Imports
	
	/**
	 * <p>The fRenderableElement class defines the basic interface for visible elements in your scene.</p>
	 *
	 * <p>Lights are NOT considered visible elements, therefore don't inherit from fRenderableElement</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT</p>
	 */
	public class RenderableElement extends MovingElement {
		
		// Public properties
		
		/**
		 * Boolean value indicating if this object receives lighting. You can change this value dynamically.
		 * Any element in your XML can be given a receiveLights="false|true" attribute in its XML definition
		 */
		public var receiveLights:Boolean = true;
		
		/**
		 * Boolean value indicating if this object receives shadows. You can change this value dynamically
		 * Any element in your XML can be given a receiveShadows="false|true" attribute in its XML definition
		 */
		public var receiveShadows:Boolean = true;
		
		/**
		 * Boolean value indicating if this object casts shadows. You can change this value dynamically
		 * Any element in your XML can be given a castShadows="false|true" attribute in its XML definition
		 */
		public var castShadows:Boolean = true;
		
		/**
		 * Boolean value indicating if this object collides with others.
		 * Any element in your XML can be given a solid="false|true" attribute in its XML definition. When a character moves to
		 * a position that overlaps another element, if will trigger either the fCollide or the fWalkover Events, depending
		 * on the solid property for that element.
		 *
		 * @see org.ffilmation.engine.events.fCollideEvent
		 * @see org.ffilmation.engine.events.fWalkoverEvent
		 */
		public var solid:Boolean = true;
		
		/**
		 * A reference to the library movieclip that was attached to create the element, so you
		 * can acces methods inside, nested clips or whatever.
		 *
		 * This property is null until the element's graphics have been created. This happens the first time the element scrolls into the viewport.
		 * Listen to the <b>fASSETS_CREATED</b> event to know when this property exist.
		 *
		 */
		public var flashClip:MovieClip;
		
		/** 
		 * <p><b>WARNING!!!: </b> This property only exists when the scene is being rendered and the graphic elements have been created. This
		 * happens when you call fEngine.showScene(). Trying to access this property before the scene is shown ( to attach a Mouse Event for example )
		 * will throw an error.</p>
		 *
		 * <p>The container is the base DisplayObject that contains everything. If you want to add Mouse Events to your elements, use this
		 * property. Camera occlusion will be applied: this means that if this element was occluded to show the camera position,
		 * its events are disabled as well so you can click on items behind this element.</p>
		 *
		 * <p>The container for each element will have two properties:</p>
		 * <p>
		 * <b>fElementId</b>: The ID for this element<br>
		 * <b>fElement</b>: A pointer to the fElement this MovieClip represents<br>
		 * </p>
		 * <p>These properties will be useful when programming MouseEvents. Using them, you will be able to access the class from an Event
		 * listener attached to the container
		 */
		public var container:ElementContainer;
		
		/** @private */
		public var _visible = true;
		/** @private */
		public var x0:Number;
		/** @private */
		public var y0:Number;
		/** @private */
		public var x1:Number;
		/** @private */
		public var y1:Number;
		/** @private */
		public var top:Number;
		
		private var pendingDestiny:* = null;
		
		// These properties are used by the renderManager
		/////////////////////////////////////////////////
		
		/** @private */
		public var _depth:Number = 0;
		
		/** @private */
		public var depthOrder:int;
		
		/** @private */
		public var isVisibleNow:Boolean = false;
		
		/** @private */
		public var willBeVisible:Boolean = false;
		
		/** @private */
		public var bounds2d:Rectangle = new Rectangle(0,0,1,1);
		
		/** @private */
		public var screenArea:Rectangle = new Rectangle();
		
		// Events
		/** @private */
		public static const DEPTHCHANGE:String = "renderableElementDepthChange";
		
		/**
		 * The fSHOW constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>renderableElementShow</code> event.
		 * The event is dispatched when the elements is shown via the show() method
		 * 
		 * @eventType renderableElementShow
		 */
		public static const SHOW:String = "renderableElementShow";
		
		/**
		 * The fHIDE constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>renderableElementHide</code> event.
		 * The event is dispatched when the elements is hidden via the hide() method
		 * 
		 * @eventType renderableElementHide
		 */
		public static const HIDE:String = "renderableElementHide";
		
		/**
		 * @private
		 * The fENABLE constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>renderableElementEnable</code> event.
		 * The event is dispatched when the elements's Mouse events are enabled
		 * 
		 * @eventType renderableElementEnable
		 */
		public static const ENABLE:String = "renderableElementEnable";
		
		/**
		 * @private
		 * The fDISABLE constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>renderableElementDisable</code> event.
		 * The event is dispatched when the elements's Mouse events are disabled
		 * 
		 * @eventType renderableElementDisable
		 */
		public static const DISABLE:String = "renderableElementDisable";
		
		/**
		 * The fASSETS_CREATED constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>renderableElementAssetsCreated</code> event.
		 * The event is dispatched when the element scrolls into view for the first time and its graphic assets are created.
		 * It is used to know when the flashClip property exists.
		 * 
		 * @eventType renderableElementAssetsCreated
		 */
		public static const ASSETS_CREATED:String = "renderableElementAssetsCreated";
		
		/**
		 * The fASSETS_DESTROYED constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>renderableElementAssetsDestroyed</code> event.
		 * The event is dispatched when the element scrolls out of view and fEngine.conserveMemory is set to true. When this shappens all assets are
		 * destroyed and the flashClip property is nullified.
		 * 
		 * @eventType renderableElementAssetsCreated
		 * Still WIP. Don't use yet !!
		 * @private
		 */
		public static const ASSETS_DESTROYED:String = "renderableElementAssetsDestroyed";
		
		
		// Constructor
		/** @private */
		function RenderableElement(defObj:XML, scene:Scene, noDepthSort:Boolean = false):void {
			
			// Previous
			super(defObj, scene);
			
			// Lights enabled ?
			var temp:XMLList = defObj.@receiveLights;
			if(temp.length() == 1) 
				this.receiveLights = (temp.toString() == "true");
			
			// Shadows enabled ?
			temp = defObj.@receiveShadows;
			if(temp.length() == 1) 
				this.receiveShadows = (temp.toString() == "true");
			
			// Projects shadow ?
			temp = defObj.@castShadows;
			if(temp.length() == 1) 
				this.castShadows = (temp.toString() == "true");
			
			// Solid ?
			temp = defObj.@solid;
			if(temp.length() == 1) 
				this.solid = (temp.toString() == "true");
			
			// Screen area
			this.screenArea = this.bounds2d.clone();
			this.screenArea.offsetPoint(Scene.translateCoords(this.x, this.y, this.z));			   
		}
		
		/**
		 * Mouse management
		 */
		public function disableMouseEvents():void {
			dispatchEvent(new Event(DISABLE));
		}
		
		/**
		 * Mouse management
		 */
		public function enableMouseEvents():void {
			dispatchEvent(new Event(ENABLE));
		}
		
		/**
		 * Makes element visible
		 */
		public function show():void {
			if(!this._visible) {
				this._visible = true;
				dispatchEvent(new Event(SHOW));
			}
		}
		
		/**
		 * Makes element invisible
		 */
		public function hide():void {
			if(this._visible) {
				this._visible = false;
				dispatchEvent(new Event(HIDE));
			}
		}
		
		/**
		 * Passes the stardard gotoAndPlay command to the base clip of this element
		 *
		 * @param where A frame number or frame label
		 */
		public function gotoAndPlay(where:*):void {
			if(this.flashClip)	
				this.flashClip.gotoAndPlay(where);
			else {
				this.pendingDestiny = where;
				this.removeEventListener(ASSETS_CREATED, this.delayedGotoAndStop);
				this.addEventListener(ASSETS_CREATED, this.delayedGotoAndPlay);
			}
		}
		
		private function delayedGotoAndPlay(e:Event):void {
			this.removeEventListener(ASSETS_CREATED, this.delayedGotoAndPlay);
			if(this.flashClip && this.pendingDestiny) this.flashClip.gotoAndPlay(this.pendingDestiny);
		}
		
		/**
		 * Passes the stardard gotoAndStop command to the base clip of this element
		 *
		 * @param where A frame number or frame label
		 */
		public function gotoAndStop(where:*):void {
			if(this.flashClip) this.flashClip.gotoAndStop(where);
			else {
				this.pendingDestiny = where;
				this.removeEventListener(ASSETS_CREATED, this.delayedGotoAndPlay);
				this.addEventListener(ASSETS_CREATED, this.delayedGotoAndStop);
			}
		}
		
		private function delayedGotoAndStop(e:Event):void {
			this.removeEventListener(ASSETS_CREATED, this.delayedGotoAndStop);
			if(this.flashClip && this.pendingDestiny) 
				this.flashClip.gotoAndStop(this.pendingDestiny);
		}
		
		
		/**
		 * Calls a function of the base clip
		 *
		 * @param what Name of the function to call
		 *
		 * @param param An optional extra parameter to pass to the function
		 */
		public function call(what:String, param:* = null):void {
			if(this.flashClip)
				this.flashClip[what](param);
		}
		
		
		// Depth management
		/** @private */
		public final function setDepth(d:Number):void {
			this._depth = d;
			
			// Reorder all objects
			this.dispatchEvent(new Event(DEPTHCHANGE));
		}
		
		/**
		 * Return the 2D distance from this element to any world coordinate
		 */
		public function distance2d(x:Number, y:Number, z:Number):Number {
			var p2d:Point = Scene.translateCoords(x, y, z);
			return this.distance2dScreen(p2d.x, p2d.y);
		}
		
		/**
		 * Return the 2D distance from this element to any screen coordinate
		 */
		public function distance2dScreen(x:Number, y:Number):Number {
			
			// Characters move. Update their screen Area
			if(this is MovingElement) {
				this.screenArea = this.bounds2d.clone();
				this.screenArea.offsetPoint(Scene.translateCoords(this.x, this.y, this.z));
			}
			
			// Test bounds
			var bounds:Rectangle = this.screenArea;
			var pos2D:Point = new Point(x, y);
			var dist:Number = Infinity;
			if(bounds.contains(pos2D.x, pos2D.y)) 
				return 0;
			
			var corner1:Point = new Point(bounds.left, bounds.top);
			var corner2:Point = new Point(bounds.left, bounds.bottom);
			var corner3:Point = new Point(bounds.right, bounds.bottom);
			var corner4:Point = new Point(bounds.right, bounds.top);
			
			var d:Number = mathUtils.distancePointToSegment(corner1, corner2, pos2D);
			if(d<dist) dist = d;
			d = mathUtils.distancePointToSegment(corner2, corner3, pos2D);
			if(d<dist) dist = d;
			d = mathUtils.distancePointToSegment(corner3, corner4, pos2D);
			if(d<dist) dist = d;
			d = mathUtils.distancePointToSegment(corner4, corner1, pos2D);
			if(d<dist) dist = d;
			
			return dist;
		}
		
		/** @private */
		public function disposeRenderable():void {
			this.flashClip = null;
			this.container = null;
			this.disposeElement();
		}
		
		/** @private */
		public override function dispose():void {
			this.disposeRenderable();
		}
	}
}
