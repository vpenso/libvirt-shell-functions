
## Virtual Machine Snapshots

**This feature is still in development!**

Freeze the state of a virtual machine instance using snapshot functionality. It is possible to snapshot a running virtual machine, but it takes quite a while. Create a snapshot like:

    $ vm cd lxdev01
    $ vm image snapshot create
    Domain snapshot 1325599831 created

Unfortunately it is not yet possible to label the snapshots. Display all available snapshots for a virtual machine instance with:

    $ vm image snapshot list
     Name                 Creation Time             State
    ---------------------------------------------------
     1325599831           2012-01-03 15:10:31 +0100 shutoff

Revert a virtual machine instance to a snapshot using its timestamp:

    $ vm image snapshot restore 1325599831
