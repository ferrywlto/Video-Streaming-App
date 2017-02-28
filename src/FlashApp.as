package grandtech
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.events.FlexEvent;
	import mx.events.VideoEvent;
	import mx.states.State;
	import mx.states.Transition;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.components.VideoDisplay;
	import spark.effects.Fade;
	import spark.layouts.VerticalLayout;
	
	public class FlashApp extends Application
	{
		public function FlashApp()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, Application_onCreateComplete);				
		}
		protected var txtbox:TextArea;
		protected var playBtn:Button;
		protected var videoPlayer:VideoDisplay;
		protected var nc1:NetConnection;
		protected var txtVidLoc:TextInput;
		
		public function Application_onCreateComplete(event:FlexEvent):void{
			width=320;
			height=480;
			layout = new VerticalLayout();

			txtVidLoc = new TextInput();
			txtVidLoc.width = 320;
			txtVidLoc.text = "rtmp://somehost/live/livestream";
			addElement(txtVidLoc);
			
			playBtn = new Button();
			playBtn.width = 320;
			playBtn.label = "play live stream";
			playBtn.addEventListener(MouseEvent.CLICK, play_btn_onClick);
			addElement(playBtn);
			
			txtbox = new TextArea();
			txtbox.width = 320;
			addElement(txtbox);
			
			videoPlayer = getNonSkinableVideoPlayer();
			addElement(videoPlayer);		
		}
		
		public function play_btn_onClick(event:Event):void{
			txtbox.text = "button clicked.\n connect to:"+txtVidLoc.text;
			videoPlayer.stop();
			videoPlayer.source = txtVidLoc.text;
			videoPlayer.play();
		}
		
		public function getNonSkinableVideoPlayer():VideoDisplay {
			var vp:VideoDisplay = new VideoDisplay();
			vp.scaleMode = "stretch";
			vp.source = txtVidLoc.text;
			vp.autoPlay = true;
			vp.addEventListener(VideoEvent.STATE_CHANGE, vp_onStateChange);	
			return vp;
		}
		
		public function vp_onStateChange(event:VideoEvent):void{
			txtbox.text = event.state;
			switch(event.state)
			{
				case VideoEvent.BUFFERING: txtbox.text = "buffering..."; break;
				case VideoEvent.CONNECTION_ERROR: txtbox.text = "connection ERROR!"; break;
				case VideoEvent.DISCONNECTED: txtbox.text = "disconneted."; break;
				case VideoEvent.READY: txtbox.text = "video is ready."; break;
				case VideoEvent.LOADING: txtbox.text = "video is loading..."; break;
			}
		}
		
		public function addPureVideo():void
		{
			nc1 = new NetConnection();
			nc1.client = {};
			nc1.client.onBWDone = function ():void {};
			nc1.addEventListener(NetStatusEvent.NET_STATUS, H_netStatus); 
			nc1.connect("rtmp://somehost/live/livestream");
		}
		
		public function H_netStatus(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Stream not found: ");
					break;
			}		
		}
		public function connectStream():void
		{
			//use non-skinable video component
			var stream:NetStream = new NetStream(nc1);
			stream.client = {};
			stream.client.onMetaData = function ():void {};
			var vdo1:Video = new Video();
			vdo1.attachNetStream(stream);
		    addChild(vdo1);
		}
	}
}