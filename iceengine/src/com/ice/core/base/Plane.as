package com.ice.core.base {
	import com.ice.core.events.NewMaterialEvent;
	import com.ice.util.polygons.Polygon;
	
	// Imports
	
	/**
	 * <p>fPlanes are the 2d surfaces that provide the main structure for any scene. Once created, planes can't be altered
	 * as the render engine relies heavily on precalculations that depend on the structure of the scene.</p>
	 *
	 * <p>Planes cannot be instantiated directly. Instead, fWall and fFloor are used.</p>
	 *
	 * <p>fPlane contains all the lighting, occlusions and shadowcasting code. They also support bump mapping</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT</p>
	 */
	public class Plane extends RenderableElement {
		
		// Static properties
		
		/**
		 * The fNEWMATERIAL constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>planenewmaterial</code> event.
		 * The event is dispatched when an new material is assigned to a plane
		 * 
		 * @eventType elementmove
		 */
		public static const NEWMATERIAL:String = "planenewmaterial";
		
		// Public properties
		
		/** 
		 * Array of holes in this plane. 
		 * You can't create holes dynamically, they must be in the plane's material, but you can open and close them
		 *
		 * @see org.ffilmation.engine.core.fHole
		 */
		public var holes:Array;								// Array of holes in this plane
		
		/** 
		 * Material currently applied to this plane. This object is shared between all planes using the same definition
		 */
		public var material:Material;
		
		// Private properties
		
		/**
		 * @private
		 * This polygon represents 2D shape of the plane. For each plane the irrelevant axis is not taken into account
		 */
		public var shapePolygon:Polygon;
		
		/** @private */
		public var zIndex:Number;
		
		private var planeWidth:Number;
		private var planeHeight:Number;
		
		// Constructor
		/** @private */
		function Plane(defObj:XML, scene:Scene, width:Number, height:Number):void {
			
			// Previous
			super(defObj, scene, defObj.@src.length() != 1);
			
			// 2D dimensions
			this.planeWidth = width;
			this.planeHeight = height;
			
			// Prepare material & holes
			this.shapePolygon = new Polygon();
			this.holes = []	;
			if(defObj.@src.length() == 1) 
				this.assignMaterial(defObj.@src);
		}
		
		/** 
		 * Changes the material for this plane.
		 *
		 * @param id Material Id
		 */
		public function assignMaterial(id:String):void {
			this.material = Material.getMaterial(id, this.scene);
			var contours:Array = this.material.getContours(this, this.planeWidth, this.planeHeight)
			this.shapePolygon.contours = contours;
			this.holes = this.material.getHoles(this, this.planeWidth, this.planeHeight);
			this.dispatchEvent(new NewMaterialEvent(NEWMATERIAL, id, this.planeWidth, this.planeHeight));
			
			// Handle invisible
			if(id.toLowerCase() == "invisible") {
				this.castShadows = this.receiveShadows = this.receiveLights = false;
			}
		}
		
		// Planes don't move
		/** @private */
		public override function moveTo(x:Number, y:Number, z:Number):void {
			throw new Error("Filmation Engine Exception: You can't move a fPlane. ("+this.id+")"); 
		}
		
		// Is this plane in front of other plane ?
		/** @private */
		public function inFrontOf(p:Plane):Boolean {
			return false;
		}
		
		/** @private */
		public function setZ(zIndex:Number):void {
			this.zIndex = zIndex;
			this.setDepth(zIndex);
		}
		
		/** @private */
		public function disposePlane():void {
			
			this.material = null;
			var hl:int = this.holes.length;
			for(var i:Number = 0; i < hl; i++) 
				delete this.holes[i];
			this.holes = null;
			this.disposeRenderable();
		}
		
		/** @private */
		public override function dispose():void {
			this.disposePlane();
		}
	}
}
