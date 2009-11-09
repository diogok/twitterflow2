/*
 * Stream.fx
 *
 * Created on 08/11/2009, 12:22:06
 */

package twitterflow2;

import java.util.Date;
import java.lang.Runnable;
import twitter4j.TwitterException;
import twitter4j.Paging;
import java.lang.System;
import twitter4j.Query;

/**
 * @author diogo
 */

def userQueue = Main.userQueue ;
def searchQueue = Main.searchQueue ;

def twitter  = Main.twitter;

def showMessage = Main.showMessage ;

var activeList:String = null on replace old {
        if(old != activeList) {
             status.since = 1;
            startStream();
        }
}


public class List {
    public var id: String ;
    public var name: String ;
}

public var lists: List[] ;

public class Lines {
    public var lines: TweetLine[];
    public var since: Long  = 1;
    public-init var update: function(list: TweetLine[]): Void;
    public-init var call: function(): TT[] ;
    public var txt: String ;
}

public class TT {
    public-init var id: Long ;
    public-init var image: String;
    public-init var name: String;
    public-init var text: String;
    public-init var date: Date ;
}

function updateClippy(list: TweetLine[]): Void {
        if(list == null or sizeof list < 1) {
            Main.updateClippy()
        } else{
            Main.updateClippy(list);
        }
}

def updateClippyMentions =function(list: TweetLine[]): Void {
        if(list ==null or sizeof list < 1) {
            Main.updateClippyMentions()
        } else{
            Main.updateClippyMentions(list);
        }
}
def updateClippyDirects =function(list: TweetLine[]): Void {
        if(list == null or sizeof list < 1) {
            Main.updateClippyDirects()
        } else{
            Main.updateClippyDirects(list);
        }
}
def updateClippySearch = function(list: TweetLine[]): Void {
        if(list ==null or sizeof list < 1) {
            Main.updateClippySearch()
        } else{
            Main.updateClippySearch(list);
        }
}
public var status: Lines = Lines{
        call: function() { for(r in twitter.getFriendsTimeline(activeList,new Paging(1,50,status.since))) {
                    TT{
                        id: r.getId()
                        image: r.getUser().getProfileImageURL().toString()
                        name: r.getUser().getScreenName()
                        text: r.getText()
                        date: r.getCreatedAt()
                    }
                } }
        update: updateClippy
    };
    
public var mentions: Lines = Lines{
        call: function() { for(r in  twitter.getMentions(new Paging(1,50,mentions.since))) {
                    TT{
                        id: r.getId()
                        image: r.getUser().getProfileImageURL().toString()
                        name: r.getUser().getScreenName()
                        text: r.getText()
                        date: r.getCreatedAt()
                    }
                } }
        update: updateClippyMentions
    };

public var directs:  Lines =  Lines{
        call: function() { for(r in twitter.getDirectMessages(new Paging(1,50,directs.since))) {
                    TT{
                        id: r.getId()
                        image: r.getSender().getProfileImageURL().toString()
                        name: r.getSender().getScreenName()
                        text: r.getText()
                        date: r.getCreatedAt()
                    }
                } }
        update: updateClippyDirects
    };

public var searchs:  Lines = Lines{
        call: function() { 
            def query: Query = new Query(searchs.txt);
            query.setSinceId(searchs.since);
            def resul = twitter.search(query);
            for(r in resul.getTweets()){
                    TT{
                        id: r.getId()
                        image: r.getProfileImageUrl().toString()
                        name: r.getFromUser()
                        text: r.getText()
                        date: r.getCreatedAt()
                    }
            }
        }
        update: updateClippySearch
    };

function createLine(tt: TT): TweetLine {
    return TweetLine {
        profileImageUrl: tt.image
        screenName: tt.name
        text: tt.text
        date: tt.date
        tweetId: tt.id
    }
}

function createRunnable(lines: Lines ): Runnable {
    Runnable {
            override function run() {
                var list: TT[] ;
                if(lines.since == 1) {
                    delete lines.lines;
                }
                try {
                    list = lines.call() ;
                } catch(te: TwitterException) {
                    showMessage("Some problem happened retreiving tweets.");
                    te.printStackTrace();
                    return ;
                }

                var count = 0;
                def max = sizeof list ;
                while(count < max) {
                    def s:TT = list[count];
                    if(lines.since == 1) {
                        insert createLine(s) into lines.lines ;
                    } else  {
                        insert createLine(s) before lines.lines[count] ;
                        delete lines.lines[sizeof lines.lines];
                        showMessage("{s.name}: {s.text}");
                    }
                    count++;
                }
                System.gc();
                if(max >= 1) {
                    if(lines.since == 1) {
                        lines.update(null);
                    } else {
                        lines.update(lines.lines[0..count]);
                    }
                    lines.since = list[0].id ;
                }
            }
    }
}

public function startStream():Void {
    userQueue.reset();
    userQueue.insert(createRunnable(status),true);
    userQueue.insert(createRunnable(mentions),true);
    userQueue.insert(createRunnable(directs),true);
}

public function startStreamSearch(txt: String): Void {
    searchs.since = 1;
    searchs.txt = txt ;
    searchQueue.reset();
    searchQueue.insert(createRunnable(searchs),true);
}

public function loadLists(): Void {
    lists = [  List{ name: "Main timeline", id: "0"}  ];
    def fls = twitter.getLists();
    for(l in fls) {
            insert List {
                name: l.getName();
                id: l.getId();
            } into lists ;
    }
}

public function setList(str: String) {
    for(l in lists) {
        if(l.name == str) {
            activeList = l.id ;
        }
    }

}

public class Stream {

}
