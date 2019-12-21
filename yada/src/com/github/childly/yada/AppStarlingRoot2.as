package com.github.childly.yada
{
import flash.display.Bitmap;
import flash.display.BitmapData;

import starling.core.Starling;

import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import flash.geom.Point;

public class AppStarlingRoot2 extends Sprite
{
    [Embed(source="/assets/brush-1-small.png", mimeType="image/png")]
//    [Embed(source="/assets/brush-circle-small.png", mimeType="image/png")]
    private var BrushBm : Class;

    private var canvas:BitmapData;
    private var brush:BitmapData;
    private var a:BitmapData;

    public function AppStarlingRoot2()
    {
        super();

        addEventListener(Event.ADDED_TO_STAGE, addedEvent);
    }

    private function addedEvent(event : Event) : void
    {
        removeEventListener(Event.ADDED_TO_STAGE, addedEvent);

        canvas = new BitmapData(512, 384, true, 0x00FFFFFF);

        brush = new BrushBm().bitmapData;

        a = new BitmapData(100, 100, true, 0x11FF0000);

        Starling.current.nativeOverlay.addChild(new Bitmap(canvas));

        stage.addEventListener(TouchEvent.TOUCH, touchEvent);
    }

    private function touchEvent(event : TouchEvent) : void
    {
        var touches : Vector.<Touch> = event.getTouches(event.target as DisplayObject);
        for each (var touch : Touch in touches)
        {
            if (touch.phase == TouchPhase.HOVER)
                continue;

            var location : Point = touch.getLocation(this);

            var prevLocation : Point = touch.getPreviousLocation(this);
            var gapX : Number = location.x - prevLocation.x;
            var gapY : Number = location.y - prevLocation.y;
            var gap : Number = Math.sqrt((gapX * gapX) + (gapY * gapY));
            var fillGaps : int = Math.ceil(Math.round(gap) / (brush.width * .05));

            for (var i : int = 1; i < gap; i++)
            {
                canvas.copyPixels(brush, brush.rect, new Point(prevLocation.x + gapX * (i / gap), prevLocation.y + gapY * (i / gap)), a, new Point(), true);
            }
        }
    }
}
}