/**
 * base bullet element class
 */
package com.ice.core.elements {
	import com.ice.core.base.RenderableElement;
	import com.ice.core.base.Scene;
	import com.ice.core.events.ShotEvent;
	import com.ice.core.interfaces.IElementController;
	import com.ice.core.interfaces.IMovingElement;
	import com.ice.core.logic.sight.LineOfSightSolver;
	import com.ice.util.ds.CoordinateOccupant;
	
	import flash.events.Event;
	
	// Imports
	
	/** 
	 * <p>A bullet is also a moving element, but its particular properties demand an specific class.
	 * Bullets move very fast, therefore its collisions must be resolved using trajectories instead of coordinates.
	 * Also in this engine bullets don't have size to simplify calculations. This doesn't mean they can't look the way
	 * you want: you have control of the render but internally, they will behave as a point travelling in space.</p>
	 *
	 * <p>As of this release, castSahdows, receiveShadows and receiveLights don't apply to fBullets. fBullets don't get
	 * any lighting applied.</p>
	 *
	 * <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT.<br>
	 * Use scene.createBullet() to add new bullets to an scene. They will be destroyed automatically when they hit something.</p>
	 *
	 * <p><b>Note to developers:</b> bullets are reused. Creating new objects is slow, and depending on your game you could have a lot
	 * being created and destroyed. The engine uses an object pool to reuse "dead" bullets and minimize the amount of new() calls. This
	 * is transparent to you but I think this information can help tracking weird bugs</p>
	 *
	 * @see org.ice.core.base.Scene#createBullet()
	 */
	public class Bullet extends RenderableElement implements IMovingElement {
		
		// Constants
		
		/**
		 * The fSHOT constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>bulletshot</code> event.
		 * The event is dispatched by solid elements when they receive a bullet impact and also by the bullet itself, so you
		 * can capture it where it fits you the most
		 * 
		 * @eventType charactercollide
		 */
		public static const SHOT:String = "bulletshot";
		
		/**
		 * The fSHOTTHROUGH constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>bulletshotthrough</code> event.
		 * The event is dispatched by non-solid elements when they receive a bullet impact (which for non-solid elements will continue
		 * its path ) and also by the bullet itself, so you can capture it where it fits you the most
		 * 
		 * @eventType characterwalkover
		 */
		public static const SHOT_THROUGH:String = "bulletshot_through";
		
		// Properties
		
		/** Speed of bullet along X-axis, in pixels per frame. Can be altered during movement. */
		public var speedx:Number;
		
		/** Speed of bullet along Y-axis, in pixels per frame. Can be altered during movement. */
		public var speedy:Number;
		
		/** Speed of bullet along Z-axis, in pixels per frame. Can be altered during movement. */
		public var speedz:Number;
		
		// Constructor
		/** @private */
		function Bullet(scene:Scene):void {
			// Previous. no real XML is needed for bullets
			super(<bullet/>, scene);
			
			// Overwrite properties that don't apply to bullets
			this.receiveLights = false;
			this.receiveShadows = false;
			this.castShadows = false;
			this.solid = true;
		}
		
		/**
		 * Main control loop for bullets
		 * @private
		 */
		public function control(event:Event):void {
			// Apply speed
			var nx:Number = this.x + this.speedx;
			var ny:Number = this.y + this.speedy;
			var nz:Number = this.z + this.speedz;
			
			// See if we collided against something. If we did, apply new coordinates
			var inFront:Array = LineOfSightSolver.calculateLineOfSight(this.scene, this.x, this.y, this.z, nx, ny, nz);
			var any:RenderableElement = null;
			
			var n:int = inFront.length;
			var co:CoordinateOccupant;
			var evt2:ShotEvent;
			for(var i:Number = 0; any == null && inFront && i < n; i++) {
				co = inFront[i];
				if(!co.element.solid) {
					// Shot non-solid
					evt2 = new ShotEvent(SHOT_THROUGH, this, co.element, co.coordinate);
					this.dispatchEvent(evt2);
					co.element.dispatchEvent(evt2);
				} else {
					// Shot solid
					any = co.element;
					nx = co.coordinate.x;
					ny = co.coordinate.y;
					nz = co.coordinate.z;
					if(this.speedx > 0) 
						nx -= 0.1; 
					else 
						nx += 0.1;
					if(this.speedy > 0) 						
						ny -= 0.1; 
					else 
						ny += 0.1;
					if(this.speedz > 0) 
						nz -= 0.1; 
					else 
						nz += 0.1;
				}
			}
			
			// Move bullet to new position
			this.moveTo(nx, ny, nz);
			
			// If we collided against something
			if(any != null) {
				// Generate event
				evt2 = new ShotEvent(SHOT, this, co.element, co.coordinate);
				this.dispatchEvent(evt2);
				co.element.dispatchEvent(evt2);
			}
		}
		
		// Bullets control themselves
		/** @private */
		public override function set controller(controller:IElementController):void {
			throw new Error("Filmation Engine Exception: You can't assign controllers to fBullets. Bullets control themselves."); 
		}
		
		// Bullets control themselves
		/** @private */
		public function enable():void {
			this.scene.container.addEventListener(Event.ENTER_FRAME, this.control, false, 0, true);
		}
		
		// Bullets control themselves
		/** @private */
		public function disable():void {
			this.scene.container.removeEventListener(Event.ENTER_FRAME, this.control);
		}
		
		/** @private */
		public function disposeBullet():void {
			this.disable();
			this.disposeRenderable();
		}
		
		/** @private */
		public override function dispose():void {
			this.disposeBullet();
		}		
	}
}