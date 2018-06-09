package
{
	/**
	 *	lazy_yu
	 *	2018-6-6
	 */
	import base.com.loader.CUrlLoader;
	import base.com.loader.event.CUrlLoaderEvent;

	import flash.desktop.ClipboardFormats;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;

	[SWF(width="1024", height="768", frameRate="60", backgroundColor="0xFFFFFF")]
	public class refreshUrl extends Sprite
	{
		private var FilrUrlArr:Array=new Array();
		private var fileUrlArr:Array=new Array();
		private var fileUpArr:Array=new Array();
		private var fileName:String='';
		private var _loadmc:loadmc;
		private var cUrlLoader:CUrlLoader;
		private var netUrl:String;
		private var xMLLoader:XMLLoader;
		private var fristStr:String;

		private var debugStr:String='';

		public function refreshUrl()
		{
			if (stage) {
				this.init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, this.init);
			}
		}

		protected function init():void
		{
			_loadmc=new loadmc();
			addChild(_loadmc);

			xMLLoader=new XMLLoader();
			xMLLoader.addEventListener(Event.COMPLETE, xmlComplete);
			xMLLoader.load('config/config.xml');

			_loadmc.upbtn.addEventListener(MouseEvent.MOUSE_UP, netRefesh)
			_loadmc.refreshBtn.addEventListener(MouseEvent.CLICK, onClick);
			_loadmc.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn);
			_loadmc.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragDropHandler);
			_loadmc.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragExitHandler);
		}

		private function netRefesh(e:MouseEvent):void
		{
			netUrl=_loadmc.netUrl.text;
			_loadmc.fileFUrl.text=netUrl + fileName + fristStr;
		}

		protected function xmlComplete(e:Event):void
		{
			var xml:XML=xMLLoader.xml;
			netUrl=_loadmc.netUrl.text=xml.host;
//			trace(xml.host);
		}

		private function onClick(e:MouseEvent):void
		{
			if (_loadmc.netUrl.text.length > 0) {
				netUrl=_loadmc.netUrl.text;
				upLink();
			}
		}

		private function upLink():void
		{
			if (fileUpArr.length > 0) {
				var url:String=fileUpArr.shift();
				var str:String=netUrl + fileName + url;
				if (cUrlLoader != null) {
					cUrlLoader.removeEventListener(CUrlLoaderEvent.SUCCESS, onSucc);
					cUrlLoader.removeEventListener(CUrlLoaderEvent.FAILE, onFaile);
				}
				debugStr=url;
				cUrlLoader=new CUrlLoader(str);
				cUrlLoader.addEventListener(CUrlLoaderEvent.SUCCESS, onSucc);
				cUrlLoader.addEventListener(CUrlLoaderEvent.FAILE, onFaile);
				cUrlLoader.load();
			}
		}

		protected function onFaile(e:CUrlLoaderEvent):void
		{
			var slice:String=debugStr.slice(1);
			_loadmc.faileName.text+=slice + ' :失败\n';
			upLink();
		}

		protected function onSucc(e:CUrlLoaderEvent):void
		{
			var slice:String=debugStr.slice(1);
			_loadmc.succName.text+=slice + ' :成功\n';
			upLink();
		}

		protected function dragExitHandler(e:NativeDragEvent):void
		{
			trace('exit');
		}

		protected function dragDropHandler(e:NativeDragEvent):void
		{
			// TODO Auto-generated method stub
		}

		protected function onDragIn(e:NativeDragEvent):void
		{
			if (e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				fileUrlArr.length=0;
				fileUpArr.length=0;
				var files:Array=e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				var f:File=files[0];
				var fileArr:Array=[];
				var fileNativePath:String=f.nativePath;
				fileName=f.name;
				try {
					fileArr=f.getDirectoryListing();
				}
				catch (error:Error) {
					fileUrlArr.push(fileName);
				}

				if (fileArr.length > 0) {
					getFileUrl(fileArr);
				}
				var fileStr:String='';
				fristStr='';
				fileUrlArr.reverse();
				for (var i:int=0; i < fileUrlArr.length; i++) {
					var s:String=fileUrlArr[i];
//					var exp1:RegExp=new RegExp("//", "g");
					s=s.replace(fileNativePath, '');
					s=s.replace("\\", "/");
					if (fristStr.length == 0) {
						fristStr=s;
					}
					fileStr+=s + '\n';
					fileUpArr.push(s);
				}

				_loadmc.fileFUrl.text=netUrl + fileName + fristStr;
				_loadmc.fileStr.text=fileNativePath;
				_loadmc.fileName.text=fileStr;
			}
		}

		private function getFileUrl(arr:Array):void
		{
			for each (var obj:Object in arr) {
				var fArr:Array=null;
				try {
					fArr=obj.getDirectoryListing();
				}
				catch (error:Error) {
				}
				if (fArr == null || fArr.length == 0) {
					fileUrlArr.push(obj.nativePath);
				} else {
					getFileUrl(fArr);
				}
			}
		}


		public function GetFiles(strPath:String):void
		{
			//获取指定路径下的所有文件名
			var directory:File=new File(strPath);
			var contents:Array=directory.getDirectoryListing();
			for (var i:uint=0; i < contents.length; i++) {
				trace(contents[i].name, contents[i].size);
				var file:File=contents[i] as File;
				if (file.isDirectory) {
					GetFiles(file.nativePath);
				} else {
					FilrUrlArr.push(file.nativePath + "==" + file.extension);
				}
			}
		}
	}
}
