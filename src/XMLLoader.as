package
{
	/**
	 *	lazy_yu
	 *	2018-6-9
	 */
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class XMLLoader extends EventDispatcher
	{
		protected var _loader:URLLoader;
		protected var _xml:XML;
		protected var _strPath:String;

		public function XMLLoader(target:IEventDispatcher=null)
		{
			super(target);
		}

		public function load($strPath:String):void
		{
			this._strPath=$strPath;
			var requests:URLRequest=new URLRequest($strPath);
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			addEvents(loader);
			loader.load(requests);
		}

		public function get xml():XML
		{
			return _xml;
		}

		protected function onLoaded(e:Event):void
		{
			var byteArr:ByteArray=ByteArray(loader.data);
			var xmlStr:String=byteArr.readMultiByte(byteArr.length, "utf-8");
			addXml(xmlStr);
		}

		protected function addXml(str:String=""):void
		{
			_xml=XML(str);
			this.dispatchEvent(new Event(Event.COMPLETE));
			removeEvents(loader);
		}

		protected function progressHandler(e:ProgressEvent):void
		{
			//todo
		}

		protected function ioErrorHandler(e:IOErrorEvent):void
		{
			addXml();
			trace("名字：", _strPath, "-------------------XML加载错误-----------------------------");
		}

		protected function addEvents(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.COMPLETE, onLoaded);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		}

		protected function removeEvents(dispatcher:IEventDispatcher):void
		{
			dispatcher.removeEventListener(Event.COMPLETE, onLoaded)
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler)
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
		}

		public function get loader():URLLoader
		{
			if (_loader == null) {
				_loader=new URLLoader();
			}
			return _loader;
		}

		public function unload():void
		{
			loader.close();
		}
	}
}
