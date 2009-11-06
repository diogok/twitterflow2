/*
 * Main.fx
 * Please don't follow my example, all in one file
 * Created on 03/09/2009, 10:31:31
 */

package twitterflow2;

import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.paint.Color;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.io.Storage;
import javafx.io.Resource;
import java.io.InputStream;
import java.lang.StringBuffer;
import javafx.scene.control.TextBox;
import javafx.scene.control.Button;
import java.io.OutputStream;
import javafx.geometry.HPos;
import twitter4j.Twitter;
import twitter4j.http.RequestToken;
import twitter4j.http.AccessToken;
import java.lang.System;
import java.lang.Runtime;
import java.lang.Exception;
import twitter4j.Status;
import twitterflow2.ProcessQueue;
import java.lang.Runnable;
import twitter4j.Paging;
import javafx.scene.image.ImageView;
import javafx.scene.image.Image;
import javafx.scene.Cursor;
import javafx.scene.input.MouseEvent;
import javafx.scene.text.Text;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.Desktop;
import java.awt.event.MouseListener;
import twitter4j.TwitterException;
import twitter4j.Query;
import twitter4j.Tweet;
import javafx.scene.Group;
import javafx.scene.CustomNode;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Font ;
import java.util.Date;
import twitter4j.DirectMessage;

/**
 * @author diogo
 */

var images: Image[] ;

