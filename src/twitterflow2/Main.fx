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
import javafx.scene.control.TextBox;
import javafx.scene.control.Button;
import twitter4j.Twitter;
import twitter4j.http.AccessToken;
import java.lang.System;
import java.lang.Runtime;
import java.lang.Exception;
import twitterflow2.ProcessQueue;
import java.lang.Runnable;
import javafx.scene.image.Image;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.Desktop;
import java.awt.event.MouseListener;
import javafx.scene.text.Text;


/**
 * @author diogo
 */


def sysTray: SystemTray = SystemTray.getSystemTray();
def image: Image = Image{ url: "{__DIR__}placeholder.png" } ;
def icon: TrayIcon = new TrayIcon(image.platformImage as java.awt.image.BufferedImage);
def desktop: Desktop = Desktop.getDesktop();
var isDown: Boolean = false;

public def twitter: Twitter = new Twitter();

def n: Long = 5 * 60 * 1000 ;
public def userQueue: ProcessQueue = new ProcessQueue(n);
def n2: Long = 2 * 60 * 1000;
public def searchQueue: ProcessQueue = new ProcessQueue(n2);
def n3: Long = 3 * 1000;
def trayQueue: ProcessQueue = new ProcessQueue(n3,n3,false);

public-read var stage: Stage ;

def HOME:Integer = 0;
def MENTIONS:Integer = 1;
def DIRECTS:Integer = 2;
def SEARCH:Integer = 3;

var active:Integer = HOME;


def startStream = Stream.startStream ;
def startStreamSearch = Stream.startStreamSearch ;
def loadLists = Stream.loadLists;

def listMenu: PopMenu = PopMenu {
    scene: scene
    itens: bind [
            for(l in Stream.lists) {
                l.name;
            }
    ]
    action: function(list: String): Void {
        Stream.setList(list);
        openHome();
    }
}

def send: Button = Button {
    text: "Send"
    action: function() {
        userQueue.once(Runnable {
                override function run():Void {
                    twitter.updateStatus(input.text);
                    FX.deferAction(function(): Void{ input.text = "" });
                    showMessage("Status updated");
                    Stream.startStream();
                }
        });
    }
}

public def input: TextBox = TextBox {
    promptText: "What are you doing?"
    action: send.action
    columns: 38
}

def counterIntro: Text = Text {
    translateY: 8
    fill: Color.WHITESMOKE
    content: "You have left"
}

def counter: Text = Text {
    translateY: 8
    fill: Color.RED
    content: bind "{(140 - input.rawText.length()).toString()} characters"
}

def inputBar:VBox = VBox {
    spacing: 5
    content: [
        input,
        HBox {
            spacing: 5
            content: [counterIntro, counter, send]
        }
    ]
}

def mainBar: HBox = HBox {
    spacing: 5
    content: [ Button{ text: "Home", action: listMenu.getShow() } , Button{text: "Mentions", action: openMentions}
               , Button{text: "Directs", action: openDirects} , Button{text: "Search", action: openSearch}
               , Button{ text: "Logout" , action: logout}]
}

def tweetList: Clippy = Clippy {
    nodeSize: 80
    inner: VBox  {spacing: 5, content: [] }
    height: bind if(active == SEARCH){scene.height - 125}else{scene.height-100}
    width: bind scene.width
}

def searchButton: Button = Button {
    text: "Search"
    action: function(): Void {
        def txt = inputSearch.text ;
        inputSearch.text = "";
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
    content:[ mainBar,  tweetList ,  inputBar]
}

def scene: Scene = Scene {
    fill:  Color.rgb(51,51,51);
    content: [ content ]
}

function logout(): Void {
    Config.saveToken("", "");
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

public function updateClippy(list: TweetLine[]):Void {
    if(active != HOME) return;
    for(t in reverse list) {
        tweetList.putAtStart(t);
        tweetList.removeLast();
    }
};
public function updateClippyMentions(list: TweetLine[]):Void {
    if(active != MENTIONS) return;
    for(t in reverse list) {
        tweetList.putAtStart(t);
        tweetList.removeLast();
    }
};

public function updateClippyDirects(list: TweetLine[]):Void {
    if(active != DIRECTS) return;
    for(t in reverse list) {
        tweetList.putAtStart(t);
        tweetList.removeLast();
    }
};

public function updateClippySearch(list: TweetLine[]):Void {
    if(active != SEARCH) return;
    for(t in reverse list) {
        tweetList.putAtStart(t);
        tweetList.removeLast();
    }
};

public function updateClippy():Void {
    if(active != HOME) return;
    tweetList.update(Stream.status.lines);
};
public function updateClippyMentions():Void {
    if(active != MENTIONS) return;
    tweetList.update(Stream.mentions.lines);
};

public function updateClippyDirects():Void {
    if(active != DIRECTS) return;
    tweetList.update(Stream.directs.lines)
};

public function updateClippySearch():Void {
    if(active != SEARCH) return;
    tweetList.update(Stream.searchs.lines);
};

public function showMessage(msg: String): Void {
    def id:Integer = trayQueue.insert(Runnable {
            override function run() {
                icon.displayMessage("TwitterFlow",msg,TrayIcon.MessageType.INFO);
            }
        });
}

public function openURL(url:String): Void {
    def  browsers:String[] = [ "opera", "firefox", "safari",  "konqueror", "epiphany",
          "seamonkey", "galeon", "kazehakase", "mozilla", "netscape" ];
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

function startApp(): Void {
    loadLists();
    startStream();
    userQueue.start();
    searchQueue.start();
    trayQueue.start();
    stage = Stage {
        title: "TwitterFlow"
        width: 352
        height: 450
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
    listMenu.scene = scene;
}

function run() {
    twitter.setOAuthConsumer(Config.consumerKey, Config.consumerSecret);
    try {
        var atk: AccessToken = Config.getToken();
        if(atk.getToken().length() <= 4) {
            throw new Exception("No token");
        } else {
            twitter.setOAuthAccessToken(atk);
            startApp();
        }
    } catch(e: Exception) {
        e.printStackTrace();
        Config.openConfig(twitter,startApp);
    }
}