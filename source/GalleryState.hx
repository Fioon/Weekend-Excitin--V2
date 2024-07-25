package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class GalleryState extends MusicBeatState
{
	var curSprite:Int = 0;
	var descriptionText:FlxTypeText;
	var curSpriteTxt:FlxText;
	var chess:ChessBG;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var galSprite:FlxSprite;

	var spritesPushed:Array<FlxSprite> = [];
	var transitioning:Bool;

	var textList:Array<String> = [
		"The Weekend Excitin'", // 0
		'Ref of Kochi', // 1
		'Ref of Hika', // 2
		'Ref of Tsubasa', // 3
		'Ref of Ren', // 4
		"Weekend Excitin' thumbnail #1", // 5
		"Weekend Excitin' thumbnail #2", // 6
		"Weekend Excitin' thumbnail #3", // 7
		'Sketch', // 8
		'I hope she made lotsa spaghetti', // 9
		'Boyfriend and Girlfriend design', // 10
		'Art by OngGamerZ0211', // 11
		'Art by KokaKoala', // 12
		'Art by SkyanUltar', // 13
		'Art by QuixSiji', // 14
		'Art by AnnikiVee', // 15
		'Art by trd_yo', // 16
		'Art by RHibatullina', // 17
		'Art by Ino', // 18
		'Art by ItsJaydenlol', // 19
		'Art by Lofi', // 20
		'Art by beautagicannie', // 21
		'Art by JexenJade', // 22
		'Art by CD', // 23
		'Art by MUPVOF', // 24
		'Art by Mj_Art', // 25
		'Art by EL_la0323', // 26
		'Art by PeakFire', // 27
		'Art by SkyDimensions', // 28
		'Art by Ryder_momo', // 29
		'Art by Mari_chan1401', // 30
	];

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In Gallery", null);
		#end

		spritesPushed = [];
		transitioning = true;

		var counter:Int = 0;
		for (bmap in Cache.gallery.keys())
		{
			var curImg:String = 'weekend$counter';
			var newSprite = Cache.gallery.get(curImg);

			if (newSprite != null)
				spritesPushed.push(new FlxSprite().loadGraphic(newSprite));
			else
				trace('Could not find "$curImg.png" file in cached data');

			counter++;
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG_b'));
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		chess = new ChessBG();
		add(chess);

		var outline = new FlxSprite().loadGraphic(Paths.image('title/outline'));
		outline.updateHitbox();
		outline.screenCenter();
		outline.antialiasing = true;
		add(outline);

		var black:FlxSprite = new FlxSprite(0, 600).makeGraphic(FlxG.width, 200, FlxColor.BLACK);
		black.alpha = 0.7;
		add(black);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		// var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);

		descriptionText = new FlxTypeText(0, Std.int(FlxG.height * 0.9), FlxG.width, "", 32);
		descriptionText.setFormat(Paths.font("PressStartK.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionText.updateHitbox();
		descriptionText.screenCenter(X);
		add(descriptionText);

		curSpriteTxt = new FlxText(FlxG.width * 0.92, 50, Std.int(FlxG.width * 0.12), "", 48);
		curSpriteTxt.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curSpriteTxt.x -= curSpriteTxt.width / 2;
		add(curSpriteTxt);

		leftArrow = new FlxSprite(60, 0);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left", 24, false);
		leftArrow.animation.play('idle');
		leftArrow.screenCenter(Y);
		add(leftArrow);

		rightArrow = new FlxSprite(1280 - 35 - 60, 0);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', "arrow right");
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.screenCenter(Y);
		add(rightArrow);

		leftArrow.animation.finishCallback = n -> if (n == "press") leftArrow.animation.play('idle');
		rightArrow.animation.finishCallback = n -> if (n == "press") rightArrow.animation.play('idle');

		changeSprite();
		forEachOfType(FlxSprite, function(spr)
		{
			spr.scrollFactor.set();
			spr.antialiasing = ClientPrefs.globalAntialiasing;
		});

		 #if android
                addVirtualPad(LEFT_RIGHT, B);
                #end
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (!transitioning && controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			rightArrow.animation.play('press');
			changeSprite(1);
		}
		if (!transitioning && controls.UI_LEFT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			leftArrow.animation.play('press');
			changeSprite(-1);
		}

		curSpriteTxt.text = '${curSprite + 1}/${spritesPushed.length}';
		super.update(elapsed);
	}

	function changeSprite(amount:Int = 0)
	{
		transitioning = true;

		curSprite += amount;
		if (curSprite < 0)
			curSprite = spritesPushed.length - 1;
		else if (curSprite > spritesPushed.length - 1)
			curSprite = 0;

		remove(galSprite);
		galSprite = new FlxSprite().loadGraphicFromSprite(spritesPushed[curSprite]);
		galSprite.setGraphicSize(0, Std.int(FlxG.height * 0.75));
		galSprite.updateHitbox();
		galSprite.screenCenter();
		add(galSprite);

		descriptionText.resetText(textList[curSprite]);
		descriptionText.start();
		FlxTween.angle(galSprite, 10 * amount, 0, 0.25, {ease: FlxEase.quadOut, onComplete: twn -> transitioning = false});
	}
}
