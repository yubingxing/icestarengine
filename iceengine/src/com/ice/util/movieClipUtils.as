package com.ice.util {
	
	// Imports
	
	/** 
	 * This class provides various useful methods regarding movieClips
	 * @private
	 */
	public class movieClipUtils {
		
		/**
		 *  Draws circle inside the given movieClip
		 */
		public static function circle(target:Graphics,x:Number,y:Number,radius:Number,softness:Number,col:Number,intensity:Number=100):void {
			
			// Gradient setup
			var colors:Array = [col, col]
			var fillType:String = GradientType.RADIAL
			var alphas:Array = [intensity/100, 0]
			var ratios:Array = [255*softness/100, 255]
			var spreadMethod:String = SpreadMethod.PAD
			var interpolationMethod:String = "linearRGB"
			var focalPointRatio:Number = 0
			var matr:Matrix = new Matrix();
			matr.createGradientBox(radius+radius, radius+radius, 0 ,-radius, -radius);
			
			target.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod, interpolationMethod, focalPointRatio);
			target.drawCircle(x,y,radius)
			target.endFill()
			
		}
		
		/**
		 *  Draws box inside the given movieClip
		 */
		public static function box(target:Graphics,x:Number,y:Number,side:Number,col:Number,intensity:Number=100):void {
			
			// Gradient setup
			target.beginFill(col,intensity/100)
			target.drawRect(x,y,side,side)
			target.endFill()
			
		}
		
		
		
		/*
		// Draws hollow circle ( donut )
		public static function hollowCircle(target:Sprite,x:Number,y:Number,radius:Number,gapRadius:Number) {
		
		var theta = (45/180)*Math.PI
		var ctrlRadius = radius/Math.cos(theta/2)
		target.lineStyle()
		target.moveTo(x+radius, y+0.1)
		target.beginFill(0xff0000,100)
		var angle = 0
		
		// target loop draws the circle in 8 segments
		
		for (var i = 0; i<8; i++) {
		// increment our angles
		angle += theta;
		angleMid = angle-(theta/2);
		// calculate our control point
		cx = x+Math.cos(angleMid)*(ctrlRadius);
		cy = y+Math.sin(angleMid)*(ctrlRadius);
		// calculate our end point
		px = x+Math.cos(angle)*radius;
		py = y+Math.sin(angle)*radius;
		// draw the circle segment
		target.curveTo(cx, cy, px, py);
		}
		
		target.lineTo(x+gapRadius, y-0.1)
		
		var ctrlRadius = gapRadius/Math.cos(theta/2)
		
		for (var i = 0; i<8; i++) {
		// increment our angles
		angle += theta;
		angleMid = angle-(theta/2);
		// calculate our control point
		cx = x+Math.cos(angleMid)*(ctrlRadius);
		cy = y-Math.sin(angleMid)*(ctrlRadius);
		// calculate our end point
		px = x+Math.cos(angle)*gapRadius;
		py = y-Math.sin(angle)*gapRadius;
		// draw the circle segment
		target.curveTo(cx, cy, px, py);
		}
		
		target.endFill()
		}
		
		*/
	}
}

