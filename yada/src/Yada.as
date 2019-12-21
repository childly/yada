package {

import com.adobe.cairngorm.CairngormNavigationFeathersSupport;
import com.adobe.cairngorm.CairngormNavigationSupport;
import com.github.childly.yada.Config;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.utils.getDefinitionByName;

import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.LogLevel;
import org.spicefactory.lib.logging.SpiceLogFactory;
import org.spicefactory.lib.logging.impl.DefaultLogFactory;
import org.spicefactory.lib.logging.impl.TraceAppender;
import org.spicefactory.lib.xml.mapper.SimpleValueMapper;
import org.spicefactory.parsley.asconfig.processor.ActionScriptConfigurationProcessor;
import org.spicefactory.parsley.context.ContextBuilder;
import org.spicefactory.parsley.starling.view.decorator.StarlingViewManagerDecorator;
import org.spicefactory.parsley.xml.XmlConfig;
import org.spicefactory.parsley.xml.XmlContextBuilder;
import org.spicefactory.parsley.xml.mapper.DefaultXmlTags;
import org.spicefactory.parsley.xml.mapper.XmlObjectDefinitionMapperFactory;

import starling.core.Starling;
import starling.utils.AssetManager;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;

public class Yada extends Sprite
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function Yada()
    {
        super();

        loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /** @private */
    protected var _starling:Starling;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    //------------------------------------
    //  Methods: Abstract API
    //------------------------------------

    /** Abstract method */
    protected function getApplicationClass():Class
    {
        return null;
    }

    /**  */
    protected function getStageSize():Point
    {
//        return ScreenUtil.getStageSize(Capabilities.screenResolutionX, Capabilities.screenResolutionY);

        return new Point(320, 480);
    }

    protected function getConfigClasses():Array
    {
        return [Config];
    }

    //------------------------------------
    //  Methods: Setup
    //------------------------------------

    protected function setupStage():void
    {
        stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
        stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        mouseEnabled = mouseChildren = false;
    }

    /**  */
    protected function setupStarling():void
    {
        var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;

        var stageSize:Point = getStageSize();

        var stageWidth:int   = stageSize.x;
        var stageHeight:int  = stageSize.y;

        Starling.multitouchEnabled = true;  // useful on mobile devices
        Starling.handleLostContext = !iOS;  // not necessary on iOS. Saves a lot of memory!

        var viewPort:Rectangle = RectangleUtil.fit(
                new Rectangle(0, 0, stageWidth, stageHeight),
                new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight),
                ScaleMode.SHOW_ALL);

        var scaleFactor:int = viewPort.width < 480 ? 1 : 2; // midway between 320 and 640

        var assets:AssetManager = new AssetManager(scaleFactor);

        assets.verbose = Capabilities.isDebugger;

        _starling = new Starling(getApplicationClass(), stage, viewPort, null, "auto", Context3DProfile.BASELINE_EXTENDED);
        _starling.stage.stageWidth  = stageWidth;  // <- same size on all devices!
        _starling.stage.stageHeight = stageHeight; // <- same size on all devices!
        _starling.simulateMultitouch  = true;
        _starling.enableErrorChecking = Capabilities.isDebugger;
        _starling.showStats = true;
        _starling.showStatsAt("right", "top", scaleFactor);

        _starling.addEventListener("rootCreated",
            function onRootCreated(event:Object, app:Object):void
            {
                _starling.removeEventListener("rootCreated", onRootCreated);

                _starling.start();
            }
        );
    }

    private function setupApplication():void
    {

        // Configure Parsley Logging

        var factory:SpiceLogFactory = new DefaultLogFactory();
        factory.setRootLogLevel(LogLevel.WARN);

        var appender:TraceAppender = new TraceAppender();
        appender.threshold = LogLevel.WARN;

        factory.addAppender(appender);

        LogContext.factory = factory;

        // Initialize Navigation with Feathers support

        CairngormNavigationSupport.initialize();

        CairngormNavigationFeathersSupport.initialize();

        // Configure Parsley Context

        ContextBuilder.newSetup()
            .services().viewManager().addDecorator(StarlingViewManagerDecorator, _starling)
            .newBuilder()
            .config(new ActionScriptConfigurationProcessor(getConfigClasses()))
            .config(XmlConfig.forFile("config.xml"))
        .build();

        XmlContextBuilder.build("config.xml");
    }

    //-----------------------------------
    //  Methods: Handlers
    //-----------------------------------

    protected function onResize():void
    {

    }

    protected function onActivated():void
    {

    }

    protected function onDeactivated():void
    {

    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    private function loaderInfo_completeHandler(event:Event):void
    {
        loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);

        setupStage();

        setupStarling();

        setupApplication();
    }

    private function stage_deactivateHandler(event:Event):void
    {
        stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);

        onDeactivated();
    }

    private function stage_activateHandler(event:Event):void
    {
        stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);

        onActivated();
    }

    private function stage_resizeHandler(event:Event):void
    {
        onResize();
    }
}
}
