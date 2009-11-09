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
    private Long between;
    private boolean active;
    private boolean loop;
    private int size = 10;

    public ProcessQueue() {
        active = true;
        loop = true ;
        this.time =  1000L;
        this.between = 5L;
        list = new Runnable[size];
        count = 0;
    }

    public ProcessQueue(Long time) {
        active = true;
        loop = true ;
        this.time = time;
        this.between = 5L;
        list = new Runnable[size];
        count = 0;
    }

    public ProcessQueue(Long time, Long between) {
        active = true;
        loop = true ;
        this.time = time;
        this.between = between;
        list = new Runnable[size];
        count = 0;
    }

    public ProcessQueue(Long time, Long between, boolean loop) {
        active = true;
        this.loop = loop ;
        this.time = time;
        this.between = between;
        list = new Runnable[size];
        count = 0;
    }

    private void rebuild() {
        Runnable[] oldList = new Runnable[count];
        for(int i=0;i < count;i++) {
            oldList[i] = list[i];
        }
        list = new Runnable[count + count + size];
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
        active = true;
        new Thread() {
            @Override
            public void run() {
                while(active) {
                    if(count >= 1) {
                        Runnable[] myList = list ;
                        if(!loop) reset();
                        for(int i =0;i<myList.length;i++) {
                            if(active && myList[i] != null) {
                                myList[i].run();
                                try {
                                    sleep(between);
                                } catch (InterruptedException ex) {
                                    ex.printStackTrace();
                                }
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

    public void reset() {
        list = new Runnable[(count > size)?count :size];
        count = 0;
    }

    public void stop() {
        active = false ;
    }

    public Runnable[] getList() {
        return list;
    }

}