function getImage(url:String, width: Integer, height: Integer) {
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

function createLine(id: Long, image: String, name:String, text:String , date:Date):TweetLine {
    return TweetLine {
        profileImageUrl: image
        screenName: name
        text: text
        date: date
        tweetId: id
    }
}

class TweetLine extends CustomNode  {
    public-init var profileImageUrl: String;
    public-init var screenName: String;
    public-init var text: String ;
    public-init var date: Date ;
    public-init var tweetId: Long;

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

        def hbox:HBox =HBox {
                spacing: 5
                translateX: 5
                translateY: 5
                content: [
                    ImageView {
                        image: getImage(profileImageUrl,46,46)
                        cursor: Cursor.HAND
                        onMouseClicked: function( e: MouseEvent ):Void {
                                seeUser();
                        }
                        translateY: 5
                    }
                    Text {
                     translateY: 5
                     content: "@{screenName}: {text}"
                     wrappingWidth: bind scene.width - 90
                     fill: Color.WHITESMOKE
                    }
                ]
        };

        def formatedDate = date.toLocaleString()
                        .replaceAll("^([0-9]\{2\})/([0-9]\{2\})/([0-9]\{4\}) ([0-9]\{2\}):([0-9]\{2\}):([0-9]\{2\})$"
                                    , "$2-$1 $4:$5:$6") ;

        def status: HBox = HBox {
            spacing: 5
            translateY: 65
            content: [
                        Text {
                            fill: Color.rgb(0,153,255),
                            content: formatedDate,
                            font: Font {size: 10}
                        }
                    ]
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

def sysTray: SystemTray = SystemTray.getSystemTray();
def image: Image = Image{ url: "{__DIR__}placeholder.png" } ;
def icon: TrayIcon = new TrayIcon(image.platformImage as java.awt.image.BufferedImage);
def desktop: Desktop = Desktop.getDesktop();
var isDown: Boolean = false;

def twitter: Twitter = new Twitter();
def consumerKey :String = "tSYh5dVobnKTnxjKSqPhEQ";
def consumerSecret: String = "zoJcXbD0xUKBrKYTQ5QOFPS0PmR8SrOzjh7rJtRdEQU";
//def resource: Resource = Storage { source: "/extras/downloads/flow-oauth-pim.txt" }.resource ;
def resource: Resource = Storage { source: "flow-oauth-pim.txt" }.resource ;

def n: Long = 5 * 60 * 1000 ;
def userQueue: ProcessQueue = new ProcessQueue(n);
def n2: Long = 1 * 60 * 1000 / 2;
def searchQueue: ProcessQueue = new ProcessQueue(n2);
def n3: Long = 5 * 1000;
def trayQueue: ProcessQueue = new ProcessQueue(n3,n3,false);

var stage: Stage ;

var sinceUser: Long = 1;
var sinceSearch: Long = 1;
var sinceMentions: Long = 1;
var sinceDirects: Long = 1;

def HOME:Integer = 0;
def MENTIONS:Integer = 1;
def DIRECTS:Integer = 2;
def SEARCH:Integer = 3;

var active:Integer = HOME;

var statusLines: TweetLine[];
var mentionsLines: TweetLine[];
var directsLines: TweetLine[];
var searchsLines: TweetLine[];

def send: Button = Button {
    text: "Send"
    action: function() {
        userQueue.once(Runnable {
                override function run():Void {
                    twitter.updateStatus(input.text);
                    FX.deferAction(function(): Void{ input.text = "" });
                    showMessage("Status updated");
                    startStream();
                }
        });
    }
}

def input: TextBox = TextBox {
    promptText: "What are you doing?"
    action: send.action
    columns: 35
}

def inputBar: HBox = HBox {
    spacing: 6
    content: [input, send]
}

def mainBar: HBox = HBox {
    spacing: 5
    content: [ Button{ text: "Home", action: openHome} , Button{text: "Mentions", action: openMentions}
               , Button{text: "Directs", action: openDirects} , Button{text: "Search", action: openSearch}
               , Button{ text: "Logout" , action: logout}]
}

def tweetList: Clippy = Clippy {
    nodeSize: 80
    inner: VBox  {spacing: 5, content: [] }
    height: bind if(active == SEARCH) { scene.height - 100 } else { scene.height - 75 }
    width: bind scene.width
}

def searchButton: Button = Button {
    text: "Search"
    action: function(): Void {
        def txt = inputSearch.text ;
        inputSearch.text = "";
        sinceSearch = 1;
        tweetList.update(null);
        startStreamSearch(txt);
    }
}

def inputSearch: TextBox = TextBox {
    promptText: "Search..."
    columns: 34
    action: searchButton.action
}

def searchBar: HBox = HBox {
    spacing: 5
    content: [ inputSearch, searchButton]
}

def content: VBox = VBox {
    spacing: 5
    translateX: 10
    translateY: 10
    content:[ mainBar , tweetList ,  inputBar]
}

def scene: Scene = Scene {
    fill:  Color.rgb(51,51,51);
    content: content
}

function logout(): Void {
    saveToken("", "");
    stage.close();
}

function openHome():Void {
    tweetList.update(null);
    active = HOME;
    delete searchBar from content.content;
    updateClippy();
}

function openMentions():Void {
    tweetList.update(null);
    active = MENTIONS;
    delete searchBar from content.content;
    updateClippyMentions();
}

function openDirects():Void {
    tweetList.update(null);
    active = DIRECTS;
    delete searchBar from content.content;
    updateClippyDirects();
}

function openSearch():Void {
    tweetList.update(null);
    delete searchBar from content.content;
    insert searchBar after content.content[0];
    active = SEARCH;
    updateClippySearch();
}

function updateClippy():Void {
        if(active != HOME) return;
        tweetList.update(statusLines);
};

function updateClippyMentions():Void {
        if(active != MENTIONS) return;
        tweetList.update(mentionsLines);
};

function updateClippyDirects():Void {
        if(active != DIRECTS) return;
        tweetList.update(directsLines)
};

function updateClippySearch():Void {
        if(active != SEARCH) return;
        tweetList.update(searchsLines);
};

function startStream():Void {
    userQueue.reset();
    userQueue.insert(Runnable {
            override function run() {
                var list ;
                if(sinceUser == 1) {
                    delete statusLines;
                }

                try {
                    list = twitter.getFriendsTimeline(new Paging(1,50,sinceUser));
                } catch(te: TwitterException) {
                    showMessage("Some problem happened retreiving tweets.");
                    te.printStackTrace();
                    return ;
                }

                var count = 0;
                def max = list.size();
                while(count < max) {
                    def s:Status = list.get(count);
                    if(sinceUser == 1) {
                        insert createLine(  s.getId()
                                            , s.getUser().getProfileImageURL().toString()
                                            , s.getUser().getScreenName()
                                            , s.getText()
                                            , s.getCreatedAt()) into statusLines ;
                    } else  {
                        insert createLine(  s.getId()
                                            , s.getUser().getProfileImageURL().toString()
                                            , s.getUser().getScreenName()
                                            , s.getText()
                                            , s.getCreatedAt()) before statusLines[count] ;
                        delete statusLines[sizeof statusLines];
                        showMessage("{s.getUser().getScreenName()}"
                                    ":{s.getText()}");
                    }
                    count++;
                }
                System.gc();
                if(max >= 1) {
                    sinceUser = list.get(0).getId();
                    updateClippy();
                }
            }
    },true);
    userQueue.insert(Runnable {
            override function run() {
                var list ;
                if(sinceMentions == 1) {
                    delete mentionsLines;
                }

                try {
                    list = twitter.getMentions(new Paging(1,50,sinceMentions));
                } catch(te: TwitterException) {
                    showMessage("Some problem happened retreiving tweets.");
                    te.printStackTrace();
                    return ;
                }

                var count = 0;
                def max = list.size();
                while(count < max) {
                    def s:Status = list.get(count);
                    if(sinceUser == 1) {
                        insert createLine(  s.getId()
                                            , s.getUser().getProfileImageURL().toString()
                                            , s.getUser().getScreenName()
                                            , s.getText()
                                            , s.getCreatedAt()) into mentionsLines ;
                    } else  {
                        insert createLine(  s.getId()
                                            , s.getUser().getProfileImageURL().toString()
                                            , s.getUser().getScreenName()
                                            , s.getText()
                                            , s.getCreatedAt()) before mentionsLines[count] ;
                        delete mentionsLines[sizeof mentionsLines];
                        showMessage("{s.getUser().getScreenName()}"
                                    ":{s.getText()}");
                    }
                    count++;
                }
                System.gc();
                if(max >= 1) {
                    sinceMentions = list.get(0).getId();
                    updateClippyMentions();
                }
            }
    },true);
    userQueue.insert(Runnable {
            override function run() {
                var list ;
                if(sinceDirects == 1) {
                    delete directsLines;
                }

                try {
                    list = twitter.getDirectMessages(new Paging(1,50,sinceDirects));
                } catch(te: TwitterException) {
                    showMessage("Some problem happened retreiving tweets.");
                    te.printStackTrace();
                    return ;
                }

                var count = 0;
                def max = list.size();
                while(count < max) {
                    def s:DirectMessage = list.get(count);
                    if(sinceUser == 1) {
                        insert createLine(  s.getId()
                                            , null
                                            , s.getSenderScreenName()
                                            , s.getText()
                                            , s.getCreatedAt()) into directsLines ;
                    } else  {
                        insert createLine(  s.getId()
                                            , null
                                            , s.getSenderScreenName()
                                            , s.getText()
                                            , s.getCreatedAt()) before directsLines[count] ;
                        delete directsLines[sizeof directsLines];
                        showMessage("{s.getSenderScreenName()}"
                                    ":{s.getText()}");
                    }
                    count++;
                }
                System.gc();
                if(max >= 1) {
                    sinceDirects = list.get(0).getId();
                    updateClippyDirects();
                }
            }
    },true);
}

function startStreamSearch(txt: String): Void {
    searchQueue.reset();
    searchQueue.insert(Runnable {
            override function run():Void {
                def query: Query = new Query(txt);
                query.setSinceId(sinceSearch);

                if(sinceSearch == 1) {
                    delete searchsLines ;
                }


                var list ;
                try {
                    def resul = twitter.search(query);
                    list = resul.getTweets();
                } catch(te: TwitterException) {
                    showMessage("Some problem happened retreiving search.");
                    te.printStackTrace();
                    return ;
                }
                var count = 0;
                def max = list.size();
                while(count < max) {
                     def s: Tweet = list.get(count);
                    if(sinceSearch == 1) {
                        insert createLine(s.getId()
                                            , s.getProfileImageUrl()
                                            , s.getFromUser()
                                            , s.getText()
                                            , s.getCreatedAt()) into searchsLines ;
                    } else  {
                        insert createLine(s.getId()
                                            , s.getProfileImageUrl()
                                            , s.getFromUser()
                                            , s.getText()
                                            , s.getCreatedAt()) before searchsLines[count] ;
                        delete searchsLines[sizeof searchsLines];
                        showMessage("{s.getFromUser()}"
                                    ":{s.getText()}");
                    }
                    count++;
                }
                if(max >= 1) {
                    sinceSearch = list.get(0).getId();
                    updateClippySearch();
                }
            }
    },true);
}

function showMessage(msg: String): Void {
    def id:Integer = trayQueue.insert(Runnable {
            override function run() {
                icon.displayMessage("TwitterFlow",msg,TrayIcon.MessageType.INFO);
            }
        });
}

function startApp(): Void {
    startStream();
    userQueue.start();
    searchQueue.start();
    trayQueue.start();
    stage = Stage {
        title: "TwitterFlow"
        width: 352
        height: 440
        scene: scene
    }
    icon.setImageAutoSize(true);
    icon.addMouseListener(MouseListener {
        override function mouseClicked(e: java.awt.event.MouseEvent):Void {
            if(isDown) {
                isDown = false;
            } else {
                isDown = true ;
            }
        }
        override function mouseEntered(e: java.awt.event.MouseEvent):Void {        }
        override function mouseExited(e: java.awt.event.MouseEvent):Void {        }
        override function mousePressed(e: java.awt.event.MouseEvent):Void {        }
        override function mouseReleased(e: java.awt.event.MouseEvent):Void {        }
    });
    icon.setToolTip("TwitterFlow: don't miss a bit.");
    if(sysTray.isSupported()) {
        sysTray.add(icon);
    }
}

function openConfig(): Void {
    def requestToken: RequestToken = twitter.getOAuthRequestToken();

    def requestAuth: Button = Button {
                                    text: "Request Authorization"
                                    action: function() {
                                        openURL(requestToken.getAuthorizationURL());
                                    }
                     };

    def pimRegister: Button = Button { text:" Enter and Save PIN  ",
                        action: function() {
                                    def accessToken: AccessToken =
                                        twitter.getOAuthAccessToken(requestToken, pimField.text);
                                    saveToken(accessToken.getToken(), accessToken.getTokenSecret());
                                    twitter.setOAuthAccessToken(accessToken);
                                    startApp();
                                    cStage.close();
                                    System.gc();
                                }
                     };
    def pimNoRegister: Button = Button { text:"Enter and Discard PIN",
                        action: function() {
                                    def accessToken: AccessToken =
                                        twitter.getOAuthAccessToken(requestToken, pimField.text);
                                    //saveToken(accessToken.getToken(), accessToken.getTokenSecret());
                                    twitter.setOAuthAccessToken(accessToken);
                                    startApp();
                                    cStage.close();
                                    System.gc();
                                }
                     };

    def pimField: TextBox = TextBox {action: pimRegister.action, promptText: "PIN", columns: 18} ;
    def cStage:Stage = Stage {
        title: "TwitterFlow - Configure"
        width : 200
        height: 170
        scene: Scene {
            fill: Color.BLACK
            content: [VBox {
                        translateX: 20
                        translateY: 20
                        hpos: HPos.CENTER 
                        spacing: 5
                        content: [ requestAuth, pimField,pimRegister, pimNoRegister ]
                    }]
        }

    }

}

function getToken(): AccessToken {
       def is: InputStream = resource.openInputStream();
       def sb:StringBuffer = StringBuffer{};
       var c= is.read();
       while(c != -1) {
           sb.append(c as Character);
           c = is.read();
       }
       is.close();
       def arg: String[] = sb.toString().split("\n");
       new AccessToken(arg[0],arg[1])
}

function saveToken( token: String,secret: String): Void {
    def os: OutputStream = resource.openOutputStream(true);
    os.write("{token}\n{secret}".getBytes());
    os.close();
}

def  browsers:String[] = [ "opera", "firefox", "safari",  "konqueror", "epiphany",
      "seamonkey", "galeon", "kazehakase", "mozilla", "netscape" ];

public function openURL(url:String): Void {
     var osName:String = System.getProperty("os.name");
     var found: Boolean ;
     if (osName.startsWith("Windows")) {
        Runtime.getRuntime().exec("rundll32 url.dll,FileProtocolHandler {url}");
     } else {
        for (browser in browsers) {
           if (found == false) {
              found = Runtime.getRuntime().exec(["which", browser]).waitFor() == 0;
              if (found) {
                 Runtime.getRuntime().exec("{browser} {url}");
              }
           }
       }
     }
}

function run() {
    twitter.setOAuthConsumer(consumerKey, consumerSecret);
    try {
        var atk: AccessToken = getToken();
        if(atk.getToken().length() <= 4) {
            throw new Exception("No token");
        } else {
            twitter.setOAuthAccessToken(atk);
            startApp();
        }
    } catch(e: Exception) {
        e.printStackTrace();
        openConfig();
    }
}