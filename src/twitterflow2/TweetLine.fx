/*
 * TweetLine.fx
 *
 * Created on 08/11/2009, 11:57:01
 */

package twitterflow2;

import javafx.scene.CustomNode;
import java.util.Date;
import javafx.scene.control.TextBox;
import java.net.URLEncoder;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import javafx.scene.layout.HBox;
import javafx.scene.image.ImageView;
import javafx.scene.image.Image;
import javafx.scene.text.Text;
import javafx.scene.Cursor;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.shape.Rectangle;
import javafx.scene.Group;
import javafx.scene.Scene;

/**
 * @author diogo
 */


var images: Image[] ;

function getImage(url:String, width: Integer, height: Integer): Image {
    for(i in images) {
        if(i.url == url) {
            return i;
        }
    }
    def im: Image = Image{
        url: url
        width: width
        height: height
        backgroundLoading: true
        placeholder: Image { url: "{__DIR__}placeholder.png", width: width, height:  height }
    }
    insert im into images;
    return im;
}

public class TweetLine extends CustomNode  {
    public-init var profileImageUrl: String;
    public-init var screenName: String;
    public-init var text: String ;
    public-init var date: Date ;
    public-init var tweetId: Long;

    public-init var input: TextBox = Main.input;
    public-init var openURL: function(str: String): Void = Main.openURL;
    public-init var sceneX: Scene = Main.stage.scene;


    function retweet():Void {
        input.text = "RT @{screenName}: {text}";
    }

    function reply():Void {
        input.text = "@{screenName} ";

    }

    function direct():Void {
        input.text = "d {screenName} ";
    }

    function link(url: String): Void {
        openURL(url);
    }

    function seeTweet(): Void {
        openURL("http://twitter.com/{screenName}/statuses/{tweetId}");
    }

    function seeUser(): Void {
        openURL("http://twitter.com/{screenName}");
    }

    override function create() {
        def pop:PopMenu = PopMenu {
            itens: ["Profile","Retweet","Reply","Direct"]
            scene: sceneX
            action: function(str: String) {
                if(str == "Profile") {
                    seeUser();
                } else if(str == "Retweet") {
                    retweet();
                } else if(str == "Reply") {
                    reply();
                } else if(str == "Direct") {
                    direct();
                } else if(str.startsWith("#")){
                    link("http://search.twitter.com/search?q={URLEncoder.encode(str)}");
                } else if(str.startsWith("@")){
                    link("http://twitter.com/{str.substring(1)}");
                } else {
                    link(str);
                }
            }
        }

        var patttern: Pattern = Pattern.compile("(https?://[^ ]+)");
        var matcher: Matcher = patttern.matcher(text);
        while(matcher.find()) {
            insert matcher.group() into pop.itens ;
        }

        patttern = Pattern.compile("(#[^ ).,:]+)");
        matcher = patttern.matcher(text);
        while(matcher.find()) {
            insert matcher.group() into pop.itens ;
        }

        patttern = Pattern.compile("(@[^ ).,:]+)");
        matcher = patttern.matcher(text);
        while(matcher.find()) {
            insert matcher.group() into pop.itens ;
        }

        def hbox:HBox =HBox {
                spacing: 5
                translateX: 5
                translateY: 5
                content: [
                    ImageView {
                        image: getImage(profileImageUrl,46,46)
                        cursor: Cursor.HAND
                        onMouseClicked: function( e: MouseEvent ):Void {
                                pop.show(e);
                        }
                        translateY: 5
                    }
                    Text {
                     translateY: 0
                     content: "@{screenName}: {text}"
                     wrappingWidth: bind scene.width - 90
                     fill: Color.WHITESMOKE
                    }
                ]
        };

        def formatedDate = date.toLocaleString()
                        .replaceAll("^([0-9]\{2\})/([0-9]\{2\})/([0-9]\{4\}) ([0-9]\{2\}):([0-9]\{2\}):([0-9]\{2\})$"
                                    , "$2-$1 $4:$5:$6") ;



        def status: Text = Text {
                            translateX: 5
                            translateY: 75
                            fill: Color.rgb(0,153,255),
                            content: formatedDate,
                            font: Font {size: 10}
                        }

        def rect: Rectangle = Rectangle {
            fill: Color.rgb(80, 80, 80);
            height: 80
            width: bind scene.width - 30
        }

        def group: Group = Group {
            content: [ rect, hbox, status ]
        }

        return group ;
    }
}
