/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package twitterflow2;

/**
 *
 * @author diogo
 */
public class ProcessQueue  {

    private Runnable[] list ;
    private int count ;
    private Long time;
    private boolean active;
    private int size = 2;

    public ProcessQueue() {
        active = true;
        this.time =  1000L;
        list = new Runnable[size];
        count = 0;
    }

    public ProcessQueue(Long time) {
        active = true;
        this.time = time;
        list = new Runnable[size];
        count = 0;
    }
    
    private void rebuild() {
        Runnable[] oldList = new Runnable[count];
        for(int i=0;i < count;i++) {
            oldList[i] = list[i];
        }
        list = new Runnable[count + size];
        for(int i =0;i < count;i++) {
            list[i] = oldList[i];
        }
        System.gc();
    }

    public void insert(final Runnable r, boolean  now) {
        if(now) {
            once(new Runnable() {
                @Override
                public void run() {
                    r.run();
                    insert(r);
                }
            } );
        } else {
            insert(r);
        }
    }
    public int insert(Runnable r) {
        if(count == list.length) {
            rebuild();
        }
        list[count] = r;
        count++;
        return count ;
    }

    public void start() {
        new Thread() {
            @Override
            public void run() {
                while(active) {
                    if(count >= 1) {
                        Runnable[] myList = list ;
                        for(int i =0;i<myList.length;i++) {
                            if(active && myList[i] != null) {
                                myList[i].run();
                            }
                        }
                        myList = null;
                        System.gc();
                    }
                    try {
                        sleep(time);
                    } catch (InterruptedException ex) {
                        active = false;
                        ex.printStackTrace();
                    }
                }
            }
        }.start();
    }

    public void once(Runnable r) {
        new Thread(r).start();
    }

    public void remove(int id) {
        Runnable[] oldList = new Runnable[count - 1];
        for(int i=0;i < count;i++) {
            if(i == id) continue;
            oldList[i] = list[i];
        }
        list = new Runnable[list.length];
        for(int i =0;i < count;i++) {
            list[i] = oldList[i];
        }
        count-- ;
        System.gc();
    }

    public void reset() {
        list = new Runnable[size];
        count = 0;
    }

    public Runnable[] getList() {
        return list;
    }

}
